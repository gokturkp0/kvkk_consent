// Renders the README / pub.dev screenshots in doc/screenshots/.
//
// Skipped in normal test runs (golden images differ between platforms).
// Regenerate with: ./tool/screenshots.sh
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kvkk_consent/kvkk_consent.dart';

const _enabled = bool.fromEnvironment('KVKK_SCREENSHOTS');

// Same sample data as example/lib/main.dart.
KvkkConsentController _controller() => KvkkConsentController(
  config: KvkkConfig(
    noticeText: '''
Bu metin örnektir, hukuki tavsiye değildir.

Veri sorumlusu: Örnek Uygulama
İşlenen veriler: ...
İşleme amaçları ve hukuki sebepler: ...
Aktarım: ...
KVKK m.11 kapsamındaki haklarınız: ...''',
    noticeVersion: '2026-11-18',
    consentVersion: '2026-11-18',
    purposes: const [
      ConsentPurpose(
        id: 'marketing',
        title: 'Ticari elektronik ileti',
        description: 'Kampanya ve duyuruların e-posta ile gönderilmesi.',
      ),
      ConsentPurpose(
        id: 'analytics_abroad',
        title: 'Yurt dışına aktarım (analitik)',
        description:
            'Kullanım verilerinin yurt dışındaki analitik '
            'hizmet sağlayıcısına aktarılması.',
      ),
    ],
  ),
  store: InMemoryConsentStore(),
);

/// Loads Roboto from the Flutter SDK so text renders as real glyphs
/// instead of the test font's boxes.
Future<void> _loadRoboto() async {
  final root = Platform.environment['FLUTTER_ROOT'];
  if (root == null) throw StateError('FLUTTER_ROOT is not set');
  final dir = '$root/bin/cache/artifacts/material_fonts';
  final loader = FontLoader('Roboto');
  for (final f in ['Roboto-Regular.ttf', 'Roboto-Medium.ttf']) {
    final bytes = File('$dir/$f').readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}

/// Lays the page out on a 390x844 phone and paints it at 3x, so the PNG is
/// 1170x2532 (golden capture always uses a pixel ratio of 1).
Future<void> _shoot(WidgetTester tester, Widget page, String name) async {
  const phone = Size(390, 844);
  const scale = 3.0;
  tester.view
    ..physicalSize = phone * scale
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    RepaintBoundary(
      child: FittedBox(
        child: SizedBox.fromSize(
          size: phone,
          child: MediaQuery(
            data: const MediaQueryData(size: phone, devicePixelRatio: scale),
            child: MaterialApp(debugShowCheckedModeBanner: false, home: page),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await expectLater(
    find.byType(RepaintBoundary).first,
    matchesGoldenFile('../doc/screenshots/$name.png'),
  );
}

void main() {
  setUpAll(() async {
    if (_enabled) await _loadRoboto();
  });

  testWidgets('notice screenshot', (tester) async {
    final c = _controller();
    await c.load();
    await _shoot(
      tester,
      KvkkNoticePage(controller: c, strings: KvkkStrings.tr),
      'notice',
    );
  }, skip: !_enabled);

  testWidgets('consent screenshot', (tester) async {
    final c = _controller();
    await c.load();
    await c.acknowledgeNotice();
    await _shoot(
      tester,
      KvkkConsentPage(controller: c, strings: KvkkStrings.tr),
      'consent',
    );
  }, skip: !_enabled);
}
