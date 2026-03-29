import 'package:flutter/material.dart';
import 'inicio_screen.dart';
import 'agregar_screen.dart';
import 'reportes_screen.dart';
import 'ajustes_screen.dart';
import '../widgets/glass_container.dart';
import '../state/app_state.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final isDark = appState.modoOscuro;

        return Scaffold(
          extendBody: true,
          body: IndexedStack(
            index: _index,
            children: [
              InicioScreen(),
              AgregarScreen(),
              ReportesScreen(),
              AjustesScreen(),
            ],
          ),
          bottomNavigationBar: Container(
            margin: const EdgeInsets.fromLTRB(24, 0, 24, 30),
            child: GlassContainer(
              height: 70,
              blur: 20,
              opacity: isDark
                  ? 0.1
                  : 0.8, // Más opacidad en modo claro para legibilidad
              color: isDark
                  ? Colors.white.withAlpha(13)
                  : Colors.white.withAlpha(230),
              borderRadius: BorderRadius.circular(35),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(
                    0,
                    Icons.home_rounded,
                    Icons.home_outlined,
                    'Inicio',
                    isDark,
                  ),
                  _buildNavItem(
                    1,
                    Icons.add_circle_rounded,
                    Icons.add_circle_outline,
                    'Nuevo',
                    isDark,
                  ),
                  _buildNavItem(
                    2,
                    Icons.bar_chart_rounded,
                    Icons.bar_chart_outlined,
                    'Reportes',
                    isDark,
                  ),
                  _buildNavItem(
                    3,
                    Icons.settings_rounded,
                    Icons.settings_outlined,
                    'Ajustes',
                    isDark,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(
    int index,
    IconData selectedIcon,
    IconData unselectedIcon,
    String label,
    bool isDark,
  ) {
    final isSelected = _index == index;
    final accentColor = const Color(0xFF6366F1);
    final iconColor = isSelected
        ? accentColor
        : (isDark ? Colors.white54 : Colors.black54);

    return GestureDetector(
      onTap: () => setState(() => _index = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withAlpha(26) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : unselectedIcon,
              color: iconColor,
              size: 24,
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
