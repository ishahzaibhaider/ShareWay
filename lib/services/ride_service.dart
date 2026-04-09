import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/ride.dart';

// ── Ride Service ─────────────────────────────────────────────────────────────
class RideService extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  final _ridesCol = FirebaseFirestore.instance.collection('rides');
  final _bookingsCol = FirebaseFirestore.instance.collection('bookings');

  // Set this to false once your Firebase project is ready
  bool useMock = true;

  // ── Create Ride ───────────────────────────────────────────────────────────
  Future<String?> createRide({
    required String driverId,
    required String pickup,
    required double pickupLat,
    required double pickupLng,
    required String destination,
    required double destLat,
    required double destLng,
    required DateTime departureTime,
    required double pricePerSeat,
    required int availableSeats,
    required List<String> preferences,
    required bool isRecurring,
  }) async {
    try {
      if (useMock) {
        await Future.delayed(const Duration(milliseconds: 500));
        return 'mock-ride-${DateTime.now().millisecondsSinceEpoch}';
      }

      final doc = await _ridesCol.add({
        'driverId': driverId,
        'pickup': pickup,
        'pickupLat': pickupLat,
        'pickupLng': pickupLng,
        'destination': destination,
        'destLat': destLat,
        'destLng': destLng,
        'departureTime': Timestamp.fromDate(departureTime),
        'pricePerSeat': pricePerSeat,
        'availableSeats': availableSeats,
        'preferences': preferences,
        'isRecurring': isRecurring,
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return doc.id;
    } catch (e) {
      debugPrint('createRide error: $e');
      return null;
    }
  }

  // ── Get Available Rides ───────────────────────────────────────────────────
  Future<List<Ride>> getAvailableRides({
    String? category,
    double? maxPrice,
  }) async {
    try {
      if (useMock) {
        await Future.delayed(const Duration(milliseconds: 300));
        var rides = Ride.getMockRides();
        if (category != null && category != 'all') {
          rides = rides.where((r) => r.category == category).toList();
        }
        if (maxPrice != null) {
          rides = rides.where((r) => r.price <= maxPrice).toList();
        }
        return rides;
      }

      Query query = _ridesCol.where('status', isEqualTo: 'active');
      if (category != null && category != 'all') {
        query = query.where('category', isEqualTo: category);
      }
      if (maxPrice != null) {
        query = query.where('pricePerSeat', isLessThanOrEqualTo: maxPrice);
      }
      
      final snapshot = await query.get();
      return snapshot.docs.map((d) {
        final data = d.data() as Map<String, dynamic>;
        data['id'] = d.id;
        return Ride.fromMap(data);
      }).toList();
    } catch (e) {
      debugPrint('getAvailableRides error: $e');
      return [];
    }
  }

  // ── Book a Ride ───────────────────────────────────────────────────────────
  Future<String?> bookRide({
    required String rideId,
    required String passengerId,
    required double fare,
  }) async {
    try {
      if (useMock) {
        await Future.delayed(const Duration(milliseconds: 600));
        return 'SW-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      }

      return await _db.runTransaction((txn) async {
        final rideRef = _ridesCol.doc(rideId);
        final rideSnap = await txn.get(rideRef);
        
        if (!rideSnap.exists) throw Exception('Ride not found');
        
        final seats = rideSnap['availableSeats'] as int;
        if (seats < 1) throw Exception('No seats left');
        
        txn.update(rideRef, {'availableSeats': seats - 1});
        
        final bookingRef = _bookingsCol.doc();
        txn.set(bookingRef, {
          'rideId': rideId,
          'passengerId': passengerId,
          'fare': fare,
          'status': 'confirmed',
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        return bookingRef.id;
      });
    } catch (e) {
      debugPrint('bookRide error: $e');
      return null;
    }
  }

  // ── Cancel Booking ────────────────────────────────────────────────────────
  Future<bool> cancelBooking(String bookingId) async {
    try {
      if (useMock) {
        await Future.delayed(const Duration(milliseconds: 400));
        return true;
      }

      await _bookingsCol.doc(bookingId).update({'status': 'cancelled'});
      return true;
    } catch (e) {
      debugPrint('cancelBooking error: $e');
      return false;
    }
  }

  // ── Rate Ride ─────────────────────────────────────────────────────────────
  Future<void> rateRide({
    required String bookingId,
    required String driverId,
    required double rating,
    String? comment,
  }) async {
    try {
      if (useMock) {
        await Future.delayed(const Duration(milliseconds: 300));
        return;
      }

      await _bookingsCol.doc(bookingId).update({
        'passengerRating': rating,
        'comment': comment,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      // Note: Driver average rating should typically be handled by a Cloud Function trigger
    } catch (e) {
      debugPrint('rateRide error: $e');
    }
  }
}
