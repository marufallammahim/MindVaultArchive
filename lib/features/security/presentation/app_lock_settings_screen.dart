import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindvault_archive/features/security/data/app_lock_service.dart';

class AppLockSettingsScreen extends ConsumerStatefulWidget {
  const AppLockSettingsScreen({super.key});

  @override
  ConsumerState<AppLockSettingsScreen> createState() =>
      _AppLockSettingsScreenState();
}

class _AppLockSettingsScreenState
    extends ConsumerState<AppLockSettingsScreen> {
  final _service = AppLockService();
  late Future<bool> _enabledFuture;

  @override
  void initState() {
    super.initState();
    _enabledFuture = _service.isEnabled();
  }

  void _refresh() {
    setState(() => _enabledFuture = _service.isEnabled());
  }

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
          decoration: const InputDecoration(
            labelText: 'Six-digit PIN',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result == null || result.length != 6) return null;
    return result;
  }

  Future<void> _enableOrChange({required bool changing}) async {
    if (changing) {
      final current = await _askPin('Enter current PIN');
      if (current == null) return;
      if (!await _service.verifyPin(current)) {
        _message('Current PIN is incorrect.');
        return;
      }
    }

    final first =
        await _askPin(changing ? 'Choose a new PIN' : 'Create app PIN');
    if (first == null) {
      _message('Enter exactly six digits.');
      return;
    }
    final second = await _askPin('Confirm your PIN');
    if (second == null) return;
    if (first != second) {
      _message('The PINs do not match. Nothing was changed.');
      return;
    }

    try {
      await _service.setPin(first);
      if (!mounted) return;
      _refresh();
      _message(changing ? 'App PIN changed.' : 'App lock enabled.');
    } catch (error) {
      _message('Could not save app PIN: $error');
    }
  }

  Future<void> _disable() async {
    final current = await _askPin('Enter current PIN to disable');
    if (current == null) return;
    try {
      await _service.disablePin(current);
      if (!mounted) return;
      _refresh();
      _message('App lock disabled.');
    } catch (error) {
      _message('Could not disable app lock: $error');
    }
  }

  void _message(String value) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(value)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App lock')),
      body: FutureBuilder<bool>(
        future: _enabledFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Secure storage unavailable: \${snapshot.error}'),
            );
          }
          final enabled = snapshot.data ?? false;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 56,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                enabled ? 'App lock is enabled' : 'Protect app access',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'A six-digit PIN is stored as a salted hash in Android secure '
                'storage. The app asks for it when opened and after returning '
                'from the background.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (enabled) ...[
                FilledButton.icon(
                  onPressed: () => _enableOrChange(changing: true),
                  icon: const Icon(Icons.password_outlined),
                  label: const Text('Change PIN'),
                ),
                OutlinedButton.icon(
                  onPressed: _disable,
                  icon: const Icon(Icons.lock_open_outlined),
                  label: const Text('Disable app lock'),
                ),
              ] else
                FilledButton.icon(
                  onPressed: () => _enableOrChange(changing: false),
                  icon: const Icon(Icons.lock_outline),
                  label: const Text('Set app PIN'),
                ),
              const SizedBox(height: 24),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Important: App lock is an access screen, not encryption. '
                    'The SQLite database and attachment files are not encrypted '
                    'by this feature. Remember your PIN; there is no PIN recovery '
                    'flow yet.',
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
