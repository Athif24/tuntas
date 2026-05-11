import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/beranda_screen.dart';
import '../screens/tambah_tugas_screen.dart';
import '../screens/daftar_tugas_screen.dart';
import '../screens/pengaturan_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/detail_tugas_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String login = '/';
  static const String beranda = '/beranda';
  static const String tambahTugas = '/tambah-tugas';
  static const String daftarTugas = '/daftar-tugas';
  static const String pengaturan = '/pengaturan';
  static const String detailTugas = '/detail-tugas';

  static Route<dynamic>? onGenerateRoute(RouteSettings routeSettings) {
    final name = routeSettings.name;
    if (name == splash) {
      return MaterialPageRoute(builder: (_) => const SplashScreen());
    } else if (name == login) {
      return MaterialPageRoute(builder: (_) => const LoginScreen());
    } else if (name == beranda) {
      return MaterialPageRoute(builder: (_) => const BerandaScreen());
    } else if (name == tambahTugas) {
      final args = routeSettings.arguments as Map<String, dynamic>?;
      final category = args?['category'] as String? ?? 'biasa';
      final task = args?['task'] as Map<String, dynamic>?;
      return MaterialPageRoute(
          builder: (_) => TambahTugasScreen(category: category, task: task));
    } else if (name == daftarTugas) {
      return MaterialPageRoute(builder: (_) => const DaftarTugasScreen());
    } else if (name == pengaturan) {
      return MaterialPageRoute(builder: (_) => const PengaturanScreen());
    } else if (name == detailTugas) {
      final task = routeSettings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
          builder: (_) => DetailTugasScreen(task: task));
    }
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(child: Text('No route defined for $name')),
      ),
    );
  }
}
