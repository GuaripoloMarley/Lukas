import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class CurrencyService {
  static const String _apiKey = '09a8dd2c6ced9ce02ba53771';
  static const String _baseUrl = 'https://v6.exchangerate-api.com/v6';
  static const String _prefRates = 'exchange_rates';
  static const String _prefDate = 'exchange_rates_date';

  // Cache en memoria — instantáneo una vez cargado
  static Map<String, double>? _cachedRates;

  static Future<Map<String, double>> getRates() async {
    // Si ya están en memoria, devolver instantáneo
    if (_cachedRates != null) return _cachedRates!;

    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString(_prefDate);
    final today = DateTime.now().toIso8601String().substring(0, 10);

    // Si tenemos tasas de hoy en disco, cargarlas a memoria
    if (savedDate == today) {
      final savedRates = prefs.getString(_prefRates);
      if (savedRates != null) {
        final Map<String, dynamic> decoded = jsonDecode(savedRates);
        _cachedRates = decoded.map(
          (k, v) => MapEntry(k, (v as num).toDouble()),
        );
        return _cachedRates!;
      }
    }

    // Si no, consultar la API
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

        // Guardar en memoria Y en disco
        _cachedRates = rates;
        await prefs.setString(_prefRates, jsonEncode(rates));
        await prefs.setString(_prefDate, today);

        return rates;
      }
    } catch (e) {
      debugPrint('Error fetching rates: $e');
    }

    // Tasas por defecto si todo falla
    _cachedRates = {'CLP': 1.0, 'USD': 0.00102, 'EUR': 0.00095};
    return _cachedRates!;
  }

  static Future<double> convert(double amount, String from, String to) async {
    if (from == to) return amount;
    final rates = await getRates();
    if (!rates.containsKey(from) || !rates.containsKey(to)) return amount;
    final amountInCLP = from == 'CLP' ? amount : amount / rates[from]!;
    return to == 'CLP' ? amountInCLP : amountInCLP * rates[to]!;
  }
}
