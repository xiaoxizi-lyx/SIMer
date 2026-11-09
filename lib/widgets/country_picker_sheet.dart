import 'package:flutter/material.dart';

import '../data/countries.dart';
import '../l10n/l10n.dart';

/// 国家/地区选择器底部弹窗
class CountryPickerSheet extends StatefulWidget {
  const CountryPickerSheet({super.key});

  /// 显示国家/地区选择器并返回选中的国家代码
  static Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const CountryPickerSheet(),
    );
  }

  @override
  State<CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<CountryPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final results = CountryData.search(_query);
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.7,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface
                    .withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            l.countryPickerTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              hintText: l.countryPickerSearchHint,
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final code = results[index];
                final emoji = CountryData.countryCodeToEmoji(code);
                return ListTile(
                  leading: Text(emoji, style: const TextStyle(fontSize: 24)),
                  title: Text(
                    CountryData.name(code, l.localeName),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Text(
                    code,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface
                          .withValues(alpha: 0.4),
                    ),
                  ),
                  onTap: () => Navigator.of(context).pop(code),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
