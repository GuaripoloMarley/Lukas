class Gasto {
  final String id, nombre, categoria;
  final double monto;
  final DateTime fecha;

  Gasto({
    required this.id,
    required this.nombre,
    required this.monto,
    required this.categoria,
    required this.fecha,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'nombre': nombre,
    'monto': monto,
    'categoria': categoria,
    'fecha': fecha.toIso8601String(),
  };

  factory Gasto.fromMap(Map<String, dynamic> map) => Gasto(
    id: map['id'],
    nombre: map['nombre'],
    monto: (map['monto'] as num).toDouble(), // Maneja int y double de forma segura
    categoria: map['categoria'],
    fecha: DateTime.parse(map['fecha']),
  );
}
