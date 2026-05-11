import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class MonthlyPickerDialog extends StatefulWidget {
  final DateTime selectedDate;
  final int selectedMonth;
  final int selectedYear;
  final Function(int month, int year, DateTime weekStart) onMonthSelected;

  const MonthlyPickerDialog({
    super.key,
    required this.selectedDate,
    required this.selectedMonth,
    required this.selectedYear,
    required this.onMonthSelected,
  });

  @override
  State<MonthlyPickerDialog> createState() => _MonthlyPickerDialogState();
}

class _MonthlyPickerDialogState extends State<MonthlyPickerDialog> {
  late int _selectedYear;

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.selectedYear;
  }

  void _selectMonth(int month) {
    final firstOfMonth = DateTime(_selectedYear, month, 1);
    final monday = firstOfMonth.subtract(Duration(days: firstOfMonth.weekday - 1));
    widget.onMonthSelected(month, _selectedYear, monday);
  }

  void _changeYear(int delta) {
    setState(() {
      _selectedYear += delta;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Provider.of<ThemeProvider>(context).currentTheme;
    final selectedMonth = widget.selectedMonth;
    final selectedYear = widget.selectedYear;

    return AlertDialog(
      backgroundColor: currentTheme.cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left, color: currentTheme.textPrimary),
                onPressed: () => _changeYear(-1),
              ),
              Text(
                '$_selectedYear',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: currentTheme.textPrimary,
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, color: currentTheme.textPrimary),
                onPressed: () => _changeYear(1),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              final month = index + 1;
              final isSelected = month == selectedMonth && _selectedYear == selectedYear;

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: isSelected ? null : () => _selectMonth(month),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? currentTheme.accentColor
                        : currentTheme.cardBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? currentTheme.accentColor
                          : currentTheme.cardBorder,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _months[index],
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? currentTheme.textPrimary
                            : currentTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
