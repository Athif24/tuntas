import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../database/database_helper.dart';
import '../providers/theme_provider.dart';
import '../utils/theme_config.dart';
import '../widgets/nav_button.dart';
import '../widgets/summary_card.dart';
import '../widgets/weekly_bar_chart.dart';
import 'tambah_tugas_screen.dart';
import 'daftar_tugas_screen.dart';
import 'pengaturan_screen.dart';

class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  int _doneTasks    = 0;
  int _pendingTasks = 0;
  String _username  = 'User';
  bool _isLoading = true;
  final _db = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final done    = await _db.getTaskCountDone();
    final pending = await _db.getTaskCountPending();
    final user    = await _db.getUser();

    setState(() {
      _doneTasks    = done;
      _pendingTasks = pending;
      _username     = user?['username'] ?? 'User';
      _isLoading    = false;
    });
  }

  Widget _buildLoading() {
    final currentTheme = Provider.of<ThemeProvider>(context, listen: false).currentTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(currentTheme.accentColor),
          ),
          const SizedBox(height: 16),
          Text(
            'Memuat...',
            style: GoogleFonts.poppins(
              color: currentTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentTheme = themeProvider.currentTheme;
    final today = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now());

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
                _buildAppBar(),

                Expanded(
                  child: _isLoading
                      ? _buildLoading()
                      : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, $_username! 👋',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: currentTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          today,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: currentTheme.textSecondary,
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(child: SummaryCard(
                              label: 'TUGAS SELESAI',
                              count: _doneTasks,
                              valueColor: AppTheme.fixedGreen,
                            )),
                            const SizedBox(width: 12),
                            Expanded(child: SummaryCard(
                              label: 'BELUM SELESAI',
                              count: _pendingTasks,
                              valueColor: AppTheme.fixedRed,
                            )),
                          ],
                        ),

                        const SizedBox(height: 16),

                        const WeeklyBarChart(),

                        const SizedBox(height: 16),

                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.25,
                          children: [
                            NavButton(
                              label: 'Tambah Tugas Penting',
                              icon: Icons.add_circle_outline_rounded,
                              dotColor: AppTheme.fixedRed,
                              onTap: () {
                                Navigator.push(context,
                                  MaterialPageRoute(builder: (_) =>
                                    const TambahTugasScreen(category: 'penting')),
                                ).then((result) {
                                  _loadData();
                                  if (result == true && mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Tugas Penting berhasil ditambahkan',
                                            style: GoogleFonts.poppins(color: Colors.white)),
                                        backgroundColor: const Color(0xFF43A047),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                });
                              },
                            ),
                            NavButton(
                              label: 'Tambah Tugas Biasa',
                              icon: Icons.add_circle_outline_rounded,
                              dotColor: AppTheme.fixedGreen,
                              onTap: () {
                                Navigator.push(context,
                                  MaterialPageRoute(builder: (_) =>
                                    const TambahTugasScreen(category: 'biasa')),
                                ).then((result) {
                                  _loadData();
                                  if (result == true && mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Tugas Biasa berhasil ditambahkan',
                                            style: GoogleFonts.poppins(color: Colors.white)),
                                        backgroundColor: const Color(0xFF43A047),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                });
                              },
                            ),
                            NavButton(
                              label: 'Daftar Tugas',
                              icon: Icons.list_alt_rounded,
                              dotColor: AppTheme.fixedBlue,
                              onTap: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) =>
                                  const DaftarTugasScreen()),
                              ).then((_) => _loadData()),
                            ),
                            NavButton(
                              label: 'Pengaturan',
                              icon: Icons.settings_outlined,
                              dotColor: AppTheme.fixedGray,
                              onTap: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) =>
                                  const PengaturanScreen())),
                            ),
                          ],
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

  Widget _buildAppBar() {
    final currentTheme = Provider.of<ThemeProvider>(context).currentTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: currentTheme.textPrimary.withValues(alpha: 0.04),
        border: Border(
          bottom: BorderSide(color: currentTheme.textPrimary.withValues(alpha: 0.07), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [currentTheme.accentColor, currentTheme.errorColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.edit_note_rounded,
                color: currentTheme.textPrimary, size: 18),
          ),
          const SizedBox(width: 10),
          Text(
            'Beranda',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: currentTheme.textPrimary,
            ),
          ),
        ],
      ),
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
      paint.color   = starColor.withValues(alpha: alpha);
      canvas.drawCircle(
        Offset(s.x * size.width, s.y * size.height),
        s.size, paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StarPainter old) => old.animValue != animValue;
}
