import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thesis_app_ediwow/data/crop_guides.dart';
import 'package:thesis_app_ediwow/models/crop_guide.dart';
import 'package:thesis_app_ediwow/screens/treatment_screen.dart';
import 'package:thesis_app_ediwow/screens/disease_prevention_screen.dart';
import 'package:thesis_app_ediwow/services/seasonal_risk.dart';
import 'package:thesis_app_ediwow/widgets/seasonal_setup_card.dart';
import 'package:thesis_app_ediwow/widgets/guide_sources.dart';

void main() {
  setUp(() {
    seasonalSelection.value = const SeasonalContext(month: 9);
  });

  test('guides cover every exported model label exactly once', () {
    final labels =
        jsonDecode(File('assets/labels.json').readAsStringSync())
            as Map<String, dynamic>;
    final rawLabels = cropGuides.map((guide) => guide.rawLabel).toList();
    expect(rawLabels, unorderedEquals(labels.values));
    expect(rawLabels.toSet().length, rawLabels.length);
    expect(cropGuides.where((guide) => guide.healthy), hasLength(4));
    expect(cropGuides.where((guide) => !guide.healthy), hasLength(19));
    expect(guideForLabel('unsupported label'), isNull);
  });

  test(
    'all conditions have complete plans and traceable prevention references',
    () {
      for (final guide in cropGuides) {
        if (!guide.healthy) {
          expect(
            guide.treatment.length,
            greaterThanOrEqualTo(4),
            reason: guide.rawLabel,
          );
          expect(
            guide.prevention.length,
            greaterThanOrEqualTo(3),
            reason: guide.rawLabel,
          );
          expect(guide.seasonalEvidence, isNotEmpty);
        }
        final steps = [...guide.treatment, ...guide.prevention];
        for (final step in steps) {
          expect(step.text, isNotEmpty);
          expect(step.sourceIds, isNotEmpty);
          for (final id in step.sourceIds) {
            expect(guideSources.containsKey(id), isTrue, reason: id);
          }
        }
        if (!guide.healthy) {
          expect(
            guide.prevention.any(
              (step) => step.sourceIds.any(
                (id) => guideSources[id]!.scope.startsWith('Philippine'),
              ),
            ),
            isTrue,
            reason: guide.rawLabel,
          );
        }
        for (final id in guide.seasonalSourceIds) {
          expect(guideSources.containsKey(id), isTrue, reason: id);
        }
      }
      for (final source in guideSources.values) {
        expect(Uri.parse(source.url).scheme, 'https');
        expect(source.note, isNotEmpty);
      }
    },
  );

  test('rainfall patterns differ between western and eastern stations', () {
    final western = climateStations.firstWhere(
      (station) => station.id == 'laoag',
    );
    final eastern = climateStations.firstWhere(
      (station) => station.id == 'borongan',
    );
    final sigatoka = guideForLabel('banana_sigatoka')!;
    SeasonalEstimate risk(ClimateStation station, int month) =>
        estimateSeasonalRisk(
          sigatoka,
          SeasonalContext(month: month, station: station),
        );
    expect(risk(western, 1).risk, SeasonalRisk.watch);
    expect(risk(eastern, 1).risk, SeasonalRisk.elevated);
    expect(risk(western, 8).risk, SeasonalRisk.elevated);
    expect(western.rainfallFor(8), 583.9);
    for (final station in climateStations) {
      expect(station.rainfall, hasLength(12));
      expect(
        station.rainfall.every((value) => value.isFinite && value >= 0),
        isTrue,
      );
    }
    expect(() => western.rainfallFor(0), throwsRangeError);
    expect(
      () => const SeasonalContext(month: 1).withMonth(13),
      throwsRangeError,
    );
  });

  test(
    'cool uplands change late blight and mite flags without guaranteeing safety',
    () {
      final station = climateStations.firstWhere(
        (station) => station.id == 'baguio',
      );
      final lateBlight = guideForLabel('tomato_Late_blight')!;
      final mites = guideForLabel(
        'tomato_Spider_mites Two-spotted_spider_mite',
      )!;
      expect(
        estimateSeasonalRisk(
          lateBlight,
          SeasonalContext(month: 8, station: station, coolUpland: true),
        ).risk,
        SeasonalRisk.elevated,
      );
      expect(
        estimateSeasonalRisk(
          lateBlight,
          SeasonalContext(month: 8, station: station),
        ).risk,
        SeasonalRisk.watch,
      );
      expect(
        estimateSeasonalRisk(
          mites,
          SeasonalContext(month: 1, station: station, coolUpland: true),
        ).risk,
        SeasonalRisk.watch,
      );
      expect(
        estimateSeasonalRisk(
          mites,
          SeasonalContext(month: 1, station: station),
        ).risk,
        SeasonalRisk.elevated,
      );
    },
  );

  test(
    'unknown location and insufficient evidence do not produce fabricated estimates',
    () {
      expect(
        estimateSeasonalRisk(
          guideForLabel('banana_sigatoka')!,
          const SeasonalContext(month: 9),
        ).risk,
        SeasonalRisk.unknown,
      );
      final station = climateStations.firstWhere(
        (station) => station.id == 'davao',
      );
      for (var month = 1; month <= 12; month++) {
        final context = SeasonalContext(month: month, station: station);
        expect(
          estimateSeasonalRisk(guideForLabel('banana_sigatoka')!, context).risk,
          SeasonalRisk.watch,
        );
        expect(
          estimateSeasonalRisk(guideForLabel('banana_cordana')!, context).risk,
          SeasonalRisk.unknown,
        );
        expect(
          estimateSeasonalRisk(
            guideForLabel('tomato_Tomato_Yellow_Leaf_Curl_Virus')!,
            context,
          ).risk,
          SeasonalRisk.unknown,
        );
        expect(
          estimateSeasonalRisk(
            guideForLabel('banana_panama_wilt')!,
            context,
          ).risk,
          SeasonalRisk.watch,
        );
        expect(
          estimateSeasonalRisk(guideForLabel('tomato_healthy')!, context).risk,
          SeasonalRisk.healthy,
        );
      }
    },
  );

  testWidgets(
    'treatment tabs list the correct crop conditions and open a detailed plan',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: TreatmentScreen()));
      for (final crop in Crop.values) {
        expect(find.text(crop.title), findsOneWidget);
      }
      expect(find.text('Cordana leaf spot'), findsOneWidget);
      await tester.tap(find.text('Eggplant'));
      await tester.pumpAndSettle();
      expect(find.text('Insect damage'), findsOneWidget);
      await tester.tap(
        find.byKey(const ValueKey('guide-eggplant_insect_pest')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Treatment plan'), findsOneWidget);
      expect(find.text('1. Identify the pest'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('scan-linked treatment opens the matching condition', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TreatmentScreen(initialLabel: 'banana_panama_wilt'),
      ),
    );
    expect(find.text('Panama wilt'), findsOneWidget);
    expect(find.text('Treatment plan'), findsOneWidget);
    expect(find.text('1. Restrict movement'), findsOneWidget);
    expect(find.text('Early blight'), findsNothing);
  });

  testWidgets('prevention settings update the area and month', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DiseasePreventionScreen()));
    expect(find.text('Disease Prevention'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('season-settings')).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('station-picker')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Laoag, Ilocos Norte').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('month-picker')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('January'),
      -200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('January').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('apply-season')));
    await tester.tap(find.byKey(const ValueKey('apply-season')));
    await tester.pumpAndSettle();
    expect(seasonalSelection.value.station?.id, 'laoag');
    expect(seasonalSelection.value.month, 1);
    expect(find.textContaining('Relatively drier month'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('source sheet retains a copyable reference and provenance', (
    tester,
  ) async {
    String? clipboardText;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            clipboardText = (call.arguments as Map)['text'] as String;
          }
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: GuideSourceButton(['ph_leafcurl'])),
      ),
    );
    await tester.tap(find.text('Source'));
    await tester.pumpAndSettle();
    expect(find.text('Philippine field research'), findsOneWidget);
    await tester.ensureVisible(find.text('Copy link'));
    await tester.tap(find.text('Copy link'));
    await tester.pumpAndSettle();
    expect(clipboardText, guideSources['ph_leafcurl']!.url);
  });

  testWidgets('guide layout supports narrow screens and larger text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        builder: (_, child) => MediaQuery(
          data: const MediaQueryData(
            size: Size(360, 800),
            textScaler: TextScaler.linear(1.5),
          ),
          child: child!,
        ),
        home: const DiseasePreventionScreen(
          initialLabel: 'tomato_Tomato_Yellow_Leaf_Curl_Virus',
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.drag(find.byType(ListView).first, const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
