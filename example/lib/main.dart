import 'package:flutter/material.dart';
import 'package:kvkk_consent/kvkk_consent.dart';

final controller = KvkkConsentController(
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
  // Use JsonStringConsentStore + shared_preferences in a real app.
  store: InMemoryConsentStore(),
);

void main() {
  controller.load();
  runApp(
    MaterialApp(
      home: KvkkGate(controller: controller, child: const HomePage()),
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ana sayfa')),
      body: Center(
        child: FilledButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (ctx) => KvkkConsentPage(
                controller: controller,
                onDone: () => Navigator.of(ctx).pop(),
              ),
            ),
          ),
          child: const Text('Gizlilik tercihleri'),
        ),
      ),
    );
  }
}
