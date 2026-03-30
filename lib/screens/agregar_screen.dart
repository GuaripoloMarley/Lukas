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
  final _descCtrl = TextEditingController();
  final _montoCtrl = TextEditingController();
  final _aiCtrl = TextEditingController();
  final FocusNode _conceptoFocus = FocusNode();
  String _catSeleccionada = 'Comida';
  DateTime _fecha = DateTime.now();
  bool _isLoadingAI = false;

  @override
  void dispose() {
    _descCtrl.dispose();
    _montoCtrl.dispose();
    _aiCtrl.dispose();
    _conceptoFocus.dispose();
    super.dispose();
  }

  void _usarIA() async {
    if (_aiCtrl.text.trim().isEmpty) return;

    setState(() => _isLoadingAI = true);
    final resultado = await SmartParser.parse(_aiCtrl.text);

    setState(() {
      _montoCtrl.text = resultado.monto > 0
          ? resultado.monto.toInt().toString()
          : "";
      _descCtrl.text = resultado.descripcion;
      _catSeleccionada = resultado.categoria;
      _fecha = resultado.fecha;
      _isLoadingAI = false;
      _aiCtrl.clear();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✨ Datos procesados por IA'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _fecha) {
      setState(() => _fecha = picked);
    }
  }

  void _guardar() {
    String cleanMonto = _montoCtrl.text
        .replaceAll('.', '')
        .replaceAll(',', '.');
    final monto = double.tryParse(cleanMonto) ?? 0.0;

    if (monto <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ingresa un monto válido')));
      return;
    }

    appState.agregarGasto(
      Gasto(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nombre: _descCtrl.text.isEmpty ? _catSeleccionada : _descCtrl.text,
        monto: monto,
        categoria: _catSeleccionada,
        fecha: _fecha,
        moneda: appState.moneda,
      ),
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('✅ Gasto guardado')));

    _descCtrl.clear();
    _montoCtrl.clear();
    setState(() {
      _catSeleccionada = 'Comida';
      _fecha = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = appState.modoOscuro;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF070B1F) : Colors.white,
      appBar: AppBar(
        title: Text(
          'NUEVO GASTO',
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SECCIÓN IA ---
            _buildLabel('ENTRADA INTELIGENTE (IA)', isDark),
            const SizedBox(height: 12),
            GlassContainer(
              opacity: isDark ? 0.1 : 0.8,
              child: TextField(
                controller: _aiCtrl,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Ej: 15 mil en bencina ayer...',
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
                    onPressed: _usarIA,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(20),
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(color: Colors.white10),
            ),

            // --- MONTO ---
            _buildLabel('¿CUÁNTO GASTASTE?', isDark),
            const SizedBox(height: 16),
            GlassContainer(
              padding: const EdgeInsets.all(24),
              opacity: isDark ? 0.1 : 0.8,
              child: TextField(
                controller: _montoCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF6366F1),
                ),
                decoration: InputDecoration(
                  hintText: '0',
                  border: InputBorder.none,
                  prefixText: '\$ ',
                  prefixStyle: TextStyle(
                    color: isDark ? Colors.white24 : Colors.black26,
                    fontSize: 32,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // --- CONCEPTO ---
            _buildLabel('CONCEPTO', isDark),
            const SizedBox(height: 12),
            GlassContainer(
              opacity: isDark ? 0.1 : 0.8,
              child: TextField(
                controller: _descCtrl,
                focusNode: _conceptoFocus,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: const InputDecoration(
                  hintText: 'Ej: Almuerzo con amigos',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(20),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // --- FECHA ---
            _buildLabel('FECHA', isDark),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _seleccionarFecha(context),
              child: GlassContainer(
                opacity: isDark ? 0.1 : 0.8,
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      color: Color(0xFF6366F1),
                      size: 20,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      DateFormat(
                        'EEEE, d MMMM',
                        'es_CL',
                      ).format(_fecha).toUpperCase(),
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // --- CATEGORÍAS ---
            _buildLabel('CATEGORÍA', isDark),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: appState.categorias.map((c) {
                final isSel = _catSeleccionada == c.nombre;
                return GestureDetector(
                  onTap: () => setState(() => _catSeleccionada = c.nombre),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSel
                          ? c.color
                          : c.color.withAlpha(isDark ? 13 : 26),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          c.icono,
                          color: isSel ? Colors.white : c.color,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          c.nombre,
                          style: TextStyle(
                            color: isSel
                                ? Colors.white
                                : (isDark ? Colors.white70 : Colors.black54),
                            fontWeight: isSel
                                ? FontWeight.w800
                                : FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 48),

            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _guardar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'GUARDAR GASTO',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
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
        color: isDark ? Colors.white38 : const Color(0xFF64748B),
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 2.0,
      ),
    );
  }
}
