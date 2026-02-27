import 'dart:convert';
import 'package:http/http.dart' as http;

class OsmService {
  static const _headers = {'User-Agent': 'ShareWay/1.0'};

  // Place autocomplete using Nominatim
  Future<List<PlacePrediction>> getPlacePredictions(String input) async {
    if (input.isEmpty) return [];

    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search'
      '?q=${Uri.encodeComponent(input)}'
      '&countrycodes=pk'
      '&format=json'
      '&limit=5'
      '&addressdetails=1',
    );

    final response = await http.get(url, headers: _headers);
    if (response.statusCode != 200) return [];

    final data = json.decode(response.body) as List;
    return data.map((p) {
      final displayName = p['display_name'] as String;
      final parts = displayName.split(', ');
      return PlacePrediction(
        placeId: p['place_id'].toString(),
        description: displayName,
        mainText: parts.isNotEmpty ? parts[0] : displayName,
        secondaryText: parts.length > 1 ? parts.sublist(1).join(', ') : '',
      );
    }).toList();
  }

  // Get place details (reverse geocode from place_id isn't directly available,
  // so we return data from search results directly)
  Future<PlaceDetails?> getPlaceDetailsFromPrediction(
      PlacePrediction prediction, double lat, double lng) async {
    return PlaceDetails(
      placeId: prediction.placeId,
      name: prediction.mainText,
      address: prediction.description,
      lat: lat,
      lng: lng,
    );
  }

  // Search and return full details in one step (Nominatim returns lat/lng in search)
  Future<List<PlaceSearchResult>> searchPlaces(String input) async {
    if (input.isEmpty) return [];

    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search'
      '?q=${Uri.encodeComponent(input)}'
      '&countrycodes=pk'
      '&format=json'
      '&limit=5'
      '&addressdetails=1',
    );

    final response = await http.get(url, headers: _headers);
    if (response.statusCode != 200) return [];

    final data = json.decode(response.body) as List;
    return data.map((p) {
      final displayName = p['display_name'] as String;
      final parts = displayName.split(', ');
      return PlaceSearchResult(
        placeId: p['place_id'].toString(),
        description: displayName,
        mainText: parts.isNotEmpty ? parts[0] : displayName,
        secondaryText: parts.length > 1 ? parts.sublist(1).join(', ') : '',
        lat: double.parse(p['lat']),
        lng: double.parse(p['lon']),
      );
    }).toList();
  }

  // Reverse geocode: get address from coordinates
  Future<String?> getAddressFromCoordinates(double lat, double lng) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse'
      '?lat=$lat'
      '&lon=$lng'
      '&format=json',
    );

    final response = await http.get(url, headers: _headers);
    if (response.statusCode != 200) return null;

    final data = json.decode(response.body);
    return data['display_name'] as String?;
  }

  // Get route using OSRM
  Future<DirectionsResult?> getDirections({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '$originLng,$originLat;$destLng,$destLat'
      '?overview=full&geometries=geojson',
    );

    final response = await http.get(url);
    if (response.statusCode != 200) return null;

    final data = json.decode(response.body);
    if (data['code'] != 'Ok' || (data['routes'] as List).isEmpty) {
      return null;
    }

    final route = data['routes'][0];
    final geometry = route['geometry'];
    final coordinates = (geometry['coordinates'] as List)
        .map((c) => [c[1].toDouble(), c[0].toDouble()]) // [lat, lng]
        .toList();

    final distanceMeters = (route['distance'] as num).toInt();
    final durationSeconds = (route['duration'] as num).toInt();

    return DirectionsResult(
      routePoints: coordinates.map((c) => LatLngPoint(c[0], c[1])).toList(),
      distanceMeters: distanceMeters,
      distanceText: _formatDistance(distanceMeters),
      durationSeconds: durationSeconds,
      durationText: _formatDuration(durationSeconds),
    );
  }

  String _formatDistance(int meters) {
    if (meters < 1000) return '$meters m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '$seconds sec';
    final minutes = seconds ~/ 60;
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '${hours}h ${remainingMinutes}m';
  }
}

class LatLngPoint {
  final double lat;
  final double lng;
  LatLngPoint(this.lat, this.lng);
}

class DirectionsResult {
  final List<LatLngPoint> routePoints;
  final int distanceMeters;
  final String distanceText;
  final int durationSeconds;
  final String durationText;

  DirectionsResult({
    required this.routePoints,
    required this.distanceMeters,
    required this.distanceText,
    required this.durationSeconds,
    required this.durationText,
  });
}

class PlacePrediction {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;

  PlacePrediction({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
  });
}

class PlaceDetails {
  final String placeId;
  final String name;
  final String address;
  final double lat;
  final double lng;

  PlaceDetails({
    required this.placeId,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
  });
}

class PlaceSearchResult {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;
  final double lat;
  final double lng;

  PlaceSearchResult({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
    required this.lat,
    required this.lng,
  });

  PlaceDetails toPlaceDetails() {
    return PlaceDetails(
      placeId: placeId,
      name: mainText,
      address: description,
      lat: lat,
      lng: lng,
    );
  }
}
