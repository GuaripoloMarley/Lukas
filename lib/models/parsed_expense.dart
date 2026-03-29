import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../state/app_state.dart';

class ParsedExpense {
  final double monto;
  final String descripcion, categoria;
  final DateTime fecha;
  ParsedExpense({
    required this.monto,
    required this.descripcion,
    required this.categoria,
    required this.fecha,
  });
}

class SmartParser {
  static Future<ParsedExpense> parse(String input) async {
    if (appState.geminiApiKey != null && appState.geminiApiKey!.isNotEmpty) {
      try {
        final result = await _parseAI(input, appState.geminiApiKey!);
        if (result != null) return result;
      } catch (e) {
        debugPrint('Gemini Error: \$e. Usando local fallback.');
      }
    }
    return _parseLocal(input);
  }

  static Future<ParsedExpense?> _parseAI(String input, String apiKey) async {
    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
    final prompt = '''
Eres un asistente de finanzas personales experto en jerga chilena y latinoamericana.
Tu tarea es extraer datos de una frase de gasto y responder ÚNICAMENTE en formato JSON.

Lista de Categorías permitidas: Comida, Transporte, Compras, Ocio, Cuentas, Viajes, Salud, Otro.

Reglas:
1. El monto debe ser un número (double). Interpreta "lukas", "lukitas", "luquitas", "k", "mil" como miles.
2. La descripción debe ser corta y limpia (ej: "Zapatillas" en lugar de "unas tillas de oferta"). 
3. La categoría debe ser una de la lista anterior. "tillas" -> Compras, "juego/steam" -> Ocio, "mensualidad/plan" -> Cuentas.
4. La fecha debe ser en formato ISO8601 relativo a hoy (\${DateTime.now().toIso8601String()}).

Frase: "\$input"

Respuesta esperada: {"monto": 0.0, "descripcion": "", "categoria": "", "fecha": ""}
''';

    final response = await model.generateContent([Content.text(prompt)]);
    final text = response.text;
    if (text == null) return null;

    try {
      final cleanJson = text
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      final Map<String, dynamic> data = jsonDecode(cleanJson);
      return ParsedExpense(
        monto: (data['monto'] as num).toDouble(),
        descripcion: data['descripcion'] as String,
        categoria: data['categoria'] as String,
        fecha: DateTime.parse(data['fecha'] as String),
      );
    } catch (e) {
      return null;
    }
  }

