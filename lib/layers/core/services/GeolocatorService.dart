import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:sagitario/layers/presentation/providers/authProvider.dart';
import 'package:sagitario/layers/presentation/providers/locationProvider.dart';
import 'package:sagitario/layers/core/services/checkAluno.dart';
import 'package:sagitario/layers/core/services/checkProfessor.dart';
import 'package:sagitario/layers/core/services/getDisciplina.dart';
import 'package:sagitario/layers/core/services/getSalaDeAula.dart';
import 'package:sagitario/layers/core/services/getUser.dart';
import 'package:sagitario/layers/core/services/listarHorarios.dart';
import 'dart:math';

class OlaPrinter {
  static Timer? _timer;

  static bool get ativo => _timer?.isActive ?? false;

  static diaDaSemanaZeroDomingo([DateTime? data]) {
    final dt = data ?? DateTime.now();
    return dt.weekday % 7;
  }

  static DateTime converteHorario(timeString) {
    List<String> parts = timeString.split(":");

    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);

    DateTime now = DateTime.now();
    DateTime dateTime = DateTime(now.year, now.month, now.day, hour, minute);

    return dateTime;
  }

  /// Retorna true se o momento atual estiver dentro do período [start, end].
  static bool isNowInPeriod(DateTime start, DateTime end) {
    final nowUtc = DateTime.now().toUtc();
    final startUtc = start.toUtc();
    final endUtc = end.toUtc();

    // Caso start == end: considera somente o instante exato como dentro.
    if (startUtc.isAtSameMomentAs(endUtc)) {
      return nowUtc.isAtSameMomentAs(startUtc);
    }

    // período normal (start <= end)
    if (!startUtc.isAfter(endUtc)) {
      return !nowUtc.isBefore(startUtc) && !nowUtc.isAfter(endUtc);
    }

    // período que "dá a volta" (start > end), por exemplo 22:00 -> 03:00
    return !nowUtc.isBefore(startUtc) || !nowUtc.isAfter(endUtc);
  }

  static String getDataAtualFormatada() {
    final agora = DateTime.now();
    final ano = agora.year.toString();
    final mes = agora.month.toString().padLeft(2, '0');
    final dia = agora.day.toString().padLeft(2, '0');

    return "$ano-$mes-$dia";
  }

  static bool estaNoLocal(
    double latLocal,
    double lonLocal,
    double latUser,
    double lonUser,
    int toleranciaMetros,
  ) {
    const double raioTerra = 6371000; // Raio médio da Terra em metros

    // Converte graus para radianos
    double toRadians(double grau) => grau * pi / 180;

    final dLat = toRadians(latUser - latLocal);
    final dLon = toRadians(lonUser - lonLocal);

    final lat1 = toRadians(latLocal);
    final lat2 = toRadians(latUser);

    final a =
        pow(sin(dLat / 2), 2) + pow(sin(dLon / 2), 2) * cos(lat1) * cos(lat2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    final distancia = raioTerra * c;

    return distancia <= toleranciaMetros;
  }

  static void ativar(BuildContext c) {
    if (ativo) return;
    _timer = Timer.periodic(const Duration(seconds: 3), (_) async {
      //  print('Sua localização atual:');
      final d = GetDisciplinasByDay(
        Provider.of<AuthProvider>(listen: false, c).token!,
      );
      int diaDaSemana = diaDaSemanaZeroDomingo();
      final disciplinas = await d.getDisciplinesByDay(diaDaSemana);
      //  print("Disciplinas: " + disciplinas!['classes'].toString());
      for (final i in disciplinas!['classes']) {
        String timeString1 = i['start_time'];
        String timeString2 = i['end_time'];

        final disciplina = await getDisciplineById(
          i['id'],
          Provider.of<AuthProvider>(c, listen: false).token!,
        );

        final salaDeAula = await getClassroomById(
          disciplina.classroomId!,
          Provider.of<AuthProvider>(c, listen: false).token!,
        );

        //   print('Sala de aula: '+salaDeAula.toString());

        if (isNowInPeriod(
          converteHorario(timeString1),
          converteHorario(timeString2),
        )) {
          //   print("disciplina no periodo atual: " + i.toString()); //
          //   print(
          //    "Hora de inicio: " + converteHorario(timeString1).toString(),
          //   ); // Exemplo: 2025-08-28 14:30:00.000
          //    print(
          //     "Hora de fim: " + converteHorario(timeString2).toString(),
          //    ); // Exemplo: 2025-08-28 14:30:00.000

          //    print(
          //    "Está no periodo? " +
          //        isNowInPeriod(
          //        converteHorario(timeString1),
          //        converteHorario(timeString2),
          //       ).toString(),
          //   );
          //  print("id: " + Provider.of<AuthProvider>(c, listen: false).id!);
          //  print("token: " + Provider.of<AuthProvider>(c, listen: false).token!);

          final user = await fetchUserById(
            bearerToken: Provider.of<AuthProvider>(c, listen: false).token!,
            id: Provider.of<AuthProvider>(c, listen: false).id!,
          );

          //   print("Usuário" + user.toString());

          if (user.type == 'teacher') {
            try {
              final pos = await _determinePosition();
              //   print('Latitude: ${pos.latitude}, Longitude: ${pos.longitude}');
              Provider.of<LocationProvider>(c, listen: false).location =
                  ('Latitude: ${pos.latitude}\nLongitude: ${pos.longitude}');

              print(
                "Tupla: " +
                    (
                      double.parse(salaDeAula.latitude),
                      double.parse(salaDeAula.longitude),
                      pos.latitude,
                      pos.longitude,
                      salaDeAula.minDistance,
                    ).toString(),
              );
              final estaNoLoocal = estaNoLocal(
                double.parse(salaDeAula.latitude),
                double.parse(salaDeAula.longitude),
                pos.latitude,
                pos.longitude,
                salaDeAula.minDistance,
              );

              final check = await registerTeacherAttendance(
                bearerToken: Provider.of<AuthProvider>(c, listen: false).token!,
                teacherId: user.id,
                disciplineId: i['id'],
                isPresent: estaNoLoocal,
                startTime: i['start_time'],
                classDate: getDataAtualFormatada(),
              );

              print("Está na distâcia tolerada?" + estaNoLoocal.toString());
              print("check: " + check.toString());
            } catch (e) {
              print('Erro ao obter localização: $e');
            }
          } else {
            try {
              final pos = await _determinePosition();
              //   print('Latitude: ${pos.latitude}, Longitude: ${pos.longitude}');
              Provider.of<LocationProvider>(c, listen: false).location =
                  ('Latitude: ${pos.latitude}\nLongitude: ${pos.longitude}');

              print(
                "Tupla: " +
                    (
                      double.parse(salaDeAula.latitude),
                      double.parse(salaDeAula.longitude),
                      pos.latitude,
                      pos.longitude,
                      salaDeAula.minDistance,
                    ).toString(),
              );
              final estaNoLoocal = estaNoLocal(
                double.parse(salaDeAula.latitude),
                double.parse(salaDeAula.longitude),
                pos.latitude,
                pos.longitude,
                salaDeAula.minDistance,
              );

              final check = await registerAttendanceCheck(
                bearerToken: Provider.of<AuthProvider>(c, listen: false).token!,
                studentId: user.id,
                disciplineId: i['id'],
                isPresent: estaNoLoocal,
                startTime: i['start_time'],
                classDate: getDataAtualFormatada(),
              );

              print("Está na distâcia tolerada?" + estaNoLoocal.toString());
              print("check: " + check.toString());
            } catch (e) {
              print('Erro ao obter localização: $e');
            }
          }
        }
      }
      try {
        final pos = await _determinePosition();
        //   print('Latitude: ${pos.latitude}, Longitude: ${pos.longitude}');
        Provider.of<LocationProvider>(c, listen: false).location =
            ('Latitude: ${pos.latitude}\nLongitude: ${pos.longitude}');
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
