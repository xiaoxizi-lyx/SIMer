import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/carrier.dart';
import '../data/carriers.dart';
import '../data/countries.dart';
import '../theme/app_colors.dart';

/// 运营商选择器底部弹窗
class CarrierPickerSheet extends StatefulWidget {
  const CarrierPickerSheet({super.key});

  /// 显示运营商选择器并返回选中的运营商
  static Future<Carrier?> show(BuildContext context) {
    return showModalBottomSheet<Carrier>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const CarrierPickerSheet(),
    );
  }

  @override
  State<CarrierPickerSheet> createState() => _CarrierPickerSheetState();
}

class _CarrierPickerSheetState extends State<CarrierPickerSheet> {
  String _query = '';
  final _customController = TextEditingController();
  bool _showCustomInput = false;

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = CarrierData.search(_query);
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.7,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 拖拽指示器
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            '选择运营商',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          // 搜索框
          TextField(
            decoration: InputDecoration(
              hintText: '搜索运营商…',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: IconButton(
                icon: const Icon(Icons.edit_rounded, size: 20),
                tooltip: '自定义运营商',
                onPressed: () {
                  setState(() => _showCustomInput = !_showCustomInput);
                },
              ),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 8),

          // 自定义输入
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: _showCustomInput
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _customController,
                            decoration: const InputDecoration(
                              hintText: '输入自定义运营商名称',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            final name = _customController.text.trim();
                            if (name.isNotEmpty) {
                              Navigator.of(context).pop(Carrier(
                                code: 'custom_$name',
                                name: name,
                                countryCode: 'CN',
                                themeColor: AppColors.cardColorPool.first,
                              ));
                            }
                          },
                          child: const Text('确定'),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // 列表
          Expanded(
            child: ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final carrier = results[index];
                final emoji =
                    CountryData.countryCodeToEmoji(carrier.countryCode);
                return ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: carrier.themeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(emoji,
                          style: const TextStyle(fontSize: 18)),
                    ),
                  ),
                  title: Text(
                    carrier.name,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    CountryData.countries[carrier.countryCode] ??
                        carrier.countryCode,
                    style: GoogleFonts.inter(fontSize: 12),
                  ),
                  trailing: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: carrier.themeColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  onTap: () => Navigator.of(context).pop(carrier),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
