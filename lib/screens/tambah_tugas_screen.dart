import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../database/database_helper.dart';
import '../providers/theme_provider.dart';
import '../utils/theme_config.dart';

class TambahTugasScreen extends StatefulWidget {
  final String category;
  final Map<String, dynamic>? task;

  const TambahTugasScreen({super.key, required this.category, this.task});

  @override
  State<TambahTugasScreen> createState() => _TambahTugasScreenState();
}

class _TambahTugasScreenState extends State<TambahTugasScreen> {
  DateTime? _selectedDate;
  final _titleController = TextEditingController();
  final _descController  = TextEditingController();
  final _db = DatabaseHelper.instance;

  bool get _isEditMode => widget.task != null;

  Color get _themeColor {
    return widget.category == 'penting' ? AppTheme.fixedRed : AppTheme.fixedGreen;
  }

  String get _screenTitle {
    if (_isEditMode) return 'Ubah Tugas';
    return widget.category == 'penting' ? 'Tambah Tugas Penting' : 'Tambah Tugas Biasa';
  }

  String get _titleHint =>
      widget.category == 'penting'
          ? 'Contoh: Submit laporan akhir'
          : 'Contoh: Beli buah di pasar';

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _titleController.text = widget.task!['title'] ?? '';
      _descController.text = widget.task!['description'] ?? '';
      try {
        _selectedDate = DateTime.parse(widget.task!['due_date'] as String);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final currentTheme = Provider.of<ThemeProvider>(context, listen: false).currentTheme;
    final now = DateTime.now();
    final initialDate = _selectedDate ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: now.add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: _themeColor,
              onPrimary: currentTheme.textPrimary,
              surface: currentTheme.bgTop ?? currentTheme.bgSolid ?? Colors.grey[900]!,
              onSurface: currentTheme.textPrimary,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: currentTheme.bgBottom ?? currentTheme.bgSolid,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<bool> _showExitConfirmation() async {
    final currentTheme = Provider.of<ThemeProvider>(context, listen: false).currentTheme;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: currentTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Batal Menambah Tugas?',
          style: GoogleFonts.poppins(
            color: currentTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Tugas yang belum disimpan akan hilang.',
          style: GoogleFonts.poppins(color: currentTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Tidak',
              style: GoogleFonts.poppins(color: currentTheme.errorColor),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Ya',
              style: GoogleFonts.poppins(color: currentTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _saveTask() async {
    final currentTheme = Provider.of<ThemeProvider>(context, listen: false).currentTheme;
    if (_selectedDate == null ||
        _titleController.text.trim().isEmpty ||
        _descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Harap lengkapi semua field',
              style: GoogleFonts.poppins(color: currentTheme.textPrimary)),
          backgroundColor: currentTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

if (_isEditMode) {
      await _db.updateTask(widget.task!['id'] as int, {
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'due_date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
      });
      if (mounted) Navigator.pop(context, true);
    } else {
      await _db.insertTask({
        'title':       _titleController.text.trim(),
        'description': _descController.text.trim(),
        'due_date':    DateFormat('yyyy-MM-dd').format(_selectedDate!),
        'category':    widget.category,
        'is_done':     0,
        'created_at':  DateFormat('yyyy-MM-dd').format(DateTime.now()),
      });
      if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentTheme = themeProvider.currentTheme;
    final themeColor = widget.category == 'penting' ? AppTheme.fixedRed : AppTheme.fixedGreen;

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
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBadge(themeColor, currentTheme),

                        const SizedBox(height: 24),

                        _fieldLabel('TANGGAL JATUH TEMPO', currentTheme),
                        const SizedBox(height: 8),
                        _buildDatePicker(themeColor, currentTheme),

                        const SizedBox(height: 20),

                        _fieldLabel('JUDUL TUGAS', currentTheme),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _titleController,
                          hint: _titleHint,
                          maxLines: 1,
                          action: TextInputAction.next,
                          currentTheme: currentTheme,
                        ),

                        const SizedBox(height: 20),

                        _fieldLabel('DESKRIPSI', currentTheme),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _descController,
                          hint: 'Jelaskan tugas secara detail...',
                          maxLines: 5,
                          action: TextInputAction.done,
                          currentTheme: currentTheme,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            left: 0, right: 0, bottom: 0,
            child: _buildSaveButton(currentTheme),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final currentTheme = Provider.of<ThemeProvider>(context).currentTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: currentTheme.textPrimary.withValues(alpha:0.04),
        border: Border(
          bottom: BorderSide(color: currentTheme.textPrimary.withValues(alpha:0.07), width: 0.5),
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
                border: Border.all(color: currentTheme.textPrimary.withValues(alpha:0.12)),
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  color: currentTheme.textPrimary, size: 16),
            ),
            onPressed: () async {
              final shouldPop = await _showExitConfirmation();
              if (shouldPop && mounted) {
                Navigator.pop(context);
              }
            },
          ),
          const SizedBox(width: 4),
          Text(
            _screenTitle,
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

  Widget _buildBadge(Color themeColor, AppTheme currentTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: themeColor.withValues(alpha:0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: themeColor.withValues(alpha:0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: themeColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            widget.category.toUpperCase(),
            style: GoogleFonts.poppins(
              color: themeColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String text, AppTheme currentTheme) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: currentTheme.textSecondary,
        letterSpacing: 1.8,
      ),
    );
  }

  Widget _buildDatePicker(Color themeColor, AppTheme currentTheme) {
    final hasDate = _selectedDate != null;
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: currentTheme.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasDate
                ? themeColor.withValues(alpha:0.4)
                : currentTheme.cardBorder,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_month_outlined,
                color: hasDate ? themeColor : currentTheme.textSecondary,
                size: 20),
            const SizedBox(width: 10),
            Text(
              hasDate
                  ? DateFormat('dd MMM yyyy').format(_selectedDate!)
                  : 'Pilih tanggal',
              style: GoogleFonts.poppins(
                color: hasDate ? currentTheme.textPrimary : currentTheme.textHint,
                fontSize: 14,
                fontWeight: hasDate ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required int maxLines,
    required TextInputAction action,
    required AppTheme currentTheme,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      textInputAction: action,
      style: GoogleFonts.poppins(color: currentTheme.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          color: currentTheme.textHint,
          fontSize: 13,
        ),
        filled: true,
        fillColor: currentTheme.cardBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: currentTheme.cardBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _themeColor.withValues(alpha:0.5), width: 1.2),
        ),
      ),
    );
  }

  Widget _buildSaveButton(AppTheme currentTheme) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        decoration: BoxDecoration(
          color: (currentTheme.bgSolid ?? currentTheme.bgBottom ?? Colors.black).withValues(alpha:0.95),
          border: Border(
            top: BorderSide(color: currentTheme.textPrimary.withValues(alpha:0.07), width: 0.5),
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saveTask,
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
                              _isEditMode ? 'SIMPAN PERUBAHAN' : 'SIMPAN TUGAS',
                              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0,
                color: currentTheme.bgBottom ?? currentTheme.bgSolid ?? Colors.black,
              ),
            ),
          ),
        ),
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
