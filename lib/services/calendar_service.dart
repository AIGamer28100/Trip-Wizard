import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/auth_io.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../models/itinerary_item.dart';
import '../models/trip.dart';

class CalendarService {
  // Share the same GoogleSignIn instance across the app
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
      'https://www.googleapis.com/auth/calendar',
      'https://www.googleapis.com/auth/calendar.events',
    ],
  );

  AuthClient? _authClient;
  calendar.CalendarApi? _calendarApi;

  Future<bool> initialize() async {
    try {
      // First, check if user is already signed in with Google
      GoogleSignInAccount? account = _googleSignIn.currentUser;

      // If not, try silent sign-in
      if (account == null) {
        account = await _googleSignIn.signInSilently();
      }

      if (account == null) {
        // User needs to sign in
        return false;
      }

      final GoogleSignInAuthentication auth = await account.authentication;

      // Check if we have a valid access token
      if (auth.accessToken == null) {
        return false;
      }

      final credentials = AccessCredentials(
        AccessToken(
          'Bearer',
          auth.accessToken!,
          DateTime.now().add(const Duration(hours: 1)),
        ),
        auth.idToken,
        [
          'https://www.googleapis.com/auth/calendar',
          'https://www.googleapis.com/auth/calendar.events',
        ],
      );

      _authClient = authenticatedClient(http.Client(), credentials);
      _calendarApi = calendar.CalendarApi(_authClient!);
      return true;
    } catch (e) {
      print('Failed to initialize calendar service: $e');
      return false;
    }
  }

  Future<bool> signIn() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) return false;

      return await initialize();
    } catch (e) {
      print('Failed to sign in to calendar: $e');
      return false;
    }
  }

  Future<String?> createTripCalendar(Trip trip) async {
    if (_calendarApi == null) return null;

    try {
      final calendar.Calendar newCalendar = calendar.Calendar(
        summary: '${trip.title} - Trip Wizards',
        description: 'Itinerary for ${trip.destination}',
      );

      final createdCalendar = await _calendarApi!.calendars.insert(newCalendar);
      return createdCalendar.id;
    } catch (e) {
      print('Failed to create trip calendar: $e');
      return null;
    }
  }

  Future<bool> syncItineraryItem(
    String calendarId,
    ItineraryItem item,
    Trip trip,
  ) async {
    if (_calendarApi == null) return false;

    try {
      // Parse the date and time
      final DateTime startDateTime = _parseDateTime(
        trip.startDate,
        item.day,
        item.time,
      );
      final DateTime endDateTime = startDateTime.add(
        const Duration(hours: 2),
      ); // Default 2 hours

      final event = calendar.Event(
        summary: item.activity,
        description: item.description ?? 'Added via Trip Wizards',
        start: calendar.EventDateTime(
          dateTime: startDateTime.toUtc(),
          timeZone: 'UTC',
        ),
        end: calendar.EventDateTime(
          dateTime: endDateTime.toUtc(),
          timeZone: 'UTC',
        ),
        reminders: calendar.EventReminders(useDefault: true),
      );

      await _calendarApi!.events.insert(event, calendarId);
      return true;
    } catch (e) {
      print('Failed to sync itinerary item: $e');
      return false;
    }
  }

  Future<bool> syncAllItineraryItems(
    String calendarId,
    List<ItineraryItem> items,
    Trip trip,
  ) async {
    if (_calendarApi == null) return false;

    bool allSuccessful = true;
    for (final item in items) {
      final success = await syncItineraryItem(calendarId, item, trip);
      if (!success) allSuccessful = false;
    }
    return allSuccessful;
  }

  Future<List<calendar.Event>> getUpcomingEvents(String calendarId) async {
    if (_calendarApi == null) return [];

    try {
      final events = await _calendarApi!.events.list(calendarId);
      return events.items ?? [];
    } catch (e) {
      print('Failed to get calendar events: $e');
      return [];
    }
  }

  DateTime _parseDateTime(DateTime tripStartDate, int day, String time) {
    // Calculate the actual date by adding (day - 1) to the trip start date
    final eventDate = tripStartDate.add(Duration(days: day - 1));

    // Parse time (assuming format like "10:00" or "14:30")
    final timeParts = time.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    return DateTime(
      eventDate.year,
      eventDate.month,
      eventDate.day,
      hour,
      minute,
    );
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _authClient?.close();
    _authClient = null;
    _calendarApi = null;
  }

  bool get isSignedIn => _googleSignIn.currentUser != null;
}
