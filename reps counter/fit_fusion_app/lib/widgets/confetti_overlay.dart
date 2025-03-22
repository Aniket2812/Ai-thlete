import 'dart:math';
import 'package:flutter/material.dart';

class ConfettiOverlay extends StatefulWidget {
  final Widget child;
  final bool showConfetti;
  final Duration duration;
  final int particleCount;

  const ConfettiOverlay({
    super.key,
    required this.child,
    this.showConfetti = false,
    this.duration = const Duration(seconds: 2),
    this.particleCount = 50,
  });

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<ConfettiParticle> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _generateParticles();

    if (widget.showConfetti) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(ConfettiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showConfetti && !oldWidget.showConfetti) {
      _generateParticles();
      _controller.reset();
      _controller.forward();
    }
  }

  void _generateParticles() {
    _particles = List.generate(
      widget.particleCount,
      (_) => ConfettiParticle(
        color: _getRandomColor(),
        position: Offset(
          _random.nextDouble() * 400 - 200,
          -50 - _random.nextDouble() * 100,
        ),
        size: 5 + _random.nextDouble() * 10,
        speed: 200 + _random.nextDouble() * 200,
        angle: (_random.nextDouble() * 60 - 30) * pi / 180,
        rotationSpeed: _random.nextDouble() * 10 - 5,
      ),
    );
  }

  Color _getRandomColor() {
    final colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.teal,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.showConfetti)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: ConfettiPainter(
                  particles: _particles,
                  progress: _controller.value,
                ),
                size: Size.infinite,
              );
            },
          ),
      ],
    );
  }
}

class ConfettiParticle {
  final Color color;
  final Offset position;
  final double size;
  final double speed;
  final double angle;
  final double rotationSpeed;
  double rotation = 0;

  ConfettiParticle({
    required this.color,
    required this.position,
    required this.size,
    required this.speed,
    required this.angle,
    required this.rotationSpeed,
  });

  Offset calculatePosition(double progress, Size size) {
    final centerX = size.width / 2;
    final gravity = 980.0; // pixels per second squared
    
    final time = progress * 2; // Scale time to make animation faster
    
    final x = centerX + position.dx + speed * cos(angle) * time;
    final y = position.dy + speed * sin(angle) * time + 0.5 * gravity * time * time;
    
    rotation = rotationSpeed * progress * 10;
    
    return Offset(x, y);
  }
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;

  ConfettiPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final position = particle.calculatePosition(progress, size);
      
      // Only draw particles that are within the screen bounds
      if (position.dx >= 0 &&
          position.dx <= size.width &&
          position.dy >= 0 &&
          position.dy <= size.height) {
        
        canvas.save();
        canvas.translate(position.dx, position.dy);
        canvas.rotate(particle.rotation);
        
        final paint = Paint()..color = particle.color;
        
        // Draw a rectangle for the confetti
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: particle.size,
            height: particle.size * 1.5,
          ),
          paint,
        );
        
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
