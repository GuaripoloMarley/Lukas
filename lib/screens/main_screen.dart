// En tu State de MainScreen:
final TextEditingController _iaController = TextEditingController();
bool _isProcessing = false;

// Dentro del build, debajo de tu Balance:
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('ENTRADA RÁPIDA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
        _buildAiBadge(), // El indicador visual
      ],
    ),
    const SizedBox(height: 12),
    GlassContainer(
      child: TextField(
        controller: _iaController,
        enabled: !_isProcessing,
        textInputAction: TextInputAction.done,
        onSubmitted: (value) async {
          if (value.trim().isEmpty) return;
          
          setState(() => _isProcessing = true);
          
          // 1. La IA (o local) procesa el texto
          final resultado = await SmartParser.parse(value);
          
          // 2. GUARDADO AUTOMÁTICO
          if (resultado.monto > 0) {
            appState.agregarGasto(Gasto(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              nombre: resultado.descripcion,
              monto: resultado.monto,
              categoria: resultado.categoria,
              fecha: resultado.fecha,
              moneda: appState.moneda,
            ));
            
            _iaController.clear();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ Guardado: ${resultado.descripcion} por \$${resultado.monto.toInt()}'),
                backgroundColor: const Color(0xFF6366F1),
                duration: const Duration(seconds: 2),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('⚠️ No pude detectar el monto. Intenta de nuevo.'))
            );
          }
          
          setState(() => _isProcessing = false);
        },
        decoration: InputDecoration(
          hintText: _isProcessing ? 'Procesando...' : 'Escribe y presiona Enter...',
          prefixIcon: _isProcessing 
              ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.auto_awesome, color: Color(0xFF6366F1)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    ),
  ],
)

// Indicador Visual
Widget _buildAiBadge() {
  final bool hasKey = appState.geminiApiKey != null && appState.geminiApiKey!.isNotEmpty;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: hasKey ? Colors.green.withOpacity(0.1) : Colors.white10,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: hasKey ? Colors.greenAccent : Colors.white24),
    ),
    child: Text(
      hasKey ? 'IA ACTIVA' : 'MODO LOCAL',
      style: TextStyle(fontSize: 8, color: hasKey ? Colors.greenAccent : Colors.white38, fontWeight: FontWeight.bold),
    ),
  );
}