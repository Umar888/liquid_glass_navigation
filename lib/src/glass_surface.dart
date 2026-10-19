import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'liquid_glass_style.dart';

/// Rounded rect for a capsule filling [rect].
RRect capsuleFor(Rect rect) =>
    RRect.fromRectAndRadius(rect, Radius.circular(rect.shortestSide / 2));

/// A blurred, tinted capsule with a rim and an outside-only shadow.
class GlassSurface extends StatelessWidget {
  const GlassSurface({super.key, required this.style, required this.child});

  final ResolvedGlassStyle style;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final rim = style.rimColor;
    return CustomPaint(
      painter: HollowShadowPainter(style.shadows),
      child: ClipPath(
        clipper: const ShapeBorderClipper(shape: StadiumBorder()),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(
            sigmaX: style.blurSigma,
            sigmaY: style.blurSigma,
          ),
          child: CustomPaint(
            painter: CapsulePainter(
              fill: style.tintColor,
              sheen: style.isGlass ? rim.withValues(alpha: rim.a * 0.3) : null,
            ),
            foregroundPainter: CapsulePainter(rim: rim),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Paints shadows only outside the capsule.
///
/// A regular BoxShadow would show through the translucent tint and get
/// picked up by the backdrop blur, making the glass look dirty.
class HollowShadowPainter extends CustomPainter {
  const HollowShadowPainter(this.shadows);

  final List<BoxShadow> shadows;

  // far enough out to cover any reasonable shadow blur
  static const double _clipOverscan = 200;

  @override
  void paint(Canvas canvas, Size size) {
    if (shadows.isEmpty) return;
    final rect = Offset.zero & size;
    final capsule = capsuleFor(rect);

    canvas.save();
    canvas.clipPath(
      Path()
        ..fillType = PathFillType.evenOdd
        ..addRect(rect.inflate(_clipOverscan))
        ..addRRect(capsule),
    );
    for (final shadow in shadows) {
      final paint = Paint()
        ..color = shadow.color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadow.blurSigma);
      final shadowRect = rect.shift(shadow.offset).inflate(shadow.spreadRadius);
      canvas.drawRRect(capsuleFor(shadowRect), paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(HollowShadowPainter oldDelegate) =>
      oldDelegate.shadows != shadows;
}

/// Fills a capsule, with an optional top sheen and a gradient rim.
class CapsulePainter extends CustomPainter {
  const CapsulePainter({this.fill, this.sheen, this.rim});

  final Color? fill;
  final Color? sheen;
  final Color? rim;

  static const double _rimWidth = 1;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final capsule = capsuleFor(rect);

    final fill = this.fill;
    if (fill != null) {
      canvas.drawRRect(capsule, Paint()..color = fill);
    }

    final sheen = this.sheen;
    if (sheen != null) {
      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [sheen, sheen.withValues(alpha: 0)],
          stops: const [0, 0.5],
        ).createShader(rect);
      canvas.drawRRect(capsule, paint);
    }

    final rim = this.rim;
    if (rim != null) {
      // bright top, faint middle, a little light refracting back at the bottom
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _rimWidth
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            rim,
            rim.withValues(alpha: rim.a * 0.12),
            rim.withValues(alpha: rim.a * 0.45),
          ],
          stops: const [0, 0.5, 1],
        ).createShader(rect);
      canvas.drawRRect(capsuleFor(rect.deflate(_rimWidth / 2)), paint);
    }
  }

  @override
  bool shouldRepaint(CapsulePainter oldDelegate) =>
      oldDelegate.fill != fill ||
      oldDelegate.sheen != sheen ||
      oldDelegate.rim != rim;
}
