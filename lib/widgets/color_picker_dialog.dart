import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../theme/app_colors.dart';

/// 卡片颜色选择对话框
///
/// 显示预设颜色池、运营商推荐色、自定义颜色选择
class ColorPickerDialog extends StatefulWidget {
  final Color currentColor;
  final Color? carrierDefaultColor;
  final String? carrierName;

  const ColorPickerDialog({
    super.key,
    required this.currentColor,
    this.carrierDefaultColor,
    this.carrierName,
  });

  /// 便捷方法：弹出对话框并返回选中颜色
  static Future<Color?> show(
    BuildContext context, {
    required Color currentColor,
    Color? carrierDefaultColor,
    String? carrierName,
  }) {
    return showDialog<Color>(
      context: context,
      builder: (context) => ColorPickerDialog(
        currentColor: currentColor,
        carrierDefaultColor: carrierDefaultColor,
        carrierName: carrierName,
      ),
    );
  }

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late Color _selectedColor;
  bool _showCustomPicker = false;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.currentColor;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '选择卡片颜色',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // ── 运营商推荐色 ──
            if (widget.carrierDefaultColor != null) ...[
              Text(
                '${widget.carrierName ?? '运营商'}推荐',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = widget.carrierDefaultColor!;
                    _showCustomPicker = false;
                  });
                },
                child: _buildSwatch(widget.carrierDefaultColor!, size: 44),
              ),
              const SizedBox(height: 16),
            ],

            // ── 预设颜色池 ──
            Text(
              '预设颜色',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: AppColors.cardColorPool.map((color) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                      _showCustomPicker = false;
                    });
                  },
                  child: _buildSwatch(color),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // ── 自定义颜色 ──
            GestureDetector(
              onTap: () {
                setState(() => _showCustomPicker = !_showCustomPicker);
              },
              child: Row(
                children: [
                  Icon(
                    _showCustomPicker
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '自定义颜色',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            // ── 自定义颜色选择器 ──
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: _showCustomPicker
                  ? Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: SizedBox(
                        height: 260,
                        child: HueRingPicker(
                          pickerColor: _selectedColor,
                          onColorChanged: (color) {
                            setState(() => _selectedColor = color);
                          },
                          enableAlpha: false,
                          displayThumbColor: true,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),

            // ── 预览与操作 ──
            Row(
              children: [
                // 当前选中预览
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _selectedColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: _selectedColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('取消'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(_selectedColor),
                  child: const Text('确定'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwatch(Color color, {double size = 36}) {
    final isSelected = _selectedColor == color;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size / 3),
        border: isSelected
            ? Border.all(color: Colors.white, width: 2.5)
            : null,
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: isSelected
          ? Icon(
              Icons.check_rounded,
              color: AppColors.textOnColor(color),
              size: size * 0.5,
            )
          : null,
    );
  }
}
