import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 内置字体及其许可证文件。
const _bundledFontLicenses = <(String, String)>[
  ('Inter', 'assets/fonts/OFL-Inter.txt'),
  ('Roboto Mono', 'assets/fonts/OFL-RobotoMono.txt'),
];

/// 把随应用分发的字体许可证（SIL OFL 1.1）注册到 [LicenseRegistry]，
/// 使其出现在「设置 → 关于 → 开源许可」页面中。
void registerBundledLicenses() {
  LicenseRegistry.addLicense(() async* {
    for (final (font, asset) in _bundledFontLicenses) {
      final text = await rootBundle.loadString(asset);
      yield LicenseEntryWithLineBreaks(<String>[font], text);
    }
  });
}
