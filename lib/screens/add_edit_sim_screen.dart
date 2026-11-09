import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../l10n/l10n.dart';
import '../models/enums.dart';
import '../models/sim_card.dart';
import '../models/tag.dart';
import '../providers/reminder_provider.dart';
import '../providers/sim_card_provider.dart';
import '../services/qr_parser_service.dart';
import 'qr_scanner_screen.dart';
import 'sim_form/form_widgets.dart';
import 'sim_form/sections/appearance_section.dart';
import 'sim_form/sections/basic_info_section.dart';
import 'sim_form/sections/esim_section.dart';
import 'sim_form/sections/features_section.dart';
import 'sim_form/sections/usage_section.dart';
import 'sim_form/sections/validity_section.dart';
import 'sim_form/sim_form_draft.dart';

/// 添加 / 编辑 SIM 卡页面。
///
/// 返回值：保存成功时 pop `true`。
class AddEditSimScreen extends StatefulWidget {
  const AddEditSimScreen({super.key, this.simCard});

  final SimCard? simCard;

  bool get isEditing => simCard != null;

  @override
  State<AddEditSimScreen> createState() => _AddEditSimScreenState();
}

class _AddEditSimScreenState extends State<AddEditSimScreen> {
  final _formKey = GlobalKey<FormState>();
  late final SimFormDraft _draft;
  SimFormSection? _expanded = SimFormSection.basic;

  /// 首次点击保存且校验失败后，开始显示各字段与分区的错误。
  bool _showErrors = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final usedColors = context.read<SimCardProvider>().usedCardColors;
    final card = widget.simCard;
    _draft = card == null
        ? SimFormDraft.create(usedColors: usedColors)
        : SimFormDraft.edit(card, usedColors: usedColors);
  }

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tags = context.watch<SimCardProvider>().tags;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_confirmLeave());
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.isEditing
                ? context.l10n.formEditTitle
                : context.l10n.formAddTitle,
          ),
          actions: [
            if (_saving)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              TextButton(
                onPressed: _save,
                child: Text(
                  context.l10n.commonSave,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        body: Form(
          key: _formKey,
          autovalidateMode: _showErrors
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: ListenableBuilder(
            listenable: _draft,
            builder: (context, _) {
              final invalid = _showErrors
                  ? _draft.invalidSections()
                  : const <SimFormSection>{};
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                child: Column(
                  spacing: 8,
                  children: [
                    for (final section in SimFormSection.values)
                      if (section != SimFormSection.esim ||
                          _draft.type == SimType.esim)
                        FormSectionCard(
                          key: ValueKey(section),
                          section: section,
                          expanded: _expanded == section,
                          hasError: invalid.contains(section),
                          onToggle: () => setState(
                            () => _expanded = _expanded == section
                                ? null
                                : section,
                          ),
                          children: [_sectionBody(section, tags)],
                        ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _sectionBody(SimFormSection section, List<Tag> tags) =>
      switch (section) {
        SimFormSection.basic => BasicInfoSection(
          draft: _draft,
          showErrors: _showErrors,
        ),
        SimFormSection.validity => ValiditySection(
          draft: _draft,
          showErrors: _showErrors,
        ),
        SimFormSection.usage => UsageSection(draft: _draft),
        SimFormSection.features => FeaturesSection(draft: _draft),
        SimFormSection.esim => EsimSection(draft: _draft, onScan: _scan),
        SimFormSection.appearance => AppearanceSection(
          draft: _draft,
          tags: tags,
        ),
      };

  Future<void> _scan() async {
    final result = await Navigator.of(context).push<QrParseResult>(
      MaterialPageRoute(builder: (_) => const QrScannerScreen()),
    );
    if (result != null) _draft.applyActivationCode(result);
  }

  Future<void> _save() async {
    if (_saving) return;
    FocusScope.of(context).unfocus();

    final invalid = _draft.invalidSections();
    final fieldsValid = _formKey.currentState!.validate();
    if (invalid.isNotEmpty || !fieldsValid) {
      setState(() {
        _showErrors = true;
        if (invalid.isNotEmpty) {
          _expanded = SimFormSection.values.firstWhere(invalid.contains);
        }
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.l10n.formCheckErrors)));
      return;
    }

    setState(() => _saving = true);
    final provider = context.read<SimCardProvider>();
    final reminders = context.read<ReminderProvider>();
    try {
      final card = _draft.build(newUuid: const Uuid().v4());
      if (_draft.isEditing) {
        await provider.updateSimCard(card);
      } else {
        await provider.addSimCard(card);
      }
      unawaited(reminders.onCardSaved(card));
      if (mounted) Navigator.of(context).pop(true);
    } on Exception catch (e) {
      debugPrint('保存失败: $e');
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.l10n.formSaveFailed)));
    }
  }

  Future<void> _confirmLeave() async {
    if (_saving) return;
    final navigator = Navigator.of(context);
    if (!_draft.hasChanges) {
      navigator.pop();
      return;
    }
    final l = context.l10n;
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.formDiscardTitle),
        content: Text(l.formDiscardMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.formKeepEditing),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.formDiscard),
          ),
        ],
      ),
    );
    if (discard == true && mounted) navigator.pop();
  }
}
