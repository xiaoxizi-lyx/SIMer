import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/reminder_provider.dart';
import '../providers/theme_provider.dart';
import '../services/auth_service.dart';
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
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // ═══════ 主题与语言 ═══════
          _buildSectionHeader(l.settingsSectionTheme),
          _buildThemeSection(context),
          const SizedBox(height: 8),
          _buildLanguageSection(context),
          const SizedBox(height: 16),

          // ═══════ 安全 ═══════
          _buildSectionHeader(l.settingsSectionSecurity),
          _buildSecuritySection(context),
          const SizedBox(height: 16),

          // ═══════ 提醒 ═══════
          _buildSectionHeader(l.settingsSectionReminders),
          _buildReminderSection(context),
          const SizedBox(height: 16),

          // ═══════ 数据 ═══════
          _buildSectionHeader(l.settingsSectionData),
          _buildDataSection(context),
          const SizedBox(height: 16),

          // ═══════ 管理 ═══════
          _buildSectionHeader(l.settingsSectionManage),
          _buildManageSection(context),
          const SizedBox(height: 16),

          // ═══════ 关于 ═══════
          _buildSectionHeader(l.settingsSectionAbout),
          _buildAboutSection(context),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
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
    final l = context.l10n;
    final themeProvider = context.watch<ThemeProvider>();
    final currentMode = themeProvider.themeMode;

    return _settingsCard(
      context,
      children: [
        _themeTile(
          title: l.commonFollowSystem,
          icon: Icons.brightness_auto_rounded,
          isSelected: currentMode == ThemeMode.system,
          onTap: () => themeProvider.setThemeMode(ThemeMode.system),
        ),
        _thinDivider(context),
        _themeTile(
          title: l.themeLight,
          icon: Icons.light_mode_rounded,
          isSelected: currentMode == ThemeMode.light,
          onTap: () => themeProvider.setThemeMode(ThemeMode.light),
        ),
        _thinDivider(context),
        _themeTile(
          title: l.themeDark,
          icon: Icons.dark_mode_rounded,
          isSelected: currentMode == ThemeMode.dark,
          onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
        ),
      ],
    );
  }

  Widget _themeTile({
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

  Widget _buildLanguageSection(BuildContext context) {
    final l = context.l10n;
    final localeProvider = context.watch<LocaleProvider>();
    String label(AppLanguage language) =>
        language.nativeName ?? l.commonFollowSystem;

    return _settingsCard(
      context,
      children: [
        ListTile(
          leading: const Icon(Icons.translate_rounded, size: 22),
          title: Text(l.settingsLanguage, style: const TextStyle(fontSize: 15)),
          trailing: Text(label(localeProvider.language)),
          onTap: () async {
            final selected = await showDialog<AppLanguage>(
              context: context,
              builder: (ctx) => SimpleDialog(
                title: Text(l.settingsLanguage),
                children: [
                  RadioGroup<AppLanguage>(
                    groupValue: localeProvider.language,
                    onChanged: (value) => Navigator.of(ctx).pop(value),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final language in AppLanguage.values)
                          RadioListTile<AppLanguage>(
                            value: language,
                            title: Text(label(language)),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
            if (selected != null) await localeProvider.setLanguage(selected);
          },
        ),
      ],
    );
  }

  Widget _buildSecuritySection(BuildContext context) {
    final l = context.l10n;
    final auth = context.watch<AuthProvider>();

    Future<void> toggleLock(bool value) async {
      final error = await auth.setLockEnabled(
        value,
        AuthPrompt(
          title: l.authPromptTitle,
          reason: l.authPromptReason,
          cancel: l.commonCancel,
        ),
      );
      if (error != null && context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message(l))));
      }
    }

    return _settingsCard(
      context,
      children: [
        SwitchListTile.adaptive(
          secondary: const Icon(Icons.fingerprint_rounded, size: 22),
          title: Text(l.settingsAppLock, style: const TextStyle(fontSize: 15)),
          subtitle: Text(
            auth.deviceSecure
                ? l.settingsAppLockOn
                : l.settingsAppLockNeedsDeviceLock,
            style: const TextStyle(fontSize: 12),
          ),
          value: auth.lockEnabled,
          onChanged: auth.isAuthenticating ? null : toggleLock,
        ),
        if (auth.lockEnabled) ...[
          _thinDivider(context),
          ListTile(
            leading: const Icon(Icons.timer_outlined, size: 22),
            title: Text(
              l.settingsAutoLock,
              style: const TextStyle(fontSize: 15),
            ),
            subtitle: Text(
              l.settingsAutoLockSubtitle,
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Text(auth.lockTimeout.label(l)),
            onTap: () => _chooseLockTimeout(context, auth),
          ),
        ],
        _thinDivider(context),
        SwitchListTile.adaptive(
          secondary: const Icon(Icons.visibility_off_outlined, size: 22),
          title: Text(
            l.settingsPrivacyScreen,
            style: const TextStyle(fontSize: 15),
          ),
          subtitle: Text(
            l.settingsPrivacyScreenSubtitle,
            style: const TextStyle(fontSize: 12),
          ),
          value: auth.privacyProtection,
          onChanged: auth.setPrivacyProtection,
        ),
        _thinDivider(context),
        SwitchListTile.adaptive(
          secondary: const Icon(Icons.password_rounded, size: 22),
          title: Text(
            l.settingsMaskSensitive,
            style: const TextStyle(fontSize: 15),
          ),
          subtitle: Text(
            l.settingsMaskSensitiveSubtitle,
            style: const TextStyle(fontSize: 12),
          ),
          value: auth.maskSensitiveInfo,
          onChanged: auth.setMaskSensitiveInfo,
        ),
      ],
    );
  }

  Future<void> _chooseLockTimeout(
    BuildContext context,
    AuthProvider auth,
  ) async {
    final l = context.l10n;
    final selected = await showDialog<LockTimeout>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l.settingsAutoLock),
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
                    title: Text(timeout.optionLabel(l)),
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
    final l = context.l10n;
    final reminders = context.watch<ReminderProvider>();
    final time = reminders.time;
    return _settingsCard(
      context,
      children: [
        SwitchListTile.adaptive(
          secondary: const Icon(Icons.notifications_active_outlined, size: 22),
          title: Text(
            l.settingsExpiryReminders,
            style: const TextStyle(fontSize: 15),
          ),
          subtitle: Text(
            l.settingsExpiryRemindersSubtitle,
            style: const TextStyle(fontSize: 12),
          ),
          value: reminders.enabled,
          onChanged: reminders.setEnabled,
        ),
        if (reminders.enabled) ...[
          _thinDivider(context),
          ListTile(
            leading: const Icon(Icons.schedule_rounded, size: 22),
            title: Text(
              l.settingsReminderTime,
              style: const TextStyle(fontSize: 15),
            ),
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
              title: Text(
                l.settingsNotificationsOff,
                style: const TextStyle(fontSize: 15),
              ),
              subtitle: Text(
                l.settingsNotificationsOffSubtitle,
                style: const TextStyle(fontSize: 12),
              ),
              onTap: reminders.requestPermission,
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildDataSection(BuildContext context) {
    final l = context.l10n;
    return _settingsCard(
      context,
      children: [
        ListTile(
          leading: const Icon(Icons.upload_file_rounded, size: 22),
          title: Text(l.settingsExport, style: const TextStyle(fontSize: 15)),
          subtitle: Text(
            l.settingsExportSubtitle,
            style: const TextStyle(fontSize: 12),
          ),
          trailing: const Icon(Icons.chevron_right_rounded, size: 22),
          onTap: () => runExportFlow(context),
        ),
        _thinDivider(context),
        ListTile(
          leading: const Icon(Icons.download_rounded, size: 22),
          title: Text(l.settingsImport, style: const TextStyle(fontSize: 15)),
          subtitle: Text(
            l.settingsImportSubtitle,
            style: const TextStyle(fontSize: 12),
          ),
          trailing: const Icon(Icons.chevron_right_rounded, size: 22),
          onTap: () => runImportFlow(context),
        ),
      ],
    );
  }

  Widget _buildManageSection(BuildContext context) {
    final l = context.l10n;
    return _settingsCard(
      context,
      children: [
        ListTile(
          leading: const Icon(Icons.label_rounded, size: 22),
          title: Text(l.tagsTitle, style: const TextStyle(fontSize: 15)),
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
          title: Text(l.archiveTitle, style: const TextStyle(fontSize: 15)),
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
    final l = context.l10n;
    return _settingsCard(
      context,
      children: [
        ListTile(
          leading: const Icon(Icons.info_outline_rounded, size: 22),
          title: Text(
            l.appTitle,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          subtitle: FutureBuilder<String?>(
            future: PlatformService.appVersion(),
            builder: (context, snapshot) => Text(
              l.settingsVersion(snapshot.data ?? '—'),
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
        _thinDivider(context),
        ListTile(
          leading: const Icon(Icons.description_outlined, size: 22),
          title: Text(
            l.settingsSectionAbout,
            style: const TextStyle(fontSize: 15),
          ),
          subtitle: Text(
            l.settingsAboutDescription,
            style: const TextStyle(fontSize: 12),
          ),
        ),
        _thinDivider(context),
        ListTile(
          leading: const Icon(Icons.gavel_rounded, size: 22),
          title: Text(l.settingsLicenses, style: const TextStyle(fontSize: 15)),
          trailing: const Icon(Icons.chevron_right_rounded, size: 22),
          onTap: () =>
              showLicensePage(context: context, applicationName: l.appTitle),
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
}
