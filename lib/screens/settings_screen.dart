import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/sim_card_provider.dart';
import '../services/backup_service.dart';
import '../theme/app_colors.dart';
import 'tag_manage_screen.dart';
import 'archive_screen.dart';

/// 设置页面
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
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
        style: GoogleFonts.inter(
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
        style: GoogleFonts.inter(
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
          title: Text(
            '启用生物识别锁',
            style: GoogleFonts.inter(fontSize: 15),
          ),
          subtitle: !authProvider.biometricAvailable
              ? Text(
                  '设备不支持生物识别',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.countdownDanger,
                  ),
                )
              : null,
          trailing: Switch.adaptive(
            value: authProvider.biometricEnabled,
            onChanged: authProvider.biometricAvailable
                ? (value) async {
                    final error =
                        await authProvider.setBiometricEnabled(value);
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
          title: Text(
            '导出JSON',
            style: GoogleFonts.inter(fontSize: 15),
          ),
          subtitle: Text(
            '将所有SIM卡数据导出为JSON文件',
            style: GoogleFonts.inter(fontSize: 12),
          ),
          trailing: const Icon(Icons.chevron_right_rounded, size: 22),
          onTap: () => _exportData(context),
        ),
        _thinDivider(context),
        ListTile(
          leading: const Icon(Icons.download_rounded, size: 22),
          title: Text(
            '导入JSON',
            style: GoogleFonts.inter(fontSize: 15),
          ),
          subtitle: Text(
            '从JSON文件导入SIM卡数据',
            style: GoogleFonts.inter(fontSize: 12),
          ),
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
          title: Text(
            '标签管理',
            style: GoogleFonts.inter(fontSize: 15),
          ),
          trailing: const Icon(Icons.chevron_right_rounded, size: 22),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TagManageScreen()),
            );
          },
        ),
        _thinDivider(context),
        ListTile(
          leading: const Icon(Icons.archive_rounded, size: 22),
          title: Text(
            '归档',
            style: GoogleFonts.inter(fontSize: 15),
          ),
          trailing: const Icon(Icons.chevron_right_rounded, size: 22),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ArchiveScreen()),
            );
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
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            '版本 1.0.0',
            style: GoogleFonts.inter(fontSize: 12),
          ),
        ),
        _thinDivider(context),
        ListTile(
          leading: const Icon(Icons.description_outlined, size: 22),
          title: Text(
            '关于',
            style: GoogleFonts.inter(fontSize: 15),
          ),
          subtitle: Text(
            'SIM卡信息记录管理，安全存储你的SIM卡与eSIM信息。',
            style: GoogleFonts.inter(fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _settingsCard(BuildContext context,
      {required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              Theme.of(context).dividerTheme.color ?? AppColors.lightDivider,
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

  Future<void> _exportData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('导出数据'),
        content: const Text(
            '将所有SIM卡及标签数据导出为JSON文件。导出后可通过系统分享面板发送到其他设备或保存到本地文件。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('导出'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final result = await BackupService.exportToJson();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _importData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('导入数据'),
        content: const Text(
            '从JSON备份文件导入SIM卡及标签数据。注意：相同UUID的记录将被更新覆盖，不存在的记录将被新增。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('选择文件'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final pickResult = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['json'],
        );

        if (pickResult != null &&
            pickResult.files.single.path != null &&
            context.mounted) {
          final filePath = pickResult.files.single.path!;
          final importResult = await BackupService.importFromJson(filePath);

          if (context.mounted) {
            final messenger = ScaffoldMessenger.of(context);
            if (importResult.isSuccess) {
              await context.read<SimCardProvider>().loadAll();
            }
            messenger.showSnackBar(
              SnackBar(
                content: Text(importResult.message),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('选择文件失败: $e'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
}
