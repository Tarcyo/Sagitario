import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:sagitario/layers/presentation/providers/authProvider.dart';
import 'package:sagitario/layers/presentation/providers/locationProvider.dart';
import 'package:sagitario/servi%C3%A7os/listarHorarios.dart';

class OlaPrinter {
  static Timer? _timer;

  static bool get ativo => _timer?.isActive ?? false;



  static void ativar(BuildContext c) {
    if (ativo) return;
    _timer = Timer.periodic(const Duration(seconds: 3), (_) async {
    //  print('Sua localização atual:');
    final d=GetDisciplinasByDay(Provider.of<AuthProvider>(listen: false,c).token!);
   final disciplinas= await d.getDisciplinesByDay(0);
    print("Disciplinas: "+disciplinas.toString());
      try {
        final pos = await _determinePosition();
     //   print('Latitude: ${pos.latitude}, Longitude: ${pos.longitude}');
        Provider.of<LocationProvider>(c,listen: false).location=('Latitude: ${pos.latitude}\nLongitude: ${pos.longitude}');
      } catch (e) {
        print('Erro ao obter localização: $e');
      }
    });
  }

  static void desativar() {
    _timer?.cancel();
    _timer = null;
  }
}

Future<Position> _determinePosition() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) throw Exception('Serviço de localização desligado.');

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception('Permissão negada.');
    }
  }
  if (permission == LocationPermission.deniedForever) {
    throw Exception('Permissão negada permanentemente.');
  }

  return await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
}
