import 'package:flutter/material.dart';
import 'package:qr/qr.dart';

/// 显示一段文本的二维码。
///
/// 始终是白底黑块并带 4 个模块宽的留白（静区），深色模式下也能被扫描。
class QrCodeView extends StatelessWidget {
  const QrCodeView({
    super.key,
    required this.data,
    required this.size,
    this.semanticLabel,
  });

  final String data;
  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final image = QrImage(QrCode(payload: QrPayload.fromString(data)));
    return Semantics(
      label: semanticLabel,
      image: true,
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: _QrPainter(image)),
      ),
    );
  }
}

class _QrPainter extends CustomPainter {
  _QrPainter(this.image);

  static const int _quietZone = 4;

  final QrImage image;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);
    final count = image.moduleCount;
    final cell = size.shortestSide / (count + _quietZone * 2);
    final dark = Paint()
      ..color = Colors.black
      ..isAntiAlias = false;
    final path = Path();
    for (var row = 0; row < count; row++) {
      for (var col = 0; col < count; col++) {
        if (!image.isDark(row, col)) continue;
        path.addRect(
          Rect.fromLTWH(
            (col + _quietZone) * cell,
            (row + _quietZone) * cell,
            // 略微放大，避免相邻模块之间出现细缝
            cell + 0.5,
            cell + 0.5,
          ),
        );
      }
    }
    canvas.drawPath(path, dark);
  }

  @override
  bool shouldRepaint(_QrPainter oldDelegate) => oldDelegate.image != image;
}
