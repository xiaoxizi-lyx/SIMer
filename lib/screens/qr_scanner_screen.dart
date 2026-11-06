import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../services/platform_service.dart';
import '../services/qr_parser_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';

/// eSIM 二维码扫描页。
///
/// 支持相机扫描、从相册图片识别、粘贴激活码文本三种方式。
/// 用户确认后通过 [Navigator.pop] 返回 [QrParseResult]（一定是解析成功的结果）。
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );

  /// 结果弹窗打开或正在识别图片时，忽略相机的识别结果。
  bool _busy = false;

  /// 最近一次被拒绝的内容，避免对同一个非激活码二维码反复提示。
  String? _lastRejected;
  String? _hint;
  Timer? _hintTimer;

  @override
  void dispose() {
    _hintTimer?.cancel();
    unawaited(_controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.maxWidth * 0.7;
            final scanWindow = Rect.fromCenter(
              center: Offset(
                constraints.maxWidth / 2,
                constraints.maxHeight / 2 - 40,
              ),
              width: size,
              height: size,
            );
            return Stack(
              children: [
                MobileScanner(
                  controller: _controller,
                  scanWindow: scanWindow,
                  onDetect: _onDetect,
                  errorBuilder: _buildError,
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _ScanOverlayPainter(scanWindow),
                    ),
                  ),
                ),
                Positioned(
                  top: scanWindow.bottom + 24,
                  left: 24,
                  right: 24,
                  child: _buildHint(),
                ),
                _buildTopBar(context),
                _buildBottomControls(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHint() {
    final hint = _hint;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Text(
        hint ?? '将 eSIM 二维码放入框内',
        key: ValueKey(hint),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: hint == null
              ? Colors.white.withValues(alpha: 0.8)
              : AppColors.countdownWarning,
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white),
              tooltip: '关闭',
              onPressed: () => Navigator.of(context).pop(),
            ),
            const Expanded(
              child: Text(
                '扫描 eSIM 二维码',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 48), // 与左侧按钮对称
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ValueListenableBuilder<MobileScannerState>(
                valueListenable: _controller,
                builder: (context, state, _) {
                  final torch = state.torchState;
                  return _ControlButton(
                    icon: torch == TorchState.on
                        ? Icons.flash_on_rounded
                        : Icons.flash_off_rounded,
                    label: '闪光灯',
                    onTap: torch == TorchState.unavailable
                        ? null
                        : _controller.toggleTorch,
                  );
                },
              ),
              _ControlButton(
                icon: Icons.photo_library_rounded,
                label: '相册识别',
                onTap: _scanImage,
              ),
              _ControlButton(
                icon: Icons.content_paste_rounded,
                label: '粘贴激活码',
                onTap: _pasteActivationCode,
              ),
              _ControlButton(
                icon: Icons.cameraswitch_rounded,
                label: '切换镜头',
                onTap: _controller.switchCamera,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, MobileScannerException error) {
    final denied = error.errorCode == MobileScannerErrorCode.permissionDenied;
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                denied
                    ? Icons.no_photography_rounded
                    : Icons.error_outline_rounded,
                size: 56,
                color: Colors.white70,
              ),
              const SizedBox(height: 16),
              Text(
                denied ? '需要相机权限才能扫描二维码' : '相机无法启动',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                '也可以使用下方的「相册识别」或「粘贴激活码」。',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.white70),
              ),
              if (denied) ...[
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: PlatformService.openAppSettings,
                  child: const Text('去设置开启相机权限'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── 识别 ──

  void _onDetect(BarcodeCapture capture) {
    if (_busy) return;
    final raw = _firstValue(capture);
    if (raw == null || raw == _lastRejected) return;
    unawaited(_handle(raw));
  }

  Future<void> _scanImage() async {
    if (_busy) return;
    _busy = true;
    File? tempCopy;
    String? raw;
    try {
      final file = await FilePicker.pickFile(type: FileType.image);
      if (file == null) return;
      var path = file.path;
      if (path == null) {
        // 非文件 URI（如 content://）时先复制到临时文件再识别
        final dir = await getTemporaryDirectory();
        tempCopy = File(p.join(dir.path, 'simer_scan_${file.name}'));
        await tempCopy.writeAsBytes(await file.readAsBytes(), flush: true);
        path = tempCopy.path;
      }
      final capture = await _controller.analyzeImage(
        path,
        formats: const [BarcodeFormat.qrCode],
      );
      raw = capture == null ? null : _firstValue(capture);
      if (raw == null) _showHint('图片中没有识别到二维码');
    } on Exception catch (e) {
      debugPrint('识别图片失败: $e');
      _showHint('无法识别这张图片');
    } finally {
      if (tempCopy != null && tempCopy.existsSync()) tempCopy.deleteSync();
      await FilePicker.clearTemporaryFiles();
      _busy = false;
    }
    if (raw != null) await _handle(raw, fromCamera: false);
  }

  Future<void> _pasteActivationCode() async {
    if (_busy) return;
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim() ?? '';
    if (text.isEmpty) {
      _showHint('剪贴板中没有文本');
      return;
    }
    await _handle(text, fromCamera: false);
  }

  Future<void> _handle(String raw, {bool fromCamera = true}) async {
    final result = QrParserService.parse(raw);
    final code = result.code;
    if (code == null) {
      if (fromCamera) _lastRejected = raw;
      _showHint(result.errorMessage!);
      return;
    }

    _busy = true;
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (_) => _ResultSheet(code: code),
    );
    if (!mounted) return;
    if (confirmed == true) {
      Navigator.of(context).pop(result);
      return;
    }
    // 弹窗以任何方式关闭（按钮、下滑、返回键）后都恢复扫描
    _busy = false;
    _lastRejected = null;
  }

  static String? _firstValue(BarcodeCapture capture) {
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;
      if (value != null && value.trim().isNotEmpty) return value;
    }
    return null;
  }

  void _showHint(String message) {
    if (!mounted) return;
    _hintTimer?.cancel();
    setState(() => _hint = message);
    _hintTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _hint = null);
    });
  }
}

