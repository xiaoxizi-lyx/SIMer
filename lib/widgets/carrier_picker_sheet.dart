import 'package:flutter/material.dart';

import '../data/carriers.dart';
import '../data/countries.dart';
import '../models/carrier.dart';

/// 运营商选择器底部弹窗。
///
/// 当前国家/地区的运营商排在最前；搜索同时匹配运营商名称、代码与国家名称；
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
            final country = CountryData.countries[c.countryCode] ?? '';
            return c.name.toLowerCase().contains(query) ||
                c.code.toLowerCase().contains(query) ||
                c.countryCode.toLowerCase() == query ||
                country.contains(query);
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
    final results = _results();
    final query = _query.trim();
    final exactMatch = results.any(
      (c) => c.name.toLowerCase() == query.toLowerCase(),
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
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                '选择运营商',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                autofocus: false,
                decoration: const InputDecoration(
                  hintText: '搜索运营商或国家，或输入自定义名称',
                  prefixIcon: Icon(Icons.search_rounded, size: 20),
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
                      title: Text('使用「$query」作为自定义运营商'),
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
                        carrier.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        CountryData.countries[carrier.countryCode] ??
                            carrier.countryCode,
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
                    const ListTile(title: Text('没有预置运营商')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
