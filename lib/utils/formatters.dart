import 'package:intl/intl.dart';
import '../services/currency_service.dart';

// Versión async — convierte Y formatea (úsala cuando puedas usar await)
Future<String> formatoMonedaAsync(double monto, String moneda) async {
  final montoConvertido = await CurrencyService.convert(monto, 'CLP', moneda);
  return _formatear(montoConvertido, moneda);
}

// Versión sync — solo formatea sin convertir (para compatibilidad)
String formatoMoneda(double monto, String moneda) {
  return _formatear(monto, moneda);
}

String _formatear(double monto, String moneda) {
  final hasDecimals = moneda != 'CLP' && (monto % 1 != 0);
  final f = NumberFormat.currency(
    symbol: moneda == 'USD' ? 'US\$' : (moneda == 'EUR' ? '€' : '\$'),
    decimalDigits: hasDecimals ? 2 : 0,
    locale: 'es_CL',
  );
  return f.format(monto).replaceAll(',', '.');
}

// Para compatibilidad con código existente
String formatoCLP(num monto) => formatoMoneda(monto.toDouble(), 'CLP');
