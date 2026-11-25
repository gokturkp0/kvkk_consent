import 'package:flutter/material.dart';

import '../consent_controller.dart';
import '../strings.dart';
import 'common.dart';

/// One switch per purpose. Switches start from the user's current choice,
/// which is "off" for anyone who has not decided yet. "Reject all" and
/// "Save" have the same visual weight on purpose (no dark patterns).
///
/// Can be opened again later from app settings to change or withdraw.
/// Both buttons call [KvkkConsentController.saveConsents]; "Reject all"
/// passes no choices, so every purpose is recorded as refused.
///
/// A link above the switches opens the privacy notice again (read-only),
/// so consent stays based on information. Controls are disabled while
/// saving, so a double tap records only once; a failed save shows
/// [KvkkStrings.saveError] and keeps the screen open.
class KvkkConsentPage extends StatefulWidget {
  /// Creates the consent screen for [controller].
  const KvkkConsentPage({
    super.key,
    required this.controller,
    this.strings,
    this.onDone,
  });

  /// Provides the purposes and records the decisions.
  final KvkkConsentController controller;

  /// UI labels. When null, [KvkkStrings.of] picks them from the device
  /// language.
  final KvkkStrings? strings;

  /// Called after the decisions are saved, e.g. to pop the route when
  /// opened from settings. Not needed inside `KvkkGate`.
  final VoidCallback? onDone;

  @override
  State<KvkkConsentPage> createState() => _KvkkConsentPageState();
}

class _KvkkConsentPageState extends State<KvkkConsentPage> {
  late final Map<String, bool> _choices = {
    for (final p in widget.controller.config.purposes)
      p.id: widget.controller.isGranted(p.id),
  };
  bool _busy = false;

  Future<void> _submit(KvkkStrings s, Map<String, bool> choices) async {
    if (_busy) return;
    setState(() => _busy = true);
    final ok = await runSave(
      context,
      s,
      () => widget.controller.saveConsents(choices),
    );
    if (mounted) setState(() => _busy = false);
    if (ok) widget.onDone?.call();
  }

  void _openNotice(KvkkStrings s) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(s.noticeTitle)),
          body: SafeArea(
            child: NoticeBody(text: widget.controller.config.noticeText),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.strings ?? KvkkStrings.of(context);
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
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Text(s.consentIntro),
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: TextButton(
                        onPressed: () => _openNotice(s),
                        child: Text(s.viewNotice),
                      ),
                    ),
                  ),
                  for (final p in purposes)
                    SwitchListTile(
                      key: ValueKey('kvkk-switch-${p.id}'),
                      title: Text(p.title),
                      subtitle: Text(p.description),
                      value: _choices[p.id]!,
                      onChanged: _busy
                          ? null
                          : (v) => setState(() => _choices[p.id] = v),
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
                      onPressed: _busy ? null : () => _submit(s, {}),
                      child: Text(s.rejectAll),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: _busy ? null : () => _submit(s, _choices),
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
