import 'package:flutter/material.dart';
import '../../core/brand/app_brand.dart';
import '../../core/services/api_client.dart';
import '../../core/services/device_security_service.dart';
import '../../core/theme/app_colors.dart';
import '../auth/login_screen.dart';
import '../home/home_screen.dart';

class BiometricLockScreen extends StatefulWidget {
  const BiometricLockScreen({super.key});

  @override
  State<BiometricLockScreen> createState() => _BiometricLockScreenState();
}

class _BiometricLockScreenState extends State<BiometricLockScreen> {
  bool _checking = false;
  String? _message;

  Future<void> _unlock() async {
    if (_checking) return;
    setState(() {
      _checking = true;
      _message = null;
    });
    final unlocked = await DeviceSecurityService.instance.authenticate(
      reason: 'Unlock Provida to view your finances',
    );
    if (!mounted) return;
    if (unlocked) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
      return;
    }
    setState(() {
      _checking = false;
      _message = 'Identity not verified. Provida remains locked.';
    });
  }

  Future<void> _logOut() async {
    await ApiClient.instance.clearTokens();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppBrandMark(size: 82),
                  const SizedBox(height: 24),
                  Text('Provida is locked', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Verify with your biometric to continue. A failed or cancelled check will never open your account.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (_message != null) ...[
                    const SizedBox(height: 14),
                    Text(_message!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.expense)),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _checking ? null : _unlock,
                      icon: _checking
                          ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.fingerprint_rounded),
                      label: Text(_checking ? 'Checking…' : 'Try again'),
                    ),
                  ),
                  TextButton(
                    onPressed: _checking ? null : _logOut,
                    style: TextButton.styleFrom(foregroundColor: dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                    child: const Text('Log out and use another account'),
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
