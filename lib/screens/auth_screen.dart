import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../widgets/glass_container.dart';

class AuthScreen extends StatefulWidget {
  final Widget child;
  const AuthScreen({super.key, required this.child});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  String _input = '';
  bool _authenticated = false;

  void _onKeyTap(String key) {
    if (_input.length < 4) {
      setState(() => _input += key);
      if (_input.length == 4) {
        if (_input == appState.pinCode) {
          setState(() => _authenticated = true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PIN Incorrecto'),
              backgroundColor: Colors.redAccent,
            ),
          );
          setState(() => _input = '');
        }
      }
    }
  }

  void _onBackspace() {
    if (_input.isNotEmpty) {
      setState(() => _input = _input.substring(0, _input.length - 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        // Si se desactiva el bloqueo desde otra pantalla, mostrar contenido
        if (!appState.bloqueoActivado || _authenticated) {
          return widget.child;
        }

        return Scaffold(
          backgroundColor: const Color(0xFF070B1F),
          body: SafeArea(
            child: Column(
              children: [
                const Spacer(),
                const Icon(
                  Icons.lock_rounded,
                  size: 64,
                  color: Color(0xFF6366F1),
                ),
                const SizedBox(height: 24),
                const Text(
                  'INGRESA TU PIN',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Protege tu información financiera',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    4,
                    (i) => Container(
                      width: 50,
                      height: 50,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: i < _input.length
                              ? const Color(0xFF6366F1)
                              : Colors.white30,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          i < _input.length ? '●' : '',
                          style: const TextStyle(
                            color: Color(0xFF6366F1),
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 64),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      for (var row in [
                        ['1', '2', '3'],
                        ['4', '5', '6'],
                        ['7', '8', '9'],
                        ['', '0', '⌫'],
                      ])
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: row.map((key) {
                              if (key == '') return const SizedBox(width: 80);
                              return _buildKey(key);
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildKey(String key) {
    return GestureDetector(
      onTap: () {
        if (key == '⌫') {
          _onBackspace();
        } else {
          _onKeyTap(key);
        }
      },
      child: GlassContainer(
        width: 80,
        height: 80,
        blur: 10,
        opacity: 0.1,
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: Center(
          child: Text(
            key,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
