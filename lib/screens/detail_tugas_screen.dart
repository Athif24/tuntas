import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../database/database_helper.dart';
import '../providers/theme_provider.dart';
import '../utils/theme_config.dart';

class DetailTugasScreen extends StatefulWidget {
  final Map<String, dynamic> task;
  const DetailTugasScreen({super.key, required this.task});

  @override
  State<DetailTugasScreen> createState() => _DetailTugasScreenState();
}

class _DetailTugasScreenState extends State<DetailTugasScreen> {
  late Map<String, dynamic> _taskData;

  @override
  void initState() {
    super.initState();
    _taskData = Map<String, dynamic>.from(widget.task);
  }

  Future<void> _deleteTask(BuildContext context) async {
    final currentTheme = Provider.of<ThemeProvider>(context, listen: false).currentTheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: currentTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Hapus Tugas',
          style: GoogleFonts.poppins(color: currentTheme.textPrimary, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Yakin ingin menghapus tugas ini?',
          style: GoogleFonts.poppins(color: currentTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal', style: GoogleFonts.poppins(color: currentTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Hapus', style: GoogleFonts.poppins(color: currentTheme.errorColor)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await DatabaseHelper.instance.deleteTask(_taskData['id'] as int);
      if (context.mounted) {
        Navigator.pop(context, {'deleted': true});
      }
    }
  }

  Future<void> _loadData() async {
    final taskData = await DatabaseHelper.instance.getTask(_taskData['id'] as int);
    if (taskData != null && mounted) {
      setState(() {
        _taskData = Map<String, dynamic>.from(taskData);
      });
    }
  }

  void _navigateToEdit(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/tambah-tugas',
      arguments: {
        'category': _taskData['category'],
        'task': _taskData,
      },
    ).then((result) {
      if (result == true && mounted) {
        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tugas berhasil diperbarui',
                style: GoogleFonts.poppins(color: Colors.white)),
            backgroundColor: const Color(0xFF43A047),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentTheme = themeProvider.currentTheme;
    final isDone = _taskData['is_done'] == 1;
    final isPenting = _taskData['category'] == 'penting';
    final themeColor = isPenting ? AppTheme.fixedRed : AppTheme.fixedGreen;
    final label = isPenting ? 'PENTING' : 'BIASA';

    String formattedDate = '';
    try {
      final date = DateTime.parse(_taskData['due_date'] as String);
      formattedDate = DateFormat('dd MMMM yyyy', 'id_ID').format(date);
    } catch (_) {
      formattedDate = _taskData['due_date'] ?? '';
    }

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
            ),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, currentTheme),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: themeColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: themeColor.withValues(alpha: 0.5), width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(color: themeColor, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                label,
                                style: GoogleFonts.poppins(
                                  color: themeColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _taskData['title'] ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: currentTheme.textPrimary,
                            decoration: isDone ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: currentTheme.cardBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: currentTheme.cardBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.calendar_today_rounded, color: currentTheme.textSecondary, size: 20),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Jatuh Tempo',
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          color: currentTheme.textSecondary,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1.8,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        formattedDate,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: currentTheme.textPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: currentTheme.cardBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: currentTheme.cardBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.description_rounded, color: currentTheme.textSecondary, size: 20),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Deskripsi',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: currentTheme.textSecondary,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.8,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _taskData['description'] ?? 'Tidak ada deskripsi',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: currentTheme.textPrimary,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildActionButton(
                          context,
                          icon: Icons.edit_rounded,
                          label: 'Ubah Tugas',
                          color: currentTheme.accentColor,
                          onTap: () => _navigateToEdit(context),
                        ),
                        const SizedBox(height: 12),
                        _buildActionButton(
                          context,
                          icon: Icons.delete_rounded,
                          label: 'Hapus Tugas',
                          color: currentTheme.errorColor,
                          onTap: () => _deleteTask(context),
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

  Widget _buildAppBar(BuildContext context, currentTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: currentTheme.textPrimary.withValues(alpha: 0.04),
        border: Border(
          bottom: BorderSide(color: currentTheme.textPrimary.withValues(alpha: 0.07), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: currentTheme.textPrimary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: currentTheme.textPrimary.withValues(alpha: 0.12)),
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded, color: currentTheme.textPrimary, size: 16),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          Text(
            'Detail Tugas',
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

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final currentTheme = Provider.of<ThemeProvider>(context, listen: false).currentTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: currentTheme.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: currentTheme.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color.withValues(alpha: 0.5), size: 22),
          ],
        ),
      ),
    );
  }
}