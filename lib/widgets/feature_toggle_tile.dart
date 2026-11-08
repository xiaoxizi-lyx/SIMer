import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../models/feature_set.dart';

/// 功能开关列表项（用于添加/编辑表单）
///
/// 左侧功能名，右侧开关，启用后展开文本框输入备注
class FeatureToggleTile extends StatefulWidget {
  const FeatureToggleTile({
    super.key,
    required this.featureName,
    required this.featureItem,
    required this.onChanged,
  });

  final String featureName;
  final FeatureItem featureItem;
  final ValueChanged<FeatureItem> onChanged;

  @override
  State<FeatureToggleTile> createState() => _FeatureToggleTileState();
}

class _FeatureToggleTileState extends State<FeatureToggleTile> {
  late final TextEditingController _noteController = TextEditingController(
    text: widget.featureItem.note ?? '',
  );

  @override
  void didUpdateWidget(covariant FeatureToggleTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 只同步外部带来的变化；用户正在输入时文本相同，不能重设（否则光标会跳到末尾）
    final note = widget.featureItem.note ?? '';
    if (note != _noteController.text) _noteController.text = note;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSupported = widget.featureItem.supported;

    return Column(
      children: [
        SwitchListTile.adaptive(
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          title: Text(
            widget.featureName,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          value: isSupported,
          // 关闭功能时一并清除备注
          onChanged: (value) => widget.onChanged(
            FeatureItem(
              supported: value,
              note: value ? widget.featureItem.note : null,
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: isSupported
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
                  child: TextField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      hintText: context.l10n.featureNoteHint,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    style: const TextStyle(fontSize: 13),
                    onChanged: (value) => widget.onChanged(
                      widget.featureItem.copyWith(
                        note: value.trim().isEmpty ? null : value,
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
