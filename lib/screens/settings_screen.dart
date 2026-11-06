import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/reminder_provider.dart';
import '../providers/theme_provider.dart';
import '../services/platform_service.dart';
import '../theme/app_colors.dart';
import 'archive_screen.dart';
import 'backup_flows.dart';
import 'tag_manage_screen.dart';

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
          _buildSectionHeader(context, '提醒'),
          _buildReminderSection(context),
          const SizedBox(height: 16),

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
        style: const TextStyle(
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
    final auth = context.watch<AuthProvider>();

    Future<void> toggleLock(bool value) async {
      final error = await auth.setLockEnabled(value);
      if (error != null && context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error)));
      }
    }

    return _settingsCard(
      context,
      children: [
        SwitchListTile.adaptive(
          secondary: const Icon(Icons.fingerprint_rounded, size: 22),
          title: const Text('应用锁', style: TextStyle(fontSize: 15)),
          subtitle: Text(
            auth.deviceSecure ? '打开应用时验证指纹、面容或设备密码' : '需要先在系统设置中设置锁屏密码',
            style: const TextStyle(fontSize: 12),
          ),
          value: auth.lockEnabled,
          onChanged: auth.isAuthenticating ? null : toggleLock,
        ),
        if (auth.lockEnabled) ...[
          _thinDivider(context),
          ListTile(
            leading: const Icon(Icons.timer_outlined, size: 22),
            title: const Text('自动锁定', style: TextStyle(fontSize: 15)),
            subtitle: const Text(
              '离开应用多久后需要重新验证',
              style: TextStyle(fontSize: 12),
            ),
            trailing: Text(auth.lockTimeout.label),
            onTap: () => _chooseLockTimeout(context, auth),
          ),
        ],
        _thinDivider(context),
        SwitchListTile.adaptive(
          secondary: const Icon(Icons.visibility_off_outlined, size: 22),
          title: const Text('防窥保护', style: TextStyle(fontSize: 15)),
          subtitle: const Text(
            '在「最近任务」中隐藏应用内容；Android 12 及以下会同时禁止截屏',
            style: TextStyle(fontSize: 12),
          ),
          value: auth.privacyProtection,
          onChanged: auth.setPrivacyProtection,
        ),
      ],
    );
  }

  Future<void> _chooseLockTimeout(
    BuildContext context,
    AuthProvider auth,
  ) async {
    final selected = await showDialog<LockTimeout>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('自动锁定'),
        children: [
          RadioGroup<LockTimeout>(
            groupValue: auth.lockTimeout,
            onChanged: (value) => Navigator.of(ctx).pop(value),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final timeout in LockTimeout.values)
                  RadioListTile<LockTimeout>(
                    value: timeout,
                    title: Text(
                      timeout == LockTimeout.immediately
                          ? '离开应用后立即'
                          : '离开应用 ${timeout.label}',
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    if (selected != null) await auth.setLockTimeout(selected);
  }

  Widget _buildReminderSection(BuildContext context) {
    final reminders = context.watch<ReminderProvider>();
    final time = reminders.time;
    return _settingsCard(
      context,
      children: [
        SwitchListTile.adaptive(
          secondary: const Icon(Icons.notifications_active_outlined, size: 22),
          title: const Text('到期提醒', style: TextStyle(fontSize: 15)),
          subtitle: const Text(
            '在卡片提前提醒日、到期当天与过期次日各提醒一次',
            style: TextStyle(fontSize: 12),
          ),
          value: reminders.enabled,
          onChanged: reminders.setEnabled,
        ),
        if (reminders.enabled) ...[
          _thinDivider(context),
          ListTile(
            leading: const Icon(Icons.schedule_rounded, size: 22),
            title: const Text('提醒时间', style: TextStyle(fontSize: 15)),
            trailing: Text(time.format(context)),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: time,
              );
              if (picked != null) await reminders.setTime(picked);
            },
          ),
          if (!reminders.permissionGranted) ...[
            _thinDivider(context),
            ListTile(
              leading: Icon(
                Icons.notifications_off_outlined,
                size: 22,
                color: Theme.of(context).colorScheme.error,
              ),
              title: const Text('通知权限未开启', style: TextStyle(fontSize: 15)),
              subtitle: const Text(
                '未开启时提醒不会显示，点击授权',
                style: TextStyle(fontSize: 12),
              ),
              onTap: reminders.requestPermission,
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildDataSection(BuildContext context) {
    return _settingsCard(
      context,
      children: [
        ListTile(
          leading: const Icon(Icons.upload_file_rounded, size: 22),
          title: const Text('导出备份', style: TextStyle(fontSize: 15)),
          subtitle: const Text(
            '手动导出全部数据，用于迁移到新设备',
            style: TextStyle(fontSize: 12),
          ),
          trailing: const Icon(Icons.chevron_right_rounded, size: 22),
          onTap: () => _exportData(context),
        ),
        _thinDivider(context),
        ListTile(
          leading: const Icon(Icons.download_rounded, size: 22),
          title: const Text('导入备份', style: TextStyle(fontSize: 15)),
          subtitle: const Text(
            '从 SIMer 备份文件恢复数据',
            style: TextStyle(fontSize: 12),
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
          title: const Text('标签管理', style: TextStyle(fontSize: 15)),
          trailing: const Icon(Icons.chevron_right_rounded, size: 22),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const TagManageScreen()),
            );
          },
        ),
        _thinDivider(context),
        ListTile(
          leading: const Icon(Icons.archive_rounded, size: 22),
          title: const Text('归档', style: TextStyle(fontSize: 15)),
          trailing: const Icon(Icons.chevron_right_rounded, size: 22),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const ArchiveScreen()),
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
          title: const Text(
            'SIMer',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          subtitle: FutureBuilder<String?>(
            future: PlatformService.appVersion(),
            builder: (context, snapshot) => Text(
              '版本 ${snapshot.data ?? '—'}',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
        _thinDivider(context),
        const ListTile(
          leading: Icon(Icons.description_outlined, size: 22),
          title: Text('关于', style: TextStyle(fontSize: 15)),
          subtitle: Text(
            'SIM卡信息记录管理，安全存储你的SIM卡与eSIM信息。',
            style: TextStyle(fontSize: 12),
          ),
        ),
        _thinDivider(context),
        ListTile(
          leading: const Icon(Icons.gavel_rounded, size: 22),
          title: const Text('开源许可', style: TextStyle(fontSize: 15)),
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
