import 'package:flutter/material.dart';

import '../data/crop_guides.dart';
import 'crop_guide_screen.dart';

class TreatmentScreen extends StatelessWidget {
  const TreatmentScreen({super.key, this.initialLabel});
  final String? initialLabel;

  @override
  Widget build(BuildContext context) {
    final guide = guideForLabel(initialLabel);
    if (guide != null) {
      return CropGuideDetailScreen(
        guide: guide,
        initialMode: GuideMode.treatment,
      );
    }
    return const CropGuideLibraryScreen(mode: GuideMode.treatment);
  }
}
