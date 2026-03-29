import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyService {
  static const String _apiKey = '09a8dd2c6ced9ce02ba53771';
  static const String _baseUrl = 'https://v6.exchangerate-api.com/v6';
  static const String _prefRates = 'exchange_rates';
  static const String _prefDate = 'exchange_rates_date';

  static Future<Map<String, double>> getRates() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString(_prefDate);
    final today = DateTime.now().toIso8601String().substring(0, 10);

    if (savedDate == today) {
      final savedRates = prefs.getString(_prefRates);
      if (savedRates != null) {
        final Map<String, dynamic> decoded = jsonDecode(savedRates);
        return decoded.map((k, v) => MapEntry(k, (v as num).toDouble()));
      }
    }

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

        await prefs.setString(_prefRates, jsonEncode(rates));
        await prefs.setString(_prefDate, today);

        return rates;
      }
    } catch (e) {
      print('Error: $e');
    }

    return {'CLP': 1.0, 'USD': 0.00102, 'EUR': 0.00095};
  }

  static Future<double> convert(double amount, String from, String to) async {
    if (from == to) return amount;

    final rates = await getRates();

    if (!rates.containsKey(from) || !rates.containsKey(to)) {
      return amount;
    }

    final amountInCLP = from == 'CLP' ? amount : amount / rates[from]!;

    final result = to == 'CLP' ? amountInCLP : amountInCLP * rates[to]!;

    return result;
  }
}
