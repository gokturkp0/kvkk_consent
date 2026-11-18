import 'package:flutter_test/flutter_test.dart';
import 'package:kvkk_consent/kvkk_consent.dart';

KvkkConfig config({String notice = 'n1', String consent = 'c1'}) => KvkkConfig(
  noticeText: 'Aydınlatma metni',
  noticeVersion: notice,
  consentVersion: consent,
  purposes: const [
    ConsentPurpose(id: 'marketing', title: 'Pazarlama', description: '-'),
    ConsentPurpose(id: 'analytics', title: 'Analitik', description: '-'),
  ],
);

Future<KvkkConsentController> loaded(
  ConsentStore store, [
  KvkkConfig? c,
]) async {
  final ctrl = KvkkConsentController(
    config: c ?? config(),
    store: store,
    clock: () => DateTime.utc(2026, 1, 1),
  );
  await ctrl.load();
  return ctrl;
}

void main() {
  test('fresh user needs notice and consent, nothing granted', () async {
    final c = await loaded(InMemoryConsentStore());
    expect(c.needsNotice, isTrue);
    expect(c.needsConsent, isTrue);
    expect(c.isGranted('marketing'), isFalse);
  });

  test('notice acknowledgement does not grant any consent', () async {
    final c = await loaded(InMemoryConsentStore());
    await c.acknowledgeNotice();
    expect(c.needsNotice, isFalse);
    expect(c.needsConsent, isTrue);
    expect(c.isGranted('marketing'), isFalse);
  });

  test('missing choices are recorded as refused', () async {
    final c = await loaded(InMemoryConsentStore());
    await c.saveConsents({'marketing': true});
    expect(c.needsConsent, isFalse);
    expect(c.isGranted('marketing'), isTrue);
    expect(c.isGranted('analytics'), isFalse);
  });

  test('reject all is a decision and does not re-prompt', () async {
    final c = await loaded(InMemoryConsentStore());
    await c.saveConsents({});
    expect(c.needsConsent, isFalse);
  });

  test('withdraw via setConsent keeps history append-only', () async {
    final c = await loaded(InMemoryConsentStore());
    await c.saveConsents({'marketing': true});
    await c.setConsent('marketing', false);
    expect(c.isGranted('marketing'), isFalse);
    expect(c.history.length, 3);
  });

  test('version bumps ask again', () async {
    final store = InMemoryConsentStore();
    final c1 = await loaded(store);
    await c1.acknowledgeNotice();
    await c1.saveConsents({'marketing': true});

    final c2 = await loaded(store, config(notice: 'n2', consent: 'c2'));
    expect(c2.needsNotice, isTrue);
    expect(c2.needsConsent, isTrue);
    expect(c2.isGranted('marketing'), isFalse);
  });

  test('unknown purpose id throws', () async {
    final c = await loaded(InMemoryConsentStore());
    expect(() => c.setConsent('nope', true), throwsArgumentError);
    expect(() => c.saveConsents({'nope': true}), throwsArgumentError);
  });

  test('changing before load throws', () {
    final c = KvkkConsentController(
      config: config(),
      store: InMemoryConsentStore(),
    );
    expect(c.acknowledgeNotice, throwsStateError);
  });

  test('JsonStringConsentStore round-trips', () async {
    String? saved;
    JsonStringConsentStore store() => JsonStringConsentStore(
      read: () async => saved,
      write: (v) async => saved = v,
    );
    final c1 = await loaded(store());
    await c1.acknowledgeNotice();
    await c1.saveConsents({'analytics': true});

    final c2 = await loaded(store());
    expect(c2.needsNotice, isFalse);
    expect(c2.isGranted('analytics'), isTrue);
    expect(c2.history.first.at, DateTime.utc(2026, 1, 1));
    expect(c2.exportJson(), contains('"purposeId": "analytics"'));
  });
}
