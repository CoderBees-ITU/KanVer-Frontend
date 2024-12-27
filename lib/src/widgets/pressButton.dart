import 'package:flutter/material.dart';

class AnimatedPressButton extends StatefulWidget {
  final Function completeFunction;

  const AnimatedPressButton({required this.completeFunction, Key? key})
      : super(key: key);

  @override
  _AnimatedPressButtonState createState() => _AnimatedPressButtonState();
}

class _AnimatedPressButtonState extends State<AnimatedPressButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5), // Animation lasts 5 seconds
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _controller.forward().whenComplete(() {
      if (_isPressed) {
        widget.completeFunction();
      }
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    _controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
        _controller.reset();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                colors: const [Color.fromARGB(255, 65, 0, 162), Color.fromARGB(255, 0, 70, 127)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: [
                  _controller.value, // Dynamically change based on the animation
                  _controller.value + 0.1 > 1.0
                      ? 1.0
                      : _controller.value + 0.1, // Smooth gradient
                ],
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcATop,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff65558F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: null, // GestureDetector handles the press
              label: const Text("Bağış Yapacağım"),
              icon: const Icon(Icons.check),
            ),
          );
        },
      ),
    );
  }
}
