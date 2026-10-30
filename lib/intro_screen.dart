import 'dart:math';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class IntroScreen extends StatefulWidget {
  final Widget nextScreen;

  const IntroScreen({
    super.key,
    required this.nextScreen,
  });

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with TickerProviderStateMixin {
  late AnimationController _treeController;
  late AnimationController _contentController;
  late AnimationController _leafController;
  late AnimationController _buttonController;

  late Animation<double> _treeAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _buttonScale;

  final Random random = Random();

  @override
  void initState() {
    super.initState();

    // ========================================================
    // TREE ANIMATION
    // ========================================================

    _treeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _treeAnimation = CurvedAnimation(
      parent: _treeController,
      curve: Curves.easeOutBack,
    );

    // ========================================================
    // CONTENT ANIMATION
    // ========================================================

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: Curves.easeOutCubic,
      ),
    );

    // ========================================================
    // LEAF ANIMATION
    // ========================================================

    _leafController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // ========================================================
    // BUTTON ANIMATION
    // ========================================================

    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(
        reverse: true,
      );

    _buttonScale = Tween<double>(
      begin: 1.0,
      end: 1.04,
    ).animate(
      CurvedAnimation(
        parent: _buttonController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animations
    Future.delayed(
      const Duration(milliseconds: 300),
      () {
        if (mounted) {
          _treeController.forward();
          _contentController.forward();
        }
      },
    );
  }

  @override
  void dispose() {
    _treeController.dispose();
    _contentController.dispose();
    _leafController.dispose();
    _buttonController.dispose();

    super.dispose();
  }

  // ==========================================================
  // GO TO LOGIN
  // ==========================================================

  void goToLogin() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration:
            const Duration(milliseconds: 800),
        pageBuilder:
            (context, animation, secondaryAnimation) {
          return LoginScreen(
            nextScreen: widget.nextScreen,
          );
        },
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeIn,
            ),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.08),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                ),
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // ====================================================
          // BACKGROUND
          // ====================================================

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color.fromARGB(255, 46, 125, 108),
                  const Color.fromARGB(255, 67, 160, 138),
                  const Color.fromARGB(255, 102, 170, 187),
                ],
              ),
            ),
          ),

          // ====================================================
          // BACKGROUND CIRCLES
          // ====================================================

          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            bottom: -120,
            left: -90,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // ====================================================
          // FLOATING LEAVES
          // ====================================================

          AnimatedBuilder(
            animation: _leafController,
            builder: (context, child) {
              return Stack(
                children: [
                  floatingLeaf(
                    left: size.width * 0.20,
                    startTop: size.height * 0.28,
                    progress:
                        _leafController.value,
                    delay: 0.0,
                    size: 22,
                  ),

                  floatingLeaf(
                    left: size.width * 0.80,
                    startTop: size.height * 0.25,
                    progress:
                        _leafController.value,
                    delay: 0.25,
                    size: 18,
                  ),

                  floatingLeaf(
                    left: size.width * 0.30,
                    startTop: size.height * 0.65,
                    progress:
                        _leafController.value,
                    delay: 0.50,
                    size: 16,
                  ),

                  floatingLeaf(
                    left: size.width * 0.85,
                    startTop: size.height * 0.60,
                    progress:
                        _leafController.value,
                    delay: 0.70,
                    size: 25,
                  ),
                ],
              );
            },
          ),

          // ====================================================
          // MAIN CONTENT
          // ====================================================

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 24,
                ),

                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  children: [
                    const SizedBox(height: 20),

                    // ==================================================
                    // APP LOGO
                    // ==================================================

                    FadeTransition(
                      opacity: _fadeAnimation,

                      child: Container(
                        width: 76,
                        height: 76,

                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 255, 255)
                              .withOpacity(0.18),
                          shape: BoxShape.circle,

                          border: Border.all(
                            color: const Color.fromARGB(255, 255, 255, 255)
                                .withOpacity(0.5),
                            width: 2,
                          ),
                        ),

                        child: const Icon(
                          Icons.eco,
                          color: Color.fromARGB(255, 255, 255, 255),
                          size: 42,
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ==================================================
                    // WELCOME TEXT
                    // ==================================================

                    SlideTransition(
                      position: _slideAnimation,

                      child: FadeTransition(
                        opacity: _fadeAnimation,

                        child: const Text(
                          'WELCOME',
                          textAlign: TextAlign.center,

                          style: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontSize: 16,
                            fontWeight:
                                FontWeight.w600,
                            letterSpacing: 5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ==================================================
                    // APP NAME
                    // ==================================================

                    SlideTransition(
                      position: _slideAnimation,

                      child: FadeTransition(
                        opacity: _fadeAnimation,

                        child: const Text(
                          'Tree Plantation\nTracker',
                          textAlign: TextAlign.center,

                          style: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontSize: 38,
                            height: 1.05,
                            fontWeight:
                                FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ==================================================
                    // TAGLINE
                    // ==================================================

                    FadeTransition(
                      opacity: _fadeAnimation,

                      child: Text(
                        'Plant today. Protect tomorrow. 🌱',
                        textAlign: TextAlign.center,

                        style: TextStyle(
                          color: const Color.fromARGB(255, 255, 255, 255)
                              .withOpacity(0.90),
                          fontSize: 16,
                          fontWeight:
                              FontWeight.w400,
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ==================================================
                    // ANIMATED TREE
                    // ==================================================

                    AnimatedBuilder(
                      animation: _treeAnimation,

                      builder:
                          (context, child) {
                        return Transform.scale(
                          scale: _treeAnimation.value,

                          child: child,
                        );
                      },

                      child: Container(
                        width: min(
                          size.width * 0.72,
                          300,
                        ),

                        height: 260,

                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 255, 255)
                              .withOpacity(0.12),

                          borderRadius:
                              BorderRadius.circular(
                            35,
                          ),

                          border: Border.all(
                            color: const Color.fromARGB(255, 255, 255, 255)
                                .withOpacity(0.18),
                          ),
                        ),

                        child: CustomPaint(
                          painter:
                              WelcomeTreePainter(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ==================================================
                    // DESCRIPTION
                    // ==================================================

                    FadeTransition(
                      opacity: _fadeAnimation,

                      child: Text(
                        'Record your trees, track their growth, '
                        'and create a greener future.',
                        textAlign: TextAlign.center,

                        style: TextStyle(
                          color: const Color.fromARGB(255, 255, 255, 255)
                              .withOpacity(0.88),
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ==================================================
                    // GET STARTED BUTTON
                    // ==================================================

                    AnimatedBuilder(
                      animation: _buttonScale,

                      builder:
                          (context, child) {
                        return Transform.scale(
                          scale: _buttonScale.value,
                          child: child,
                        );
                      },

                      child: SizedBox(
                        width: min(
                          size.width * 0.78,
                          330,
                        ),
                        height: 58,

                        child: ElevatedButton(
                          onPressed: goToLogin,

                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 255, 255, 255),

                            foregroundColor:
                                const Color.fromARGB(255, 56, 142, 99),

                            elevation: 8,

                            shadowColor:
                                const Color.fromARGB(255, 0, 0, 0)
                                    .withOpacity(0.25),

                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                30,
                              ),
                            ),
                          ),

                          child: const Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,

                            children: [
                              Text(
                                'Get Started',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              SizedBox(width: 10),

                              Icon(
                                Icons.arrow_forward,
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ==================================================
                    // BOTTOM TEXT
                    // ==================================================

                    FadeTransition(
                      opacity: _fadeAnimation,

                      child: Text(
                        'Every tree makes a difference 🌍',
                        textAlign: TextAlign.center,

                        style: TextStyle(
                          color: const Color.fromARGB(255, 255, 255, 255)
                              .withOpacity(0.75),
                          fontSize: 12,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // FLOATING LEAF
  // ==========================================================

  Widget floatingLeaf({
    required double left,
    required double startTop,
    required double progress,
    required double delay,
    required double size,
  }) {
    double value =
        (progress + delay) % 1.0;

    double top =
        startTop + (value * 150);

    double rotation =
        sin(value * pi * 2) * 0.6;

    return Positioned(
      left: left,
      top: top,

      child: Transform.rotate(
        angle: rotation,

        child: Opacity(
          opacity: 0.35,

          child: Icon(
            Icons.eco,
            size: size,
            color: const Color.fromARGB(255, 255, 255, 255),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// BEAUTIFUL TREE PAINTER
// ============================================================

class WelcomeTreePainter extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final centerX = size.width / 2;

    // ========================================================
    // GROUND
    // ========================================================

    final groundPaint = Paint()
      ..color = const Color.fromARGB(255, 255, 255, 255).withOpacity(0.18)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
          centerX,
          size.height - 30,
        ),
        width: size.width * 0.65,
        height: 28,
      ),
      groundPaint,
    );

    // ========================================================
    // TREE TRUNK
    // ========================================================

    final trunkPaint = Paint()
      ..color = const Color.fromARGB(255, 121, 98, 72)
      ..style = PaintingStyle.fill;

    final trunk = Path();

    trunk.moveTo(
      centerX - 18,
      size.height - 38,
    );

    trunk.lineTo(
      centerX - 10,
      size.height - 135,
    );

    trunk.lineTo(
      centerX + 10,
      size.height - 135,
    );

    trunk.lineTo(
      centerX + 18,
      size.height - 38,
    );

    trunk.close();

    canvas.drawPath(
      trunk,
      trunkPaint,
    );

    // ========================================================
    // BRANCHES
    // ========================================================

    final branchPaint = Paint()
      ..color = const Color(0xFF795548)
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(
        centerX,
        size.height - 110,
      ),
      Offset(
        centerX - 45,
        size.height - 155,
      ),
      branchPaint,
    );

    canvas.drawLine(
      Offset(
        centerX,
        size.height - 100,
      ),
      Offset(
        centerX + 45,
        size.height - 155,
      ),
      branchPaint,
    );

    // ========================================================
    // TREE TOP
    // ========================================================

    final leafPaint = Paint()
      ..color = const Color.fromARGB(255, 185, 228, 246)
      ..style = PaintingStyle.fill;

    // Bottom
    canvas.drawCircle(
      Offset(
        centerX,
        size.height - 145,
      ),
      62,
      leafPaint,
    );

    // Left
    canvas.drawCircle(
      Offset(
        centerX - 48,
        size.height - 175,
      ),
      48,
      leafPaint,
    );

    // Right
    canvas.drawCircle(
      Offset(
        centerX + 48,
        size.height - 175,
      ),
      48,
      leafPaint,
    );

    // Top
    canvas.drawCircle(
      Offset(
        centerX,
        size.height - 205,
      ),
      48,
      leafPaint,
    );

    // ========================================================
    // SMALL LEAVES
    // ========================================================

    final smallLeafPaint = Paint()
      ..color = const Color.fromARGB(255, 255, 255, 255).withOpacity(0.45)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(
        centerX - 75,
        size.height - 220,
      ),
      9,
      smallLeafPaint,
    );

    canvas.drawCircle(
      Offset(
        centerX + 72,
        size.height - 225,
      ),
      8,
      smallLeafPaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}