import 'package:flutter/material.dart';

import '../consent_controller.dart';
import '../strings.dart';

/// Shows the aydınlatma metni. It informs only: there is deliberately no
/// "I accept" wording and no checkbox here (consent is a separate step).
///
/// Tapping the button calls [KvkkConsentController.acknowledgeNotice],
/// which grants no consent.
class KvkkNoticePage extends StatelessWidget {
  /// Creates the notice screen for [controller].
  const KvkkNoticePage({
    super.key,
    required this.controller,
    this.strings = KvkkStrings.tr,
    this.onDone,
  });

  /// Provides the notice text and records the acknowledgement.
  final KvkkConsentController controller;

  /// UI labels. Defaults to Turkish.
  final KvkkStrings strings;

  /// Called after the acknowledgement is saved, e.g. to pop the route.
  /// Not needed inside `KvkkGate`, which reacts to the controller.
  final VoidCallback? onDone;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(strings.noticeTitle)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: SelectableText(controller.config.noticeText),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    await controller.acknowledgeNotice();
                    onDone?.call();
                  },
                  child: Text(strings.noticeContinue),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
