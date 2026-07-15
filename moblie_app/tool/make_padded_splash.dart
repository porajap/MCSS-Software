import 'dart:io';

import 'package:image/image.dart';

/// Builds a padded splash icon so Android 12's circular mask
/// is less likely to clip logo content.
void main() {
  final sourcePath = File('lib/assets/images/logo_app.jpg');
  final outPath = File('lib/assets/images/logo_splash_padded.png');

  final bytes = sourcePath.readAsBytesSync();
  final src = decodeImage(bytes);
  if (src == null) {
    stderr.writeln('Failed to decode ${sourcePath.path}');
    exit(1);
  }

  const canvasSize = 1152;
  // Keep logo well inside the Android 12 icon safe zone (~66% diameter).
  const logoScale = 0.58;

  final canvas = Image(width: canvasSize, height: canvasSize);
  // Match app splash brown #795548
  fill(canvas, color: ColorRgb8(0x79, 0x55, 0x48));

  final targetW = (canvasSize * logoScale).round();
  final resized = copyResize(
    src,
    width: targetW,
    interpolation: Interpolation.average,
  );
  final offsetX = ((canvasSize - resized.width) / 2).round();
  final offsetY = ((canvasSize - resized.height) / 2).round();
  compositeImage(canvas, resized, dstX: offsetX, dstY: offsetY);

  outPath.writeAsBytesSync(encodePng(canvas));
  stdout.writeln('Wrote ${outPath.path} (${canvasSize}x$canvasSize, scale=$logoScale)');
}
