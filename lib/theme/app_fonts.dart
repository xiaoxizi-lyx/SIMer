/// 内置字体（assets/fonts，均为 SIL OFL 1.1 授权）。
///
/// 字体随 APK 打包，运行时不会联网下载。
abstract final class AppFonts {
  /// 界面主字体（拉丁字符；中文由系统字体回退显示）。
  static const String sans = 'Inter';

  /// 等宽字体，用于 ICCID、激活码等需要逐位对齐的内容。
  static const String mono = 'RobotoMono';
}
