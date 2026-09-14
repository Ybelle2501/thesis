import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/crop_guides.dart';
import '../theme/app_theme.dart';

class GuideSourceButton extends StatelessWidget {
  const GuideSourceButton(this.sourceIds, {super.key});
  final List<String> sourceIds;

  @override
  Widget build(BuildContext context) {
    if (sourceIds.isEmpty) return const SizedBox.shrink();
    return TextButton.icon(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        alignment: Alignment.centerLeft,
      ),
      icon: const Icon(Icons.menu_book_outlined, size: 16),
      label: Text(
        sourceIds.length == 1 ? 'Source' : 'Sources (${sourceIds.length})',
      ),
      onPressed: () => showGuideSources(context, sourceIds),
    );
  }
}

Future<void> showGuideSources(BuildContext context, Iterable<String> ids) {
  final sources = ids.toSet().map((id) => guideSources[id]!).toList();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (sheetContext) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.35,
      maxChildSize: 0.95,
      builder: (context, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          const Text('Sources & evidence', style: AppTextStyles.titleLarge),
          const SizedBox(height: 8),
          const Text(
            'Reviewed 9 September 2026. Each note explains what the reference supports.',
          ),
          for (final source in sources) ...[
            const Divider(height: 28),
            Text(
              source.scope,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(source.title, style: AppTextStyles.titleMedium),
            Text(source.publisher),
            const SizedBox(height: 8),
            Text(source.note),
            const SizedBox(height: 8),
            SelectableText(source.url, style: const TextStyle(fontSize: 12)),
            Wrap(
              spacing: 8,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('Open reference'),
                  onPressed: () async {
                    try {
                      final opened = await launchUrl(
                        Uri.parse(source.url),
                        mode: LaunchMode.externalApplication,
                      );
                      if (opened) return;
                    } catch (_) {
                      // The reference remains readable/copyable without a browser.
                    }
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Could not open the reference. Copy its link to use in a browser.',
                        ),
                      ),
                    );
                  },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.copy_outlined, size: 16),
                  label: const Text('Copy link'),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: source.url));
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Reference link copied')),
                    );
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    ),
  );
}
