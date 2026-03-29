import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../state/app_state.dart';
import '../models/gasto.dart';
import '../widgets/glass_container.dart';

class AgregarScreen extends StatefulWidget {
  const AgregarScreen({super.key});
  @override
  State<AgregarScreen> createState() => _AgregarScreenState();
}

class _AgregarScreenState extends State<AgregarScreen> {
  final _descCtrl = TextEditingController();
  final _montoCtrl = TextEditingController();
  String _catSeleccionada = 'Comida';
  DateTime _fecha = DateTime.now();

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: appState.modoOscuro
              ? ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: Color(0xFF6366F1),
                  ),
                )
              : ThemeData.light().copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Color(0xFF6366F1),
                  ),
                ),
          child: child!,
        );
      },
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
        moneda: appState.moneda, // 👈 ESTA LÍNEA
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('✅ Gasto guardado'),
        backgroundColor: const Color(0xFF6366F1),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 110),
      ),
    );

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // MONTO CARD
            GlassContainer(
              padding: const EdgeInsets.all(24),
              opacity: isDark ? 0.1 : 0.8,
              color: isDark
                  ? Colors.white.withAlpha(13)
                  : const Color(0xFFF8FAFC),
              child: Column(
                children: [
                  Text(
                    '¿CUÁNTO GASTASTE?',
                    style: TextStyle(
                      color: isDark ? Colors.white38 : const Color(0xFF64748B),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
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
                      hintStyle: TextStyle(
                        color: isDark ? Colors.white10 : Colors.black12,
                      ),
                      border: InputBorder.none,
                      prefixText: appState.moneda == 'USD'
                          ? 'US\$ '
                          : (appState.moneda == 'EUR' ? '€ ' : '\$ '),
                      prefixStyle: TextStyle(
                        color: isDark
                            ? Colors.white24
                            : const Color(0xFF64748B),
                        fontSize: 32,
                      ),
                    ),
                    onChanged: (v) {
                      // Opcional: Podríamos añadir formateo en tiempo real aquí.
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // DESCRIPCION
            Text(
              'CONCEPTO',
              style: TextStyle(
                color: isDark ? Colors.white38 : const Color(0xFF64748B),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 12),
            GlassContainer(
              opacity: isDark ? 0.1 : 0.8,
              color: isDark
                  ? Colors.white.withAlpha(13)
                  : const Color(0xFFF8FAFC),
              child: TextField(
                controller: _descCtrl,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Ej: Almuerzo con amigos',
                  hintStyle: TextStyle(
                    color: isDark
                        ? Colors.white.withAlpha(51)
                        : const Color(0xFF94A3B8),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(20),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // FECHA SELECTOR
            Text(
              'FECHA',
              style: TextStyle(
                color: isDark ? Colors.white38 : const Color(0xFF64748B),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _seleccionarFecha(context),
              child: GlassContainer(
                opacity: isDark ? 0.1 : 0.8,
                color: isDark
                    ? Colors.white.withAlpha(13)
                    : const Color(0xFFF8FAFC),
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
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // CATEGORIAS
            Text(
              'CATEGORÍA',
              style: TextStyle(
                color: isDark ? Colors.white38 : const Color(0xFF64748B),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.0,
              ),
            ),
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
                          : (isDark
                                ? c.color.withAlpha(13)
                                : c.color.withAlpha(26)),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSel
                            ? (isDark ? Colors.white24 : Colors.black12)
                            : Colors.transparent,
                      ),
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
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 48),

            // BOTON GUARDAR
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
                  elevation: 0,
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
}
