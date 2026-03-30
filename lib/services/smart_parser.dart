import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../state/app_state.dart';
import '../models/parsed_expense.dart';

class SmartParser {
  static Future<ParsedExpense> parse(String input) async {
    if (appState.geminiApiKey != null && appState.geminiApiKey!.isNotEmpty) {
      try {
        debugPrint('🤖 Consultando Gemini...');
        final result = await _parseAI(input, appState.geminiApiKey!);
        if (result != null) return result;
      } catch (e) {
        debugPrint('❌ Error Gemini: $e');
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
    Eres un asistente contable chileno. Hoy es ${DateTime.now().toIso8601String()}.
    Extrae de: "$input"
    Reglas: 1 luca=1000. Anteayer=Hoy-2 días. Ayer=Hoy-1 día.
    Categorías: Comida, Transporte, Compras, Ocio, Cuentas, Viajes, Salud, Otro.
    Responde SOLO JSON: {"monto": double, "descripcion": string, "categoria": string, "fecha": "ISO8601"}
    ''';

    final response = await model.generateContent([Content.text(prompt)]);
    if (response.text == null) return null;

    final data = jsonDecode(response.text!);
    return ParsedExpense(
      monto: (data['monto'] as num).toDouble(),
      descripcion: data['descripcion'] as String,
      categoria: data['categoria'] as String,
      fecha: DateTime.parse(data['fecha'] as String),
    );
  }

  static ParsedExpense _parseLocal(String input) {
    // Aquí podrías poner tu lógica de regex original si quieres
    return ParsedExpense(
      monto: 0,
      descripcion: input,
      categoria: "Otro",
      fecha: DateTime.now(),
    );
  }
}