  static ParsedExpense _parseLocal(String input) {
    double monto = 0;
    String categoria = "Otro";
    DateTime fecha = DateTime.now();
    final lowerInput = input.toLowerCase();

    // Regex mejorado: captura "lukitas", "lucitas", "luki", etc.
    final RegExp numReg = RegExp(
      r'(\d+(?:[.,]\d+)?)\s*(lukitas?|lucitas?|luki|lukas?|lucas?|luca|k|mil|\$)?',
      caseSensitive: false,
    );
    final match = numReg.firstMatch(lowerInput);
    if (match != null) {
      String valStr = match.group(1)!.replaceAll(',', '.');
      double base = double.tryParse(valStr) ?? 0;
      String? suffix = match.group(2);
      if (suffix != null) {
        final s = suffix.toLowerCase();
        if (s.contains('luk') || s.contains('luc') || s == 'k' || s == 'mil') {
          monto = base * 1000;
        } else {
          monto = base;
        }
      } else {
        monto = base;
      }
    }

    final tokens = lowerInput
        .split(RegExp(r'[\s,.]+'))
        .where((t) => t.length > 2)
        .toList();
    final Map<String, double> scores = {
      'Comida': 0,
      'Transporte': 0,
      'Compras': 0,
      'Ocio': 0,
      'Cuentas': 0,
      'Viajes': 0,
      'Salud': 0,
    };
    final conceptMap = {
      'café': 'Comida',
      'cafe': 'Comida',
      'almuerzo': 'Comida',
      'almorzar': 'Comida',
      'cena': 'Comida',
      'cenar': 'Comida',
      'pizza': 'Comida',
      'hambre': 'Comida',
      'restaurante': 'Comida',
      'sushi': 'Comida',
      'hamburguesa': 'Comida',
      'burger': 'Comida',
      'empanada': 'Comida',
      'pan': 'Comida',
      'super': 'Comida',
      'supermercado': 'Comida',
      'comestibles': 'Comida',
      'feria': 'Comida',
      'uber': 'Transporte',
      'didi': 'Transporte',
      'cabify': 'Transporte',
      'taxi': 'Transporte',
      'micro': 'Transporte',
      'gasolina': 'Transporte',
      'bencina': 'Transporte',
      'combustible': 'Transporte',
      'metro': 'Transporte',
      'bus': 'Transporte',
      'colectivo': 'Transporte',
      'peaje': 'Transporte',
      'estacionamiento': 'Transporte',
      'ropa': 'Compras',
      'zapatos': 'Compras',
      'zapatillas': 'Compras',
      'zapas': 'Compras',
      'tillas': 'Compras',
      'mall': 'Compras',
      'tienda': 'Compras',
      'polera': 'Compras',
      'pantalón': 'Compras',
      'regalo': 'Compras',
      'juguete': 'Compras',
      'ferretería': 'Compras',
      'mueble': 'Compras',
      'netflix': 'Ocio',
      'spotify': 'Ocio',
      'disney': 'Ocio',
      'hbo': 'Ocio',
      'cine': 'Ocio',
      'película': 'Ocio',
      'juego': 'Ocio',
      'game': 'Ocio',
      'switch': 'Ocio',
      'swtich': 'Ocio',
      'nintendo': 'Ocio',
      'ps5': 'Ocio',
      'playstation': 'Ocio',
      'ps4': 'Ocio',
      'xbox': 'Ocio',
      'steam': 'Ocio',
      'skin': 'Ocio',
      'puntos': 'Ocio',
      'bar': 'Ocio',
      'cerveza': 'Ocio',
      'club': 'Ocio',
      'fiesta': 'Ocio',
      'carrete': 'Ocio',
      'entrada': 'Ocio',
      'estadio': 'Ocio',
      'luz': 'Cuentas',
      'agua': 'Cuentas',
      'gas': 'Cuentas',
      'electricidad': 'Cuentas',
      'internet': 'Cuentas',
      'wifi': 'Cuentas',
      'fibra': 'Cuentas',
      'teléfono': 'Cuentas',
      'celular': 'Cuentas',
      'plan': 'Cuentas',
      'arriendo': 'Cuentas',
      'alquiler': 'Cuentas',
      'dividendo': 'Cuentas',
      'cuota': 'Cuentas',
      'visa': 'Cuentas',
      'mastercard': 'Cuentas',
      'seguro': 'Cuentas',
      'mensualidad': 'Cuentas',
      'suscripción': 'Cuentas',
      'vuelo': 'Viajes',
      'avión': 'Viajes',
      'hotel': 'Viajes',
      'hostal': 'Viajes',
      'pasaje': 'Viajes',
      'turismo': 'Viajes',
      'vacaciones': 'Viajes',
      'maleta': 'Viajes',
      'médico': 'Salud',
      'doctor': 'Salud',
      'clínica': 'Salud',
      'hospital': 'Salud',
      'farmacia': 'Salud',
      'remedio': 'Salud',
      'medicamento': 'Salud',
      'dentista': 'Salud',
      'psicólogo': 'Salud',
      'gym': 'Salud',
      'gimnasio': 'Salud',
      'deporte': 'Salud',
      'proteína': 'Salud',
    };

    for (var token in tokens) {
      if (conceptMap.containsKey(token)) {
        scores[conceptMap[token]!] = (scores[conceptMap[token]!] ?? 0) + 1.0;
      }
    }
    var bestCat = scores.entries.reduce((a, b) => a.value > b.value ? a : b);
    if (bestCat.value > 0) {
      categoria = bestCat.key;
    }

    final now = DateTime.now();
    final RegExp haceReg = RegExp(
      r'hace\s*(\d+)\s*d[ií]as',
      caseSensitive: false,
    );
    final matchHace = haceReg.firstMatch(lowerInput);
    if (matchHace != null) {
      fecha = now.subtract(Duration(days: int.parse(matchHace.group(1)!)));
    } else {
      final daysOrder = [
        'lunes',
        'martes',
        'miércoles',
        'miercoles',
        'jueves',
        'viernes',
        'sábado',
        'sabado',
        'domingo',
      ];
      bool dateDetected = false;
      for (int i = 0; i < daysOrder.length; i++) {
        if (lowerInput.contains(daysOrder[i])) {
          int targetDay = (i % 7) + 1;
          int diff = now.weekday - targetDay;
          if (diff < 0) diff += 7;
          if (lowerInput.contains('pasado') || lowerInput.contains('paso')) {
            if (diff < 0) {
              diff += 7;
            }
          }
          fecha = now.subtract(
            Duration(
              days:
                  diff == 0 &&
                      (lowerInput.contains('pasado') ||
                          lowerInput.contains('paso'))
                  ? 7
                  : diff,
            ),
          );
          dateDetected = true;
          break;
        }
      }
      if (!dateDetected) {
        if (lowerInput.contains('anteayer')) {
          fecha = now.subtract(const Duration(days: 2));
        } else if (lowerInput.contains('ayer')) {
          fecha = now.subtract(const Duration(days: 1));
        }
      }
    }

    // Limpiar descripción: saco el monto del texto y elimino palabras de relleno
    String desc = input;
    if (match != null) {
      desc = desc.replaceFirst(match.group(0)!, '');
    }

    final noise = {
      'wena',
      'wenas',
      'buena',
      'buenas',
      'oe',
      'weon',
      'weón',
      'cachai',
      'cachái',
      'viste',
      'ps',
      'pues',
      'compré',
      'compro',
      'compró',
      'compramos',
      'gasté',
      'gastamos',
      'pagué',
      'pagamos',
      'pago',
      'pagó',
      'pague',
      'gaste',
      'hace',
      'días',
      'dias',
      'ayer',
      'hoy',
      'anteayer',
      'semana',
      'pasada',
      'que',
      'paso',
      'pasó',
      'fue',
      'ya',
      'del',
      'otro',
      'dia',
      'día',
      'un',
      'una',
      'unos',
      'unas',
      'el',
      'la',
      'los',
      'las',
      'en',
      'de',
      'por',
      'con',
      'para',
      'pal',
      'al',
      'mi',
      'mis',
      'tu',
      'tus',
      'lucas',
      'lukas',
      'luca',
      'luka',
      'lukitas',
      'lucitas',
      'mil',
      'oferta',
      'como',
      'ahi',
      'ahí',
      'tambien',
      'también',
      'y',
      'o',
      'pero',
      'si',
      'no',
      'me',
      'te',
      'se',
      'le',
      'les',
      'nos',
    };

    List<String> descTokens = desc.split(RegExp(r'\s+'));
    List<String> cleanTokens = [];
    for (var t in descTokens) {
      String cleanT = t.toLowerCase().replaceAll(RegExp(r'[^\wáéíóúñ]'), '');
      if (cleanT.length > 2 && !noise.contains(cleanT)) {
        final entities = {
          'swtich': 'Switch',
          'nintendo': 'Nintendo',
          'ps5': 'PS5',
          'ps4': 'PS4',
          'playstation': 'PlayStation',
          'xbox': 'Xbox',
          'steam': 'Steam',
          'tillas': 'zapatillas',
          'zapas': 'zapatillas',
        };
        if (entities.containsKey(cleanT)) {
          cleanTokens.add(entities[cleanT]!);
        } else {
          cleanTokens.add(t);
        }
      }
    }
    desc = cleanTokens.join(' ');
    if (desc.isEmpty || desc.length < 2) {
      desc = categoria;
    } else {
      desc = desc[0].toUpperCase() + desc.substring(1);
    }
    return ParsedExpense(
      monto: monto,
      descripcion: desc,
      categoria: categoria,
      fecha: fecha,
    );
  }
}
