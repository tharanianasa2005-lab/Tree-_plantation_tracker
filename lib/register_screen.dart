import 'dart:math';
import 'package:flutter/material.dart';
import 'api_service.dart';

class RegisterScreen extends StatefulWidget {
  final Widget loginScreen;

  const RegisterScreen({super.key, required this.loginScreen});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool hidePassword = true;
  bool hideConfirmPassword = true;
  bool isLoading = false;

  late AnimationController backgroundController;
  late AnimationController logoController;
  late AnimationController formController;
  late AnimationController buttonController;
  late AnimationController particleController;

  late Animation<double> logoAnimation;
  late Animation<double> formAnimation;
  late Animation<double> buttonAnimation;

  // ============================================================
  // INITIALIZATION
  // ============================================================

  @override
  void initState() {
    super.initState();

    // Main background animation
    backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();

    // Logo animation
    logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    logoAnimation = Tween<double>(
      begin: -0.07,
      end: 0.07,
    ).animate(CurvedAnimation(parent: logoController, curve: Curves.easeInOut));

    // Form entrance
    formController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    formAnimation = CurvedAnimation(
      parent: formController,
      curve: Curves.easeOutCubic,
    );

    // Button breathing animation
    buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    buttonAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: buttonController, curve: Curves.easeInOut),
    );

    // Small particles
    particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    formController.forward();

    passwordController.addListener(() {
      setState(() {});
    });

    confirmPasswordController.addListener(() {
      setState(() {});
    });
  }

  // ============================================================
  // PASSWORD STRENGTH
  // ============================================================

  double get passwordStrength {
    final password = passwordController.text;

    if (password.isEmpty) return 0;

    double strength = 0;

    if (password.length >= 6) {
      strength += 0.25;
    }

    if (password.length >= 8) {
      strength += 0.25;
    }

    if (RegExp(r'[A-Z]').hasMatch(password)) {
      strength += 0.15;
    }

    if (RegExp(r'[0-9]').hasMatch(password)) {
      strength += 0.15;
    }

    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      strength += 0.20;
    }

    return min(strength, 1.0);
  }

  String get passwordStrengthText {
    if (passwordStrength == 0) {
      return '';
    }

    if (passwordStrength < 0.4) {
      return 'Weak password';
    }

    if (passwordStrength < 0.7) {
      return 'Medium password';
    }

    return 'Strong password';
  }

  Color get passwordStrengthColor {
    if (passwordStrength < 0.4) {
      return const Color.fromARGB(255, 197, 54, 244);
    }

    if (passwordStrength < 0.7) {
      return const Color.fromARGB(255, 221, 255, 0);
    }

    return const Color.fromARGB(255, 46, 125, 124);
  }

  bool get passwordsMatch {
    return confirmPasswordController.text.isNotEmpty &&
        confirmPasswordController.text == passwordController.text;
  }

  // ============================================================
  // CREATE ACCOUNT
  // ============================================================

  Future<void> createAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final result = await ApiService.registerUser(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully.'),
            backgroundColor: Color.fromARGB(255, 125, 46, 108),
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => widget.loginScreen),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Registration failed'),
            backgroundColor: const Color.fromARGB(255, 255, 82, 252),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to create account: $e'),
          backgroundColor: const Color.fromARGB(255, 255, 82, 200),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // FIELD DECORATION
  // ============================================================

  InputDecoration fieldDecoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,

      prefixIcon: Icon(icon, color: const Color.fromARGB(255, 46, 117, 125)),

      suffixIcon: suffixIcon,

      filled: true,
      fillColor: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.93),

      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: const Color.fromARGB(255, 200, 220, 230),
          width: 1,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Color.fromARGB(255, 46, 122, 125),
          width: 2,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color.fromARGB(255, 255, 82, 229)),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Color.fromARGB(255, 255, 82, 174),
          width: 2,
        ),
      ),
    );
  }

  // ============================================================
  // ANIMATED GRADIENT BACKGROUND
  // ============================================================

  Widget buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: backgroundController,
      builder: (context, child) {
        final value = backgroundController.value;

        final x1 = sin(value * 2 * pi);
        final y1 = cos(value * 2 * pi);

        final x2 = cos(value * 2 * pi);
        final y2 = sin(value * 2 * pi);

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(x1, y1),
              end: Alignment(x2, y2),
              colors: const [
                Color.fromARGB(255, 247, 223, 243),
                Color.fromARGB(255, 232, 236, 246),
                Color.fromARGB(255, 221, 241, 245),
                Color.fromARGB(255, 240, 232, 248),
                Color.fromARGB(255, 242, 216, 239),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // GLOWING ORBS
  // ============================================================

  Widget buildGlowOrb({
    required double left,
    required double top,
    required double size,
    required Color color,
    required double delay,
  }) {
    return AnimatedBuilder(
      animation: backgroundController,
      builder: (context, child) {
        final value = (backgroundController.value + delay) % 1.0;

        final movement = sin(value * 2 * pi) * 30;

        final scale = 0.85 + sin(value * 2 * pi) * 0.12;

        return Positioned(
          left: left,
          top: top + movement,
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.10),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.16),
                    blurRadius: 60,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // FLOATING LEAF
  // ============================================================

  Widget buildFloatingLeaf({
    required double left,
    required double top,
    required double size,
    required double delay,
  }) {
    return AnimatedBuilder(
      animation: backgroundController,
      builder: (context, child) {
        final value = (backgroundController.value + delay) % 1.0;

        final verticalMovement = sin(value * 2 * pi) * 28;

        final horizontalMovement = cos(value * 2 * pi) * 18;

        final rotation = sin(value * 2 * pi) * 0.6;

        return Positioned(
          left: left + horizontalMovement,
          top: top + verticalMovement,
          child: Transform.rotate(
            angle: rotation,
            child: Opacity(
              opacity: 0.20,
              child: Icon(
                Icons.eco,
                size: size,
                color: const Color.fromARGB(255, 116, 46, 125),
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // FLOATING PARTICLE
  // ============================================================

  Widget buildParticle({
    required double left,
    required double top,
    required double size,
    required double delay,
  }) {
    return AnimatedBuilder(
      animation: particleController,
      builder: (context, child) {
        final value = (particleController.value + delay) % 1.0;

        final movement = sin(value * 2 * pi) * 20;

        final opacity = 0.15 + (sin(value * 2 * pi) + 1) * 0.12;

        return Positioned(
          left: left,
          top: top + movement,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color.fromARGB(
                255,
                46,
                99,
                125,
              ).withOpacity(opacity),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // ======================================================
          // ANIMATED BACKGROUND
          // ======================================================
          Positioned.fill(child: buildAnimatedBackground()),

          // ======================================================
          // GLOWING ORBS
          // ======================================================
          buildGlowOrb(
            left: -90,
            top: 50,
            size: 230,
            color: const Color.fromARGB(255, 67, 164, 162),
            delay: 0.0,
          ),

          buildGlowOrb(
            left: screenWidth - 140,
            top: 120,
            size: 240,
            color: const Color(0xFF4C9FB0),
            delay: 0.25,
          ),

          buildGlowOrb(
            left: screenWidth * 0.2,
            top: 620,
            size: 220,
            color: const Color.fromARGB(255, 175, 195, 74),
            delay: 0.5,
          ),

          // ======================================================
          // LEAVES
          // ======================================================
          buildFloatingLeaf(left: 20, top: 100, size: 48, delay: 0.05),

          buildFloatingLeaf(
            left: screenWidth * 0.78,
            top: 130,
            size: 58,
            delay: 0.25,
          ),

          buildFloatingLeaf(
            left: screenWidth * 0.08,
            top: 480,
            size: 42,
            delay: 0.45,
          ),

          buildFloatingLeaf(
            left: screenWidth * 0.82,
            top: 650,
            size: 50,
            delay: 0.7,
          ),

          // ======================================================
          // PARTICLES
          // ======================================================
          buildParticle(left: screenWidth * 0.25, top: 80, size: 8, delay: 0.1),

          buildParticle(
            left: screenWidth * 0.65,
            top: 100,
            size: 6,
            delay: 0.35,
          ),

          buildParticle(
            left: screenWidth * 0.15,
            top: 350,
            size: 7,
            delay: 0.5,
          ),

          buildParticle(
            left: screenWidth * 0.85,
            top: 430,
            size: 9,
            delay: 0.75,
          ),

          buildParticle(
            left: screenWidth * 0.45,
            top: 700,
            size: 6,
            delay: 0.9,
          ),

          // ======================================================
          // MAIN CONTENT
          // ======================================================
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: FadeTransition(
                  opacity: formAnimation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.15),
                      end: Offset.zero,
                    ).animate(formAnimation),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Card(
                        elevation: 20,
                        shadowColor: const Color.fromARGB(
                          255,
                          46,
                          120,
                          125,
                        ).withOpacity(0.22),
                        color: const Color.fromARGB(
                          255,
                          255,
                          255,
                          255,
                        ).withOpacity(0.95),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(screenWidth < 400 ? 20 : 30),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // ==================================================
                                // ANIMATED LOGO
                                // ==================================================
                                AnimatedBuilder(
                                  animation: logoAnimation,
                                  builder: (context, child) {
                                    return Transform.rotate(
                                      angle: logoAnimation.value,
                                      child: child,
                                    );
                                  },
                                  child: Container(
                                    height: 90,
                                    width: 90,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color.fromARGB(255, 164, 67, 151),
                                          Color.fromARGB(255, 123, 40, 120),
                                          Color.fromARGB(255, 61, 96, 160),
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color.fromARGB(
                                            255,
                                            46,
                                            122,
                                            125,
                                          ).withOpacity(0.30),
                                          blurRadius: 28,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.eco,
                                      size: 54,
                                      color: Color.fromARGB(255, 255, 255, 255),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 22),

                                // ==================================================
                                // TITLE
                                // ==================================================
                                const Text(
                                  'Create Account',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 24, 82, 92),
                                  ),
                                ),

                                const SizedBox(height: 8),

                                const Text(
                                  'Start your green journey 🌱',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Color.fromARGB(255, 158, 158, 158),
                                  ),
                                ),

                                const SizedBox(height: 30),

                                // ==================================================
                                // NAME
                                // ==================================================
                                TextFormField(
                                  controller: nameController,
                                  keyboardType: TextInputType.name,
                                  decoration: fieldDecoration(
                                    label: 'Full Name',
                                    hint: 'Enter your full name',
                                    icon: Icons.person_outline,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter your name';
                                    }

                                    return null;
                                  },
                                ),

                                const SizedBox(height: 16),

                                // ==================================================
                                // EMAIL
                                // ==================================================
                                TextFormField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: fieldDecoration(
                                    label: 'Email Address',
                                    hint: 'Enter your email',
                                    icon: Icons.email_outlined,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter your email';
                                    }

                                    if (!RegExp(
                                      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                    ).hasMatch(value.trim())) {
                                      return 'Enter a valid email';
                                    }

                                    return null;
                                  },
                                ),

                                const SizedBox(height: 16),

                                // ==================================================
                                // PASSWORD
                                // ==================================================
                                TextFormField(
                                  controller: passwordController,
                                  obscureText: hidePassword,
                                  decoration: fieldDecoration(
                                    label: 'Password',
                                    hint: 'Create a strong password',
                                    icon: Icons.lock_outline,
                                    suffixIcon: IconButton(
                                      tooltip: hidePassword
                                          ? 'Show password'
                                          : 'Hide password',
                                      icon: Icon(
                                        hidePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: const Color.fromARGB(
                                          255,
                                          46,
                                          113,
                                          125,
                                        ),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          hidePassword = !hidePassword;
                                        });
                                      },
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a password';
                                    }

                                    if (value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }

                                    return null;
                                  },
                                ),

                                // ==================================================
                                // PASSWORD STRENGTH
                                // ==================================================
                                AnimatedSize(
                                  duration: const Duration(milliseconds: 300),
                                  child: passwordController.text.isEmpty
                                      ? const SizedBox()
                                      : Padding(
                                          padding: const EdgeInsets.only(
                                            top: 9,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              TweenAnimationBuilder<double>(
                                                tween: Tween(
                                                  begin: 0,
                                                  end: passwordStrength,
                                                ),
                                                duration: const Duration(
                                                  milliseconds: 350,
                                                ),
                                                builder: (context, value, child) {
                                                  return ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                    child: LinearProgressIndicator(
                                                      value: value,
                                                      minHeight: 8,
                                                      backgroundColor:
                                                          const Color.fromARGB(
                                                            255,
                                                            238,
                                                            238,
                                                            238,
                                                          ),
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                            Color
                                                          >(
                                                            passwordStrengthColor,
                                                          ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              const SizedBox(height: 6),
                                              AnimatedSwitcher(
                                                duration: const Duration(
                                                  milliseconds: 250,
                                                ),
                                                child: Text(
                                                  passwordStrengthText,
                                                  key: ValueKey(
                                                    passwordStrengthText,
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        passwordStrengthColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                ),

                                const SizedBox(height: 16),

                                // ==================================================
                                // CONFIRM PASSWORD
                                // ==================================================
                                TextFormField(
                                  controller: confirmPasswordController,
                                  obscureText: hideConfirmPassword,
                                  decoration: fieldDecoration(
                                    label: 'Confirm Password',
                                    hint: 'Re-enter your password',
                                    icon: Icons.lock_reset_outlined,
                                    suffixIcon:
                                        confirmPasswordController.text.isEmpty
                                        ? IconButton(
                                            icon: Icon(
                                              hideConfirmPassword
                                                  ? Icons.visibility_off
                                                  : Icons.visibility,
                                              color: const Color.fromARGB(
                                                255,
                                                46,
                                                114,
                                                125,
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                hideConfirmPassword =
                                                    !hideConfirmPassword;
                                              });
                                            },
                                          )
                                        : AnimatedSwitcher(
                                            duration: const Duration(
                                              milliseconds: 200,
                                            ),
                                            child: Icon(
                                              passwordsMatch
                                                  ? Icons.check_circle
                                                  : Icons.error,
                                              key: ValueKey(passwordsMatch),
                                              color: passwordsMatch
                                                  ? const Color.fromARGB(
                                                      255,
                                                      46,
                                                      89,
                                                      125,
                                                    )
                                                  : const Color.fromARGB(
                                                      255,
                                                      200,
                                                      82,
                                                      255,
                                                    ),
                                            ),
                                          ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please confirm your password';
                                    }

                                    if (value != passwordController.text) {
                                      return 'Passwords do not match';
                                    }

                                    return null;
                                  },
                                ),

                                // ==================================================
                                // PASSWORD MATCH
                                // ==================================================
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  child: confirmPasswordController.text.isEmpty
                                      ? const SizedBox(key: ValueKey('empty'))
                                      : Padding(
                                          key: ValueKey(passwordsMatch),
                                          padding: const EdgeInsets.only(
                                            top: 8,
                                            left: 5,
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                passwordsMatch
                                                    ? Icons.check_circle
                                                    : Icons.error,
                                                size: 16,
                                                color: passwordsMatch
                                                    ? const Color.fromARGB(
                                                        255,
                                                        46,
                                                        108,
                                                        125,
                                                      )
                                                    : const Color.fromARGB(
                                                        255,
                                                        235,
                                                        255,
                                                        82,
                                                      ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                passwordsMatch
                                                    ? 'Passwords match'
                                                    : 'Passwords do not match',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: passwordsMatch
                                                      ? const Color(0xFF2E7D5B)
                                                      : const Color.fromARGB(
                                                          255,
                                                          241,
                                                          82,
                                                          255,
                                                        ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                ),

                                const SizedBox(height: 26),

                                // ==================================================
                                // ANIMATED CREATE BUTTON
                                // ==================================================
                                AnimatedBuilder(
                                  animation: buttonAnimation,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: isLoading
                                          ? 1
                                          : buttonAnimation.value,
                                      child: child,
                                    );
                                  },
                                  child: SizedBox(
                                    height: 58,
                                    child: ElevatedButton(
                                      onPressed: isLoading
                                          ? null
                                          : createAccount,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                          255,
                                          40,
                                          72,
                                          123,
                                        ),
                                        foregroundColor: const Color.fromARGB(
                                          255,
                                          255,
                                          255,
                                          255,
                                        ),
                                        elevation: 8,
                                        shadowColor: const Color.fromARGB(
                                          255,
                                          46,
                                          89,
                                          125,
                                        ).withOpacity(0.30),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                        ),
                                      ),
                                      child: AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 250,
                                        ),
                                        child: isLoading
                                            ? const Row(
                                                key: ValueKey('loading'),
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    height: 23,
                                                    width: 23,
                                                    child:
                                                        CircularProgressIndicator(
                                                          color: Color.fromARGB(
                                                            255,
                                                            255,
                                                            255,
                                                            255,
                                                          ),
                                                          strokeWidth: 3,
                                                        ),
                                                  ),
                                                  SizedBox(width: 12),
                                                  Text(
                                                    'Creating Account...',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : const Row(
                                                key: ValueKey('create'),
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.person_add_alt_1),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    'Create Account',
                                                    style: TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // ==================================================
                                // LOGIN
                                // ==================================================
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Already have an account?',
                                      style: TextStyle(
                                        color: Color.fromARGB(
                                          255,
                                          158,
                                          158,
                                          158,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                widget.loginScreen,
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        'Login',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(
                                            255,
                                            123,
                                            40,
                                            115,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 5),

                                // ==================================================
                                // SECURITY
                                // ==================================================
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.verified_user_outlined,
                                      size: 16,
                                      color: Color.fromARGB(255, 67, 143, 164),
                                    ),
                                    SizedBox(width: 5),
                                    Flexible(
                                      child: Text(
                                        'Your account is securely protected',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Color.fromARGB(
                                            255,
                                            158,
                                            158,
                                            158,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    backgroundController.dispose();
    logoController.dispose();
    formController.dispose();
    buttonController.dispose();
    particleController.dispose();

    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }
}
