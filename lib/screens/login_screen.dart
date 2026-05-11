import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../database/database_helper.dart';
import '../providers/theme_provider.dart';
import '../utils/theme_config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _errorMessage;
  final _db = DatabaseHelper.instance;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => _errorMessage = null);
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Username dan password harus diisi');
      return;
    }

    final user = await _db.getUser();
    if (user != null &&
        username == user['username'] &&
        password == user['password']) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/beranda');
      }
    } else if (mounted) {
      final theme = Provider.of<ThemeProvider>(context, listen: false).currentTheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Username atau password salah',
              style: GoogleFonts.poppins(color: theme.textPrimary)),
          backgroundColor: theme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentTheme = themeProvider.currentTheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: currentTheme.gradientColors != null
              ? LinearGradient(
                  colors: currentTheme.gradientColors!,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : currentTheme.bgTop != null && currentTheme.bgBottom != null
                  ? LinearGradient(
                      colors: [currentTheme.bgTop!, currentTheme.bgBottom!],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    )
                  : null,
          color: currentTheme.bgSolid ?? currentTheme.bgBottom,
        ),
        child: Stack(
          children: [
            if (currentTheme.hasStarField) const _StarField(),

            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [currentTheme.accentColor, currentTheme.errorColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: currentTheme.errorColor.withValues(alpha:0.45),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.edit_note_rounded,
                          color: currentTheme.textPrimary,
                          size: 38,
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        'Tuntas',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: currentTheme.textPrimary,
                          letterSpacing: 0.3,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'TUNTASKAN HARI INI',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: currentTheme.textPrimary.withValues(alpha:0.4),
                          letterSpacing: 2.5,
                        ),
                      ),

                      const SizedBox(height: 40),

                      _buildFieldLabel('USERNAME'),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: _usernameController,
                        hint: 'Masukkan username',
                        icon: Icons.person_outline_rounded,
                        obscure: false,
                        action: TextInputAction.next,
                      ),

                      const SizedBox(height: 18),

                      _buildFieldLabel('PASSWORD'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _handleLogin(),
                        style: GoogleFonts.poppins(
                          color: currentTheme.textPrimary,
                          fontSize: 13,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Masukkan password',
                          hintStyle: GoogleFonts.poppins(
                            color: currentTheme.textHint,
                            fontSize: 13,
                          ),
                          prefixIcon: Icon(Icons.lock_outline_rounded, color: currentTheme.textSecondary, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                              color: currentTheme.textSecondary,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: currentTheme.cardBg,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: currentTheme.cardBorder, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: currentTheme.accentColor.withValues(alpha:0.5), width: 1.2),
                          ),
                        ),
                      ),

                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.error_outline,
                                color: currentTheme.errorColor, size: 15),
                            const SizedBox(width: 6),
                            Text(
                              _errorMessage!,
                              style: GoogleFonts.poppins(
                                color: currentTheme.errorColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 28),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: currentTheme.textPrimary.withValues(alpha:0.92),
                            foregroundColor: currentTheme.bgBottom ?? currentTheme.bgSolid ?? Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'MASUK',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.0,
                              color: currentTheme.bgBottom ?? currentTheme.bgSolid ?? Colors.black,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      Text(
                        'Tuntas v1.0',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: currentTheme.textPrimary.withValues(alpha:0.25),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _dot(false, currentTheme),
                          const SizedBox(width: 5),
                          _dot(true, currentTheme),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    final currentTheme = Provider.of<ThemeProvider>(context, listen: false).currentTheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: currentTheme.textSecondary,
          letterSpacing: 1.8,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool obscure,
    required TextInputAction action,
    ValueChanged<String>? onSubmit,
  }) {
    final currentTheme = Provider.of<ThemeProvider>(context, listen: false).currentTheme;
    return TextField(
      controller: controller,
      obscureText: obscure,
      textInputAction: action,
      onSubmitted: onSubmit,
      style: GoogleFonts.poppins(
        color: currentTheme.textPrimary,
        fontSize: 13,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          color: currentTheme.textHint,
          fontSize: 13,
        ),
        prefixIcon: Icon(icon, color: currentTheme.textSecondary, size: 20),
        filled: true,
        fillColor: currentTheme.cardBg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: currentTheme.cardBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: currentTheme.accentColor.withValues(alpha:0.5), width: 1.2),
        ),
      ),
    );
  }

  Widget _dot(bool active, AppTheme currentTheme) => Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          color: active
              ? currentTheme.textPrimary.withValues(alpha:0.6)
              : currentTheme.textPrimary.withValues(alpha:0.2),
          shape: BoxShape.circle,
        ),
      );
}

class _StarField extends StatefulWidget {
  const _StarField();

  @override
  State<_StarField> createState() => _StarFieldState();
}

class _StarFieldState extends State<_StarField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Star> _stars = [];
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..repeat(reverse: true);
    for (int i = 0; i < 55; i++) {
      _stars.add(_Star(
        x: _rng.nextDouble(),
        y: _rng.nextDouble(),
        size: _rng.nextDouble() * 2.0 + 0.8,
        opacity: _rng.nextDouble() * 0.5 + 0.2,
        phase: _rng.nextDouble(),
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Provider.of<ThemeProvider>(context).currentTheme;
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return CustomPaint(
          painter: _StarPainter(_stars, _controller.value, currentTheme.textPrimary),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _Star {
  final double x, y, size, opacity, phase;
  const _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.phase,
  });
}

class _StarPainter extends CustomPainter {
  final List<_Star> stars;
  final double animValue;
  final Color starColor;
  _StarPainter(this.stars, this.animValue, this.starColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final s in stars) {
      final twinkle = (sin((animValue + s.phase) * pi)).abs();
      final alpha = (s.opacity * (0.4 + 0.6 * twinkle)).clamp(0.0, 1.0);
      paint.color = starColor.withValues(alpha:alpha);
      canvas.drawCircle(
        Offset(s.x * size.width, s.y * size.height),
        s.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StarPainter old) => old.animValue != animValue;
}
