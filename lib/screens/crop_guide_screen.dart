import 'package:flutter/material.dart';

import '../data/crop_guides.dart';
import '../models/crop_guide.dart';
import '../services/seasonal_risk.dart';
import '../theme/app_theme.dart';
import '../widgets/guide_sources.dart';
import '../widgets/seasonal_setup_card.dart';
import '../widgets/shared_widgets.dart';

enum GuideMode { treatment, prevention }

class CropGuideLibraryScreen extends StatelessWidget {
  const CropGuideLibraryScreen({super.key, required this.mode});
  final GuideMode mode;

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: Crop.values.length,
    child: Scaffold(
      backgroundColor: AppColors.surface,
      bottomNavigationBar: const AiDisclaimer(),
      appBar: AppBar(
        title: Text(
          mode == GuideMode.treatment
              ? 'Treatment Advice'
              : 'Disease Prevention',
        ),
        bottom: const TabBar(
          isScrollable: true,
          tabAlignment: TabAlignment.center,
          labelColor: AppColors.primary,
          tabs: [
            Tab(text: 'Banana'),
            Tab(text: 'Eggplant'),
            Tab(text: 'Lettuce'),
            Tab(text: 'Tomato'),
          ],
        ),
      ),
      body: TabBarView(
        children: [
          for (final crop in Crop.values)
            _CropGuideList(crop: crop, mode: mode),
        ],
      ),
    ),
  );
}

class _CropGuideList extends StatelessWidget {
  const _CropGuideList({required this.crop, required this.mode});
  final Crop crop;
  final GuideMode mode;

