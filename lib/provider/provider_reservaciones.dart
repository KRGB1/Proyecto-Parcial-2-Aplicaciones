import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/models.dart';
import '../main.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ReservasProvider with ChangeNotifier {
  final List<Sala> _salas = [
    Sala(id: 's1', nombre: 'Sala 1', imagenAsset: 'assets/sala1.jpeg'),
    Sala(id: 's2', nombre: 'Sala 2', imagenAsset: 'assets/sala2.jpeg'),
    Sala(id: 's3', nombre: 'Sala 3', imagenAsset: 'assets/sala3.jpeg'),
    Sala(id: 's4', nombre: 'Sala 4', imagenAsset: 'assets/sala4.jpeg'),
  ];

  List<Reserva> _reservas = [];

  List<Sala> get salas => [..._salas];
  List<Reserva> get reservas => [..._reservas];

  ReservasProvider() {
    _cargarReservas();
  }

  static const String _reservasKey = 'mis_reservas';

  Future<void> _cargarReservas() async {
    final prefs = await SharedPreferences.getInstance();
    final reservasString = prefs.getString(_reservasKey);

    if (reservasString != null) {
      final List<dynamic> reservasJson = json.decode(reservasString);
      _reservas = reservasJson.map((json) => Reserva.fromJson(json)).toList();

      for (var sala in _salas) {
        sala.isReservada = _reservas.any((res) => res.salaId == sala.id);
      }
    }
    notifyListeners();
  }

  Future<void> _guardarReservas() async {
    final prefs = await SharedPreferences.getInstance();

    final String reservasString = json.encode(
      _reservas.map((reserva) => reserva.toJson()).toList(),
    );
    await prefs.setString(_reservasKey, reservasString);
  }

  void reservarSala(
    String salaId,
    DateTime fecha,
    TimeOfDay horaInicio,
    TimeOfDay horaFin,
    BuildContext context,
  ) {
    final salaIndex = _salas.indexWhere((sala) => sala.id == salaId);
    if (salaIndex != -1 && !_salas[salaIndex].isReservada) {
      _salas[salaIndex].isReservada = true;

      final nuevaReserva = Reserva(
        id: DateTime.now().toString(),
        salaId: salaId,
        nombreSala: _salas[salaIndex].nombre,
        fechaReserva: fecha,
        horaInicio: horaInicio,
        horaFin: horaFin,
      );
      _reservas.add(nuevaReserva);

      _mostrarNotificacionReservaExitosa(nuevaReserva, context);
      _guardarReservas(); // ¡Guardar después de un cambio!

      notifyListeners();
      print('Sala ${_salas[salaIndex].nombre} reservada con éxito!');
    } else {
      print('La sala ya está reservada o no se encontró.');
    }
  }

  Future<void> _mostrarNotificacionReservaExitosa(
    Reserva reserva,
    BuildContext context,
  ) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'reservas_channel_id',
          'Confirmación de Reserva',
          channelDescription:
              'Notificaciones sobre la confirmación de reservas de salas.',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'Reserva Exitosa',
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      reserva.id.hashCode,
      '¡Reserva de ${reserva.nombreSala} Confirmada!',
      'Tu reserva para el ${DateFormat('dd/MM/yyyy').format(reserva.fechaReserva)} de ${reserva.horaInicio.format(context)} a ${reserva.horaFin.format(context)} ha sido guardada.',
      platformChannelSpecifics,
      payload: reserva.id,
    );
  }

  void liberarSala(String salaId) {
    final salaIndex = _salas.indexWhere((sala) => sala.id == salaId);
    if (salaIndex != -1 && _salas[salaIndex].isReservada) {
      _salas[salaIndex].isReservada = false;
      _reservas.removeWhere((reserva) => reserva.salaId == salaId);
      _guardarReservas(); // ¡Guardar después de un cambio!
      notifyListeners();
      print('Sala ${_salas[salaIndex].nombre} liberada.');
    }
  }
}
