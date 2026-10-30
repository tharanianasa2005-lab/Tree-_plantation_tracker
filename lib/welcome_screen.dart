import 'dart:math' as math;
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _backgroundController;
  late AnimationController _buttonController;
  late AnimationController _leafController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _buttonAnimation;

  final List<_LeafParticle> _leaves = [];

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _leafController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    _fadeAnimation = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(
        0.0,
        0.8,
        curve: Curves.easeIn,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: Curves.easeOutCubic,
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.65,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: Curves.elasticOut,
      ),
    );

    _buttonAnimation = Tween<double>(
      begin: 1.0,
      end: 1.045,
    ).animate(
      CurvedAnimation(
        parent: _buttonController,
        curve: Curves.easeInOut,
      ),
    );

    final random = math.Random(42);

    for (int i = 0; i < 24; i++) {
      _leaves.add(
        _LeafParticle(
          x: random.nextDouble(),
          y: random.nextDouble(),
          size: 8 + random.nextDouble() * 18,
          speed: 0.3 + random.nextDouble() * 0.8,
          rotation: random.nextDouble() * math.pi * 2,
        ),
      );
    }

    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _backgroundController.dispose();
    _buttonController.dispose();
    _leafController.dispose();
    super.dispose();
  }

  void _getStarted() {
    Navigator.pushNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Nature-inspired animated background.
          AnimatedBuilder(
            animation: _backgroundController,
            builder: (context, child) {
              final value = _backgroundController.value;

              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(
                      -1 + value * 0.8,
                      -1,
                    ),
                    end: Alignment(
                      1 - value * 0.8,
                      1,
                    ),
                    colors: const [
                      Color.fromARGB(255, 11, 45, 61),
                      Color.fromARGB(255, 17, 53, 101),
                      Color.fromARGB(255, 109, 35, 134),
                      Color.fromARGB(255, 185, 71, 145),
                    ],
                    stops: const [
                      0.0,
                      0.35,
                      0.70,
                      1.0,
                    ],
                  ),
                ),
              );
            },
          ),

          // Soft background circles.
          Positioned(
            top: -100,
            right: -80,
            child: _glowCircle(
              280,
              const Color.fromARGB(255, 195, 74, 141).withValues(alpha: 0.15),
            ),
          ),

          Positioned(
            bottom: -120,
            left: -100,
            child: _glowCircle(
              300,
              const Color.fromARGB(255, 255, 255, 255).withValues(alpha: 0.08),
            ),
          ),

          Positioned(
            top: 220,
            left: -80,
            child: _glowCircle(
              160,
              const Color.fromARGB(255, 57, 71, 220).withValues(alpha: 0.09),
            ),
          ),

          // Animated floating leaves.
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _leafController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _LeafPainter(
                      leaves: _leaves,
                      progress: _leafController.value,
                    ),
                  );
                },
              ),
            ),
          ),

          // Main welcome content.
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 26,
                        vertical: 18,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 12),

                          // App logo.
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: ScaleTransition(
                              scale: _scaleAnimation,
                              child: _buildLogo(),
                            ),
                          ),

                          const SizedBox(height: 26),

                          // App title.
                          SlideTransition(
                            position: _slideAnimation,
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: Column(
                                children: [
                                  const Text(
                                    'Tree Plantation',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 34,
                                      fontWeight: FontWeight.w900,
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      height: 1.2,
                                      letterSpacing: 0.3,
                                    ),
                                  ),

                                  const SizedBox(height: 5),

                                  const Text(
                                    'TRACKER',
                                    style: TextStyle(
                                      fontSize: 16,
                                      letterSpacing: 6,
                                      fontWeight: FontWeight.w600,
                                      color: Color.fromARGB(255, 247, 165, 228),
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Text(
                                      'Grow a greener tomorrow, '
                                      'one tree at a time.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        height: 1.6,
                                        color: const Color.fromARGB(255, 255, 255, 255).withValues(
                                          alpha: 0.88,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Feature cards.
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _featureCard(
                                        icon: Icons.eco_rounded,
                                        title: 'Track Trees',
                                        subtitle:
                                            'Manage your trees',
                                        delay: 0,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: _featureCard(
                                        icon: Icons.location_on_rounded,
                                        title: 'Save Locations',
                                        subtitle:
                                            'Record tree locations',
                                        delay: 1,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 14),

                                Row(
                                  children: [
                                    Expanded(
                                      child: _featureCard(
                                        icon: Icons.camera_alt_rounded,
                                        title: 'Tree Photos',
                                        subtitle:
                                            'Capture memories',
                                        delay: 2,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: _featureCard(
                                        icon: Icons.favorite_rounded,
                                        title: 'Tree Health',
                                        subtitle:
                                            'Monitor tree growth',
                                        delay: 3,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 34),

                          // Animated Get Started button.
                          ScaleTransition(
                            scale: _buttonAnimation,
                            child: SizedBox(
                              width: double.infinity,
                              height: 60,
                              child: ElevatedButton(
                                onPressed: _getStarted,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                                  foregroundColor:
                                      const Color.fromARGB(255, 68, 20, 83),
                                  elevation: 8,
                                  shadowColor: const Color.fromARGB(255, 0, 0, 0).withValues(
                                    alpha: 0.25,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Get Started',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 23,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          // Footer.
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.public_rounded,
                                  size: 17,
                                  color: const Color.fromARGB(255, 255, 255, 255).withValues(
                                    alpha: 0.8,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Make the Earth Greener',
                                  style: TextStyle(
                                    fontSize: 13,
                                    letterSpacing: 0.5,
                                    color: const Color.fromARGB(255, 255, 255, 255).withValues(
                                      alpha: 0.85,
                                    ),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      height: 150,
      width: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color.fromARGB(255, 255, 255, 255).withValues(alpha: 0.12),
        border: Border.all(
          color: const Color.fromARGB(255, 255, 255, 255).withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 0, 0, 0).withValues(alpha: 0.12),
            blurRadius: 30,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(13),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 201, 222, 255),
              Color.fromARGB(255, 205, 99, 224),
            ],
          ),
        ),
        child: const Icon(
          Icons.park_rounded,
          size: 82,
          color: Color(0xFF14532D),
        ),
      ),
    );
  }

  Widget _glowCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  Widget _featureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      key: ValueKey('feature_$delay'),
      tween: Tween<double>(
        begin: 0.0,
        end: 1.0,
      ),
      duration: Duration(
        milliseconds: 650 + delay * 160,
      ),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 18 * (1 - value)),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 18,
        ),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color.fromARGB(255, 255, 255, 255).withValues(alpha: 0.20),
          ),
        ),
        child: Column(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255).withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                icon,
                color: const Color.fromARGB(255, 181, 220, 255),
                size: 26,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
            ),

            const SizedBox(height: 5),

            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                height: 1.4,
                color: const Color.fromARGB(255, 255, 255, 255).withValues(alpha: 0.78),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Floating leaf data.
class _LeafParticle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double rotation;

  const _LeafParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.rotation,
  });
}

// Paints animated leaves without using external images.
class _LeafPainter extends CustomPainter {
  final List<_LeafParticle> leaves;
  final double progress;

  _LeafPainter({
    required this.leaves,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final leaf in leaves) {
      final x = (
        leaf.x +
        math.sin(
          (progress * math.pi * 2 * leaf.speed) + leaf.rotation,
        ) *
        0.035
      ) * size.width;

      final y = (
        leaf.y +
        progress * leaf.speed * 0.30
      ) % 1.0 * size.height;

      final paint = Paint()
        ..color = Colors.white.withValues(alpha: 0.13)
        ..style = PaintingStyle.fill;

      canvas.save();

      canvas.translate(x, y);

      canvas.rotate(
        leaf.rotation + progress * math.pi * 2,
      );

      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: leaf.size,
        height: leaf.size * 1.65,
      );

      canvas.drawOval(rect, paint);

      final veinPaint = Paint()
        ..color = const Color.fromARGB(255, 255, 255, 255).withValues(alpha: 0.15)
        ..strokeWidth = 0.8
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(0, -leaf.size * 0.55),
        Offset(0, leaf.size * 0.55),
        veinPaint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _LeafPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}