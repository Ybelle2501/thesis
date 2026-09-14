enum Crop {
  banana('Banana', 'B'),
  eggplant('Eggplant', 'E'),
  lettuce('Lettuce', 'L'),
  tomato('Tomato', 'T');

  const Crop(this.title, this.initial);
  final String title;
  final String initial;
}

enum SeasonalPattern {
  wet,
  dry,
  coolWet,
  yearRound,
  siteDependent,
  insufficient,
  healthy,
}

class GuideSource {
  const GuideSource({
    required this.id,
    required this.title,
    required this.publisher,
    required this.url,
    required this.scope,
    required this.note,
  });
  final String id;
  final String title;
  final String publisher;
  final String url;
  final String scope;
  final String note;
}

class GuidanceStep {
  const GuidanceStep(this.title, this.text, this.sourceIds);
  final String title;
  final String text;
  final List<String> sourceIds;
}

class CropGuide {
  const CropGuide({
    required this.rawLabel,
    required this.crop,
    required this.name,
    required this.category,
    required this.summary,
    required this.treatment,
    required this.prevention,
    required this.seasonalPattern,
    required this.seasonalEvidence,
    required this.seasonalSourceIds,
    this.healthy = false,
  });
  final String rawLabel;
  final Crop crop;
  final String name;
  final String category;
  final String summary;
  final List<GuidanceStep> treatment;
  final List<GuidanceStep> prevention;
  final SeasonalPattern seasonalPattern;
  final String seasonalEvidence;
  final List<String> seasonalSourceIds;
  final bool healthy;
}
