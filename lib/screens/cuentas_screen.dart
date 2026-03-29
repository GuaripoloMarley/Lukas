import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../models/account.dart';
import '../widgets/glass_container.dart';

class CuentasScreen extends StatefulWidget {
  const CuentasScreen({super.key});

  @override
  State<CuentasScreen> createState() => _CuentasScreenState();
}

class _CuentasScreenState extends State<CuentasScreen> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final isDark = appState.modoOscuro;
        final accounts = appState.accounts;
        final active = appState.activeAccount;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF070B1F) : Colors.white,
          appBar: AppBar(
            title: Text(
              'CUENTAS',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.0,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                color: isDark ? Colors.white70 : Colors.black54,
                onPressed: () => _mostrarAgregarCuenta(context),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (active != null) ...[
                  Text(
                    'CUENTA ACTIVA',
                    style: TextStyle(
                      color: isDark ? Colors.white38 : const Color(0xFF64748B),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GlassContainer(
                    padding: const EdgeInsets.all(20),
                    opacity: isDark ? 0.1 : 0.8,
                    color: isDark
                        ? Colors.white.withAlpha(13)
                        : const Color(0xFFF8FAFC),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Color(active.color).withAlpha(38),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              active.icon,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                active.name,
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${active.currency} ${active.balance.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black54,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Chip(
                          backgroundColor: const Color(
                            0xFF6366F1,
                          ).withAlpha(38),
                          label: const Text(
                            'ACTIVA',
                            style: TextStyle(
                              color: Color(0xFF6366F1),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],

                Text(
                  'TODAS LAS CUENTAS',
                  style: TextStyle(
                    color: isDark ? Colors.white38 : const Color(0xFF64748B),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: accounts.isEmpty
                      ? Center(
                          child: Text(
                            'No hay cuentas creadas aún. Toca + para crear una.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white38
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        )
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          itemCount: accounts.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final account = accounts[index];
                            final selected = account.id == active?.id;
                            return GlassContainer(
                              padding: const EdgeInsets.all(16),
                              opacity: isDark ? 0.1 : 0.9,
                              color: isDark
                                  ? Colors.white.withAlpha(13)
                                  : Colors.white,
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: Color(account.color).withAlpha(38),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Center(
                                      child: Text(
                                        account.icon,
                                        style: const TextStyle(fontSize: 22),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          account.name,
                                          style: TextStyle(
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black87,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${account.currency} ${account.balance.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            color: isDark
                                                ? Colors.white54
                                                : Colors.black54,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      selected
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_unchecked,
                                      color: selected
                                          ? const Color(0xFF6366F1)
                                          : Colors.grey,
                                    ),
                                    onPressed: () =>
                                        appState.setActiveAccount(account.id!),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: isDark
                                          ? Colors.white24
                                          : Colors.black26,
                                    ),
                                    onPressed: () => _confirmEliminarCuenta(
                                      context,
                                      account,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _mostrarAgregarCuenta(context),
            backgroundColor: const Color(0xFF6366F1),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _confirmEliminarCuenta(BuildContext context, Account account) {
    final isDark = appState.modoOscuro;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        title: Text(
          'Eliminar cuenta',
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        content: Text(
          '¿Seguro quieres eliminar ${account.name}?',
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () {
              appState.deleteAccount(account.id!);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
            ),
            child: const Text('ELIMINAR'),
          ),
        ],
      ),
    );
  }

  void _mostrarAgregarCuenta(BuildContext context) {
    final isDark = appState.modoOscuro;
    final nameCtrl = TextEditingController();
    final balanceCtrl = TextEditingController(text: '0');
    var currency = appState.moneda;
    var icon = '🏦';

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
          title: Text(
            'Nueva cuenta',
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: nameCtrl,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Nombre de la cuenta',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white24 : Colors.black38,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: balanceCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Saldo inicial',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white24 : Colors.black38,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: currency,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: ['CLP', 'USD', 'EUR']
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => currency = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: ['🏦', '💳', '💰', '🏠', '👜', '📱']
                    .map(
                      (option) => ChoiceChip(
                        label: Text(
                          option,
                          style: const TextStyle(fontSize: 18),
                        ),
                        selected: icon == option,
                        onSelected: (_) => setState(() => icon = option),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCELAR'),
            ),
            ElevatedButton(
              onPressed: () {
                final nombre = nameCtrl.text.trim();
                final saldo =
                    double.tryParse(balanceCtrl.text.replaceAll(',', '.')) ??
                    0.0;
                if (nombre.isEmpty) return;
                appState.addAccount(
                  Account(
                    name: nombre,
                    balance: saldo,
                    currency: currency,
                    color: 0xFF6366F1,
                    icon: icon,
                  ),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
              ),
              child: const Text('GUARDAR'),
            ),
          ],
        ),
      ),
    );
  }
}
