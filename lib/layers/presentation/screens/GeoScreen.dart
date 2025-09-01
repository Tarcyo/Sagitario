// main.dart
import 'package:flutter/material.dart';
import 'package:sagitario/layers/core/services/GeolocatorService.dart';
import 'package:provider/provider.dart';
import 'package:sagitario/layers/presentation/providers/locationProvider.dart';

// Variável global para indicar se já inicializamos o plugin
class GeolocalizacaoScreen extends StatefulWidget {
  @override
  _GeolocalizacaoScreenState createState() => _GeolocalizacaoScreenState();
}

class _GeolocalizacaoScreenState extends State<GeolocalizacaoScreen>
    with SingleTickerProviderStateMixin {
  static bool _activated = false;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // Controller sempre de 0 a 1
    _pulseController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 200),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _pulseController.reverse();
          }
        });

    // Tween para ir de 0.9 até 1.1, aplicando uma curva “bounce”
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onTap() {
    if (_activated) {
      OlaPrinter.desativar();
    } else {
      OlaPrinter.ativar(context);
    }
    _pulseController.forward(from: 0);
    setState(() => _activated = !_activated);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Geolocalização',
                style: TextStyle(fontSize: 50, color: Colors.white),
              ),
              const SizedBox(height: 40),
              ScaleTransition(
                scale: _pulseAnimation,
                child: GestureDetector(
                  onTap: _onTap,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 60,
                      vertical: 24,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: _activated
                          ? Colors.redAccent.shade200
                          : Colors.greenAccent.shade400,
                      boxShadow: [
                        BoxShadow(
                          color:
                              (_activated
                                      ? Colors.redAccent
                                      : Colors.greenAccent)
                                  .withOpacity(0.5),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          transitionBuilder: (child, anim) => FadeTransition(
                            opacity: anim,
                            child: ScaleTransition(scale: anim, child: child),
                          ),
                          child: Icon(
                            _activated ? Icons.location_off : Icons.location_on,
                            key: ValueKey<bool>(_activated),
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          _activated ? 'Desativar' : 'Ativar',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 50),
              Consumer<LocationProvider>(
                builder: (context, value, child) {
                  return Column(
                    children: [
                       Text(
                        "Ultima Verificação: "+DateTime.now().hour.toString()+":"+DateTime.now().minute.toString()+":"+DateTime.now().second.toString(),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: _activated ? Colors.white : Colors.transparent,
                        ),
                      ),
                      SizedBox(),
                      Text(
                        value.location ?? "",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: _activated ? Colors.white : Colors.transparent,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
