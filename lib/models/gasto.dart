class Gasto {
  final String id, nombre, categoria, moneda;
  final double monto;
  final DateTime fecha;

  Gasto({
    required this.id,
    required this.nombre,
    required this.monto,
    required this.categoria,
    required this.fecha,
    required this.moneda,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'nombre': nombre,
    'monto': monto,
    'categoria': categoria,
    'fecha': fecha.toIso8601String(),
    'moneda': moneda,
  };

  factory Gasto.fromMap(Map<String, dynamic> map) => Gasto(
    id: map['id'],
    nombre: map['nombre'],
    monto: (map['monto'] as num).toDouble(),
    categoria: map['categoria'],
    fecha: DateTime.parse(map['fecha']),
    moneda: map['moneda'] ?? 'CLP', // fallback
  );
}
