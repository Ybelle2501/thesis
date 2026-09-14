import 'package:flutter/material.dart';

import '../data/crop_guides.dart';
import 'crop_guide_screen.dart';

class DiseasePreventionScreen extends StatelessWidget {
  const DiseasePreventionScreen({super.key, this.initialLabel});
  final String? initialLabel;

  @override
  Widget build(BuildContext context) {
    final guide = guideForLabel(initialLabel);
    if (guide != null) {
      return CropGuideDetailScreen(
        guide: guide,
        initialMode: GuideMode.prevention,
      );
    }
    return const CropGuideLibraryScreen(mode: GuideMode.prevention);
  }
}
