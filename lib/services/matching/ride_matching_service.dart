import 'dart:math';
import '../../models/ride_model.dart';
import '../../config/app_constants.dart';

class MatchResult {
  final RideModel ride;
  final double score;
  final double routeSimilarity;
  final double timeOverlap;
  final double ratingScore;
  final double distanceScore;

  MatchResult({
    required this.ride,
    required this.score,
    required this.routeSimilarity,
    required this.timeOverlap,
    required this.ratingScore,
    required this.distanceScore,
  });
}

class RideMatchingService {
  /// Main matching function - finds best rides for a passenger
  List<MatchResult> findMatchingRides({
    required List<RideModel> availableRides,
    required double passengerPickupLat,
    required double passengerPickupLng,
    required double passengerDropoffLat,
    required double passengerDropoffLng,
    required DateTime passengerTime,
  }) {
    final results = <MatchResult>[];

    for (final ride in availableRides) {
      if (ride.availableSeats <= 0) continue;

      // 1. Route Similarity Score (40%)
      final routeSimilarity = _calculateRouteSimilarity(
        driverOriginLat: ride.origin.lat,
        driverOriginLng: ride.origin.lng,
        driverDestLat: ride.destination.lat,
        driverDestLng: ride.destination.lng,
        passengerPickupLat: passengerPickupLat,
        passengerPickupLng: passengerPickupLng,
        passengerDropoffLat: passengerDropoffLat,
        passengerDropoffLng: passengerDropoffLng,
      );

      // 2. Time Overlap Score (30%)
      final timeOverlap = _calculateTimeOverlap(
        driverDeparture: ride.departureTime,
        passengerTime: passengerTime,
        windowMinutes: AppConstants.timeWindowMinutes,
      );

      // 3. Driver Rating Score (20%)
      final ratingScore = ride.driverRating / 5.0;

      // 4. Distance Score (10%) - how close pickup is to driver's route
      final distanceScore = _calculateDistanceScore(
        driverOriginLat: ride.origin.lat,
        driverOriginLng: ride.origin.lng,
        passengerPickupLat: passengerPickupLat,
        passengerPickupLng: passengerPickupLng,
      );

      // Weighted final score
      final finalScore = (routeSimilarity * AppConstants.routeSimilarityWeight) +
          (timeOverlap * AppConstants.timeOverlapWeight) +
          (ratingScore * AppConstants.ratingWeight) +
          (distanceScore * AppConstants.distanceWeight);

      // Only include if above minimum threshold
      if (finalScore >= AppConstants.minimumMatchScore) {
        results.add(MatchResult(
          ride: ride,
          score: finalScore,
          routeSimilarity: routeSimilarity,
          timeOverlap: timeOverlap,
          ratingScore: ratingScore,
          distanceScore: distanceScore,
        ));
      }
    }

    // Sort by score descending
    results.sort((a, b) => b.score.compareTo(a.score));

    return results;
  }

  /// Calculate how similar two routes are
  /// Uses Haversine distance to compare origin-to-origin and dest-to-dest
  double _calculateRouteSimilarity({
    required double driverOriginLat,
    required double driverOriginLng,
    required double driverDestLat,
    required double driverDestLng,
    required double passengerPickupLat,
    required double passengerPickupLng,
    required double passengerDropoffLat,
    required double passengerDropoffLng,
  }) {
    // Distance from passenger pickup to driver origin
    final pickupDistance = _haversineDistance(
      passengerPickupLat,
      passengerPickupLng,
      driverOriginLat,
      driverOriginLng,
    );

    // Distance from passenger dropoff to driver destination
    final dropoffDistance = _haversineDistance(
      passengerDropoffLat,
      passengerDropoffLng,
      driverDestLat,
      driverDestLng,
    );

    // Calculate direction similarity (are they going the same way?)
    final driverBearing = _calculateBearing(
      driverOriginLat, driverOriginLng,
      driverDestLat, driverDestLng,
    );
    final passengerBearing = _calculateBearing(
      passengerPickupLat, passengerPickupLng,
      passengerDropoffLat, passengerDropoffLng,
    );

    // Bearing difference (0 = same direction, 180 = opposite)
    double bearingDiff = (driverBearing - passengerBearing).abs();
    if (bearingDiff > 180) bearingDiff = 360 - bearingDiff;
    final directionScore = max(0.0, 1.0 - (bearingDiff / 90.0));

    // Max distance threshold (5km)
    final maxDist = AppConstants.maxPickupDistanceKm * 1000; // meters
    final pickupScore = max(0.0, 1.0 - (pickupDistance / maxDist));
    final dropoffScore = max(0.0, 1.0 - (dropoffDistance / maxDist));

    // Combined score: pickup proximity + dropoff proximity + direction match
    return (pickupScore * 0.35) + (dropoffScore * 0.35) + (directionScore * 0.3);
  }

  /// Calculate time overlap score
  double _calculateTimeOverlap({
    required DateTime driverDeparture,
    required DateTime passengerTime,
    required int windowMinutes,
  }) {
    final diffMinutes =
        driverDeparture.difference(passengerTime).inMinutes.abs();
    return max(0.0, 1.0 - (diffMinutes / windowMinutes));
  }

  /// Calculate how close passenger pickup is to driver's starting point
  double _calculateDistanceScore({
    required double driverOriginLat,
    required double driverOriginLng,
    required double passengerPickupLat,
    required double passengerPickupLng,
  }) {
    final distance = _haversineDistance(
      driverOriginLat,
      driverOriginLng,
      passengerPickupLat,
      passengerPickupLng,
    );
    final maxDist = AppConstants.maxPickupDistanceKm * 1000;
    return max(0.0, 1.0 - (distance / maxDist));
  }

  /// Haversine formula - distance between two lat/lng points in meters
  double _haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371000.0; // meters
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  /// Calculate bearing between two points (in degrees)
  double _calculateBearing(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final dLon = _toRadians(lon2 - lon1);
    final lat1Rad = _toRadians(lat1);
    final lat2Rad = _toRadians(lat2);

    final y = sin(dLon) * cos(lat2Rad);
    final x = cos(lat1Rad) * sin(lat2Rad) -
        sin(lat1Rad) * cos(lat2Rad) * cos(dLon);

    final bearing = atan2(y, x);
    return (_toDegrees(bearing) + 360) % 360;
  }

  double _toRadians(double degrees) => degrees * pi / 180;
  double _toDegrees(double radians) => radians * 180 / pi;
}