  @override
  Widget build(BuildContext context) {
    final guides = guidesForCrop(crop);
    final conditions = guides.where((guide) => !guide.healthy).length;
    return ListView(
      key: PageStorageKey('${mode.name}-${crop.name}'),
      padding: const EdgeInsets.all(16),
      children: [
        if (mode == GuideMode.prevention) ...[
          const SeasonalSetupCard(),
          const SizedBox(height: 20),
        ],
        Text('${crop.title} care', style: AppTextStyles.displayMedium),
        const SizedBox(height: 6),
        Text('$conditions disease or pest guides • Healthy crop care'),
        const SizedBox(height: 8),
        Text(
          mode == GuideMode.treatment
              ? 'Choose a condition for treatment steps and supporting references.'
              : 'Choose a condition for prevention steps and the evidence behind its seasonal outlook.',
        ),
        const SizedBox(height: 16),
        for (final guide in guides)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
              clipBehavior: Clip.antiAlias,
              margin: EdgeInsets.zero,
              child: InkWell(
                key: ValueKey('guide-${guide.rawLabel}'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        CropGuideDetailScreen(guide: guide, initialMode: mode),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: guide.healthy
                            ? AppColors.accent
                            : AppColors.divider,
                        foregroundColor: AppColors.primary,
                        child: Icon(
                          guide.healthy
                              ? Icons.spa_outlined
                              : Icons.eco_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(guide.name, style: AppTextStyles.titleMedium),
                            const SizedBox(height: 4),
                            Text(guide.category),
                            if (mode == GuideMode.prevention) ...[
                              const SizedBox(height: 8),
                              ValueListenableBuilder<SeasonalContext>(
                                valueListenable: seasonalSelection,
                                builder: (_, selection, child) => _RiskBadge(
                                  estimateSeasonalRisk(guide, selection),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class CropGuideDetailScreen extends StatefulWidget {
  const CropGuideDetailScreen({
    super.key,
    required this.guide,
    required this.initialMode,
  });
  final CropGuide guide;
  final GuideMode initialMode;

  @override
  State<CropGuideDetailScreen> createState() => _CropGuideDetailScreenState();
}

class _CropGuideDetailScreenState extends State<CropGuideDetailScreen> {
  late GuideMode _mode = widget.initialMode;

  @override
  Widget build(BuildContext context) {
    final guide = widget.guide;
    final treatment = _mode == GuideMode.treatment;
    final steps = treatment ? guide.treatment : guide.prevention;
    final references = <String>{
      ...guide.treatment.expand((step) => step.sourceIds),
      ...guide.prevention.expand((step) => step.sourceIds),
      ...guide.seasonalSourceIds,
    };
    return Scaffold(
      backgroundColor: AppColors.surface,
      bottomNavigationBar: const AiDisclaimer(),
      appBar: AppBar(
        title: Text(guide.crop.title),
        actions: [
          IconButton(
            tooltip: 'View all sources',
            onPressed: () => showGuideSources(context, references),
            icon: const Icon(Icons.menu_book_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            guide.category,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(guide.name, style: AppTextStyles.displayMedium),
          const SizedBox(height: 12),
          Text(
            guide.summary,
            style: const TextStyle(fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                key: const ValueKey('treatment-mode'),
                label: const Text('Treatment'),
                selected: treatment,
                onSelected: (_) => setState(() => _mode = GuideMode.treatment),
              ),
              ChoiceChip(
                key: const ValueKey('prevention-mode'),
                label: const Text('Prevention'),
                selected: !treatment,
                onSelected: (_) => setState(() => _mode = GuideMode.prevention),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (!treatment && !guide.healthy) ...[
            const SeasonalSetupCard(),
            const SizedBox(height: 16),
            _SeasonalRiskPanel(guide),
            const SizedBox(height: 24),
          ],
          Text(
            guide.healthy
                ? 'Routine crop care'
                : treatment
                ? 'Treatment plan'
                : 'Prevention steps',
            style: AppTextStyles.titleLarge,
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < steps.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${i + 1}. ${steps[i].title}',
                        style: AppTextStyles.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(steps[i].text, style: const TextStyle(height: 1.5)),
                      GuideSourceButton(steps[i].sourceIds),
                    ],
                  ),
                ),
              ),
            ),
          if (treatment && !guide.healthy) ...[
            const SizedBox(height: 8),
            const Text(
              'Selecting a crop-protection product',
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Check current FPA registration for the crop and pest. Follow the product label for dose, protective equipment, re-entry and time before harvest. Ask your municipal agriculturist to confirm suitability.',
            ),
            const GuideSourceButton(['fpa']),
          ],
          const SizedBox(height: 12),
          const Text(
            'References reviewed 9 September 2026',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

Color _riskColor(SeasonalRisk risk) => switch (risk) {
  SeasonalRisk.elevated => const Color(0xFF9B471B),
  SeasonalRisk.watch => const Color(0xFF245D45),
  SeasonalRisk.unknown => const Color(0xFF536171),
  SeasonalRisk.healthy => const Color(0xFF245D45),
};

class _RiskBadge extends StatelessWidget {
  const _RiskBadge(this.estimate);
  final SeasonalEstimate estimate;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: _riskColor(estimate.risk).withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      estimate.label,
      style: TextStyle(
        color: _riskColor(estimate.risk),
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class _SeasonalRiskPanel extends StatelessWidget {
  const _SeasonalRiskPanel(this.guide);
  final CropGuide guide;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<SeasonalContext>(
    valueListenable: seasonalSelection,
    builder: (context, selection, _) {
      final estimate = estimateSeasonalRisk(guide, selection);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RiskBadge(estimate),
          const SizedBox(height: 10),
          Text(estimate.explanation),
          const SizedBox(height: 12),
          const Text(
            'Evidence for this condition',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(guide.seasonalEvidence),
          GuideSourceButton(guide.seasonalSourceIds),
          if (selection.station != null) ...[
            const SizedBox(height: 12),
            const Text('Explore the year', style: AppTextStyles.titleMedium),
            const SizedBox(height: 6),
            const Text(
              'Tap a month. Orange: elevated concern. Green: monitoring. Gray: more evidence needed.',
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (var month = 1; month <= 12; month++)
                  _MonthChip(guide: guide, selection: selection, month: month),
              ],
            ),
          ],
        ],
      );
    },
  );
}

class _MonthChip extends StatelessWidget {
  const _MonthChip({
    required this.guide,
    required this.selection,
    required this.month,
  });
  final CropGuide guide;
  final SeasonalContext selection;
  final int month;

  @override
  Widget build(BuildContext context) {
    final estimate = estimateSeasonalRisk(guide, selection.withMonth(month));
    final color = _riskColor(estimate.risk);
    return Semantics(
      label: '${monthNames[month - 1]}: ${estimate.label}',
      child: ChoiceChip(
        key: ValueKey('outlook-month-$month'),
        label: Text(monthNames[month - 1].substring(0, 3)),
        selected: month == selection.month,
        labelStyle: TextStyle(color: color),
        backgroundColor: color.withValues(alpha: 0.08),
        selectedColor: color.withValues(alpha: 0.2),
        onSelected: (_) => seasonalSelection.value = selection.withMonth(month),
      ),
    );
  }
}
