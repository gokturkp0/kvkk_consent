// kvkk_consent example: notice → consent gate, a privacy settings screen,
// language selection and the consent history.
import 'package:flutter/material.dart';
import 'package:kvkk_consent/kvkk_consent.dart';

/// Stands in for persistent storage so the example has no dependencies.
/// In a real app, back JsonStringConsentStore with shared_preferences:
///
///   final prefs = await SharedPreferences.getInstance();
///   JsonStringConsentStore(
///     read: () async => prefs.getString('kvkk'),
///     write: (v) => prefs.setString('kvkk', v),
///   );
String? savedJson;

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
  store: JsonStringConsentStore(
    read: () async => savedJson,
    write: (v) async => savedJson = v,
  ),
);

/// Null follows the device language (KvkkStrings.of).
final language = ValueNotifier<KvkkStrings?>(null);

void main() {
  controller.load();
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<KvkkStrings?>(
      valueListenable: language,
      builder: (context, strings, _) => MaterialApp(
        title: 'kvkk_consent example',
        theme: ThemeData(colorSchemeSeed: Colors.teal),
        home: KvkkGate(
          controller: controller,
          strings: strings,
          child: const HomePage(),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Örnek uygulama')),
      body: ListenableBuilder(
        listenable: Listenable.merge([controller, language]),
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Dil', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<KvkkStrings?>(
              segments: const [
                ButtonSegment(value: null, label: Text('Cihaz')),
                ButtonSegment(value: KvkkStrings.tr, label: Text('Türkçe')),
                ButtonSegment(value: KvkkStrings.en, label: Text('English')),
              ],
              selected: {language.value},
              onSelectionChanged: (s) => language.value = s.first,
            ),
            const SizedBox(height: 24),
            Text('Rıza durumu', style: Theme.of(context).textTheme.titleMedium),
            for (final p in controller.config.purposes)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  controller.isGranted(p.id)
                      ? Icons.check_circle
                      : Icons.cancel_outlined,
                ),
                title: Text(p.title),
                subtitle: Text(
                  controller.isGranted(p.id) ? 'Onay verildi' : 'Onay yok',
                ),
              ),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.tune),
              label: const Text('Gizlilik tercihleri'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (ctx) => KvkkConsentPage(
                    controller: controller,
                    strings: language.value,
                    onDone: () => Navigator.of(ctx).pop(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.history),
              label: Text('Kayıt geçmişi (${controller.history.length})'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const HistoryPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows exportJson(), e.g. what you would hand over for a data access
/// request or send to your own backend.
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kayıt geçmişi')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SelectableText(
          controller.exportJson(),
          style: const TextStyle(fontFamily: 'monospace'),
        ),
      ),
    );
  }
}
