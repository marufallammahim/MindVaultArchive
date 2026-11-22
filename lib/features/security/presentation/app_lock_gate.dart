import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:mindvault_archive/core/widgets/feature_hero.dart';
import 'package:mindvault_archive/core/widgets/neo_brutalist_panel.dart';
import 'package:mindvault_archive/features/security/data/app_lock_service.dart';

class AppLockGate extends StatefulWidget {
  const AppLockGate({super.key, required this.child, this.service});

  final Widget child;
  final AppLockService? service;

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate> with WidgetsBindingObserver {
  late final AppLockService _service = widget.service ?? AppLockService();
  bool _loading = true;
  bool _enabled = false;
  bool _locked = false;
  bool _checking = false;
  bool _storageError = false;

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
        _storageError = false;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _enabled = true;
        _locked = true;
        _storageError = true;
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
        _storageError = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _enabled = true;
          _locked = true;
          _storageError = true;
        });
      }
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
      return const Material(child: Center(child: CircularProgressIndicator()));
    }
    if (_storageError) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const FeatureHero(
                      icon: Icons.shield_outlined,
                      title: 'Secure storage unavailable',
                      subtitle: 'MindVault keeps the archive locked until app-lock settings can be verified.',
                    ),
                    const SizedBox(height: 18),
                    NeoBrutalistPanel(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.security_update_warning_outlined,
                            size: 42,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Access is paused. Check that secure storage is available, then retry.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: () {
                                setState(() => _loading = true);
                                _load();
                              },
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Retry'),
                            ),
                          ),
                        ],
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
    if (_enabled && _locked) {
      return _UnlockScreen(
        onUnlock: _unlock,
        onSuccess: _unlockSucceeded,
        lockoutRemaining: _service.lockoutRemaining,
      );
    }
    return widget.child;
  }
}

class _UnlockScreen extends StatefulWidget {
  const _UnlockScreen({
    required this.onUnlock,
    required this.onSuccess,
    required this.lockoutRemaining,
  });

  final Future<bool> Function(String pin) onUnlock;
  final VoidCallback onSuccess;
  final Future<Duration?> Function() lockoutRemaining;

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
    bool valid;
    try {
      valid = await widget.onUnlock(_controller.text);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'Secure storage is unavailable. Try again.';
      });
      return;
    }
    if (!mounted) return;
    if (valid) {
      setState(() => _busy = false);
      widget.onSuccess();
    } else {
      Duration? remaining;
      try {
        remaining = await widget.lockoutRemaining();
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _busy = false;
          _error = 'Secure storage is unavailable. Try again.';
        });
        return;
      }
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = remaining == null
            ? 'Incorrect PIN. Try again.'
            : 'Too many attempts. Try again in ${remaining.inSeconds.ceil()} seconds.';
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const FeatureHero(
                    icon: Icons.lock_rounded,
                    title: 'MindVault is locked',
                    subtitle: 'Enter your six-digit app PIN to continue.',
                  ),
                  const SizedBox(height: 18),
                  NeoBrutalistPanel(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _controller,
                          autofocus: true,
                          enabled: !_busy,
                          obscureText: true,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          maxLength: 6,
                          textAlign: TextAlign.center,
                          onSubmitted: (_) => _submit(),
                          decoration: InputDecoration(
                            labelText: 'App PIN',
                            errorText: _error,
                            counterText: '',
                            prefixIcon: const Icon(Icons.password_rounded),
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
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
                      ],
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
