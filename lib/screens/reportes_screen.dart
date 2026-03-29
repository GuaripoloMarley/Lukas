import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:excel/excel.dart' hide Border, TextSpan;
import 'package:share_plus/share_plus.dart';
import '../state/app_state.dart';
import '../models/gasto.dart';
import '../utils/formatters.dart';
import '../widgets/glass_container.dart';

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});
  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  bool _mensual = true;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final isDark = appState.modoOscuro;
        final gastos = _mensual
            ? appState.gastosMesActual
            : appState.gastosSemanaActual;
        final total = gastos.fold<double>(0.0, (s, g) => s + g.monto);

        final Map<String, double> porCat = {};
        final Map<int, double> porDia = {};
        String topCat = "Ninguna";
        double maxMontoCat = 0;

        for (var g in gastos) {
          porCat[g.categoria] = (porCat[g.categoria] ?? 0) + g.monto;
          porDia[g.fecha.day] = (porDia[g.fecha.day] ?? 0) + g.monto;
          if (porCat[g.categoria]! > maxMontoCat) {
            maxMontoCat = porCat[g.categoria]!;
            topCat = g.categoria;
          }
        }

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF070B1F) : Colors.white,
          appBar: AppBar(
            title: Text(
              'REPORTE',
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
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 120),
            child: Column(
              children: [
                // SUMMARY CARDS
                Row(
                  children: [
                    Expanded(
                      child: GlassContainer(
                        padding: const EdgeInsets.all(20),
                        opacity: isDark ? 0.1 : 0.9,
                        color: isDark
                            ? Colors.white.withAlpha(13)
                            : Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'GASTADO',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white38
                                    : const Color(0xFF64748B),
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formatoMoneda(total, appState.moneda),
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1E293B),
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GlassContainer(
                        padding: const EdgeInsets.all(20),
                        opacity: isDark ? 0.1 : 0.9,
                        color: isDark
                            ? Colors.white.withAlpha(13)
                            : Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TENDENCIA',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white38
                                    : const Color(0xFF64748B),
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              topCat.toUpperCase(),
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF6366F1),
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // BAR CHART (DIARIO)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'FLUJO DIARIO',
                    style: TextStyle(
                      color: isDark ? Colors.white38 : const Color(0xFF64748B),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GlassContainer(
                  height: 240,
                  padding: const EdgeInsets.fromLTRB(10, 24, 20, 10),
                  opacity: isDark ? 0.1 : 0.8,
                  color: isDark
                      ? Colors.white.withAlpha(13)
                      : const Color(0xFFF8FAFC),
                  child: BarChart(
                    BarChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        show: true,
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (val, meta) {
                              if (val.toInt() <= 0) return const SizedBox();
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  val.toInt().toString(),
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white24
                                        : const Color(0xFF94A3B8),
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: porDia.entries
                          .map(
                            (e) => BarChartGroupData(
                              x: e.key,
                              barRods: [
                                BarChartRodData(
                                  toY: e.value,
                                  color: const Color(0xFF6366F1),
                                  width: 8,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // PIE CHART CARD (CATEGORÍAS)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'DISTRIBUCIÓN',
                    style: TextStyle(
                      color: isDark ? Colors.white38 : const Color(0xFF64748B),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GlassContainer(
                  height: 300,
                  padding: const EdgeInsets.all(24),
                  opacity: isDark ? 0.1 : 0.8,
                  color: isDark
                      ? Colors.white.withAlpha(13)
                      : const Color(0xFFF8FAFC),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 4,
                          centerSpaceRadius: 60,
                          sections: porCat.isEmpty
                              ? [
                                  PieChartSectionData(
                                    color: Colors.grey.withAlpha(51),
                                    value: 1,
                                    title: '',
                                    radius: 10,
                                  ),
                                ]
                              : porCat.entries.map((e) {
                                  final cat = appState.obtenerCategoria(e.key);
                                  return PieChartSectionData(
                                    color: cat.color,
                                    value: e.value,
                                    title: '',
                                    radius: 12,
                                  );
                                }).toList(),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'TOTAL',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white38
                                  : const Color(0xFF64748B),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            formatoMoneda(total, appState.moneda),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // CATEGORY BREAKDOWN
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Text(
                        'DESGLOSE',
                        style: TextStyle(
                          color: isDark
                              ? Colors.white38
                              : const Color(0xFF64748B),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const Spacer(),
                      _PeriodButton(
                        label: 'MES',
                        selected: _mensual,
                        onTap: () => setState(() => _mensual = true),
                        isDark: isDark,
                      ),
                      const SizedBox(width: 8),
                      _PeriodButton(
                        label: 'SEMANA',
                        selected: !_mensual,
                        onTap: () => setState(() => _mensual = false),
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                if (porCat.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: Text(
                      'Sin datos en este período',
                      style: TextStyle(
                        color: isDark
                            ? Colors.white.withAlpha(51)
                            : Colors.black12,
                      ),
                    ),
                  )
                else
                  ...porCat.entries.map((e) {
                    final cat = appState.obtenerCategoria(e.key);
                    final pct = total == 0 ? 0.0 : (e.value / total);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(cat.icono, color: cat.color, size: 16),
                              const SizedBox(width: 12),
                              Text(
                                cat.nombre.toUpperCase(),
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF1E293B),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                "${(pct * 100).toStringAsFixed(1)}%",
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white30
                                      : const Color(0xFF94A3B8),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                formatoMoneda(e.value, appState.moneda),
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF1E293B),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: pct,
                              minHeight: 6,
                              backgroundColor: isDark
                                  ? Colors.white.withAlpha(13)
                                  : Colors.black.withAlpha(13),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                cat.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                const SizedBox(height: 32),

                // EXPORTS
                Row(
                  children: [
                    Expanded(
                      child: _buildExportButton(
                        context: context,
                        label: 'PDF',
                        icon: Icons.picture_as_pdf_outlined,
                        color: Colors.redAccent,
                        onTap: () => _exportarPDF(context, gastos),
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildExportButton(
                        context: context,
                        label: 'EXCEL',
                        icon: Icons.table_chart_outlined,
                        color: Colors.greenAccent,
                        onTap: () => _exportarExcel(context, gastos),
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExportButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GlassContainer(
      opacity: isDark ? 0.1 : 0.8,
      color: isDark ? Colors.white.withAlpha(13) : Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportarPDF(BuildContext context, List<Gasto> lista) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context ctx) => [
          pw.Header(level: 0, child: pw.Text("REPORTE DE GASTOS - LUKAS")),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: ['Fecha', 'Descripción', 'Categoría', 'Monto'],
            data: lista
                .map(
                  (g) => [
                    DateFormat('dd/MM/yyyy').format(g.fecha),
                    g.nombre,
                    g.categoria,
                    formatoMoneda(g.monto, appState.moneda),
                  ],
                )
                .toList(),
          ),
          pw.SizedBox(height: 20),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              "Total: ${formatoMoneda(lista.fold(0.0, (s, g) => s + g.monto), appState.moneda)}",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'reporte_lukas.pdf',
    );
  }

  Future<void> _exportarExcel(BuildContext context, List<Gasto> lista) async {
    final excel = Excel.createExcel();
    final sheet = excel['Gastos'];
    sheet.appendRow([
      TextCellValue('Fecha'),
      TextCellValue('Descripción'),
      TextCellValue('Categoría'),
      TextCellValue('Monto'),
      TextCellValue('Moneda'),
    ]);
    for (var g in lista) {
      sheet.appendRow([
        TextCellValue(DateFormat('dd/MM/yyyy').format(g.fecha)),
        TextCellValue(g.nombre),
        TextCellValue(g.categoria),
        DoubleCellValue(g.monto),
        TextCellValue(appState.moneda),
      ]);
    }
    final bytes = excel.save();
    if (bytes != null) {
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              Uint8List.fromList(bytes),
              name: 'reporte_lukas.xlsx',
            ),
          ],
        ),
      );
    }
  }
}

class _PeriodButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool isDark;
  const _PeriodButton({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        opacity: selected ? (isDark ? 0.2 : 0.9) : (isDark ? 0.05 : 0.4),
        color: selected
            ? (isDark ? Colors.white.withAlpha(26) : Colors.white)
            : (isDark ? Colors.transparent : Colors.white.withAlpha(128)),
        borderRadius: BorderRadius.circular(20),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? (isDark ? Colors.white : const Color(0xFF6366F1))
                : (isDark ? Colors.white60 : const Color(0xFF94A3B8)),
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
