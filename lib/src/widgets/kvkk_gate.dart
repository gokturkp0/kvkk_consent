import 'package:flutter/material.dart';

import '../consent_controller.dart';
import '../strings.dart';
import 'kvkk_consent_page.dart';
import 'kvkk_notice_page.dart';

/// Shows notice → consent → [child], skipping steps already done.
///
/// Users who refuse every purpose still reach [child]: using the app is
/// never made conditional on consent. Call `controller.load()` before or
/// while building this; a progress indicator is shown until it completes.
class KvkkGate extends StatelessWidget {
  /// Creates a gate in front of [child].
  const KvkkGate({
    super.key,
    required this.controller,
    required this.child,
    this.strings,
  });

  /// Decides which step to show and records the user's answers.
  final KvkkConsentController controller;

  /// UI labels passed to both screens. When null, each screen picks them
  /// from the device language via [KvkkStrings.of].
  final KvkkStrings? strings;

  /// The app content shown once the notice and consent steps are done.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (!controller.isLoaded) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (controller.needsNotice) {
          return KvkkNoticePage(controller: controller, strings: strings);
        }
        if (controller.needsConsent) {
          return KvkkConsentPage(controller: controller, strings: strings);
        }
        return child;
      },
    );
  }
}
