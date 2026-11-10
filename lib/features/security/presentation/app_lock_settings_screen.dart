import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindvault_archive/features/security/data/app_lock_service.dart';

class AppLockSettingsScreen extends ConsumerStatefulWidget {
  const AppLockSettingsScreen({super.key});

  @override
  ConsumerState<AppLockSettingsScreen> createState() => _AppLockSettingsScreenState();
}

class _AppLockSettingsScreenState extends ConsumerState<AppLockSettingsScreen> {
  final _service = AppLockService();
  late Future<bool> _enabledFuture;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _enabledFuture = _service.isEnabled();
  }

  void _refresh() => setState(() => _enabledFuture = _service.isEnabled());

  Future<String?> _askPin(String title) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          obscureText: true,
          maxLength: 6,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(labelText: 'Six-digit PIN', counterText: ''),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, controller.text.trim()), child: const Text('Continue')),
        ],
      ),
    );
    controller.dispose();
    if (result == null || result.length != 6) return null;
    return result;
  }

  Future<void> _enableOrChange({required bool changing}) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      if (changing) {
        final current = await _askPin('Enter current PIN');
        if (current == null) return;
        if (!await _service.verifyPin(current)) {
          _message('PIN is incorrect or temporarily locked. Try again later.');
          return;
        }
      }
      final first = await _askPin(changing ? 'Choose a new PIN' : 'Create app PIN');
      if (first == null) {
        _message('Enter exactly six digits.');
        return;
      }
      final second = await _askPin('Confirm your PIN');
      if (second == null) return;
      if (first != second) {
        _message('PINs do not match. Nothing was changed.');
        return;
      }
      await _service.setPin(first);
      _message(changing ? 'Protector PIN updated.' : 'Protector enabled.');
      _refresh();
    } catch (error) {
      _message('Could not update Protector: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _disable() async {
    if (_busy) return;
    final current = await _askPin('Verify PIN to turn off Protector');
    if (current == null) return;
    setState(() => _busy = true);
    try {
      await _service.disablePin(current);
      _message('Protector disabled.');
      _refresh();
    } catch (error) {
      _message('Could not disable Protector: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _message(String value) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  Widget _featureRow(BuildContext context, IconData icon, String title, String detail, {bool available = true}) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 38, height: 38, decoration: BoxDecoration(color: scheme.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: scheme.primary, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 3),
          Text(detail, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
        ])),
        const SizedBox(width: 8),
        Icon(available ? Icons.check_circle_rounded : Icons.schedule_rounded, size: 18, color: available ? Colors.green : scheme.onSurfaceVariant),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Protector')),
      body: FutureBuilder<bool>(
        future: _enabledFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Secure storage is unavailable: ${snapshot.error}')));
          final enabled = snapshot.data ?? false;
          return ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 36), children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withValues(alpha: 0.42),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: scheme.primary.withValues(alpha: 0.18)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(width: 54, height: 54, decoration: BoxDecoration(color: scheme.primary, borderRadius: BorderRadius.circular(19)), child: Icon(enabled ? Icons.shield_rounded : Icons.shield_outlined, color: scheme.onPrimary, size: 29)),
                  const Spacer(),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7), decoration: BoxDecoration(color: enabled ? Colors.green.withValues(alpha: 0.14) : scheme.surface.withValues(alpha: 0.65), borderRadius: BorderRadius.circular(30)), child: Text(enabled ? 'PROTECTED' : 'NOT ENABLED', style: TextStyle(fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.w900, color: enabled ? Colors.green : scheme.onSurfaceVariant))),
                ]),
                const SizedBox(height: 20),
                Text(enabled ? 'Your app has an access lock.' : 'Add a private entry checkpoint.', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.7)),
                const SizedBox(height: 7),
                Text(enabled ? 'A PIN is required by the app lock gate when the app is opened or resumed.' : 'Set a six-digit PIN to prevent casual access when someone opens your app.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
                const SizedBox(height: 18),
                SizedBox(width: double.infinity, child: FilledButton.icon(
                  onPressed: _busy ? null : () => enabled ? _enableOrChange(changing: true) : _enableOrChange(changing: false),
                  icon: Icon(enabled ? Icons.password_rounded : Icons.lock_outline_rounded),
                  label: Text(enabled ? 'Change PIN' : 'Set up Protector'),
                )),
                if (enabled) ...[
                  const SizedBox(height: 8),
                  SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: _busy ? null : _disable, icon: const Icon(Icons.lock_open_rounded), label: const Text('Turn off Protector'))),
                ],
              ]),
            ),
            const SizedBox(height: 24),
            Text('PROTECTION STATUS', style: Theme.of(context).textTheme.labelMedium?.copyWith(letterSpacing: 1.3, fontWeight: FontWeight.w900, color: scheme.primary)),
            const SizedBox(height: 8),
            Card(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Column(children: [
              _featureRow(context, Icons.password_rounded, 'Six-digit PIN', 'Salted PIN hash stored in Android secure storage.', available: enabled),
              const Divider(height: 1),
              _featureRow(context, Icons.timer_outlined, 'Failed-attempt delay', 'Five failed attempts trigger a 30-second cooldown.', available: true),
              const Divider(height: 1),
              _featureRow(context, Icons.fingerprint_rounded, 'Biometric unlock', 'Not implemented in this build.', available: false),
              const Divider(height: 1),
              _featureRow(context, Icons.key_off_rounded, 'PIN recovery', 'No recovery flow is available yet.', available: false),
              const Divider(height: 1),
              _featureRow(context, Icons.enhanced_encryption_outlined, 'Database encryption', 'App lock does not encrypt notes or attachments.', available: false),
            ]))),
            const SizedBox(height: 14),
            Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: scheme.errorContainer.withValues(alpha: 0.45), borderRadius: BorderRadius.circular(20)), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.info_outline_rounded, color: scheme.onErrorContainer),
              const SizedBox(width: 10),
              Expanded(child: Text('Important: Protector is an app access screen, not vault encryption. Your local database and attachments are not encrypted by this feature. Keep your PIN safe; there is currently no PIN recovery option.', style: TextStyle(color: scheme.onErrorContainer, height: 1.4))),
            ])),
          ]);
        },
      ),
    );
  }
}
