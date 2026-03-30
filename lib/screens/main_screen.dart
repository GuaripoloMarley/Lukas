import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../models/gasto.dart';
import '../models/parsed_expense.dart'; // Solo para la clase de datos
import '../services/smart_parser.dart'; // Solo para la lógica .parse()
import '../widgets/glass_container.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController _iaController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _iaController.dispose();
    super.dispose();
  }

  Widget _buildAiBadge() {
    final bool hasKey =
        appState.geminiApiKey != null && appState.geminiApiKey!.isNotEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: hasKey
            ? Colors.green.withOpacity(0.1)
            : Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasKey ? Colors.greenAccent : Colors.amber,
          width: 0.5,
        ),
      ),
      child: Text(
        hasKey ? 'IA ACTIVA' : 'MODO LOCAL',
        style: TextStyle(
          fontSize: 8,
          color: hasKey ? Colors.greenAccent : Colors.amber,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = appState.modoOscuro;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF070B1F) : Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),

            // --- AQUÍ VA TU CÓDIGO DEL BALANCE (El que ya tenías) ---
            // Asegúrate de mantener tus widgets de saldo aquí.
            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ENTRADA RÁPIDA',
                  style: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black38,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                _buildAiBadge(),
              ],
            ),
            const SizedBox(height: 12),
            GlassContainer(
              opacity: isDark ? 0.1 : 0.8,
              child: TextField(
                controller: _iaController,
                enabled: !_isProcessing,
                textInputAction: TextInputAction.done,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                onSubmitted: (value) async {
                  if (value.trim().isEmpty) return;

                  setState(() => _isProcessing = true);

                  final resultado = await SmartParser.parse(value);

                  if (resultado.monto > 0) {
                    appState.agregarGasto(
                      Gasto(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        nombre: resultado.descripcion,
                        monto: resultado.monto,
                        categoria: resultado.categoria,
                        fecha: resultado.fecha,
                        moneda: appState.moneda,
                      ),
                    );
                    _iaController.clear();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('✅ Guardado: ${resultado.descripcion}'),
                        ),
                      );
                    }
                  }

                  setState(() => _isProcessing = false);
                },
                decoration: InputDecoration(
                  hintText: _isProcessing
                      ? 'Procesando...'
                      : 'Ej: 15 lucas en bencina ayer',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white24 : Colors.black26,
                  ),
                  prefixIcon: const Icon(
                    Icons.auto_awesome,
                    color: Color(0xFF6366F1),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(20),
                ),
              ),
            ),

            // --- AQUÍ VA TU CÓDIGO DE LA LISTA DE GASTOS ---
          ],
        ),
      ),
    );
  }
}
