import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart';

/// Creates a circular splash logo on the brown splash background.
void main() {
  final sourcePath = File('lib/assets/images/logo_app.jpg');
  final outPath = File('lib/assets/images/logo_splash_circle.png');

  final bytes = sourcePath.readAsBytesSync();
  final src = decodeImage(bytes);
  if (src == null) {
    stderr.writeln('Failed to decode ${sourcePath.path}');
    exit(1);
  }

  const canvasSize = 1152;
  // Slightly under full size so Android's circular mask retains margins.
  const diameter = 980;

  final canvas = Image(width: canvasSize, height: canvasSize);
  // Match splash brown #795548
  fill(canvas, color: ColorRgb8(0x79, 0x55, 0x48));

  final resized = copyResize(
    src,
    width: diameter,
    height: diameter,
    interpolation: Interpolation.average,
  );

  final offset = ((canvasSize - diameter) / 2).round();
  final center = canvasSize / 2.0;
  final radius = diameter / 2.0;

  for (var y = 0; y < diameter; y++) {
    for (var x = 0; x < diameter; x++) {
      final dx = (x + 0.5) - radius;
      final dy = (y + 0.5) - radius;
      if (math.sqrt(dx * dx + dy * dy) <= radius) {
        canvas.setPixel(offset + x, offset + y, resized.getPixel(x, y));
      }
    }
  }

  // Soft edge anti-alias against brown
  for (var y = 0; y < canvasSize; y++) {
    for (var x = 0; x < canvasSize; x++) {
      final dx = (x + 0.5) - center;
      final dy = (y + 0.5) - center;
      final d = math.sqrt(dx * dx + dy * dy);
      final edge = d - radius;
      if (edge > 0 && edge < 1.5) {
        final t = (edge / 1.5).clamp(0.0, 1.0);
        final p = canvas.getPixel(x, y);
        final r = (p.r * (1 - t) + 0x79 * t).round();
        final g = (p.g * (1 - t) + 0x55 * t).round();
        final b = (p.b * (1 - t) + 0x48 * t).round();
        canvas.setPixelRgb(x, y, r, g, b);
      }
    }
  }

  outPath.writeAsBytesSync(encodePng(canvas));
  stdout.writeln('Wrote ${outPath.path} (${canvasSize}x$canvasSize, diameter=$diameter)');
}
