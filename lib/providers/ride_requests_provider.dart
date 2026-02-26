import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ride_request_model.dart';
import 'rides_provider.dart';
import 'auth_provider.dart';

// Incoming requests for driver
final incomingRequestsProvider =
    StreamProvider<List<RideRequestModel>>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return Stream.value([]);
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getIncomingRequests(user.uid);
});

// Sent requests by passenger
final sentRequestsProvider =
    StreamProvider<List<RideRequestModel>>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return Stream.value([]);
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getSentRequests(user.uid);
});
