import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart';

/// Circular splash logo with enough inner margin so long text
/// ("CHEMICAL SENSOR") stays inside Android 12's circular icon mask.
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
  // Android 12 splash icon safe zone is ~66% of diameter.
  // Keep logo below that so side letters are not clipped.
  const logoScale = 0.52;

  final canvas = Image(width: canvasSize, height: canvasSize);
  fill(canvas, color: ColorRgb8(0x79, 0x55, 0x48));

  final logoSize = (canvasSize * logoScale).round();
  final resized = copyResize(
    src,
    width: logoSize,
    height: logoSize,
    interpolation: Interpolation.average,
  );

  final offset = ((canvasSize - logoSize) / 2).round();
  final center = canvasSize / 2.0;
  // Soft circle slightly larger than logo, for a clean circular silhouette.
  final radius = logoSize / 2.0 + 6;

  for (var y = 0; y < logoSize; y++) {
    for (var x = 0; x < logoSize; x++) {
      final dx = (offset + x + 0.5) - center;
      final dy = (offset + y + 0.5) - center;
      if (math.sqrt(dx * dx + dy * dy) <= radius) {
        canvas.setPixel(offset + x, offset + y, resized.getPixel(x, y));
      }
    }
  }

  // Anti-alias circle edge into brown background.
  for (var y = 0; y < canvasSize; y++) {
    for (var x = 0; x < canvasSize; x++) {
      final dx = (x + 0.5) - center;
      final dy = (y + 0.5) - center;
      final d = math.sqrt(dx * dx + dy * dy);
      final edge = d - radius;
      if (edge > 0 && edge < 1.8) {
        final t = (edge / 1.8).clamp(0.0, 1.0);
        final p = canvas.getPixel(x, y);
        final r = (p.r * (1 - t) + 0x79 * t).round();
        final g = (p.g * (1 - t) + 0x55 * t).round();
        final b = (p.b * (1 - t) + 0x48 * t).round();
        canvas.setPixelRgb(x, y, r, g, b);
      }
    }
  }

  outPath.writeAsBytesSync(encodePng(canvas));
  stdout.writeln('Wrote ${outPath.path} (scale=$logoScale)');
}
