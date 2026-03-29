import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../widgets/glass_container.dart';
import 'auth_screen.dart';
import 'cuentas_screen.dart';
import 'main_screen.dart';

class AjustesScreen extends StatefulWidget {
  const AjustesScreen({super.key});
  @override
  State<AjustesScreen> createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final isDark = appState.modoOscuro;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF070B1F) : Colors.white,
          appBar: AppBar(
            title: Text(
              'AJUSTES',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.0,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
            children: [
              // PREMIUM CARD
              if (!appState.esPremium)
                GestureDetector(
                  onTap: appState.activarPremium,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    margin: const EdgeInsets.only(bottom: 32),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0x4D6366F1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.workspace_premium,
                          color: Colors.white,
                          size: 32,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'LUKAS PRO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Gastos ilimitados y funciones extra',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ),

              Text(
                'SISTEMA',
                style: TextStyle(
                  color: isDark ? Colors.white38 : const Color(0xFF64748B),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 16),
              GlassContainer(
                opacity: isDark ? 0.1 : 0.8,
                color: isDark
                    ? Colors.white.withAlpha(13)
                    : const Color(0xFFF8FAFC),
                child: Column(
                  children: [
                    _buildToggleTile(
                      label: 'Modo Oscuro',
                      icon: Icons.dark_mode_outlined,
                      value: appState.modoOscuro,
                      onChanged: (v) => appState.toggleModoOscuro(),
                      isDark: isDark,
                    ),
                    _buildDivider(isDark),
                    _buildDropdownTile(
                      label: 'Moneda',
                      icon: Icons.payments_outlined,
                      value: appState.moneda,
                      options: ['CLP', 'USD', 'EUR'],
                      onChanged: (v) {
                        if (v != null) {
                          appState.moneda = v;
                          appState.saveData();
                        }
                      },
                      isDark: isDark,
                    ),
                    _buildDivider(isDark),
                    _buildNavigationTile(
                      label: 'Administrar cuentas',
                      icon: Icons.account_balance_wallet_outlined,
                      isDark: isDark,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CuentasScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Text(
                'INTELIGENCIA ARTIFICIAL',
                style: TextStyle(
                  color: isDark ? Colors.white38 : const Color(0xFF64748B),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 16),
              GlassContainer(
                opacity: isDark ? 0.1 : 0.8,
                color: isDark
                    ? Colors.white.withAlpha(13)
                    : const Color(0xFFF8FAFC),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.auto_awesome,
                        color: Color(0xFF6366F1),
                        size: 20,
                      ),
                      title: Text(
                        'Google Gemini API Key',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        appState.geminiApiKey != null
                            ? 'Llave configurada'
                            : 'No configurada (usando local)',
                        style: TextStyle(
                          color: isDark ? Colors.white38 : Colors.black38,
                          fontSize: 11,
                        ),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: isDark ? Colors.white24 : Colors.black12,
                      ),
                      onTap: () => _mostrarDialogoGemini(context),
                    ),
                    _buildDivider(isDark),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        'Obtén tu llave gratis en aistudio.google.com/app/apikey',
                        style: TextStyle(
                          color: const Color(0x996366F1),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Text(
                'SEGURIDAD',
                style: TextStyle(
                  color: isDark ? Colors.white38 : const Color(0xFF64748B),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 16),
              GlassContainer(
                opacity: isDark ? 0.1 : 0.8,
                color: isDark
                    ? Colors.white.withAlpha(13)
                    : const Color(0xFFF8FAFC),
                child: ListTile(
                  onTap: () => _mostrarDialogoPin(context),
                  leading: Icon(
                    Icons.lock_outline,
                    color: appState.bloqueoActivado
                        ? Colors.greenAccent
                        : (isDark ? Colors.white38 : const Color(0xFF64748B)),
                  ),
                  title: Text(
                    'Bloqueo por PIN',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  trailing: Icon(
                    appState.bloqueoActivado
                        ? Icons.check_circle_rounded
                        : Icons.circle_outlined,
                    color: appState.bloqueoActivado
                        ? Colors.greenAccent
                        : (isDark ? Colors.white12 : Colors.black12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _mostrarDialogoGemini(BuildContext context) {
    final isDark = appState.modoOscuro;
    final ctrl = TextEditingController(text: appState.geminiApiKey);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        title: Text(
          'API Key de Gemini',
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        content: TextField(
          controller: ctrl,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: 'Pega tu API Key aquí...',
            hintStyle: TextStyle(
              color: isDark ? Colors.white10 : Colors.black12,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () {
              appState.establecerGeminiKey(ctrl.text.trim());
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
            ),
            child: const Text('GUARDAR'),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTile({
    required String label,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
    required bool isDark,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      secondary: Icon(
        icon,
        color: isDark ? Colors.white70 : Colors.black54,
        size: 20,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      activeThumbColor: const Color(0xFF6366F1),
    );
  }

  Widget _buildDropdownTile({
    required String label,
    required IconData icon,
    required String value,
    required List<String> options,
    required Function(String?) onChanged,
    required bool isDark,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDark ? Colors.white70 : Colors.black54,
        size: 20,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        dropdownColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        style: const TextStyle(
          color: Color(0xFF6366F1),
          fontWeight: FontWeight.w800,
        ),
        items: options
            .map((s) => DropdownMenuItem(value: s, child: Text(s)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildNavigationTile({
    required String label,
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: isDark ? Colors.white70 : Colors.black54,
        size: 20,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: isDark ? Colors.white24 : Colors.black26,
      ),
    );
  }

  Widget _buildDivider(bool isDark) => Divider(
    height: 1,
    thickness: 1,
    indent: 56,
    color: isDark ? Colors.white.withAlpha(13) : Colors.black.withAlpha(40),
  );

  void _mostrarDialogoPin(BuildContext context) {
    final isDark = appState.modoOscuro;
    final ctrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
          title: Text(
            appState.bloqueoActivado ? 'Desactivar PIN' : 'Nuevo PIN',
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          ),
          content: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 4,
            onChanged: (_) => setState(() {}),
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 24,
              letterSpacing: 10,
            ),
            decoration: InputDecoration(
              hintText: '****',
              hintStyle: TextStyle(
                color: isDark ? Colors.white10 : Colors.black12,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCELAR'),
            ),
            ElevatedButton(
              onPressed: ctrl.text.length == 4
                  ? () {
                      if (appState.bloqueoActivado) {
                        appState.desactivarBloqueo();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('PIN desactivado')),
                        );
                        Navigator.pop(context);
                      } else {
                        appState.establecerPin(ctrl.text);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'PIN guardado. Ingresa tu PIN para acceder.',
                            ),
                          ),
                        );
                        // Redirigir a pantalla de bloqueo
                        Future.delayed(const Duration(milliseconds: 300), () {
                          if (context.mounted) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) =>
                                    AuthScreen(child: const MainScreen()),
                              ),
                            );
                          }
                        });
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
              ),
              child: Text(appState.bloqueoActivado ? 'DESACTIVAR' : 'ACTIVAR'),
            ),
          ],
        ),
      ),
    );
  }
}
