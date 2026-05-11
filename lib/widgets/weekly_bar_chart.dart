import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../database/database_helper.dart';
import '../providers/theme_provider.dart';
import '../widgets/daily_task.dart';
import '../widgets/monthly_picker_dialog.dart';
import '../utils/theme_config.dart';

class WeeklyBarChart extends StatefulWidget {
  const WeeklyBarChart({super.key});

  @override
  State<WeeklyBarChart> createState() => _WeeklyBarChartState();
}

class _WeeklyBarChartState extends State<WeeklyBarChart> {
  late DateTime _activeWeekStart;
  late int _displayMonth;
  late int _displayYear;
  List<DailyTask> _weeklyData = [];
  bool _isLoading = true;
  final _db = DatabaseHelper.instance;

  static const List<String> _dayNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  @override
  void initState() {
    super.initState();
    _activeWeekStart = _getThisWeekStart();
    final weekEnd = _activeWeekStart.add(const Duration(days: 6));
    _displayMonth = weekEnd.month;
    _displayYear = weekEnd.year;
    _loadData();
  }

  DateTime _getThisWeekStart() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monday = today.subtract(Duration(days: now.weekday - 1));
    return monday;
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final completedData = await _db.getTasksCompletedPerDay(_activeWeekStart);
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    final List<DailyTask> data = [];
    for (int i = 0; i < 7; i++) {
      final date = _activeWeekStart.add(Duration(days: i));
      final dateOnly = DateTime(date.year, date.month, date.day);
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final isFuture = dateOnly.isAfter(todayOnly);

      data.add(DailyTask(
        date: date,
        completedCount: completedData[dateStr] ?? 0,
        isFuture: isFuture,
      ));
    }

    setState(() {
      _weeklyData = data;
      _isLoading = false;
    });
  }

  void _navigateWeek(int days) {
    setState(() {
      _activeWeekStart = _activeWeekStart.add(Duration(days: days));
      final weekEnd = _activeWeekStart.add(const Duration(days: 6));
      _displayMonth = weekEnd.month;
      _displayYear = weekEnd.year;
    });
    _loadData();
  }

  void _goToPreviousWeek() => _navigateWeek(-7);

  void _goToNextWeek() => _navigateWeek(7);

  void _showMonthPicker() {
    showDialog(
      context: context,
      builder: (ctx) => MonthlyPickerDialog(
        selectedDate: _activeWeekStart,
        selectedMonth: _displayMonth,
        selectedYear: _displayYear,
        onMonthSelected: (month, year, weekStart) {
          setState(() {
            _activeWeekStart = weekStart;
            _displayMonth = month;
            _displayYear = year;
          });
          _loadData();
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  String _getMonthYearText() {
    const months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
                    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    return '${months[_displayMonth - 1]} $_displayYear';
  }

  String _getDateRangeText() {
    final weekEnd = _activeWeekStart.add(const Duration(days: 6));
    final startFormat = DateFormat('d', 'id_ID');
    final endFormat = DateFormat('d MMMM yyyy', 'id_ID');
    return '${startFormat.format(_activeWeekStart)} - ${endFormat.format(weekEnd)}';
  }

  double _getMaxY() {
    if (_weeklyData.isEmpty) return 5;
    final max = _weeklyData.map((e) => e.completedCount).reduce((a, b) => a > b ? a : b);
    return max > 0 ? max + 1 : 5;
  }

  Widget _buildLoading() {
    final currentTheme = Provider.of<ThemeProvider>(context, listen: false).currentTheme;
    return SizedBox(
      height: 140,
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(currentTheme.accentColor),
        ),
      ),
    );
  }

  Widget _buildBarChart(AppTheme currentTheme) {
    final maxY = _getMaxY();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => currentTheme.cardBg,
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final task = _weeklyData[group.x];
              return BarTooltipItem(
                '${task.completedCount} tugas',
                GoogleFonts.poppins(
                  color: currentTheme.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= _weeklyData.length) {
                  return const SizedBox();
                }
                final task = _weeklyData[index];
                final dayName = _dayNames[index];

                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        task.completedCount.toString(),
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: currentTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        dayName,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: currentTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: _weeklyData.asMap().entries.map((entry) {
          final index = entry.key;
          final task = entry.value;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: task.completedCount.toDouble(),
                width: 26,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                color: task.isFuture
                    ? currentTheme.accentColor.withValues(alpha: 0.15)
                    : currentTheme.accentColor,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentTheme = themeProvider.currentTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: currentTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: currentTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TUGAS SELESAI / HARI',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: currentTheme.textSecondary,
                  letterSpacing: 1.4,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.celebration, color: currentTheme.accentColor, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Ayo semangat!',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: currentTheme.accentColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left, color: currentTheme.textSecondary),
                onPressed: _goToPreviousWeek,
                iconSize: 24,
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _showMonthPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: currentTheme.textPrimary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _getMonthYearText(),
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: currentTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_drop_down,
                        color: currentTheme.textSecondary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  Icons.chevron_right,
                  color: currentTheme.textSecondary,
                ),
                onPressed: _goToNextWeek,
                iconSize: 24,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _isLoading
              ? _buildLoading()
              : SizedBox(
                  height: 140,
                  child: _buildBarChart(currentTheme),
                ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              _getDateRangeText(),
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: currentTheme.textHint,
              ),
            ),
          ),
        ],
      ),
    );
  }
}