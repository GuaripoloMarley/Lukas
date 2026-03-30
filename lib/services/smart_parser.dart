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
        debugPrint('Gemini Error: $e');
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
    Contexto: Asistente contable chileno.
    Fecha de HOY: ${DateTime.now().toIso8601String()}
    Entrada: "$input"

    Tareas:
    1. Monto: "23 lukitas" -> 23000. 
    2. Fecha: "anteayer/antes de ayer" -> resta 2 días exactos a HOY. "ayer" -> resta 1 día.
    3. Categoría: Escoger estrictamente de [Comida, Transporte, Compras, Ocio, Cuentas, Viajes, Salud, Otro].
    4. Descripción: "tillas en oferta" -> "Zapatillas".

    Retorna solo JSON:
    {"monto": double, "descripcion": string, "categoria": string, "fecha": "string_iso8601"}
    ''';

    final response = await model.generateContent([Content.text(prompt)]);
    if (response.text == null) return null;

    try {
      final Map<String, dynamic> data = jsonDecode(response.text!);
      return ParsedExpense(
        monto: (data['monto'] as num).toDouble(),
        descripcion: data['descripcion'],
        categoria: data['categoria'],
        fecha: DateTime.parse(data['fecha']),
      );
    } catch (e) {
      return null;
    }
  }

  static ParsedExpense _parseLocal(String input) {
    // Fallback minimalista por si falla la red
    return ParsedExpense(
      monto: 0,
      descripcion: input,
      categoria: "Otro",
      fecha: DateTime.now(),
    );
  }
}
