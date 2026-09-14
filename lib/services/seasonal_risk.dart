import '../models/crop_guide.dart';

class ClimateStation {
  const ClimateStation(
    this.id,
    this.name,
    this.rainfall, {
    this.rainAllYear = false,
  });
  final String id;
  final String name;
  final List<double> rainfall;
  final bool rainAllYear;

  double rainfallFor(int month) {
    RangeError.checkValueInInterval(month, 1, 12, 'month');
    return rainfall[month - 1];
  }

  /// A relative scouting heuristic, not a PAGASA disease threshold:
  /// flag months above the median of this station's 12 rainfall normals.
  bool isWetterMonth(int month) {
    final sorted = [...rainfall]..sort();
    final median = (sorted[5] + sorted[6]) / 2;
    return rainfallFor(month) > median;
  }

  String seasonFor(int month) {
    if (rainAllYear) return 'Rain throughout the year';
    return isWetterMonth(month)
        ? 'Wetter part of the year'
        : 'Relatively drier month';
  }
}

// PAGASA station table, retrieved 2026-09-09; Jan–Dec, millimetres.
// These are published normals, not current weather. See docs/crop-guidance.md.
const climateStations = <ClimateStation>[
  ClimateStation('laoag', 'Laoag, Ilocos Norte', [
    5.3,
    2.8,
    6.0,
    24.8,
    246.9,
    312.9,
    448.2,
    583.9,
    415.8,
    103.3,
    30.2,
    2.8,
  ]),
  ClimateStation('baguio', 'Baguio, Cordillera', [
    15.2,
    23.4,
    46.0,
    104.1,
    341.1,
    475.8,
    781.9,
    905.0,
    570.9,
    454.3,
    97.4,
    26.2,
  ]),
  ClimateStation('clark', 'Clark, Pampanga', [
    17.4,
    18.6,
    28.4,
    65.0,
    221.8,
    241.2,
    422.6,
    429.4,
    293.1,
    177.0,
    78.0,
    34.2,
  ]),
  ClimateStation('ambulong', 'Ambulong, Batangas', [
    22.7,
    16.0,
    21.5,
    35.0,
    116.6,
    228.7,
    329.6,
    286.9,
    255.0,
    218.4,
    144.7,
    92.0,
  ]),
  ClimateStation('calapan', 'Calapan, Oriental Mindoro', [
    112.9,
    64.7,
    75.9,
    116.0,
    196.4,
    263.6,
    253.0,
    195.4,
    235.5,
    326.5,
    281.0,
    216.2,
  ]),
  ClimateStation('legazpi', 'Legazpi, Albay', [
    311.7,
    236.4,
    193.8,
    171.2,
    186.6,
    230.5,
    259.8,
    222.5,
    285.9,
    333.0,
    480.3,
    520.2,
  ]),
  ClimateStation('mactan', 'Mactan, Cebu', [
    105.2,
    69.6,
    58.6,
    48.1,
    95.0,
    175.6,
    192.9,
    143.5,
    179.6,
    194.8,
    161.9,
    139.7,
  ]),
  ClimateStation('borongan', 'Borongan, Eastern Samar', [
    613.7,
    345.4,
    312.6,
    225.5,
    207.2,
    233.4,
    249.9,
    146.4,
    189.9,
    347.3,
    508.4,
    674.8,
  ]),
  ClimateStation('malaybalay', 'Malaybalay, Bukidnon', [
    142.5,
    106.1,
    112.5,
    115.6,
    224.8,
    313.5,
    323.3,
    294.4,
    315.7,
    314.7,
    176.1,
    130.7,
  ]),
  ClimateStation('davao', 'Davao City', [
    140.3,
    109.4,
    108.4,
    124.7,
    158.7,
    186.7,
    165.0,
    170.0,
    170.4,
    174.8,
    138.1,
    112.6,
  ], rainAllYear: true),
  ClimateStation('cotabato', 'Cotabato City', [
    88.4,
    83.9,
    119.9,
    146.7,
    268.5,
    312.3,
    325.4,
    244.8,
    256.6,
    285.5,
    216.3,
    139.6,
  ]),
];

const monthNames = <String>[
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

class SeasonalContext {
  const SeasonalContext({
    required this.month,
    this.station,
    this.coolUpland = false,
  }) : assert(month >= 1 && month <= 12);

  factory SeasonalContext.current() =>
      SeasonalContext(month: DateTime.now().month);

  final int month;
  final ClimateStation? station;
  final bool coolUpland;

  SeasonalContext withMonth(int month) {
    RangeError.checkValueInInterval(month, 1, 12, 'month');
    return SeasonalContext(
      month: month,
      station: station,
      coolUpland: coolUpland,
    );
  }
}

enum SeasonalRisk { elevated, watch, unknown, healthy }

class SeasonalEstimate {
  const SeasonalEstimate(this.risk, this.label, this.explanation);
  final SeasonalRisk risk;
  final String label;
  final String explanation;
}

SeasonalEstimate estimateSeasonalRisk(
  CropGuide guide,
  SeasonalContext context,
) {
  RangeError.checkValueInInterval(context.month, 1, 12, 'month');
  if (guide.healthy) {
    return const SeasonalEstimate(
      SeasonalRisk.healthy,
      'Routine care',
      'A healthy scan does not forecast future disease.',
    );
  }
  if (guide.seasonalPattern == SeasonalPattern.insufficient) {
    return const SeasonalEstimate(
      SeasonalRisk.unknown,
      'Evidence limited',
      'No supported Philippine calendar estimate. Use the evidence note and field inspections.',
    );
  }
  if (guide.seasonalPattern == SeasonalPattern.siteDependent) {
    return const SeasonalEstimate(
      SeasonalRisk.unknown,
      'Field data needed',
      'Month and rainfall alone cannot estimate this condition. Check humidity, vectors and the confirmed cause.',
    );
  }
  if (guide.seasonalPattern == SeasonalPattern.yearRound) {
    return const SeasonalEstimate(
      SeasonalRisk.watch,
      'Year-round watch',
      'Keep prevention in place in every month; exposure is not determined by season alone.',
    );
  }
  final station = context.station;
  if (station == null) {
    return const SeasonalEstimate(
      SeasonalRisk.unknown,
      'Choose an area',
      'Select a nearby PAGASA station to view seasonal guidance for your area.',
    );
  }
  if (station.rainAllYear) {
    return const SeasonalEstimate(
      SeasonalRisk.watch,
      'Year-round watch',
      'This station has rainfall throughout the year. Observe actual leaf wetness and dry spells instead of assuming a dry season.',
    );
  }
  final wetter = station.isWetterMonth(context.month);
  final elevated = switch (guide.seasonalPattern) {
    SeasonalPattern.wet => wetter,
    SeasonalPattern.dry => !wetter && !context.coolUpland,
    SeasonalPattern.coolWet => wetter && context.coolUpland,
    _ => false,
  };
  return SeasonalEstimate(
    elevated ? SeasonalRisk.elevated : SeasonalRisk.watch,
    elevated ? 'Elevated seasonal concern' : 'Routine monitoring',
    elevated
        ? 'Typical seasonal conditions may favor this problem. Increase scouting and apply the prevention steps below.'
        : 'The seasonal flag is not elevated. Disease can still occur with local moisture, susceptible plants or infection sources.',
  );
}
