import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/qr_parser_service.dart';

/// QR 码扫描页面
///
/// 用于扫描 eSIM LPA 格式的 QR 码，解析后返回 SM-DP+ 地址和激活码
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  late MobileScannerController _scannerController;
  bool _hasScanned = false;
  bool _flashOn = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── 相机预览 ──
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),

          // ── 扫描区域覆盖层 ──
          _buildOverlay(context),

          // ── 顶部操作栏 ──
          _buildTopBar(context),

          // ── 底部控制按钮 ──
          _buildBottomControls(),
        ],
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scanAreaSize = constraints.maxWidth * 0.7;
        final top = (constraints.maxHeight - scanAreaSize) / 2 - 40;
        final left = (constraints.maxWidth - scanAreaSize) / 2;

        return Stack(
          children: [
            // 半透明遮罩
            ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Colors.black54,
                BlendMode.srcOut,
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      backgroundBlendMode: BlendMode.dstOut,
                    ),
                  ),
                  Positioned(
                    top: top,
                    left: left,
                    child: Container(
                      width: scanAreaSize,
                      height: scanAreaSize,
                      decoration: BoxDecoration(
                        color: Colors.red, // 会被 srcOut 移除
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 扫描框边框
            Positioned(
              top: top,
              left: left,
              child: Container(
                width: scanAreaSize,
                height: scanAreaSize,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
            // 提示文字
            Positioned(
              top: top + scanAreaSize + 24,
              left: 0,
              right: 0,
              child: Text(
                '将eSIM QR码放入框内',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // 关闭按钮
            _circleButton(
              icon: Icons.close_rounded,
              onTap: () => Navigator.of(context).pop(),
            ),
            const Spacer(),
            Text(
              '扫描eSIM QR码',
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            const SizedBox(width: 44), // 平衡布局
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
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 闪光灯
              _circleButton(
                icon: _flashOn
                    ? Icons.flash_on_rounded
                    : Icons.flash_off_rounded,
                onTap: () {
                  _scannerController.toggleTorch();
                  setState(() => _flashOn = !_flashOn);
                },
              ),
              // 切换摄像头
              _circleButton(
                icon: Icons.cameraswitch_rounded,
                onTap: () => _scannerController.switchCamera(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    final rawData = barcode.rawValue!;
    final parsed = _parseLpaQrCode(rawData);

    if (parsed != null) {
      _hasScanned = true;
      _showResultSheet(rawData, parsed);
    }
  }

  /// 解析 LPA 格式 QR 码，优先使用 QrParserService 解析标准 LPA 数据，并提供容错回退
  Map<String, String>? _parseLpaQrCode(String rawData) {
    final trimmed = rawData.trim();
    if (trimmed.isEmpty) return null;

    final result = QrParserService.parse(trimmed);
    if (result.isSuccess) {
      return {
        'rspServer': result.smdpAddress ?? '',
        'activationCode': result.matchingId ?? '',
        if (result.confirmationCode != null &&
            result.confirmationCode!.isNotEmpty)
          'confirmationCode': result.confirmationCode!,
      };
    }

    // 容错回退：无 LPA: 前缀但包含 $ 分隔的激活码
    if (trimmed.contains('\$') && !trimmed.startsWith('http')) {
      final parts = trimmed.split('\$');
      if (parts.length >= 2) {
        return {
          'rspServer': parts[0].trim(),
          'activationCode': parts[1].trim(),
          if (parts.length >= 3 && parts[2].trim().isNotEmpty)
            'confirmationCode': parts[2].trim(),
        };
      }
    }

    // 无法解析为 LPA 但有内容，返回原始文本作为激活码
    return {
      'rspServer': '',
      'activationCode': trimmed,
    };
  }

  void _showResultSheet(String rawData, Map<String, String> parsed) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: Color(0xFF34C759), size: 24),
                  const SizedBox(width: 8),
                  Text(
                    '扫描成功',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (parsed['rspServer']!.isNotEmpty) ...[
                _resultRow('SM-DP+', parsed['rspServer']!),
                const SizedBox(height: 8),
              ],
              _resultRow('激活码', parsed['activationCode']!),
              if (parsed['confirmationCode'] != null) ...[
                const SizedBox(height: 8),
                _resultRow('确认码', parsed['confirmationCode']!),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() => _hasScanned = false);
                      },
                      child: const Text('重新扫描'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // 关闭底部弹窗
                        Navigator.of(this.context).pop(parsed); // 返回结果
                      },
                      child: const Text('使用此信息'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _resultRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.robotoMono(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
