// lib/main.dart

import 'package:aplicacion_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aplicacion_app/models/models.dart';
import 'package:aplicacion_app/provider/provider_reservaciones.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:aplicacion_app/generated/app_localizations.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class LanguageProvider with ChangeNotifier {
  Locale _locale = const Locale('es');

  Locale get locale => _locale;

  void setLocale(Locale newLocale) {
    if (_locale != newLocale) {
      _locale = newLocale;
      notifyListeners();
    }
  }
}

void onDidReceiveNotificationResponse(
  NotificationResponse notificationResponse,
) async {
  final String? payload = notificationResponse.payload;
  if (notificationResponse.payload != null) {
    debugPrint('notification payload: $payload');
  }
}

void onDidReceiveLocalNotification(
  int id,
  String? title,
  String? body,
  String? payload,
) async {
  debugPrint('Old iOS notification received: $title, $body, $payload');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');

  const DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification: onDidReceiveLocalNotification,
      );

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
    macOS: initializationSettingsDarwin,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ReservasProvider()),
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, langProvider, child) {
          return MaterialApp(
            title: AppLocalizations.of(context)?.appName ?? 'Gestión de Salas',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              useMaterial3: true,
            ),
            locale: langProvider.locale,

            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const SalasScreen(),
          );
        },
      ),
    );
  }
}

class SalasScreen extends StatelessWidget {
  const SalasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reservasProvider = Provider.of<ReservasProvider>(context);
    final salas = reservasProvider.salas;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.availableRooms),
      ), // Traducido
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: salas.length,
        itemBuilder: (context, index) {
          final sala = salas[index];
          return SalaCard(sala: sala);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => const MisReservasScreen()),
          );
        },
        child: const Icon(Icons.list),
        tooltip: AppLocalizations.of(context)!.myBookings,
      ),
    );
  }
}

class SalaCard extends StatefulWidget {
  final Sala sala;

  const SalaCard({super.key, required this.sala});

  @override
  State<SalaCard> createState() => _SalaCardState();
}

class _SalaCardState extends State<SalaCard> {
  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaInicioSeleccionada;
  TimeOfDay? _horaFinSeleccionada;

