import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking.dart';

class BookingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new booking
  Future<String> createBooking(Booking booking) async {
    final docRef = await _firestore
        .collection('bookings')
        .add(booking.toFirestore());
    return docRef.id;
  }

  // Get bookings for a trip
  Stream<List<Booking>> getTripBookings(String tripId) {
    return _firestore
        .collection('bookings')
        .where('tripId', isEqualTo: tripId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList(),
        );
  }

  // Update a booking
  Future<void> updateBooking(
    String bookingId,
    Map<String, dynamic> updates,
  ) async {
    await _firestore.collection('bookings').doc(bookingId).update(updates);
  }

  // Delete a booking
  Future<void> deleteBooking(String bookingId) async {
    await _firestore.collection('bookings').doc(bookingId).delete();
  }
}
