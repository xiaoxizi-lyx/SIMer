import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';

/// 在锁定时覆盖整个应用（包括所有已打开的页面、对话框和底部弹窗）。
///
/// 放在 `MaterialApp.builder` 中，位于 Navigator 之上；同时把应用生命周期转发给
/// [AuthProvider] 以便离开应用超时后重新上锁。
class AppLockGate extends StatefulWidget {
  const AppLockGate({super.key, required this.child});

  final Widget child;

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate> {
  late final AppLifecycleListener _lifecycle = AppLifecycleListener(
    onStateChange: (state) =>
        context.read<AuthProvider>().handleLifecycle(state),
  );

  @override
  void initState() {
    super.initState();
    _lifecycle; // 立即开始监听
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locked = context.select<AuthProvider, bool>((a) => a.isLocked);
    return Stack(
      fit: StackFit.expand,
      children: [
        // 锁定时下层内容既不可交互，也不暴露给读屏，动画暂停
        ExcludeSemantics(
          excluding: locked,
          child: TickerMode(
            enabled: !locked,
            child: IgnorePointer(ignoring: locked, child: widget.child),
          ),
        ),
        if (locked) const LockScreen(),
      ],
    );
  }
}

/// 锁屏界面。出现时（且应用在前台）自动发起一次验证。
class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breathe = AnimationController(
    duration: const Duration(milliseconds: 2000),
    vsync: this,
  );
  late final AppLifecycleListener _lifecycle = AppLifecycleListener(
    onResume: _authenticate,
  );

  @override
  void initState() {
    super.initState();
    _lifecycle;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!MediaQuery.disableAnimationsOf(context)) {
        _breathe.repeat(reverse: true);
      }
      if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
        _authenticate();
      }
    });
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _breathe.dispose();
    super.dispose();
  }

  void _authenticate() {
    if (!mounted) return;
    final l = context.l10n;
    unawaited(
      context.read<AuthProvider>().authenticate(
        AuthPrompt(
          title: l.authPromptTitle,
          reason: l.authPromptReason,
          cancel: l.commonCancel,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final l = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.darkBackground
            : AppColors.lightBackground,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: Tween<double>(begin: 0.85, end: 1).animate(
                      CurvedAnimation(
                        parent: _breathe,
                        curve: Curves.easeInOut,
                      ),
                    ),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: AppColors.cardGradient(AppColors.primary),
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.sim_card_rounded,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l.lockScreenTitle,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    auth.lastError?.message(l) ?? l.lockScreenPrompt,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: auth.lastError == null
                          ? secondary
                          : theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 40),
                  FilledButton.icon(
                    onPressed: auth.isAuthenticating ? null : _authenticate,
                    icon: auth.isAuthenticating
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.fingerprint_rounded),
                    label: Text(l.lockScreenUnlock),
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
