import 'dart:math';

import 'package:flutter/material.dart';

import 'register_screen.dart';
import 'user_session.dart';
import 'main.dart';
import 'admin_dashboard_screen.dart';
import 'api_service.dart';

class LoginScreen extends StatefulWidget {
  final Widget nextScreen;

  const LoginScreen({super.key, required this.nextScreen});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  bool hidePassword = true;
  bool isLoading = false;

  late AnimationController backgroundController;
  late AnimationController logoController;
  late AnimationController formController;
  late AnimationController buttonController;

  late Animation<double> logoAnimation;
  late Animation<double> formAnimation;
  late Animation<double> buttonAnimation;

  @override
  void initState() {
    super.initState();

    // Animated background
    backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Logo animation
    logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    logoAnimation = Tween<double>(
      begin: -0.06,
      end: 0.06,
    ).animate(CurvedAnimation(parent: logoController, curve: Curves.easeInOut));

    // Form animation
    formController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    formAnimation = CurvedAnimation(
      parent: formController,
      curve: Curves.easeOutCubic,
    );

    // Button animation
    buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    buttonAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: buttonController, curve: Curves.easeInOut),
    );

    formController.forward();

    emailController.addListener(_onInputChanged);
    passwordController.addListener(_onInputChanged);
  }

  void _onInputChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  // Email validation
  bool get isEmailValid {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      return false;
    }

    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  // Login
  Future<void> login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final apiResult = await ApiService.loginUser(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      Map<String, dynamic>? user;
      String? authToken;

      if (apiResult['success'] == true && apiResult['user'] is Map) {
        user = Map<String, dynamic>.from(apiResult['user'] as Map);
        authToken = apiResult['token']?.toString();
      }

      if (!mounted) return;

      if (user != null) {
        UserSession.setUser(
          name: user['name']?.toString() ?? 'Tree Plantation User',
          email: user['email']?.toString() ?? emailController.text.trim(),
          role: user['role']?.toString() ?? 'USER',
          authToken: authToken,
          userIdValue: user['user_id']?.toString() ??
              user['id']?.toString() ??
              user['userId']?.toString(),
        );

        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              UserSession.isAdmin
                  ? 'Admin login successful! Welcome, Admin'
                  : 'Login successful! Welcome back',
            ),
            backgroundColor: const Color.fromARGB(255, 46, 72, 125),
            behavior: SnackBarBehavior.floating,
          ),
        );

        final Widget destination = UserSession.isAdmin
            ? AdminDashboardScreen(username: UserSession.userName)
            : DashboardScreen(username: UserSession.userName);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      } else {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              apiResult['message']?.toString() ??
                  'Email or password is incorrect.',
            ),
            backgroundColor: const Color.fromARGB(255, 82, 151, 203),
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
          content: Text('Unable to sign in: $e'),
          backgroundColor: const Color.fromARGB(255, 203, 82, 120),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Input field decoration
  InputDecoration fieldDecoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color.fromARGB(255, 125, 46, 95)),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withOpacity(0.92),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color.fromARGB(255, 200, 222, 230)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Color.fromARGB(255, 125, 46, 101),
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Color.fromARGB(255, 255, 82, 229),
          width: 2,
        ),
      ),
    );
  }

  // Animated background
  Widget buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: backgroundController,
      builder: (context, child) {
        final value = backgroundController.value;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(
                -1 + sin(value * 2 * pi) * 0.4,
                -1 + cos(value * 2 * pi) * 0.3,
              ),
              end: Alignment(
                1 + cos(value * 2 * pi) * 0.3,
                1 + sin(value * 2 * pi) * 0.4,
              ),
              colors: const [
                Color.fromARGB(255, 232, 241, 248),
                Color.fromARGB(255, 242, 217, 234),
                Color.fromARGB(255, 231, 235, 248),
                Color.fromARGB(255, 233, 238, 249),
                Color.fromARGB(255, 243, 221, 236),
              ],
            ),
          ),
        );
      },
    );
  }

  // Floating glow circles
  Widget buildGlow({
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

        final movement = sin(value * 2 * pi) * 25;

        return Positioned(
          left: left,
          top: top + movement,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.12),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.15),
                  blurRadius: 50,
                  spreadRadius: 15,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Floating leaves
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

        final verticalMovement = sin(value * 2 * pi) * 25;

        final rotation = sin(value * 2 * pi) * 0.5;

        return Positioned(
          left: left,
          top: top + verticalMovement,
          child: Transform.rotate(
            angle: rotation,
            child: Opacity(
              opacity: 0.18,
              child: Icon(
                Icons.eco,
                size: size,
                color: const Color.fromARGB(255, 121, 46, 125),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    backgroundController.dispose();
    logoController.dispose();
    formController.dispose();
    buttonController.dispose();

    emailController.removeListener(_onInputChanged);
    passwordController.removeListener(_onInputChanged);

    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(child: buildAnimatedBackground()),

          // Glowing circles
          buildGlow(
            left: -80,
            top: 80,
            size: 220,
            color: const Color.fromARGB(255, 67, 158, 164),
            delay: 0.0,
          ),

          buildGlow(
            left: screenWidth - 140,
            top: 160,
            size: 230,
            color: const Color.fromARGB(255, 76, 123, 176),
            delay: 0.25,
          ),

          buildGlow(
            left: screenWidth * 0.25,
            top: 600,
            size: 200,
            color: const Color.fromARGB(255, 173, 195, 74),
            delay: 0.5,
          ),

          // Floating leaves
          buildFloatingLeaf(left: 25, top: 110, size: 45, delay: 0.1),

          buildFloatingLeaf(
            left: screenWidth * 0.82,
            top: 120,
            size: 55,
            delay: 0.3,
          ),

          buildFloatingLeaf(
            left: screenWidth * 0.12,
            top: 500,
            size: 40,
            delay: 0.5,
          ),

          buildFloatingLeaf(
            left: screenWidth * 0.78,
            top: 620,
            size: 48,
            delay: 0.7,
          ),

          // Login form
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: FadeTransition(
                  opacity: formAnimation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.12),
                      end: Offset.zero,
                    ).animate(formAnimation),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Card(
                        elevation: 18,
                        shadowColor: const Color.fromARGB(
                          255,
                          125,
                          46,
                          105,
                        ).withOpacity(0.22),
                        color: Colors.white.withOpacity(0.94),
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
                                // Logo
                                Center(
                                  child: AnimatedBuilder(
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
                                            Color.fromARGB(255, 164, 67, 135),
                                            Color.fromARGB(255, 36, 98, 123),
                                            Color.fromARGB(255, 153, 61, 160),
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color.fromARGB(
                                              255,
                                              46,
                                              108,
                                              125,
                                            ).withOpacity(0.28),
                                            blurRadius: 25,
                                            spreadRadius: 5,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.eco,
                                        size: 54,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 22),

                                // Title
                                const Text(
                                  'Welcome Back',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 24, 71, 92),
                                  ),
                                ),

                                const SizedBox(height: 8),

                                const Text(
                                  'Login to Tree Plantation Tracker 🌱',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Color.fromARGB(255, 158, 158, 158),
                                  ),
                                ),

                                const SizedBox(height: 30),

                                // Email field
                                TextFormField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  autocorrect: false,
                                  decoration: fieldDecoration(
                                    label: 'Email Address',
                                    hint: 'Enter your registered email',
                                    icon: Icons.email_outlined,
                                    suffixIcon: emailController.text.isEmpty
                                        ? null
                                        : Icon(
                                            isEmailValid
                                                ? Icons.check_circle
                                                : Icons.error_outline,
                                            color: isEmailValid
                                                ? const Color.fromARGB(
                                                    255,
                                                    107,
                                                    46,
                                                    125,
                                                  )
                                                : Colors.red,
                                          ),
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

                                const SizedBox(height: 18),

                                // Password field
                                TextFormField(
                                  controller: passwordController,
                                  obscureText: hidePassword,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) {
                                    if (!isLoading) {
                                      login();
                                    }
                                  },
                                  decoration: fieldDecoration(
                                    label: 'Password',
                                    hint: 'Enter your password',
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
                                          103,
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
                                      return 'Please enter your password';
                                    }

                                    return null;
                                  },
                                ),

                                // Password message
                                AnimatedSize(
                                  duration: const Duration(milliseconds: 250),
                                  child: passwordController.text.isEmpty
                                      ? const SizedBox.shrink()
                                      : const Padding(
                                          padding: EdgeInsets.only(top: 8),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.security,
                                                size: 16,
                                                color: Color.fromARGB(
                                                  255,
                                                  67,
                                                  146,
                                                  164,
                                                ),
                                              ),
                                              SizedBox(width: 6),
                                              Text(
                                                'Password entered securely',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color.fromARGB(
                                                    255,
                                                    117,
                                                    117,
                                                    117,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                ),

                                const SizedBox(height: 22),

                                // Login button
                                AnimatedBuilder(
                                  animation: buttonAnimation,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: isLoading
                                          ? 1.0
                                          : buttonAnimation.value,
                                      child: child,
                                    );
                                  },
                                  child: SizedBox(
                                    height: 58,
                                    child: ElevatedButton(
                                      onPressed: isLoading ? null : login,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                          255,
                                          40,
                                          99,
                                          123,
                                        ),
                                        foregroundColor: Colors.white,
                                        elevation: 7,
                                        shadowColor: const Color.fromARGB(
                                          255,
                                          40,
                                          94,
                                          123,
                                        ).withOpacity(0.3),
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
                                                          color: Colors.white,
                                                          strokeWidth: 3,
                                                        ),
                                                  ),
                                                  SizedBox(width: 12),
                                                  Text(
                                                    'Logging in...',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : const Row(
                                                key: ValueKey('login'),
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.login_rounded),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    'Login',
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

                                const SizedBox(height: 22),

                                // Divider
                                Row(
                                  children: [
                                    const Expanded(
                                      child: Divider(
                                        color: Color.fromARGB(
                                          255,
                                          224,
                                          224,
                                          224,
                                        ),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      child: Text(
                                        'OR',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color.fromARGB(
                                            255,
                                            158,
                                            158,
                                            158,
                                          ),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const Expanded(
                                      child: Divider(
                                        color: Color.fromARGB(
                                          255,
                                          224,
                                          224,
                                          224,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 18),

                                // Registration navigation
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Flexible(
                                      child: Text(
                                        "Don't have an account? ",
                                        style: TextStyle(
                                          color: Color.fromARGB(
                                            255,
                                            158,
                                            158,
                                            158,
                                          ),
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                RegisterScreen(
                                                  loginScreen: LoginScreen(
                                                    nextScreen:
                                                        widget.nextScreen,
                                                  ),
                                                ),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        'Register',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Color.fromARGB(
                                            255,
                                            40,
                                            99,
                                            123,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 5),

                                // Security message
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.verified_user_outlined,
                                      size: 16,
                                      color: Color.fromARGB(255, 67, 130, 164),
                                    ),
                                    SizedBox(width: 5),
                                    Flexible(
                                      child: Text(
                                        'Secure login protected by your account',
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
}
