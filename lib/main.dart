import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'utils/app_routes.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi locale data untuk intl
  await initializeDateFormatting('id_ID', null);

  runApp(ChangeNotifierProvider(
    create: (_) => ThemeProvider(),
    child: const TuntasApp(),
  ));
}

class TuntasApp extends StatelessWidget {
  const TuntasApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Tuntas',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.currentTheme.materialTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
