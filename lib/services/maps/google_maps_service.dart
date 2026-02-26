import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GoogleMapsService {
  String get _apiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  // Get directions between two points
  Future<DirectionsResult?> getDirections({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json'
      '?origin=$originLat,$originLng'
      '&destination=$destLat,$destLng'
      '&key=$_apiKey',
    );

    final response = await http.get(url);
    if (response.statusCode != 200) return null;

    final data = json.decode(response.body);
    if (data['status'] != 'OK' || (data['routes'] as List).isEmpty) {
      return null;
    }

    final route = data['routes'][0];
    final leg = route['legs'][0];

    return DirectionsResult(
      polyline: route['overview_polyline']['points'],
      distanceMeters: leg['distance']['value'],
      distanceText: leg['distance']['text'],
      durationSeconds: leg['duration']['value'],
      durationText: leg['duration']['text'],
    );
  }

  // Get distance matrix between origins and destinations
  Future<DistanceMatrixResult?> getDistanceMatrix({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/distancematrix/json'
      '?origins=$originLat,$originLng'
      '&destinations=$destLat,$destLng'
      '&key=$_apiKey',
    );

    final response = await http.get(url);
    if (response.statusCode != 200) return null;

    final data = json.decode(response.body);
    if (data['status'] != 'OK') return null;

    final element = data['rows'][0]['elements'][0];
    if (element['status'] != 'OK') return null;

    return DistanceMatrixResult(
      distanceMeters: element['distance']['value'],
      distanceText: element['distance']['text'],
      durationSeconds: element['duration']['value'],
      durationText: element['duration']['text'],
    );
  }

  // Place autocomplete
  Future<List<PlacePrediction>> getPlacePredictions(String input) async {
    if (input.isEmpty) return [];

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json'
      '?input=${Uri.encodeComponent(input)}'
      '&components=country:pk'
      '&key=$_apiKey',
    );

    final response = await http.get(url);
    if (response.statusCode != 200) return [];

    final data = json.decode(response.body);
    if (data['status'] != 'OK') return [];

    return (data['predictions'] as List)
        .map((p) => PlacePrediction(
              placeId: p['place_id'],
              description: p['description'],
              mainText: p['structured_formatting']['main_text'],
              secondaryText:
                  p['structured_formatting']['secondary_text'] ?? '',
            ))
        .toList();
  }

  // Get place details (lat, lng from place ID)
  Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json'
      '?place_id=$placeId'
      '&fields=geometry,formatted_address,name'
      '&key=$_apiKey',
    );

    final response = await http.get(url);
    if (response.statusCode != 200) return null;

    final data = json.decode(response.body);
    if (data['status'] != 'OK') return null;

    final result = data['result'];
    final location = result['geometry']['location'];

    return PlaceDetails(
      placeId: placeId,
      name: result['name'] ?? '',
      address: result['formatted_address'] ?? '',
      lat: location['lat'].toDouble(),
      lng: location['lng'].toDouble(),
    );
  }
}

class DirectionsResult {
  final String polyline;
  final int distanceMeters;
  final String distanceText;
  final int durationSeconds;
  final String durationText;

  DirectionsResult({
    required this.polyline,
    required this.distanceMeters,
    required this.distanceText,
    required this.durationSeconds,
    required this.durationText,
  });
}

class DistanceMatrixResult {
  final int distanceMeters;
  final String distanceText;
  final int durationSeconds;
  final String durationText;

  DistanceMatrixResult({
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
