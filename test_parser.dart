// Test simple para el SmartParser
// Ejecutar: dart test_parser.dart

void main() {
  // Simulamos el parser
  final tests = [
    "wena wena ayer me compre unas tillas por 7 lukitas",
    "por 9 lucas me compre una pizza",
    "pague 15000 del uber ayer",
    "gasté 5 mil en la micro",
    "oe cachai que ayer fui al cine y gaste como 10 lukas en la entrada",
    "compre una polera 20 lucas hoy",
  ];

  for (var test in tests) {
    final result = parseLocal(test);
    // ignore: avoid_print
    print('Input: "$test"');
    // ignore: avoid_print
    print(
      '  → monto: ${result['monto']}, desc: "${result['desc']}", cat: "${result['cat']}"',
    );
    // ignore: avoid_print
    print('');
  }
}

Map<String, dynamic> parseLocal(String input) {
  double monto = 0;
  String categoria = "Otro";
  final lowerInput = input.toLowerCase();

  // Regex mejorado
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

  // Detectar categoría
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
    'cena': 'Comida',
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
    'taxi': 'Transporte',
    'micro': 'Transporte',
    'gasolina': 'Transporte',
    'bencina': 'Transporte',
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
    'netflix': 'Ocio',
    'spotify': 'Ocio',
    'disney': 'Ocio',
    'cine': 'Ocio',
    'película': 'Ocio',
    'juego': 'Ocio',
    'switch': 'Ocio',
    'nintendo': 'Ocio',
    'ps5': 'Ocio',
    'playstation': 'Ocio',
    'xbox': 'Ocio',
    'steam': 'Ocio',
    'bar': 'Ocio',
    'cerveza': 'Ocio',
    'club': 'Ocio',
    'fiesta': 'Ocio',
    'carrete': 'Ocio',
    'entrada': 'Ocio',
    'luz': 'Cuentas',
    'agua': 'Cuentas',
    'gas': 'Cuentas',
    'electricidad': 'Cuentas',
    'internet': 'Cuentas',
    'wifi': 'Cuentas',
    'teléfono': 'Cuentas',
    'celular': 'Cuentas',
    'plan': 'Cuentas',
    'arriendo': 'Cuentas',
    'cuota': 'Cuentas',
    'visa': 'Cuentas',
    'seguro': 'Cuentas',
    'mensualidad': 'Cuentas',
    'vuelo': 'Viajes',
    'avión': 'Viajes',
    'hotel': 'Viajes',
    'pasaje': 'Viajes',
    'turismo': 'Viajes',
    'vacaciones': 'Viajes',
    'médico': 'Salud',
    'doctor': 'Salud',
    'clínica': 'Salud',
    'hospital': 'Salud',
    'farmacia': 'Salud',
    'remedio': 'Salud',
    'medicamento': 'Salud',
    'gym': 'Salud',
    'gimnasio': 'Salud',
  };

  for (var token in tokens) {
    if (conceptMap.containsKey(token)) {
      scores[conceptMap[token]!] = (scores[conceptMap[token]!] ?? 0) + 1.0;
    }
  }
  var bestCat = scores.entries.reduce((a, b) => a.value > b.value ? a : b);
  if (bestCat.value > 0) categoria = bestCat.key;

  // Limpiar descripción
  String desc = input;
  if (match != null) desc = desc.replaceFirst(match.group(0)!, '');

  final noise = {
    'wena',
    'wenas',
    'buena',
    'buenas',
    'oe',
    'weon',
    'cachai',
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
    'tambien',
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

  return {'monto': monto, 'desc': desc, 'cat': categoria};
}
