import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../database/database_helper.dart';
import '../providers/theme_provider.dart';

class PengaturanScreen extends StatefulWidget {
  const PengaturanScreen({super.key});

  @override
  State<PengaturanScreen> createState() => _PengaturanScreenState();
}

class _PengaturanScreenState extends State<PengaturanScreen> {
  final _currentPassController = TextEditingController();
  final _newPassController     = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool _showPassword = false;
  final _db = DatabaseHelper.instance;

  @override
  void dispose() {
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final user = await _db.getUser();
    if (user == null) return;

    final current = _currentPassController.text;
    final newPass = _newPassController.text.trim();
    final confirm = _confirmPassController.text.trim();

    if (current.isEmpty) {
      _showSnack('Password saat ini harus diisi', isError: true);
      return;
    }
    if (newPass.isEmpty) {
      _showSnack('Password baru tidak boleh kosong', isError: true);
      return;
    }
    if (confirm.isEmpty) {
      _showSnack('Konfirmasi password harus diisi', isError: true);
      return;
    }
    if (current != user['password']) {
      _showSnack('Password saat ini salah', isError: true);
      return;
    }
    if (newPass != confirm) {
      _showSnack('Konfirmasi password tidak cocok', isError: true);
      return;
    }

    await _db.updatePassword(newPass);
    _currentPassController.clear();
    _newPassController.clear();
    _confirmPassController.clear();
    if (mounted) _showSnack('Password berhasil diubah');
  }

