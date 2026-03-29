import 'package:intl/intl.dart';

String formatoMoneda(double monto, String moneda) {
  final hasDecimals = moneda != 'CLP' && (monto % 1 != 0);
  final f = NumberFormat.currency(
    symbol: moneda == 'USD' ? 'US\$' : (moneda == 'EUR' ? '€' : '\$'),
    decimalDigits: hasDecimals ? 2 : 0,
    locale: 'es_CL',
  );
  return f.format(monto).replaceAll(',', '.');
}

// Para compatibilidad con código existente que aún usa formatoCLP
String formatoCLP(num monto) => formatoMoneda(monto.toDouble(), 'CLP');
