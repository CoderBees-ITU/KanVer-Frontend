import 'package:flutter/material.dart';
import 'dart:math';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final dynamic user =
      null; // Replace with user from your auth system (e.g., FirebaseAuth.instance.currentUser)

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 8),
    )..repeat(reverse: false);

    _navigateBasedOnUser();
  }

  Future<void> _navigateBasedOnUser() async {
    // Simulate a delay for the splash screen
    await Future.delayed(Duration(seconds: 9));

    if (user == null) {
      Navigator.pushReplacementNamed(context, '/'); // Navigate to Login
    } else {
      Navigator.pushReplacementNamed(context, '/home'); // Navigate to Home
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              size: Size(300, 300),
              painter: RealisticGlassHeartPainter(_controller.value),
            );
          },
        ),
      ),
    );
  }
}

class RealisticGlassHeartPainter extends CustomPainter {
  final double animationValue;

  RealisticGlassHeartPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    Path heartPath = _createHeartPath(size);

    // Main glass outline
    Paint glassPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.white.withOpacity(0.5), Colors.white.withOpacity(0.1)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8);

    // Glass highlights and reflections
    Paint highlightPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.7),
          Colors.transparent,
        ],
        center: Alignment(0.3, -0.3), // Top-left reflection
        radius: 0.6,
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.3, size.height * 0.3),
        radius: size.width / 3,
      ));

    // Glass texture overlay
    Paint texturePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withOpacity(0.05),
          Colors.white.withOpacity(0.15),
          Colors.white.withOpacity(0.05),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Draw glass outline and highlights
    canvas.drawPath(heartPath, glassPaint);
    canvas.drawPath(heartPath, highlightPaint);
    canvas.drawPath(heartPath, texturePaint);

    // Clip heart shape for liquid and bubbles
    canvas.save();
    canvas.clipPath(heartPath);

    // Liquid fill with dynamic waves
    double liquidTop = size.height * (1.0 - animationValue);
    _drawLiquidWithDynamicWaves(canvas, size, liquidTop);

    // Varied bubbles for realism
    _drawVariedBubbles(canvas, size, liquidTop);

    canvas.restore();
  }

  void _drawLiquidWithDynamicWaves(Canvas canvas, Size size, double liquidTop) {
    Paint liquidPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.yellow.withOpacity(0.5),
          const Color.fromARGB(255, 255, 153, 0).withOpacity(0.4),
          Colors.pink.withOpacity(0.3),
          Colors.purple.withOpacity(0.4),
          Colors.blue.withOpacity(0.4),
          const Color.fromARGB(255, 18, 83, 135).withOpacity(0.7),
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        transform:
            GradientRotation(pi / 4), // Rotate the gradient by 45 degrees
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..blendMode = BlendMode.overlay; // Blend mode for smooth merging

    Path liquidPath = Path();
    double waveHeight = 10;
    double waveLength = size.width / 3;
    double waveSpeed = animationValue * 4 * pi;

    for (double x = 0; x <= size.width; x++) {
      double y = liquidTop + sin((x / waveLength) + waveSpeed) * waveHeight;
      if (x == 0) {
        liquidPath.moveTo(x, y);
      } else {
        liquidPath.lineTo(x, y);
      }
    }

    liquidPath.lineTo(size.width, size.height);
    liquidPath.lineTo(0, size.height);
    liquidPath.close();

    canvas.drawPath(liquidPath, liquidPaint);
  }

  void _drawVariedBubbles(Canvas canvas, Size size, double liquidTop) {
    Paint bubblePaint = Paint()..style = PaintingStyle.fill;
    Random random = Random();

    for (int i = 0; i < 8; i++) {
      double bubbleX = random.nextDouble() * size.width;
      double bubbleY = liquidTop +
          (random.nextDouble() * (size.height - liquidTop) * 0.5) -
          animationValue * 10;
      double bubbleRadius = random.nextDouble() * 3 + 2;

      bubblePaint.shader = RadialGradient(
        colors: [
          Colors.pink.withOpacity(0.3),
          Colors.orange.withOpacity(0.2),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
          center: Offset(bubbleX, bubbleY), radius: bubbleRadius));

      bubblePaint.maskFilter = MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(Offset(bubbleX, bubbleY), bubbleRadius, bubblePaint);
    }
  }

  Path _createHeartPath(Size size) {
    Path path = Path();
    path.moveTo(size.width / 2, size.height * 0.3);
    path.cubicTo(
      size.width * 0.1,
      size.height * 0.0,
      size.width * -0.2,
      size.height * 0.6,
      size.width / 2,
      size.height,
    );
    path.cubicTo(
      size.width * 1.2,
      size.height * 0.6,
      size.width * 0.9,
      size.height * 0.0,
      size.width / 2,
      size.height * 0.3,
    );
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

void main() {
  runApp(MaterialApp(
    home: SplashScreen(),
    debugShowCheckedModeBanner: false,
  ));
}
