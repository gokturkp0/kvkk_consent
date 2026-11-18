import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kvkk_consent/kvkk_consent.dart';

KvkkConsentController controller() => KvkkConsentController(
  config: KvkkConfig(
    noticeText: 'AYDINLATMA',
    noticeVersion: '1',
    consentVersion: '1',
    purposes: const [
      ConsentPurpose(id: 'marketing', title: 'Pazarlama', description: '-'),
    ],
  ),
  store: InMemoryConsentStore(),
);

Widget app(KvkkConsentController c) => MaterialApp(
  home: KvkkGate(controller: c, child: const Text('HOME')),
);

void main() {
  testWidgets('notice → consent (reject all) → home', (tester) async {
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
}
