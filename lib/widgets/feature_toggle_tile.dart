import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/feature_set.dart';

/// 功能开关列表项（用于添加/编辑表单）
///
/// 左侧功能名，右侧开关，启用后展开文本框输入备注
class FeatureToggleTile extends StatefulWidget {
  final String featureName;
  final FeatureItem featureItem;
  final ValueChanged<FeatureItem> onChanged;

  const FeatureToggleTile({
    super.key,
    required this.featureName,
    required this.featureItem,
    required this.onChanged,
  });

  @override
  State<FeatureToggleTile> createState() => _FeatureToggleTileState();
}

class _FeatureToggleTileState extends State<FeatureToggleTile>
    with SingleTickerProviderStateMixin {
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.featureItem.note ?? '');
  }

  @override
  void didUpdateWidget(covariant FeatureToggleTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.featureItem.note != widget.featureItem.note) {
      _noteController.text = widget.featureItem.note ?? '';
    }
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
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          title: Text(
            widget.featureName,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: Switch.adaptive(
            value: isSupported,
            onChanged: (value) {
              widget.onChanged(widget.featureItem.copyWith(
                supported: value,
                note: value ? widget.featureItem.note : null,
              ));
            },
          ),
        ),
        // ── 展开的备注输入框 ──
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: isSupported
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
                  child: TextField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      hintText: '备注（可选）',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    style: GoogleFonts.inter(fontSize: 13),
                    onChanged: (value) {
                      widget.onChanged(widget.featureItem.copyWith(
                        note: value.isEmpty ? null : value,
                      ));
                    },
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
