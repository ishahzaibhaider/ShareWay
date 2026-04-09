/// ShareWay — AI Matching Engine
/// Implements GeoHash-based route matching + scoring algorithm
/// Sprint 3: Core AI logic for the Matching Engine Module

import 'dart:math';

// ── GeoHash Utility ─────────────────────────────────────────────────────────
class GeoHash {
  static const String _base32 = '0123456789bcdefghjkmnpqrstuvwxyz';

  /// Encode lat/lng to geohash of given precision
  static String encode(double lat, double lng, {int precision = 7}) {
    double minLat = -90, maxLat = 90;
    double minLng = -180, maxLng = 180;
    final buffer = StringBuffer();
    int bits = 0, bitsTotal = 0, hashValue = 0;
    bool isEven = true;

    while (buffer.length < precision) {
      double mid;
      if (isEven) {
        mid = (minLng + maxLng) / 2;
        if (lng > mid) { hashValue = (hashValue << 1) + 1; minLng = mid; }
        else            { hashValue = (hashValue << 1);     maxLng = mid; }
      } else {
        mid = (minLat + maxLat) / 2;
        if (lat > mid) { hashValue = (hashValue << 1) + 1; minLat = mid; }
        else            { hashValue = (hashValue << 1);     maxLat = mid; }
      }
      isEven = !isEven;
      if (++bits == 5) {
        buffer.write(_base32[hashValue]);
        bits = 0; hashValue = 0;
      }
      bitsTotal++;
    }
    return buffer.toString();
  }

  /// Return the 8 neighboring geohash cells + center
  static List<String> neighbors(String hash) {
    // Simplified: return hash + adjacent prefix variations
    // In production replace with full neighbor algorithm
    return [hash, '${hash.substring(0, hash.length - 1)}'];
  }
}

// ── Ride Match Model ─────────────────────────────────────────────────────────
class RideMatch {
  final String rideId;
  final double score;           // 0.0 – 1.0
  final double routeOverlapPct;
  final int timeDeltaMinutes;
  final double price;
  final double driverRating;

  const RideMatch({
    required this.rideId,
    required this.score,
    required this.routeOverlapPct,
    required this.timeDeltaMinutes,
    required this.price,
    required this.driverRating,
  });

  @override
  String toString() =>
      'RideMatch(id: $rideId, score: ${score.toStringAsFixed(2)}, overlap: ${routeOverlapPct.toStringAsFixed(0)}%)';
}

// ── Matching Engine ──────────────────────────────────────────────────────────
class MatchingEngine {
  // Weight factors for scoring (must sum to 1.0)
  static const double _wOverlap  = 0.40;
  static const double _wTime     = 0.25;
  static const double _wPrice    = 0.20;
  static const double _wRating   = 0.15;

  /// Main entry point — returns ranked list of matching rides
  /// [passengerLat/Lng] = passenger pickup coordinates
  /// [destLat/Lng]      = passenger destination coordinates
  /// [desiredTime]      = passenger's desired departure time
  /// [maxPrice]         = passenger's max fare per seat
  /// [availableRides]   = list of ride documents from Firestore
  static List<RideMatch> findMatches({
    required double passengerLat,
    required double passengerLng,
    required double destLat,
    required double destLng,
    required DateTime desiredTime,
    required double maxPrice,
    required List<Map<String, dynamic>> availableRides,
    int topN = 10,
  }) {
    final passengerHash = GeoHash.encode(passengerLat, passengerLng);
    final destHash      = GeoHash.encode(destLat, destLng);

    final List<RideMatch> matches = [];

    for (final ride in availableRides) {
      // ── Step 1: GeoHash proximity filter ────────────────────────────
      final pickupHash = ride['pickupGeoHash'] as String? ?? '';
      if (!_isNearby(passengerHash, pickupHash)) continue;

      // ── Step 2: Calculate route overlap ─────────────────────────────
      final overlap = _calculateRouteOverlap(
        passengerLat: passengerLat, passengerLng: passengerLng,
        destLat: destLat,           destLng: destLng,
        driverPickupLat: (ride['pickupLat'] as num?)?.toDouble() ?? 0,
        driverPickupLng: (ride['pickupLng'] as num?)?.toDouble() ?? 0,
        driverDestLat:   (ride['destLat']   as num?)?.toDouble() ?? 0,
        driverDestLng:   (ride['destLng']   as num?)?.toDouble() ?? 0,
      );
      if (overlap < 0.3) continue; // Require at least 30% overlap

      // ── Step 3: Time delta ───────────────────────────────────────────
      final rideTime    = (ride['departureTime'] as DateTime?) ?? desiredTime;
      final timeDelta   = desiredTime.difference(rideTime).inMinutes.abs();
      if (timeDelta > 30) continue; // Only rides within ±30 min

      // ── Step 4: Price check ──────────────────────────────────────────
      final price = (ride['pricePerSeat'] as num?)?.toDouble() ?? 0;
      if (price > maxPrice) continue;

      // ── Step 5: Compute composite score ─────────────────────────────
      final rating      = (ride['driverRating'] as num?)?.toDouble() ?? 3.0;
      final score       = _computeScore(
        overlap: overlap,
        timeDelta: timeDelta,
        price: price,
        maxPrice: maxPrice,
        rating: rating,
      );

      matches.add(RideMatch(
        rideId: ride['id'] as String? ?? '',
        score: score,
        routeOverlapPct: overlap * 100,
        timeDeltaMinutes: timeDelta,
        price: price,
        driverRating: rating,
      ));
    }

    // Sort descending by score, take top N
    matches.sort((a, b) => b.score.compareTo(a.score));
    return matches.take(topN).toList();
  }

