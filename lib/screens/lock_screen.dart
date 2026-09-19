import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';

/// 生物识别锁屏页面
///
/// App 启动时如果开启了生物识别锁，展示此页面
/// 自动触发认证，成功后跳转到首页
class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _breatheController;
  late Animation<double> _breatheAnimation;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _breatheController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _breatheAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );
    _breatheController.repeat(reverse: true);

    // 自动触发认证
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerAuth();
    });
  }

  @override
  void dispose() {
    _breatheController.dispose();
    super.dispose();
  }

  Future<void> _triggerAuth() async {
    if (_isAuthenticating) return;
    setState(() => _isAuthenticating = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.authenticate();
      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (_) {
      // 认证失败或取消
    } finally {
      if (mounted) {
        setState(() => _isAuthenticating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final secondaryColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── App 图标 ──
              AnimatedBuilder(
                animation: _breatheAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _breatheAnimation.value,
                    child: child,
                  );
                },
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
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.sim_card_rounded,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── App 名称 ──
              Text(
                'SIMer',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),

              // ── 提示信息 ──
              Text(
                '请验证身份',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: secondaryColor,
                ),
              ),
              const SizedBox(height: 48),

              // ── 指纹按钮 ──
              GestureDetector(
                onTap: _isAuthenticating ? null : _triggerAuth,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: _isAuthenticating
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : AppColors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: _isAuthenticating
                      ? const Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator.adaptive(
                            strokeWidth: 2.5,
                          ),
                        )
                      : Icon(
                          Icons.fingerprint_rounded,
                          size: 36,
                          color: AppColors.primary,
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // ── 点击提示 ──
              if (!_isAuthenticating)
                Text(
                  '点击验证',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: secondaryColor.withValues(alpha: 0.7),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
