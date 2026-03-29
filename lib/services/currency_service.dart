import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyService {
  static const String _apiKey = '09a8dd2c6ced9ce02ba53771';
  static const String _baseUrl = 'https://v6.exchangerate-api.com/v6';
  static const String _prefRates = 'exchange_rates';
  static const String _prefDate = 'exchange_rates_date';

  // Obtener tasas — usa caché si ya se consultó hoy
  static Future<Map<String, double>> getRates() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString(_prefDate);
    final today = DateTime.now().toIso8601String().substring(0, 10);

    // Si ya tenemos tasas de hoy, las devolvemos sin consultar la API
    if (savedDate == today) {
      final savedRates = prefs.getString(_prefRates);
      if (savedRates != null) {
        final Map<String, dynamic> decoded = jsonDecode(savedRates);
        return decoded.map((k, v) => MapEntry(k, (v as num).toDouble()));
      }
    }

    // Si no, consultamos la API
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$_apiKey/latest/CLP'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rates = Map<String, double>.from(
          (data['conversion_rates'] as Map).map(
            (k, v) => MapEntry(k, (v as num).toDouble()),
          ),
        );

        // Guardar en caché
        await prefs.setString(_prefRates, jsonEncode(rates));
        await prefs.setString(_prefDate, today);

        return rates;
      }
    } catch (e) {
      // Si falla la API, usar tasas por defecto
    }

    // Tasas por defecto si todo falla
    return {'CLP': 1.0, 'USD': 0.00102, 'EUR': 0.00095};
  }

  // Convertir moneda
  static Future<double> convert(double amount, String from, String to) async {
    if (from == to) return amount;
    final rates = await getRates();
    if (!rates.containsKey(from) || !rates.containsKey(to)) return amount;

    // Convertir a CLP primero, luego a destino
    final amountInCLP = from == 'CLP' ? amount : amount / rates[from]!;
    return to == 'CLP' ? amountInCLP : amountInCLP * rates[to]!;
  }
}
```

Reemplaza `TU_API_KEY_AQUI` con tu key. Guarda con `Ctrl+S` 👍

Pero antes de seguir — necesitas agregar el paquete `http` al pubspec.yaml. En terminal:
```
flutter pub add http