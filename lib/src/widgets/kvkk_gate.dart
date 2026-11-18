import 'package:flutter/material.dart';

import '../consent_controller.dart';
import '../strings.dart';
import 'kvkk_consent_page.dart';
import 'kvkk_notice_page.dart';

/// Shows notice → consent → [child], skipping steps already done.
/// Call `controller.load()` before or while building this.
class KvkkGate extends StatelessWidget {
  const KvkkGate({
    super.key,
    required this.controller,
    required this.child,
    this.strings = KvkkStrings.tr,
  });

  final KvkkConsentController controller;
  final KvkkStrings strings;
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
