import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ride_model.dart';
import '../services/firebase/firestore_service.dart';
import '../services/matching/ride_matching_service.dart';
import 'auth_provider.dart';

final firestoreServiceProvider = Provider((ref) => FirestoreService());
final rideMatchingServiceProvider = Provider((ref) => RideMatchingService());

// Active rides stream
final activeRidesProvider = StreamProvider<List<RideModel>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getActiveRides();
});

// Driver's rides stream
final driverRidesProvider = StreamProvider<List<RideModel>>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return Stream.value([]);
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getDriverRides(user.uid);
});

// Single ride stream
final rideStreamProvider =
    StreamProvider.family<RideModel?, String>((ref, rideId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getRideStream(rideId);
});

// Matching rides for passenger
final matchingRidesProvider = StateNotifierProvider<MatchingRidesNotifier,
    AsyncValue<List<MatchResult>>>((ref) {
  return MatchingRidesNotifier(ref);
});

class MatchingRidesNotifier
    extends StateNotifier<AsyncValue<List<MatchResult>>> {
  final Ref _ref;

  MatchingRidesNotifier(this._ref) : super(const AsyncValue.data([]));

  Future<void> findMatches({
    required double pickupLat,
    required double pickupLng,
    required double dropoffLat,
    required double dropoffLng,
    required DateTime departureTime,
  }) async {
    state = const AsyncValue.loading();
    try {
      final rides = _ref.read(activeRidesProvider).valueOrNull ?? [];
      final matchingService = _ref.read(rideMatchingServiceProvider);

      final results = matchingService.findMatchingRides(
        availableRides: rides,
        passengerPickupLat: pickupLat,
        passengerPickupLng: pickupLng,
        passengerDropoffLat: dropoffLat,
        passengerDropoffLng: dropoffLng,
        passengerTime: departureTime,
      );

      state = AsyncValue.data(results);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  void clear() {
    state = const AsyncValue.data([]);
  }
}
