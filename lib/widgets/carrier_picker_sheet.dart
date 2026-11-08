import 'package:flutter/material.dart';

import '../data/carriers.dart';
import '../data/countries.dart';
import '../l10n/l10n.dart';
import '../models/carrier.dart';

/// 运营商选择器底部弹窗。
///
/// 当前国家/地区的运营商排在最前；搜索同时匹配运营商的中英文名称、代码与国家名称；
/// 输入的名称没有对应的预置运营商时，可直接作为自定义运营商使用。
class CarrierPickerSheet extends StatefulWidget {
  const CarrierPickerSheet({super.key, this.countryCode});

  final String? countryCode;

  static Future<CarrierChoice?> show(
    BuildContext context, {
    String? countryCode,
  }) {
    return showModalBottomSheet<CarrierChoice>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => CarrierPickerSheet(countryCode: countryCode),
    );
  }

  @override
  State<CarrierPickerSheet> createState() => _CarrierPickerSheetState();
}

class _CarrierPickerSheetState extends State<CarrierPickerSheet> {
  String _query = '';

  List<Carrier> _results() {
    final query = _query.trim().toLowerCase();
    final matches = query.isEmpty
        ? CarrierData.carriers
        : CarrierData.carriers.where((c) {
            return c.name.toLowerCase().contains(query) ||
                (c.nameEn?.toLowerCase().contains(query) ?? false) ||
                c.code.toLowerCase().contains(query) ||
                c.countryCode.toLowerCase() == query ||
                CountryData.name(c.countryCode, 'zh').contains(query) ||
                CountryData.name(
                  c.countryCode,
                  'en',
                ).toLowerCase().contains(query);
          }).toList();
    final home = widget.countryCode;
    if (home == null) return matches;
    // 稳定排序：当前国家/地区的运营商在前
    return [
      ...matches.where((c) => c.countryCode == home),
      ...matches.where((c) => c.countryCode != home),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final results = _results();
    final query = _query.trim();
    final exactMatch = results.any(
      (c) =>
          c.name.toLowerCase() == query.toLowerCase() ||
          c.nameEn?.toLowerCase() == query.toLowerCase(),
    );
    final mediaQuery = MediaQuery.of(context);

    return Padding(
      // 键盘弹出时整体上移，避免列表被遮挡
      padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
      child: SizedBox(
        height: mediaQuery.size.height * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                l.carrierPickerTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                autofocus: false,
                decoration: InputDecoration(
                  hintText: l.carrierPickerSearchHint,
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                ),
                onChanged: (value) => setState(() => _query = value),
                onSubmitted: (value) {
                  final name = value.trim();
                  if (name.isNotEmpty && !exactMatch) {
                    Navigator.of(context).pop(CustomCarrierChoice(name));
                  }
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: [
                  if (query.isNotEmpty && !exactMatch)
                    ListTile(
                      leading: const Icon(Icons.edit_rounded),
                      title: Text(l.carrierPickerUseCustom(query)),
                      onTap: () =>
                          Navigator.of(context).pop(CustomCarrierChoice(query)),
                    ),
                  for (final carrier in results)
                    ListTile(
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: carrier.themeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          CountryData.countryCodeToEmoji(carrier.countryCode),
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      title: Text(
                        carrier.localizedName(l.localeName),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        CountryData.name(carrier.countryCode, l.localeName),
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: carrier.themeColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      onTap: () =>
                          Navigator.of(context)
                              .pop(PresetCarrierChoice(carrier)),
                    ),
                  if (results.isEmpty && query.isEmpty)
                    ListTile(title: Text(l.carrierPickerEmpty)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