  void _showSnack(String msg, {bool isError = false}) {
    final theme = Provider.of<ThemeProvider>(context, listen: false).currentTheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins(color: theme.textPrimary)),
        backgroundColor: isError ? theme.errorColor : theme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _confirmLogout() {
    final currentTheme = Provider.of<ThemeProvider>(context, listen: false).currentTheme;
    final Color dialogBg = currentTheme.isDark 
        ? const Color(0xFF1E1E1E) 
        : Colors.white;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: dialogBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Konfirmasi Keluar',
          style: GoogleFonts.poppins(
            color: currentTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Yakin ingin keluar dari aplikasi?',
          style: GoogleFonts.poppins(
            color: currentTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(color: currentTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/');
            },
            child: Text(
              'Keluar',
              style: GoogleFonts.poppins(color: currentTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLogoutCard() {
    final currentTheme = Provider.of<ThemeProvider>(context, listen: false).currentTheme;
    return GestureDetector(
      onTap: _confirmLogout,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: currentTheme.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: currentTheme.cardBorder, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: currentTheme.errorColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.logout_rounded,
                  color: currentTheme.errorColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'KELUAR',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: currentTheme.errorColor,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: currentTheme.errorColor.withValues(alpha: 0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeBottomSheet(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final themes = themeProvider.themes;
    final currentTheme = themeProvider.currentTheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: currentTheme.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('PILIH TEMA',
                style: GoogleFonts.poppins(
                    color: currentTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.0)),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
              children: themes.asMap().entries.map((entry) {
                final index = entry.key;
                final theme = entry.value;
                final isSelected = index == themeProvider.selectedThemeIndex;

                return GestureDetector(
                  onTap: () {
                    themeProvider.setTheme(index);
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.cardBg,
                      border: Border.all(
                        color: isSelected ? theme.accentColor : theme.cardBorder,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            gradient: theme.gradientColors != null
                                ? LinearGradient(colors: theme.gradientColors!)
                                : null,
                            color: theme.gradientColors == null ? theme.bgSolid ?? theme.bgBottom : null,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(theme.name,
                            style: GoogleFonts.poppins(
                                color: theme.textPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                        if (isSelected) ...[
                          const SizedBox(height: 4),
                          Container(width: 8, height: 8,
                              decoration: BoxDecoration(color: theme.accentColor, shape: BoxShape.circle)),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentTheme = themeProvider.currentTheme;

    return Scaffold(
      backgroundColor: currentTheme.bgSolid ?? currentTheme.bgBottom,
      body: Stack(
        children: [
          if (currentTheme.gradientColors != null)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: currentTheme.gradientColors!,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            )
          else if (currentTheme.bgTop != null && currentTheme.bgBottom != null)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [currentTheme.bgTop!, currentTheme.bgBottom!],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

          if (currentTheme.hasStarField) const _StarField(),

          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionLabel('KEAMANAN AKUN'),
                        const SizedBox(height: 12),

                        _GlassCard(
                          child: Column(
                            children: [
                              _buildPassField(
                                label: 'PASSWORD SAAT INI',
                                hint: 'Masukkan password lama',
                                controller: _currentPassController,
                                action: TextInputAction.next,
                              ),
                              _divider(),
                              _buildPassField(
                                label: 'PASSWORD BARU',
                                hint: 'Masukkan password baru',
                                controller: _newPassController,
                                action: TextInputAction.next,
                              ),
                              _divider(),
                              _buildPassField(
                                label: 'KONFIRMASI PASSWORD',
                                hint: 'Ulangi password baru',
                                controller: _confirmPassController,
                                action: TextInputAction.done,
                                onSubmit: (_) => _changePassword(),
                                isLast: true,
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: Checkbox(
                                      value: _showPassword,
                                      onChanged: (_) => setState(() => _showPassword = !_showPassword),
                                      activeColor: currentTheme.accentColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      side: BorderSide(color: currentTheme.textSecondary, width: 1.5),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Tampilkan Kata Sandi',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: currentTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _changePassword,
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
                              'SIMPAN PASSWORD',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2.0,
                                color: currentTheme.bgBottom ?? currentTheme.bgSolid ?? Colors.black,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        _sectionLabel('AKUN'),
                        const SizedBox(height: 12),

                        buildLogoutCard(),

                        const SizedBox(height: 32),

                        _sectionLabel('DEVELOPER'),
                        const SizedBox(height: 12),

                        _GlassCard(
                          child: Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [currentTheme.successColor, currentTheme.successColor.withValues(alpha:0.7)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(Icons.person_rounded,
                                    color: currentTheme.textPrimary, size: 28),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Muhammad \'Athif Attaqy',
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: currentTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'NIM: 2241760107',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: currentTheme.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'DEVELOPER APLIKASI',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: currentTheme.successColor,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentTheme = themeProvider.currentTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: currentTheme.textPrimary.withValues(alpha:0.04),
        border: Border(
          bottom: BorderSide(
              color: currentTheme.textPrimary.withValues(alpha:0.07), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: currentTheme.textPrimary.withValues(alpha:0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: currentTheme.textPrimary.withValues(alpha:0.12), width: 1),
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  color: currentTheme.textPrimary, size: 16),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          Text(
            'Pengaturan',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: currentTheme.textPrimary,
            ),
          ),
          const Spacer(),
          Stack(
            children: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: currentTheme.textPrimary.withValues(alpha:0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: currentTheme.textPrimary.withValues(alpha:0.12), width: 1),
                  ),
                  child: Icon(Icons.color_lens_rounded,
                      color: currentTheme.textPrimary, size: 16),
                ),
                onPressed: () => _showThemeBottomSheet(context),
              ),
              Positioned(
                right: 6,
                bottom: 6,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: currentTheme.accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    final currentTheme = Provider.of<ThemeProvider>(context, listen: false).currentTheme;
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: currentTheme.textSecondary,
        letterSpacing: 2.0,
      ),
    );
  }

  Widget _divider() {
    final currentTheme = Provider.of<ThemeProvider>(context, listen: false).currentTheme;
    return Divider(
      color: currentTheme.textPrimary.withValues(alpha:0.07),
      height: 1,
      thickness: 1,
    );
  }

  Widget _buildPassField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required TextInputAction action,
    ValueChanged<String>? onSubmit,
    bool isLast = false,
  }) {
    final currentTheme = Provider.of<ThemeProvider>(context, listen: false).currentTheme;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: currentTheme.textSecondary,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            obscureText: !_showPassword,
            textInputAction: action,
            onSubmitted: onSubmit,
            style: GoogleFonts.poppins(color: currentTheme.textPrimary, fontSize: 13),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                color: currentTheme.textHint,
                fontSize: 13,
              ),
              prefixIcon: Icon(Icons.lock_outline_rounded,
                  color: currentTheme.textSecondary, size: 18),
              filled: true,
              fillColor: currentTheme.textPrimary.withValues(alpha:0.05),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    BorderSide(color: currentTheme.textPrimary.withValues(alpha:0.08), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    color: currentTheme.successColor.withValues(alpha:0.5), width: 1.2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final currentTheme = Provider.of<ThemeProvider>(context).currentTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: currentTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: currentTheme.cardBorder, width: 1),
      ),
      child: child,
    );
  }
}

class _StarField extends StatefulWidget {
  const _StarField();
  @override
  State<_StarField> createState() => _StarFieldState();
}

class _StarFieldState extends State<_StarField>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  final _stars = <_Star>[];
  final _rng   = Random();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    for (int i = 0; i < 55; i++) {
      _stars.add(_Star(
        x:       _rng.nextDouble(),
        y:       _rng.nextDouble(),
        size:    _rng.nextDouble() * 2.0 + 0.8,
        opacity: _rng.nextDouble() * 0.5 + 0.2,
        phase:   _rng.nextDouble(),
      ));
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Provider.of<ThemeProvider>(context).currentTheme;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        painter: _StarPainter(_stars, _ctrl.value, currentTheme.textPrimary),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _Star {
  final double x, y, size, opacity, phase;
  const _Star({required this.x, required this.y, required this.size,
               required this.opacity, required this.phase});
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
      final twinkle = sin((animValue + s.phase) * pi).abs();
      final alpha   = (s.opacity * (0.4 + 0.6 * twinkle)).clamp(0.0, 1.0);
      paint.color   = starColor.withValues(alpha:alpha);
      canvas.drawCircle(
        Offset(s.x * size.width, s.y * size.height),
        s.size, paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StarPainter old) => old.animValue != animValue;
}
