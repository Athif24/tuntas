import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class NavButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color dotColor;
  final VoidCallback onTap;
  const NavButton({
    super.key,
    required this.label,
    required this.icon,
    required this.dotColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currentTheme = Provider.of<ThemeProvider>(context).currentTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: currentTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: currentTheme.cardBorder, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: dotColor.withValues(alpha:0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: dotColor, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: currentTheme.textPrimary.withValues(alpha:0.85),
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
