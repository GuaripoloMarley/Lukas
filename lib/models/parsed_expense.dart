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
