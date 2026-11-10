import 'package:flutter/material.dart';
import 'package:mindvault_archive/features/security/data/app_lock_service.dart';

class AppLockGate extends StatefulWidget {
  const AppLockGate({super.key, required this.child});

  final Widget child;

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate>
    with WidgetsBindingObserver {
  final _service = AppLockService();
  bool _loading = true;
  bool _enabled = false;
  bool _locked = false;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final enabled = await _service.isEnabled();
      if (!mounted) return;
      setState(() {
        _enabled = enabled;
        _locked = enabled;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _enabled = false;
        _locked = false;
        _loading = false;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _lockIfEnabled();
    }
  }

  Future<void> _lockIfEnabled() async {
    if (_checking) return;
    _checking = true;
    try {
      final enabled = await _service.isEnabled();
      if (!mounted) return;
      setState(() {
        _enabled = enabled;
        _locked = enabled;
      });
    } finally {
      _checking = false;
    }
  }

  Future<bool> _unlock(String pin) => _service.verifyPin(pin);

  void _unlockSucceeded() {
    if (!mounted) return;
    setState(() => _locked = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Material(
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_enabled && _locked) {
      return _UnlockScreen(onUnlock: _unlock);
    }
    return widget.child;
  }
}

class _UnlockScreen extends StatefulWidget {
  const _UnlockScreen({required this.onUnlock});

  final Future<bool> Function(String pin) onUnlock;

  @override
  State<_UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends State<_UnlockScreen> {
  final _controller = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final valid = await widget.onUnlock(_controller.text);
    if (!mounted) return;
    if (valid) {
      setState(() => _busy = false);
      context.findAncestorStateOfType<_AppLockGateState>()?._unlockSucceeded();
    } else {
      setState(() {
        _busy = false;
        _error = 'Incorrect PIN. Try again.';
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'MindVault is locked',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter your six-digit app PIN to continue.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _controller,
                    autofocus: true,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    onSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      labelText: 'App PIN',
                      errorText: _error,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _busy ? null : _submit,
                      child: _busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Unlock'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
