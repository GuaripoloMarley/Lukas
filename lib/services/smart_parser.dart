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
        debugPrint('Gemini Error: $e. Usando local fallback.');
      }
    }
    return _parseLocal(input);
  }

  static Future<ParsedExpense?> _parseAI(String input, String apiKey) async {
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
    );

    final prompt =
        '''
    Eres un asistente de finanzas personales experto en jerga chilena y latinoamericana.
    Extrae datos de la frase de gasto y responde ÚNICAMENTE en formato JSON.

    Lista de Categorías permitidas: Comida, Transporte, Compras, Ocio, Cuentas, Viajes, Salud, Otro.

    Reglas:
    1. El monto debe ser un número (double). "lukas", "k", "mil" son miles.
    2. La descripción debe ser corta y limpia.
    3. La categoría debe ser una de la lista.
    4. La fecha en formato ISO8601 relativo a hoy (${DateTime.now().toIso8601String()}).

    Frase: "$input"

    Esquema JSON: {"monto": 0.0, "descripcion": "", "categoria": "", "fecha": ""}
    ''';

    final response = await model.generateContent([Content.text(prompt)]);
    if (response.text == null) return null;

    try {
      final Map<String, dynamic> data = jsonDecode(response.text!);
      return ParsedExpense(
        monto: (data['monto'] as num).toDouble(),
        descripcion: data['descripcion'] as String,
        categoria: _validarCategoria(data['categoria'] as String),
        fecha: DateTime.parse(data['fecha'] as String),
      );
    } catch (e) {
      return null;
    }
  }

  static String _validarCategoria(String cat) {
    const validas = [
      'Comida',
      'Transporte',
      'Compras',
      'Ocio',
      'Cuentas',
      'Viajes',
      'Salud',
      'Otro',
    ];
    return validas.contains(cat) ? cat : 'Otro';
  }

  static ParsedExpense _parseLocal(String input) {
    double monto = 0;
    String categoria = "Otro";
    DateTime fecha = DateTime.now();
    final lowerInput = input.toLowerCase();

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

    final conceptMap = {
      'café': 'Comida',
      'almuerzo': 'Comida',
      'pizza': 'Comida',
      'super': 'Comida',
      'uber': 'Transporte',
      'taxi': 'Transporte',
      'micro': 'Transporte',
      'bencina': 'Transporte',
      'ropa': 'Compras',
      'tillas': 'Compras',
      'mall': 'Compras',
      'netflix': 'Ocio',
      'cine': 'Ocio',
      'carrete': 'Ocio',
      'steam': 'Ocio',
      'luz': 'Cuentas',
      'agua': 'Cuentas',
      'internet': 'Cuentas',
      'plan': 'Cuentas',
      'vuelo': 'Viajes',
      'hotel': 'Viajes',
      'pasaje': 'Viajes',
      'médico': 'Salud',
      'farmacia': 'Salud',
      'gym': 'Salud',
    };

    conceptMap.forEach((key, value) {
      if (lowerInput.contains(key)) categoria = value;
    });

    return ParsedExpense(
      monto: monto,
      descripcion: input.length > 20 ? input.substring(0, 20) : input,
      categoria: categoria,
      fecha: fecha,
    );
  }
}
