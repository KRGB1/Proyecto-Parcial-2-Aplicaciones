// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Room Management';

  @override
  String get availableRooms => 'Available Rooms';

  @override
  String get myBookings => 'My Bookings';

  @override
  String get bookingConfirmed => 'Booking Confirmed';

  @override
  String get yourBookingFor => 'Your booking for';

  @override
  String get from => 'from';

  @override
  String get to => 'to';

  @override
  String get hasBeenSaved => 'has been saved.';

  @override
  String get room => 'Room';

  @override
  String get status => 'Status';

  @override
  String get booked => 'Booked';

  @override
  String get available => 'Available';

  @override
  String get releaseRoom => 'Release Room';

  @override
  String get bookRoom => 'Book Room';

  @override
  String get roomAlreadyBooked => 'The room is already booked.';

  @override
  String get selectDate => 'Select Date';

  @override
  String get noDateSelected => 'No date selected';

  @override
  String get selectStartDate => 'Select Start Time';

  @override
  String get noStartTimeSelected => 'No start time selected';

  @override
  String get selectEndTime => 'Select End Time';

  @override
  String get noEndTimeSelected => 'No end time selected';

  @override
  String get cancel => 'Cancel';

  @override
  String get book => 'Book';

  @override
  String get pleaseSelectDateAndTime => 'Please select date and times.';

  @override
  String get endTimeMustBeAfterStartTime =>
      'End time must be after start time.';

  @override
  String get noBookingsYet => 'You don\'t have any bookings yet.';

  @override
  String get date => 'Date';

  @override
  String get time => 'Time';

  @override
  String get language => 'Language';

  @override
  String get changeLanguage => 'Change Language';
}
