import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../database/database_helper.dart';
import '../providers/theme_provider.dart';
import '../utils/theme_config.dart';

class DaftarTugasScreen extends StatefulWidget {
  const DaftarTugasScreen({super.key});

  @override
  State<DaftarTugasScreen> createState() => _DaftarTugasScreenState();
}

class _DaftarTugasScreenState extends State<DaftarTugasScreen> {
  List<Map<String, dynamic>> _tasks = [];
  String _selectedTab = 'semua';
  final _db = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await _db.getTasks();
    setState(() {
      _tasks = tasks;
    });
  }

  List<Map<String, dynamic>> get _filteredTasks {
    if (_selectedTab == 'semua') return _tasks;
    return _tasks.where((t) => t['category'] == _selectedTab).toList();
  }

  int _getCountByCategory(String category) {
    if (category == 'semua') return _tasks.length;
    return _tasks.where((t) => t['category'] == category).length;
  }

  Future<void> _toggleDone(Map<String, dynamic> task) async {
    final newStatus = task['is_done'] == 1 ? 0 : 1;
    await _db.toggleTaskDone(task['id'] as int, newStatus);
    _loadTasks();
  }

  bool _isDateOverdue(String dateStr) {
    try {
      final dueDate = DateTime.parse(dateStr);
      final today = DateTime.now();
      final todayOnly = DateTime(today.year, today.month, today.day);
      final dueOnly = DateTime(dueDate.year, dueDate.month, dueDate.day);
      return todayOnly.isAfter(dueOnly);
    } catch (_) {
      return false;
    }
  }

  void _navigateToDetail(Map<String, dynamic> task) {
    Navigator.pushNamed(context, '/detail-tugas', arguments: task).then((result) {
      _loadTasks();
      if (result is Map && result['deleted'] == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tugas berhasil dihapus',
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

          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),

                _buildTabBar(currentTheme),

                Expanded(
                  child: _filteredTasks.isEmpty
                      ? _buildEmpty(currentTheme)
                      : ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              itemCount: _filteredTasks.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                return _TaskCard(
                                  task: _filteredTasks[index],
                                  onToggle: () => _toggleDone(_filteredTasks[index]),
                                  onTap: () => _navigateToDetail(_filteredTasks[index]),
                                  currentTheme: currentTheme,
                                  isOverdue: _isDateOverdue(_filteredTasks[index]['due_date'] as String),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(currentTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(child: _buildTab('Semua', 'semua', _getCountByCategory('semua'), currentTheme)),
          const SizedBox(width: 8),
          Expanded(child: _buildTab('Penting', 'penting', _getCountByCategory('penting'), currentTheme)),
          const SizedBox(width: 8),
          Expanded(child: _buildTab('Biasa', 'biasa', _getCountByCategory('biasa'), currentTheme)),
        ],
      ),
    );
  }

  Widget _buildTab(String label, String value, int count, currentTheme) {
    final isSelected = _selectedTab == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? currentTheme.accentColor : currentTheme.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? currentTheme.accentColor : currentTheme.cardBorder,
          ),
        ),
        child: Text(
          '$label ($count)',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? currentTheme.textPrimary : currentTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(currentTheme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.list_alt_rounded, size: 56, color: currentTheme.textPrimary.withValues(alpha: 0.15)),
          const SizedBox(height: 14),
          Text(
            'Belum ada tugas',
            style: GoogleFonts.poppins(color: currentTheme.textSecondary, fontSize: 15),
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
            'Daftar Tugas',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: currentTheme.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Map<String, dynamic> task;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final AppTheme currentTheme;
  final bool isOverdue;

  const _TaskCard({
    required this.task,
    required this.onToggle,
    required this.onTap,
    required this.currentTheme,
    required this.isOverdue,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = task['is_done'] == 1;
    final isPenting = task['category'] == 'penting';
    final arrowColor = isPenting ? AppTheme.fixedRed : AppTheme.fixedGreen;
    final labelColor = isPenting ? AppTheme.fixedRed : AppTheme.fixedGreen;
    final label = isPenting ? 'Penting' : 'Biasa';

    String formattedDate = '';
    try {
      final date = DateTime.parse(task['due_date'] as String);
      formattedDate = DateFormat('dd MMM yyyy').format(date);
    } catch (_) {
      formattedDate = task['due_date'] ?? '';
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: currentTheme.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDone
                  ? currentTheme.successColor.withValues(alpha: 0.25)
                  : isOverdue && !isDone
                      ? currentTheme.overdueColor.withValues(alpha: 0.5)
                      : currentTheme.cardBorder,
              width: 1,
            ),
),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: onToggle,
                    child: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: isDone ? currentTheme.successColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isDone
                                ? currentTheme.successColor
                                : currentTheme.textPrimary.withValues(alpha: 0.35),
                            width: 1.5,
                          ),
                        ),
                        child: isDone
                            ? Icon(Icons.check_rounded, color: currentTheme.textPrimary, size: 16)
                            : null,
                      ),
                    ),
                  ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task['title'] ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDone
                            ? currentTheme.textPrimary.withValues(alpha: 0.35)
                            : currentTheme.textPrimary,
                        decoration: isDone ? TextDecoration.lineThrough : null,
                        decorationColor: currentTheme.textPrimary.withValues(alpha: 0.35),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '$formattedDate · $label',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: isDone
                                  ? currentTheme.textPrimary.withValues(alpha: 0.25)
                                  : labelColor.withValues(alpha: 0.75),
                              fontWeight: FontWeight.w400,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isOverdue && !isDone) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: currentTheme.overdueColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.warning_amber_rounded, color: currentTheme.overdueColor, size: 10),
                                const SizedBox(width: 2),
                                Text(
                                  'LEWAT DEADLINE',
                                  style: GoogleFonts.poppins(
                                    color: currentTheme.overdueColor,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: isDone ? currentTheme.textPrimary.withValues(alpha: 0.2) : arrowColor,
                size: 16,
              ),
            ],
          ),
        ),
    );
  }
}