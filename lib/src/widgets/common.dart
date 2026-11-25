// Internal helpers shared by the screens. Not exported.
import 'package:flutter/material.dart';

import '../strings.dart';

/// Scrollable, selectable privacy notice text.
class NoticeBody extends StatelessWidget {
  /// Creates the notice body for [text].
  const NoticeBody({super.key, required this.text});

  /// The notice text.
  final String text;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: SelectableText(text),
  );
}

/// Runs [save] and reports whether it succeeded.
///
/// On an [Exception] (e.g. a failing `ConsentStore`), reports it to
/// [FlutterError] for logging and shows [KvkkStrings.saveError] so the user
/// knows nothing was recorded. Errors are not caught: they indicate a bug.
Future<bool> runSave(
  BuildContext context,
  KvkkStrings strings,
  Future<void> Function() save,
) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  try {
    await save();
    return true;
  } on Exception catch (e, st) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: e,
        stack: st,
        library: 'kvkk_consent',
        context: ErrorDescription('while saving a consent record'),
      ),
    );
    messenger?.showSnackBar(SnackBar(content: Text(strings.saveError)));
    return false;
  }
}
