import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../state/app_state.dart';
import '../models/gasto.dart';
import '../models/parsed_expense.dart';
import '../utils/formatters.dart';
import '../widgets/glass_container.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});
  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  final _ctrl = TextEditingController();
  final FocusNode _focus = FocusNode();
  double _lastBalance = 0;
  bool _cargandoAi = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final isDark = appState.modoOscuro;
        final gastos = appState.gastos;

        return Container(
          decoration: isDark
              ? const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0A1128), Color(0xFF000000)],
                  ),
                )
              : BoxDecoration(color: Colors.grey[50]),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(32),
                    blur: 20,
                    opacity: isDark ? 0.1 : 0.8,
                    color: isDark ? Colors.white.withAlpha(13) : Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'BALANCE TOTAL v2',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white38
                                : const Color(0xFF64748B),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(
                            begin: _lastBalance,
                            end: appState.totalMes,
                          ),
                          duration: const Duration(seconds: 1),
                          onEnd: () => _lastBalance = appState.totalMes,
                          builder: (context, value, child) =>
                              FutureBuilder<String>(
                                future: formatoMonedaAsync(
                                  value,
                                  appState.moneda,
                                ),
                                builder: (context, snapshot) => Text(
                                  snapshot.data ??
                                      formatoMoneda(value, appState.moneda),
                                  style: GoogleFonts.montserrat(
                                    fontSize: 48,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -2,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF6366F1),
                                  ),
                                ),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GlassContainer(
                    blur: 5,
                    opacity: isDark ? 0.1 : 0.95,
                    color: isDark ? Colors.white.withAlpha(13) : Colors.white,
                    child: TextField(
                      controller: _ctrl,
                      focusNode: _focus,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: _cargandoAi
                            ? 'Analizando con IA...'
                            : 'Ej: Pizza 15000 hoy',
                        hintStyle: TextStyle(
                          color: isDark
                              ? Colors.white.withAlpha(77)
                              : const Color(0xFF94A3B8),
                        ),
                        prefixIcon: _cargandoAi
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: Padding(
                                  padding: EdgeInsets.all(14),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF6366F1),
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.auto_awesome,
                                color: Color(0xFF6366F1),
                                size: 20,
                              ),
                        filled: true,
                        fillColor: Colors.transparent,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                      ),
                      onSubmitted: (v) async {
                        if (v.trim().isEmpty || _cargandoAi) return;
                        setState(() => _cargandoAi = true);
                        final p = await SmartParser.parse(v);
                        if (!mounted) return;
                        setState(() => _cargandoAi = false);
                        if (!mounted) return;
                        if (p.monto > 0) {
                          appState.agregarGasto(
                            Gasto(
                              id: DateTime.now().millisecondsSinceEpoch
                                  .toString(),
                              nombre: p.descripcion,
                              monto: p.monto,
                              categoria: p.categoria,
                              fecha: p.fecha,
                              moneda: appState.moneda,
                            ),
                          );
                          _ctrl.clear();
                          _mostrarSnackBar(
                            '✅ ${p.descripcion} guardado',
                            const Color(0xFF6366F1),
                          );
                        } else {
                          _mostrarSnackBar(
                            '⚠️ No se detectó un monto. Ej: Pizza 15000',
                            Colors.orange.shade700,
                          );
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'RECIENTES',
                        style: TextStyle(
                          color: isDark
                              ? Colors.white38
                              : const Color(0xFF64748B),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: gastos.isEmpty
                      ? Center(
                          child: Text(
                            'Sin gastos aún',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white.withAlpha(51)
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                          itemCount: gastos.length,
                          itemBuilder: (_, i) {
                            final g = gastos[i];
                            final cat = appState.obtenerCategoria(g.categoria);
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: GlassContainer(
                                padding: const EdgeInsets.all(10),
                                blur: 2,
                                opacity: isDark ? 0.05 : 0.8,
                                color: isDark
                                    ? Colors.white.withAlpha(13)
                                    : Colors.white,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: cat.color.withAlpha(26),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        cat.icono,
                                        color: cat.color,
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            g.nombre,
                                            style: TextStyle(
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black87,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13,
                                            ),
                                          ),
                                          Text(
                                            DateFormat(
                                              'EEEE, d MMMM',
                                              'es_CL',
                                            ).format(g.fecha),
                                            style: TextStyle(
                                              color: isDark
                                                  ? Colors.white.withAlpha(102)
                                                  : const Color(0xFF64748B),
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    FutureBuilder<String>(
                                      future: formatoMonedaAsync(
                                        g.monto,
                                        appState.moneda,
                                      ),
                                      builder: (context, snapshot) => Text(
                                        snapshot.data ??
                                            formatoMoneda(
                                              g.monto,
                                              appState.moneda,
                                            ),
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black87,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _mostrarSnackBar(String mensaje, Color backgroundColor) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 110),
      ),
    );
  }
}
