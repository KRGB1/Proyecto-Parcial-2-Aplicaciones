// lib/models/models.dart
import 'package:flutter/material.dart';

class Sala {
  final String id;
  final String nombre;
  final String imagenAsset;
  bool isReservada; // Indicador de si la sala está reservada

  Sala({
    required this.id,
    required this.nombre,
    required this.imagenAsset,
    this.isReservada = false,
  });
}

class Reserva {
  final String id;
  final String salaId;
  final String nombreSala;
  final DateTime fechaReserva;
  final TimeOfDay horaInicio;
  final TimeOfDay horaFin;

  Reserva({
    required this.id,
    required this.salaId,
    required this.nombreSala,
    required this.fechaReserva,
    required this.horaInicio,
    required this.horaFin,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'salaId': salaId,
    'nombreSala': nombreSala,
    'fechaReserva': fechaReserva.toIso8601String(),
    'horaInicioHour': horaInicio.hour,
    'horaInicioMinute': horaInicio.minute,
    'horaFinHour': horaFin.hour,
    'horaFinMinute': horaFin.minute,
  };

  factory Reserva.fromJson(Map<String, dynamic> json) {
    return Reserva(
      id: json['id'],
      salaId: json['salaId'],
      nombreSala: json['nombreSala'],
      fechaReserva: DateTime.parse(
        json['fechaReserva'],
      ), // Convertir String a DateTime
      horaInicio: TimeOfDay(
        hour: json['horaInicioHour'],
        minute: json['horaInicioMinute'],
      ),
      horaFin: TimeOfDay(
        hour: json['horaFinHour'],
        minute: json['horaFinMinute'],
      ),
    );
  }
}
