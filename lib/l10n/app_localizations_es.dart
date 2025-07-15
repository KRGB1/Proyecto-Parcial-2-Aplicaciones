// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Gestión de Salas';

  @override
  String get availableRooms => 'Salas Disponibles';

  @override
  String get myBookings => 'Mis Reservas';

  @override
  String get bookingConfirmed => 'Reserva Confirmada';

  @override
  String get yourBookingFor => 'Tu reserva para el';

  @override
  String get from => 'de';

  @override
  String get to => 'a';

  @override
  String get hasBeenSaved => 'ha sido guardada.';

  @override
  String get room => 'Sala';

  @override
  String get status => 'Estado';

  @override
  String get booked => 'Reservada';

  @override
  String get available => 'Disponible';

  @override
  String get releaseRoom => 'Liberar Sala';

  @override
  String get bookRoom => 'Reservar Sala';

  @override
  String get roomAlreadyBooked => 'La sala ya está reservada.';

  @override
  String get selectDate => 'Seleccionar Fecha';

  @override
  String get noDateSelected => 'Ninguna fecha seleccionada';

  @override
  String get selectStartDate => 'Seleccionar Hora de Inicio';

  @override
  String get noStartTimeSelected => 'Ninguna hora de inicio seleccionada';

  @override
  String get selectEndTime => 'Seleccionar Hora de Fin';

  @override
  String get noEndTimeSelected => 'Ninguna hora de fin seleccionada';

  @override
  String get cancel => 'Cancelar';

  @override
  String get book => 'Reservar';

  @override
  String get pleaseSelectDateAndTime => 'Por favor, selecciona fecha y horas.';

  @override
  String get endTimeMustBeAfterStartTime =>
      'La hora de fin debe ser posterior a la de inicio.';

  @override
  String get noBookingsYet => 'Aún no tienes reservas.';

  @override
  String get date => 'Fecha';

  @override
  String get time => 'Hora';

  @override
  String get language => 'Idioma';

  @override
  String get changeLanguage => 'Cambiar Idioma';
}
