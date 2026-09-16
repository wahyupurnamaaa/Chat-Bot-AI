import 'package:flutter/material.dart';

const purple = Color(0xFF4B32C3);

class Brand extends StatelessWidget {
  final double size;
  const Brand({super.key, this.size = 96});
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Nova AI',
    child: Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * .13),
      decoration: BoxDecoration(
        color: purple.withValues(alpha: .07),
        shape: BoxShape.circle,
      ),
      child: CustomPaint(painter: _Logo()),
    ),
  );
}

class _Logo extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    final p = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [purple, Color(0xFF9675FA)],
      ).createShader(bounds)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .105
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    // Monogram N with a nova star at the upper right.
    canvas.drawPath(
      Path()
        ..moveTo(size.width * .22, size.height * .76)
        ..lineTo(size.width * .22, size.height * .26)
        ..lineTo(size.width * .68, size.height * .76)
        ..lineTo(size.width * .68, size.height * .43),
      p,
    );
    final star = Path()
      ..moveTo(size.width * .75, size.height * .10)
      ..quadraticBezierTo(
        size.width * .77,
        size.height * .24,
        size.width * .91,
        size.height * .26,
      )
      ..quadraticBezierTo(
        size.width * .77,
        size.height * .28,
        size.width * .75,
        size.height * .42,
      )
      ..quadraticBezierTo(
        size.width * .73,
        size.height * .28,
        size.width * .59,
        size.height * .26,
      )
      ..quadraticBezierTo(
        size.width * .73,
        size.height * .24,
        size.width * .75,
        size.height * .10,
      )
      ..close();
    canvas.drawPath(star, Paint()..color = const Color(0xFF9675FA));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Widget primaryButton(String label, VoidCallback? onPressed) => SizedBox(
  width: double.infinity,
  height: 52,
  child: FilledButton(onPressed: onPressed, child: Text(label)),
);
