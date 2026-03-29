import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:google_fonts/google_fonts.dart';
import 'state/app_state.dart';
import 'screens/main_screen.dart';
import 'screens/auth_screen.dart';

final appState = AppState();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_CL', null);

  try {
    await appState.loadData();
  } catch (e) {
    debugPrint('Error cargando datos: $e');
  }

  runApp(const LukasApp());
}

class LukasApp extends StatelessWidget {
  const LukasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Lukas',
        themeMode: appState.modoOscuro ? ThemeMode.dark : ThemeMode.light,
        theme: _buildTheme(brightness: Brightness.light),
        darkTheme: _buildTheme(brightness: Brightness.dark),
        home: appState.bloqueoActivado
            ? AuthScreen(child: const MainScreen())
            : const MainScreen(),
      ),
    );
  }

  ThemeData _buildTheme({required Brightness brightness}) {
    const seedColor = Color(0xFF6366F1);
    final isDark = brightness == Brightness.dark;
    final baseTextTheme = isDark
        ? ThemeData.dark().textTheme
        : ThemeData.light().textTheme;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
      surface: isDark ? const Color(0xFF0F172A) : Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.montserratTextTheme(baseTextTheme),
      scaffoldBackgroundColor: isDark
          ? const Color(0xFF070B1F)
          : const Color(0xFFF8FAFC),
    );
  }
}