  Future<void> _presentDatePicker() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      setState(() {
        _fechaSeleccionada = pickedDate;
      });
    }
  }

  Future<void> _presentStartTimePicker() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.input,
    );
    if (pickedTime != null) {
      setState(() {
        _horaInicioSeleccionada = pickedTime;
      });
    }
  }

  Future<void> _presentEndTimePicker() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _horaInicioSeleccionada != null
          ? TimeOfDay(
              hour: _horaInicioSeleccionada!.hour + 1,
              minute: _horaInicioSeleccionada!.minute,
            )
          : TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.input,
    );
    if (pickedTime != null) {
      setState(() {
        _horaFinSeleccionada = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final reservasProvider = Provider.of<ReservasProvider>(
      context,
      listen: false,
    );

    final Color cardColor = widget.sala.isReservada
        ? Colors.red.withOpacity(0.7)
        : Colors.green.withOpacity(0.7);

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: InkWell(
        onTap: () {
          if (!widget.sala.isReservada) {
            _mostrarDialogoReserva(context, widget.sala, reservasProvider);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)!.roomAlreadyBooked,
                ), // Traducido
              ),
            );
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.asset(
                    widget.sala.imagenAsset,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.sala.nombre,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${AppLocalizations.of(context)!.status}: ${widget.sala.isReservada ? AppLocalizations.of(context)!.booked : AppLocalizations.of(context)!.available}',
                  style: TextStyle(
                    fontSize: 16,
                    color: widget.sala.isReservada
                        ? Colors.white
                        : Colors.white,
                  ),
                ),
                if (widget.sala.isReservada)
                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                      onPressed: () {
                        reservasProvider.liberarSala(widget.sala.id);
                      },
                      child: Text(
                        AppLocalizations.of(context)!.releaseRoom,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _mostrarDialogoReserva(
    BuildContext context,
    Sala sala,
    ReservasProvider provider,
  ) {
    _fechaSeleccionada = null;
    _horaInicioSeleccionada = null;
    _horaFinSeleccionada = null;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(
                '${AppLocalizations.of(context)!.bookRoom} ${sala.nombre}',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _fechaSeleccionada == null
                                ? AppLocalizations.of(context)!.noDateSelected
                                : '${AppLocalizations.of(context)!.date}: ${DateFormat('dd/MM/yyyy').format(_fechaSeleccionada!)}',
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            await _presentDatePicker();
                            setStateDialog(() {});
                          },
                          child: Text(AppLocalizations.of(context)!.selectDate),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _horaInicioSeleccionada == null
                                ? AppLocalizations.of(
                                    context,
                                  )!.noStartTimeSelected
                                : '${AppLocalizations.of(context)!.from}: ${_horaInicioSeleccionada!.format(context)}',
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            await _presentStartTimePicker();
                            setStateDialog(() {});
                          },
                          child: Text(
                            AppLocalizations.of(context)!.selectStartDate,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _horaFinSeleccionada == null
                                ? AppLocalizations.of(
                                    context,
                                  )!.noEndTimeSelected
                                : '${AppLocalizations.of(context)!.to}: ${_horaFinSeleccionada!.format(context)}',
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            await _presentEndTimePicker();
                            setStateDialog(() {});
                          },
                          child: Text(
                            AppLocalizations.of(context)!.selectEndTime,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(
                    AppLocalizations.of(context)!.cancel,
                  ), // Traducido
                ),
                TextButton(
                  onPressed: () {
                    if (_fechaSeleccionada == null ||
                        _horaInicioSeleccionada == null ||
                        _horaFinSeleccionada == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(
                              context,
                            )!.pleaseSelectDateAndTime,
                          ), // Traducido
                        ),
                      );
                      return;
                    }

                    final now = DateTime.now();
                    final startDateTime = DateTime(
                      now.year,
                      now.month,
                      now.day,
                      _horaInicioSeleccionada!.hour,
                      _horaInicioSeleccionada!.minute,
                    );
                    final endDateTime = DateTime(
                      now.year,
                      now.month,
                      now.day,
                      _horaFinSeleccionada!.hour,
                      _horaFinSeleccionada!.minute,
                    );

                    if (endDateTime.isBefore(startDateTime) ||
                        endDateTime.isAtSameMomentAs(startDateTime)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(
                              context,
                            )!.endTimeMustBeAfterStartTime,
                          ),
                        ),
                      );
                      return;
                    }

                    provider.reservarSala(
                      sala.id,
                      _fechaSeleccionada!,
                      _horaInicioSeleccionada!,
                      _horaFinSeleccionada!,
                      context,
                    );
                    Navigator.of(ctx).pop();
                  },
                  child: Text(AppLocalizations.of(context)!.book),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class MisReservasScreen extends StatelessWidget {
  const MisReservasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reservasProvider = Provider.of<ReservasProvider>(context);

    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final reservas = reservasProvider.reservas;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.myBookings),
        actions: [
          PopupMenuButton<Locale>(
            onSelected: (Locale newLocale) {
              languageProvider.setLocale(newLocale);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Locale>>[
              const PopupMenuItem<Locale>(
                value: Locale('es'),
                child: Text('Español'),
              ),
              const PopupMenuItem<Locale>(
                value: Locale('en'),
                child: Text('English'),
              ),
            ],
            icon: const Icon(Icons.language),
            tooltip: AppLocalizations.of(context)!.changeLanguage,
          ),
        ],
      ),
      body: reservas.isEmpty
          ? Center(child: Text(AppLocalizations.of(context)!.noBookingsYet))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: reservas.length,
              itemBuilder: (context, index) {
                final reserva = reservas[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(reserva.nombreSala),
                    subtitle: Text(
                      '${AppLocalizations.of(context)!.date}: ${DateFormat('yyyy-MM-dd').format(reserva.fechaReserva)}\n${AppLocalizations.of(context)!.time}: ${reserva.horaInicio.format(context)} - ${reserva.horaFin.format(context)}',
                    ),
                  ),
                );
              },
            ),
    );
  }
}