  // ── Private Helpers ────────────────────────────────────────────────────────

  static bool _isNearby(String hashA, String hashB) {
    if (hashA.isEmpty || hashB.isEmpty) return true;
    // Match on first 5 chars = ~4.9km × 4.9km cell
    final len = min(5, min(hashA.length, hashB.length));
    return hashA.substring(0, len) == hashB.substring(0, len);
  }

  /// Simplified route overlap: measures how much of the passenger's
  /// route falls within the driver's route bounding box
  static double _calculateRouteOverlap({
    required double passengerLat, required double passengerLng,
    required double destLat,      required double destLng,
    required double driverPickupLat, required double driverPickupLng,
    required double driverDestLat,   required double driverDestLng,
  }) {
    // Bounding box of driver's route
    final dMinLat = min(driverPickupLat, driverDestLat);
    final dMaxLat = max(driverPickupLat, driverDestLat);
    final dMinLng = min(driverPickupLng, driverDestLng);
    final dMaxLng = max(driverPickupLng, driverDestLng);

    // Check how much of passenger route is inside driver bounding box
    int insideCount = 0;
    final points = [
      [passengerLat, passengerLng],
      [destLat, destLng],
      [(passengerLat + destLat) / 2, (passengerLng + destLng) / 2],
    ];

    for (final p in points) {
      if (p[0] >= dMinLat && p[0] <= dMaxLat &&
          p[1] >= dMinLng && p[1] <= dMaxLng) {
        insideCount++;
      }
    }

    return insideCount / points.length;
  }

  static double _computeScore({
    required double overlap,
    required int timeDelta,
    required double price,
    required double maxPrice,
    required double rating,
  }) {
    // Normalize each factor to [0, 1]
    final overlapScore = overlap.clamp(0.0, 1.0);
    final timeScore    = 1.0 - (timeDelta / 30.0).clamp(0.0, 1.0);
    final priceScore   = maxPrice > 0 ? (1.0 - price / maxPrice).clamp(0.0, 1.0) : 0.5;
    final ratingScore  = ((rating - 1.0) / 4.0).clamp(0.0, 1.0); // 1–5 → 0–1

    return _wOverlap * overlapScore
         + _wTime    * timeScore
         + _wPrice   * priceScore
         + _wRating  * ratingScore;
  }
}

// ── Fare Calculator ──────────────────────────────────────────────────────────
class FareCalculator {
  static const double _baseFare        = 50.0;   // Rs
  static const double _perKmRate       = 25.0;   // Rs/km
  static const double _peakMultiplier  = 1.3;
  static const double _minFare         = 80.0;

  /// Calculate suggested fare per seat for a driver
  static double calculateFare({
    required double distanceKm,
    required int totalSeats,
    required int occupiedSeats,
    bool isPeakHour = false,
  }) {
    final base = _baseFare + (distanceKm * _perKmRate);
    final withPeak = isPeakHour ? base * _peakMultiplier : base;
    final perSeat = withPeak / (occupiedSeats + 1); // split including driver
    return max(_minFare, perSeat.roundToDouble());
  }

  /// Haversine distance between two coordinates (km)
  static double haversineKm(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371.0;
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
              cos(_toRad(lat1)) * cos(_toRad(lat2)) *
              sin(dLng / 2) * sin(dLng / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  static double _toRad(double deg) => deg * pi / 180;
}
