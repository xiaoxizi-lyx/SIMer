import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import 'tag_manage_screen.dart';
import 'archive_screen.dart';
import 'backup_flows.dart';

/// 设置页面
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // ═══════ 主题 ═══════
          _buildSectionHeader(context, '主题'),
          _buildThemeSection(context),
          const SizedBox(height: 16),

          // ═══════ 安全 ═══════
          _buildSectionHeader(context, '安全'),
          _buildSecuritySection(context),
          const SizedBox(height: 16),

          // ═══════ 数据 ═══════
          _buildSectionHeader(context, '数据'),
          _buildDataSection(context),
          const SizedBox(height: 16),

          // ═══════ 管理 ═══════
          _buildSectionHeader(context, '管理'),
          _buildManageSection(context),
          const SizedBox(height: 16),

          // ═══════ 关于 ═══════
          _buildSectionHeader(context, '关于'),
          _buildAboutSection(context),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildThemeSection(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final currentMode = themeProvider.themeMode;

    return _settingsCard(
      context,
      children: [
        _themeTile(
          context,
          title: '跟随系统',
          icon: Icons.brightness_auto_rounded,
          isSelected: currentMode == ThemeMode.system,
          onTap: () => themeProvider.setThemeMode(ThemeMode.system),
        ),
        _thinDivider(context),
        _themeTile(
          context,
          title: '浅色',
          icon: Icons.light_mode_rounded,
          isSelected: currentMode == ThemeMode.light,
          onTap: () => themeProvider.setThemeMode(ThemeMode.light),
        ),
        _thinDivider(context),
        _themeTile(
          context,
          title: '深色',
          icon: Icons.dark_mode_rounded,
          isSelected: currentMode == ThemeMode.dark,
          onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
        ),
      ],
    );
  }

  Widget _themeTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 22),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_rounded, color: AppColors.primary, size: 22)
          : null,
      onTap: onTap,
    );
  }

  Widget _buildSecuritySection(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return _settingsCard(
      context,
      children: [
        ListTile(
          leading: const Icon(Icons.fingerprint_rounded, size: 22),
          title: Text('启用生物识别锁', style: TextStyle(fontSize: 15)),
          subtitle: !authProvider.biometricAvailable
              ? Text(
                  '设备不支持生物识别',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.countdownDanger,
                  ),
                )
              : null,
          trailing: Switch.adaptive(
            value: authProvider.biometricEnabled,
            onChanged: authProvider.biometricAvailable
                ? (value) async {
                    final error = await authProvider.setBiometricEnabled(value);
                    if (error != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(error),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildDataSection(BuildContext context) {
    return _settingsCard(
      context,
      children: [
        ListTile(
          leading: const Icon(Icons.upload_file_rounded, size: 22),
          title: Text('导出备份', style: TextStyle(fontSize: 15)),
          subtitle: Text('手动导出全部数据，用于迁移到新设备', style: TextStyle(fontSize: 12)),
          trailing: const Icon(Icons.chevron_right_rounded, size: 22),
          onTap: () => _exportData(context),
        ),
        _thinDivider(context),
        ListTile(
          leading: const Icon(Icons.download_rounded, size: 22),
          title: Text('导入备份', style: TextStyle(fontSize: 15)),
          subtitle: Text('从 SIMer 备份文件恢复数据', style: TextStyle(fontSize: 12)),
          trailing: const Icon(Icons.chevron_right_rounded, size: 22),
          onTap: () => _importData(context),
        ),
      ],
    );
  }

  Widget _buildManageSection(BuildContext context) {
    return _settingsCard(
      context,
      children: [
        ListTile(
          leading: const Icon(Icons.label_rounded, size: 22),
          title: Text('标签管理', style: TextStyle(fontSize: 15)),
          trailing: const Icon(Icons.chevron_right_rounded, size: 22),
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const TagManageScreen()));
          },
        ),
        _thinDivider(context),
        ListTile(
          leading: const Icon(Icons.archive_rounded, size: 22),
          title: Text('归档', style: TextStyle(fontSize: 15)),
          trailing: const Icon(Icons.chevron_right_rounded, size: 22),
          onTap: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const ArchiveScreen()));
          },
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return _settingsCard(
      context,
      children: [
        ListTile(
          leading: const Icon(Icons.info_outline_rounded, size: 22),
          title: Text(
            'SIMer',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          subtitle: Text('版本 1.0.0', style: TextStyle(fontSize: 12)),
        ),
        _thinDivider(context),
        ListTile(
          leading: const Icon(Icons.description_outlined, size: 22),
          title: Text('关于', style: TextStyle(fontSize: 15)),
          subtitle: Text(
            'SIM卡信息记录管理，安全存储你的SIM卡与eSIM信息。',
            style: TextStyle(fontSize: 12),
          ),
        ),
        _thinDivider(context),
        ListTile(
          leading: const Icon(Icons.gavel_rounded, size: 22),
          title: Text('开源许可', style: TextStyle(fontSize: 15)),
          trailing: const Icon(Icons.chevron_right_rounded, size: 22),
          onTap: () =>
              showLicensePage(context: context, applicationName: 'SIMer'),
        ),
      ],
    );
  }

  Widget _settingsCard(BuildContext context, {required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerTheme.color ?? AppColors.lightDivider,
          width: 0.5,
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _thinDivider(BuildContext context) {
    return Divider(
      height: 0.5,
      indent: 56,
      color: Theme.of(context).dividerTheme.color ?? AppColors.lightDivider,
    );
  }

  Future<void> _exportData(BuildContext context) => runExportFlow(context);

  Future<void> _importData(BuildContext context) => runImportFlow(context);
}
