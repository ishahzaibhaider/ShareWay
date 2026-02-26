import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../services/maps/location_service.dart';

final locationServiceProvider = Provider((ref) => LocationService());

final currentLocationProvider =
    FutureProvider<Position?>((ref) async {
  final locationService = ref.watch(locationServiceProvider);
  return await locationService.getCurrentPosition();
});
