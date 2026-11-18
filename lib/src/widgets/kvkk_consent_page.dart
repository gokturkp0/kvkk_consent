import 'package:flutter/material.dart';

import '../consent_controller.dart';
import '../strings.dart';

/// One switch per purpose. Switches start from the user's current choice,
/// which is "off" for anyone who has not decided yet. "Reject all" and
/// "Save" have the same visual weight on purpose (no dark patterns).
///
/// Can be opened again later from app settings to change or withdraw.
class KvkkConsentPage extends StatefulWidget {
  const KvkkConsentPage({
    super.key,
    required this.controller,
    this.strings = KvkkStrings.tr,
    this.onDone,
  });

  final KvkkConsentController controller;
  final KvkkStrings strings;
  final VoidCallback? onDone;

  @override
  State<KvkkConsentPage> createState() => _KvkkConsentPageState();
}

class _KvkkConsentPageState extends State<KvkkConsentPage> {
  late final Map<String, bool> _choices = {
    for (final p in widget.controller.config.purposes)
      p.id: widget.controller.isGranted(p.id),
  };

  Future<void> _submit(Map<String, bool> choices) async {
    await widget.controller.saveConsents(choices);
    widget.onDone?.call();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.strings;
    final purposes = widget.controller.config.purposes;
    return Scaffold(
      appBar: AppBar(title: Text(s.consentTitle)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(s.consentIntro),
                  ),
                  for (final p in purposes)
                    SwitchListTile(
                      key: ValueKey('kvkk-switch-${p.id}'),
                      title: Text(p.title),
                      subtitle: Text(p.description),
                      value: _choices[p.id]!,
                      onChanged: (v) => setState(() => _choices[p.id] = v),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: () => _submit({}),
                      child: Text(s.rejectAll),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: () => _submit(_choices),
                      child: Text(s.saveChoices),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
