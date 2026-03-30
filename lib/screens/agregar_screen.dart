import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../state/app_state.dart';
import '../models/gasto.dart';
import '../widgets/glass_container.dart';
import '../services/smart_parser.dart';

class AgregarScreen extends StatefulWidget {
  const AgregarScreen({super.key});
  @override
  State<AgregarScreen> createState() => _AgregarScreenState();
}

class _AgregarScreenState extends State<AgregarScreen> {
  final _aiCtrl = TextEditingController();
  final _montoCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _catSeleccionada = 'Comida';
  DateTime _fecha = DateTime.now();
  bool _isLoadingAI = false;

  void _procesarConIA() async {
    if (_aiCtrl.text.trim().isEmpty) return;
    setState(() => _isLoadingAI = true);

    final res = await SmartParser.parse(_aiCtrl.text);

    setState(() {
      _montoCtrl.text = res.monto > 0 ? res.monto.toInt().toString() : "";
      _descCtrl.text = res.descripcion;
      _catSeleccionada = res.categoria;
      _fecha = res.fecha;
      _isLoadingAI = false;
      _aiCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = appState.modoOscuro;
    final hasAiKey =
        appState.geminiApiKey != null && appState.geminiApiKey!.isNotEmpty;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF070B1F) : Colors.white,
      appBar: AppBar(
        title: Text(
          'NUEVA ENTRADA',
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // INDICADOR DE ESTADO IA
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLabel('ENTRADA INTELIGENTE', isDark),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: hasAiKey
                        ? Colors.greenAccent.withOpacity(0.1)
                        : Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: hasAiKey ? Colors.greenAccent : Colors.amber,
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 8,
                        color: hasAiKey ? Colors.greenAccent : Colors.amber,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        hasAiKey ? 'IA ACTIVA' : 'MODO LOCAL',
                        style: GoogleFonts.montserrat(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: hasAiKey ? Colors.greenAccent : Colors.amber,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // CUADRO DE TEXTO IA PRINCIPAL
            GlassContainer(
              opacity: isDark ? 0.1 : 0.8,
              child: TextField(
                controller: _aiCtrl,
                maxLines: 2,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Ej: 23 lukitas en tillas anteayer...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white24 : Colors.black26,
                  ),
                  suffixIcon: IconButton(
                    icon: _isLoadingAI
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(
                            Icons.auto_awesome,
                            color: Color(0xFF6366F1),
                          ),
                    onPressed: _procesarConIA,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(20),
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Divider(color: Colors.white10),
            ),

            // FORMULARIO DE RESULTADOS (RESUMIDO)
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('MONTO', isDark),
                      TextField(
                        controller: _montoCtrl,
                        style: GoogleFonts.montserrat(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF6366F1),
                        ),
                        decoration: const InputDecoration(
                          prefixText: '\$ ',
                          border: InputBorder.none,
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('FECHA', isDark),
                      const SizedBox(height: 8),
                      Text(
                        DateFormat('dd/MM/yy').format(_fecha),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildLabel('CONCEPTO FINAL', isDark),
            TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                hintText: 'Descripción...',
                border: UnderlineInputBorder(),
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // Reutiliza tu lógica de guardar anterior
                  final monto = double.tryParse(_montoCtrl.text) ?? 0.0;
                  if (monto > 0) {
                    appState.agregarGasto(
                      Gasto(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        nombre: _descCtrl.text,
                        monto: monto,
                        categoria: _catSeleccionada,
                        fecha: _fecha,
                        moneda: appState.moneda,
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'CONFIRMAR GASTO',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        color: isDark ? Colors.white38 : Colors.black38,
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
      ),
    );
  }
}
