import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

final RegExp locationTagPattern = RegExp(r'^[A-Za-z0-9]+(?: [A-Za-z0-9]+)*$');

String normalizeLocationTag(String value) {
  return value.trim().replaceAll(RegExp(r'\s+'), ' ');
}

bool locationTagsMatch(String first, String second) {
  return normalizeLocationTag(first).toLowerCase() ==
      normalizeLocationTag(second).toLowerCase();
}

Future<String?> showLocationTagDialog(
  BuildContext context, {
  String initialLocation = '',
  String title = 'Where is this crop located?',
  bool required = true,
}) {
  return showDialog<String>(
    context: context,
    barrierDismissible: !required,
    builder: (context) => PopScope(
      canPop: !required,
      child: _LocationTagDialog(
        initialLocation: initialLocation,
        title: title,
        required: required,
      ),
    ),
  );
}

class _LocationTagDialog extends StatefulWidget {
  const _LocationTagDialog({
    required this.initialLocation,
    required this.title,
    required this.required,
  });

  final String initialLocation;
  final String title;
  final bool required;

  @override
  State<_LocationTagDialog> createState() => _LocationTagDialogState();
}

class _LocationTagDialogState extends State<_LocationTagDialog> {
  late final TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialLocation);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = normalizeLocationTag(_controller.text);
    if (value.isEmpty || !locationTagPattern.hasMatch(value)) {
      setState(() {
        _error = value.isEmpty
            ? 'Enter the crop location.'
            : 'Use letters, numbers, and spaces only.';
      });
      return;
    }
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This tag groups scans into the correct scouting report.',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            maxLength: 50,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9 ]')),
            ],
            decoration: InputDecoration(
              labelText: 'Crop location',
              hintText: 'Example: Greenhouse 1',
              errorText: _error,
              prefixIcon: const Icon(Icons.location_on_outlined),
            ),
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        if (!widget.required)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        FilledButton(onPressed: _submit, child: const Text('Save location')),
      ],
    );
  }
}
