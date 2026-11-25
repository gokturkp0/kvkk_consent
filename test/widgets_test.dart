import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kvkk_consent/kvkk_consent.dart';

KvkkConsentController controller([ConsentStore? store]) =>
    KvkkConsentController(
      config: KvkkConfig(
        noticeText: 'AYDINLATMA',
        noticeVersion: '1',
        consentVersion: '1',
        purposes: const [
          ConsentPurpose(id: 'marketing', title: 'Pazarlama', description: '-'),
        ],
      ),
      store: store ?? InMemoryConsentStore(),
    );

Widget app(KvkkConsentController c) => MaterialApp(
  home: KvkkGate(controller: c, child: const Text('HOME')),
);

/// Pretends the device language is [languageCode] for this test.
void deviceLanguage(WidgetTester tester, String languageCode) {
  tester.platformDispatcher.localeTestValue = Locale(languageCode);
  addTearDown(tester.platformDispatcher.clearLocaleTestValue);
}

/// Saves only when [gate] completes, to observe the in-flight state.
class SlowStore extends InMemoryConsentStore {
  final gate = Completer<void>();
  int saves = 0;

  @override
  Future<void> save(List<ConsentRecord> records) async {
    saves++;
    await gate.future;
    await super.save(records);
  }
}

/// Always fails to save, like a full disk or a broken backend.
class FailingStore extends InMemoryConsentStore {
  @override
  Future<void> save(List<ConsentRecord> records) async =>
      throw Exception('disk full');
}

void main() {
  testWidgets('notice → consent (reject all) → home', (tester) async {
    deviceLanguage(tester, 'tr');
    final c = controller();
    await c.load();
    await tester.pumpWidget(app(c));

    expect(find.text('AYDINLATMA'), findsOneWidget);
    expect(find.byType(Switch), findsNothing); // notice asks nothing
    await tester.tap(find.text(KvkkStrings.tr.noticeContinue));
    await tester.pumpAndSettle();

    final sw = tester.widget<Switch>(find.byType(Switch));
    expect(sw.value, isFalse); // never pre-checked
    await tester.tap(find.text(KvkkStrings.tr.rejectAll));
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsOneWidget);
    expect(c.isGranted('marketing'), isFalse);
  });

  testWidgets('switch on + save grants', (tester) async {
    deviceLanguage(tester, 'tr');
    final c = controller();
    await c.load();
    await c.acknowledgeNotice();
    await tester.pumpWidget(app(c));

    await tester.tap(find.byKey(const ValueKey('kvkk-switch-marketing')));
    await tester.pump();
    await tester.tap(find.text(KvkkStrings.tr.saveChoices));
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsOneWidget);
    expect(c.isGranted('marketing'), isTrue);
  });

  group('language', () {
    testWidgets('follows the device language when strings is null', (
      tester,
    ) async {
      deviceLanguage(tester, 'en');
      final c = controller();
      await c.load();
      await tester.pumpWidget(app(c));
      expect(find.text(KvkkStrings.en.noticeTitle), findsOneWidget);
    });

    testWidgets('explicit strings win over the device language', (
      tester,
    ) async {
      deviceLanguage(tester, 'en');
      final c = controller();
      await c.load();
      await tester.pumpWidget(
        MaterialApp(
          home: KvkkGate(
            controller: c,
            strings: KvkkStrings.tr,
            child: const SizedBox(),
          ),
        ),
      );
      expect(find.text(KvkkStrings.tr.noticeTitle), findsOneWidget);
    });

    test('forLocale: tr is Turkish, anything else English', () {
      expect(KvkkStrings.forLocale(const Locale('tr', 'TR')), KvkkStrings.tr);
      expect(KvkkStrings.forLocale(const Locale('en')), KvkkStrings.en);
      expect(KvkkStrings.forLocale(const Locale('de')), KvkkStrings.en);
    });
  });

  testWidgets('double tap on save records once', (tester) async {
    deviceLanguage(tester, 'tr');
    final store = SlowStore();
    final c = controller(store);
    await c.load();
    await tester.pumpWidget(MaterialApp(home: KvkkConsentPage(controller: c)));

    final save = find.text(KvkkStrings.tr.saveChoices);
    await tester.tap(save);
    await tester.tap(save);
    await tester.pump();

    // While saving, every control is disabled.
    final switchTile = tester.widget<SwitchListTile>(
      find.byType(SwitchListTile),
    );
    expect(switchTile.onChanged, isNull);

    store.gate.complete();
    await tester.pumpAndSettle();
    expect(store.saves, 1);
    expect(c.history, hasLength(1));
  });

  testWidgets('failed save shows an error and records nothing', (tester) async {
    deviceLanguage(tester, 'tr');
    final c = controller(FailingStore());
    await c.load();
    var done = false;
    await tester.pumpWidget(
      MaterialApp(
        home: KvkkConsentPage(controller: c, onDone: () => done = true),
      ),
    );

    await tester.tap(find.text(KvkkStrings.tr.rejectAll));
    await tester.pump();

    expect(tester.takeException(), isA<Exception>()); // reported for logs
    expect(find.text(KvkkStrings.tr.saveError), findsOneWidget);
    expect(c.history, isEmpty);
    expect(done, isFalse);
    // Buttons are enabled again so the user can retry.
    final button = tester.widget<FilledButton>(
      find.ancestor(
        of: find.text(KvkkStrings.tr.rejectAll),
        matching: find.byType(FilledButton),
      ),
    );
    expect(button.onPressed, isNotNull);
  });

  testWidgets('consent screen can open the notice read-only', (tester) async {
    deviceLanguage(tester, 'tr');
    final c = controller();
    await c.load();
    await c.acknowledgeNotice();
    await tester.pumpWidget(MaterialApp(home: KvkkConsentPage(controller: c)));

    await tester.tap(find.text(KvkkStrings.tr.viewNotice));
    await tester.pumpAndSettle();
    expect(find.text('AYDINLATMA'), findsOneWidget);
    expect(find.text(KvkkStrings.tr.noticeContinue), findsNothing);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(SwitchListTile), findsOneWidget);
    expect(c.history, hasLength(1)); // reading again records nothing new
  });
}
