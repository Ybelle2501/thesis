import 'package:flutter/material.dart';

import '../services/seasonal_risk.dart';
import '../theme/app_theme.dart';
import 'guide_sources.dart';

// Shared between the library and scan-linked guides during this app session.
final seasonalSelection = ValueNotifier<SeasonalContext>(
  SeasonalContext.current(),
);

class SeasonalSetupCard extends StatelessWidget {
  const SeasonalSetupCard({super.key});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<SeasonalContext>(
    valueListenable: seasonalSelection,
    builder: (context, selection, _) {
      final station = selection.station;
      return Card(
        margin: EdgeInsets.zero,
        color: AppColors.accent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.cloud_outlined, color: AppColors.primary),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Seasonal outlook',
                      style: AppTextStyles.titleLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${monthNames[selection.month - 1]} • ${station?.name ?? 'Choose your area'}',
              ),
              if (station != null) ...[
                const SizedBox(height: 4),
                Text(
                  '${station.seasonFor(selection.month)} • ${station.rainfallFor(selection.month).toStringAsFixed(1)} mm typical rainfall',
                ),
                Text(
                  selection.coolUpland
                      ? 'Growing site: cool upland'
                      : 'Growing site: warm / lowland',
                ),
              ],
              const SizedBox(height: 8),
              const Text(
                'Seasonal guidance uses typical rainfall, not live weather or a measured chance of infection. Local field conditions can differ.',
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                key: const ValueKey('season-settings'),
                icon: const Icon(Icons.tune, size: 18),
                label: Text(
                  station == null
                      ? 'Choose area & month'
                      : 'Change area & month',
                ),
                onPressed: () => _showSeasonSettings(context),
              ),
              const GuideSourceButton(['pagasa']),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> _showSeasonSettings(BuildContext context) async {
  var selected = seasonalSelection.value;
  final result = await showModalBottomSheet<SeasonalContext>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your growing area', style: AppTextStyles.titleLarge),
            const SizedBox(height: 8),
            const Text(
              'Choose a nearby station with a similar climate. A station does not represent every farm in its province. If none fits, use local advice.',
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              key: const ValueKey('station-picker'),
              initialValue: selected.station?.id ?? 'none',
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Nearby PAGASA station',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(
                  value: 'none',
                  child: Text('No matching station'),
                ),
                for (final station in climateStations)
                  DropdownMenuItem(
                    value: station.id,
                    child: Text(station.name),
                  ),
              ],
              onChanged: (id) {
                ClimateStation? station;
                for (final item in climateStations) {
                  if (item.id == id) station = item;
                }
                setState(
                  () => selected = SeasonalContext(
                    month: selected.month,
                    station: station,
                    coolUpland: station?.id == 'baguio',
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              key: const ValueKey('month-picker'),
              initialValue: selected.month,
              decoration: const InputDecoration(
                labelText: 'Month',
                border: OutlineInputBorder(),
              ),
              items: [
                for (var month = 1; month <= 12; month++)
                  DropdownMenuItem(
                    value: month,
                    child: Text(monthNames[month - 1]),
                  ),
              ],
              onChanged: (month) {
                if (month != null) {
                  setState(() => selected = selected.withMonth(month));
                }
              },
            ),
            const SizedBox(height: 8),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Cool upland growing site'),
              subtitle: const Text(
                'Use your farm conditions; relevant to late blight and hot-weather mite pressure.',
              ),
              value: selected.coolUpland,
              onChanged: (value) => setState(
                () => selected = SeasonalContext(
                  month: selected.month,
                  station: selected.station,
                  coolUpland: value,
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              key: const ValueKey('apply-season'),
              onPressed: () => Navigator.pop(context, selected),
              child: const Text('Apply seasonal settings'),
            ),
          ],
        ),
      ),
    ),
  );
  if (result != null) seasonalSelection.value = result;
}
