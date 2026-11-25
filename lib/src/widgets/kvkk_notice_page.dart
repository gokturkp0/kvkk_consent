import 'package:flutter/material.dart';

import '../consent_controller.dart';
import '../strings.dart';
import 'common.dart';

/// Shows the aydınlatma metni. It informs only: there is deliberately no
/// "I accept" wording and no checkbox here (consent is a separate step).
///
/// Tapping the button calls [KvkkConsentController.acknowledgeNotice],
/// which grants no consent. The button is disabled while saving, so a
/// double tap records only once; a failed save shows
/// [KvkkStrings.saveError].
class KvkkNoticePage extends StatefulWidget {
  /// Creates the notice screen for [controller].
  const KvkkNoticePage({
    super.key,
    required this.controller,
    this.strings,
    this.onDone,
  });

  /// Provides the notice text and records the acknowledgement.
  final KvkkConsentController controller;

  /// UI labels. When null, [KvkkStrings.of] picks them from the device
  /// language.
  final KvkkStrings? strings;

  /// Called after the acknowledgement is saved, e.g. to pop the route.
  /// Not needed inside `KvkkGate`, which reacts to the controller.
  final VoidCallback? onDone;

  @override
  State<KvkkNoticePage> createState() => _KvkkNoticePageState();
}

class _KvkkNoticePageState extends State<KvkkNoticePage> {
  bool _busy = false;

  Future<void> _acknowledge(KvkkStrings s) async {
    if (_busy) return;
    setState(() => _busy = true);
    final ok = await runSave(context, s, widget.controller.acknowledgeNotice);
    if (mounted) setState(() => _busy = false);
    if (ok) widget.onDone?.call();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.strings ?? KvkkStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.noticeTitle)),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: NoticeBody(text: widget.controller.config.noticeText),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: _busy ? null : () => _acknowledge(s),
                child: Text(s.noticeContinue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
