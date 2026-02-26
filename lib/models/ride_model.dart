import 'package:cloud_firestore/cloud_firestore.dart';

class LocationPoint {
  final double lat;
  final double lng;
  final String address;
  final String? placeId;

  LocationPoint({
    required this.lat,
    required this.lng,
    required this.address,
    this.placeId,
  });

  factory LocationPoint.fromMap(Map<String, dynamic> map) {
    return LocationPoint(
      lat: (map['lat'] ?? 0.0).toDouble(),
      lng: (map['lng'] ?? 0.0).toDouble(),
      address: map['address'] ?? '',
      placeId: map['placeId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lat': lat,
      'lng': lng,
      'address': address,
      'placeId': placeId,
    };
  }
}

class RidePassenger {
  final String passengerId;
  final String status; // 'requested', 'accepted', 'rejected', 'completed', 'cancelled'
  final double pickupLat;
  final double pickupLng;
  final double dropoffLat;
  final double dropoffLng;
  final String pickupAddress;
  final String dropoffAddress;
  final DateTime? acceptedAt;

  RidePassenger({
    required this.passengerId,
    required this.status,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffLat,
    required this.dropoffLng,
    this.pickupAddress = '',
    this.dropoffAddress = '',
    this.acceptedAt,
  });

  factory RidePassenger.fromMap(Map<String, dynamic> map) {
    return RidePassenger(
      passengerId: map['passengerId'] ?? '',
      status: map['status'] ?? 'requested',
      pickupLat: (map['pickupLat'] ?? 0.0).toDouble(),
      pickupLng: (map['pickupLng'] ?? 0.0).toDouble(),
      dropoffLat: (map['dropoffLat'] ?? 0.0).toDouble(),
      dropoffLng: (map['dropoffLng'] ?? 0.0).toDouble(),
      pickupAddress: map['pickupAddress'] ?? '',
      dropoffAddress: map['dropoffAddress'] ?? '',
      acceptedAt: (map['acceptedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'passengerId': passengerId,
      'status': status,
      'pickupLat': pickupLat,
      'pickupLng': pickupLng,
      'dropoffLat': dropoffLat,
      'dropoffLng': dropoffLng,
      'pickupAddress': pickupAddress,
      'dropoffAddress': dropoffAddress,
      'acceptedAt': acceptedAt != null ? Timestamp.fromDate(acceptedAt!) : null,
    };
  }
}

class RideModel {
  final String id;
  final String driverId;
  final String driverName;
  final double driverRating;
  final String? driverPhoto;
  final LocationPoint origin;
  final LocationPoint destination;
  final DateTime departureTime;
  final DateTime? estimatedArrival;
  final int availableSeats;
  final int totalSeats;
  final String? routePolyline;
  final double estimatedDistance;
  final double estimatedFare;
  final String rideType; // 'recurring', 'onetime'
  final List<String> recurringDays;
  final String status; // 'active', 'started', 'completed', 'cancelled'
  final List<RidePassenger> passengers;
  final List<String> paymentMethods;
  final DateTime createdAt;
  final DateTime updatedAt;

  RideModel({
    required this.id,
    required this.driverId,
    required this.driverName,
    this.driverRating = 0.0,
    this.driverPhoto,
    required this.origin,
    required this.destination,
    required this.departureTime,
    this.estimatedArrival,
    required this.availableSeats,
    required this.totalSeats,
    this.routePolyline,
    this.estimatedDistance = 0.0,
    this.estimatedFare = 0.0,
    this.rideType = 'onetime',
    this.recurringDays = const [],
    this.status = 'active',
    this.passengers = const [],
    this.paymentMethods = const ['Cash'],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory RideModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RideModel(
      id: doc.id,
      driverId: data['driverId'] ?? '',
      driverName: data['driverName'] ?? '',
      driverRating: (data['driverRating'] ?? 0.0).toDouble(),
      driverPhoto: data['driverPhoto'],
      origin: LocationPoint.fromMap(data['origin'] ?? {}),
      destination: LocationPoint.fromMap(data['destination'] ?? {}),
      departureTime:
          (data['departureTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      estimatedArrival: (data['estimatedArrival'] as Timestamp?)?.toDate(),
      availableSeats: data['availableSeats'] ?? 0,
      totalSeats: data['totalSeats'] ?? 4,
      routePolyline: data['routePolyline'],
      estimatedDistance: (data['estimatedDistance'] ?? 0.0).toDouble(),
      estimatedFare: (data['estimatedFare'] ?? 0.0).toDouble(),
      rideType: data['rideType'] ?? 'onetime',
      recurringDays: List<String>.from(data['recurringDays'] ?? []),
      status: data['status'] ?? 'active',
      passengers: (data['passengers'] as List<dynamic>?)
              ?.map((p) => RidePassenger.fromMap(p))
              .toList() ??
          [],
      paymentMethods: List<String>.from(data['paymentMethods'] ?? ['Cash']),
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:
          (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'driverId': driverId,
      'driverName': driverName,
      'driverRating': driverRating,
      'driverPhoto': driverPhoto,
      'origin': origin.toMap(),
      'destination': destination.toMap(),
      'departureTime': Timestamp.fromDate(departureTime),
      'estimatedArrival':
          estimatedArrival != null ? Timestamp.fromDate(estimatedArrival!) : null,
      'availableSeats': availableSeats,
      'totalSeats': totalSeats,
      'routePolyline': routePolyline,
      'estimatedDistance': estimatedDistance,
      'estimatedFare': estimatedFare,
      'rideType': rideType,
      'recurringDays': recurringDays,
      'status': status,
      'passengers': passengers.map((p) => p.toMap()).toList(),
      'paymentMethods': paymentMethods,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
  }

  RideModel copyWith({
    int? availableSeats,
    String? status,
    List<RidePassenger>? passengers,
    String? routePolyline,
    double? estimatedDistance,
    double? estimatedFare,
  }) {
    return RideModel(
      id: id,
      driverId: driverId,
      driverName: driverName,
      driverRating: driverRating,
      driverPhoto: driverPhoto,
      origin: origin,
      destination: destination,
      departureTime: departureTime,
      estimatedArrival: estimatedArrival,
      availableSeats: availableSeats ?? this.availableSeats,
      totalSeats: totalSeats,
      routePolyline: routePolyline ?? this.routePolyline,
      estimatedDistance: estimatedDistance ?? this.estimatedDistance,
      estimatedFare: estimatedFare ?? this.estimatedFare,
      rideType: rideType,
      recurringDays: recurringDays,
      status: status ?? this.status,
      passengers: passengers ?? this.passengers,
      paymentMethods: paymentMethods,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