class _ResultSheet extends StatelessWidget {
  const _ResultSheet({required this.code});

  final LpaActivationCode code;

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.onSurface
        .withValues(alpha: 0.6);
    Widget field(String label, String value) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: secondary)),
          const SizedBox(height: 2),
          SelectableText(
            value,
            style: const TextStyle(
              fontFamily: AppFonts.mono,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.statusActive,
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  '识别到 eSIM 激活码',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            field('SM-DP+ 地址', code.smdpAddress),
            field('激活码（匹配 ID）', code.matchingId),
            if (code.smdpOid != null) field('SM-DP+ OID', code.smdpOid!),
            if (code.confirmationCodeRequired)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.countdownWarning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '此 eSIM 安装时需要确认码。确认码不包含在二维码中，'
                  '请向运营商获取后在表单中填写。',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('重新扫描'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('使用此信息'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: InkResponse(
        onTap: onTap,
        radius: 36,
        child: Opacity(
          opacity: enabled ? 1 : 0.4,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(height: 6),
              ExcludeSemantics(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 扫描框外的半透明遮罩与边框。
class _ScanOverlayPainter extends CustomPainter {
  const _ScanOverlayPainter(this.window);

  final Rect window;

  @override
  void paint(Canvas canvas, Size size) {
    final hole = RRect.fromRectAndRadius(window, const Radius.circular(24));
    final mask = Path.combine(
      PathOperation.difference,
      Path()..addRect(Offset.zero & size),
      Path()..addRRect(hole),
    );
    canvas
      ..drawPath(mask, Paint()..color = Colors.black54)
      ..drawRRect(
        hole,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Colors.white.withValues(alpha: 0.6),
      );
  }

  @override
  bool shouldRepaint(_ScanOverlayPainter oldDelegate) =>
      oldDelegate.window != window;
}
