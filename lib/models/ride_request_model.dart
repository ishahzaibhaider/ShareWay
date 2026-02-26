import 'package:cloud_firestore/cloud_firestore.dart';
import 'ride_model.dart';

class RideRequestModel {
  final String id;
  final String passengerId;
  final String passengerName;
  final String? passengerPhoto;
  final double passengerRating;
  final String rideId;
  final String driverId;
  final LocationPoint pickupLocation;
  final LocationPoint dropoffLocation;
  final String status; // 'pending', 'accepted', 'rejected', 'completed', 'cancelled'
  final DateTime createdAt;
  final DateTime? respondedAt;
  final DateTime? completedAt;

  RideRequestModel({
    required this.id,
    required this.passengerId,
    required this.passengerName,
    this.passengerPhoto,
    this.passengerRating = 0.0,
    required this.rideId,
    required this.driverId,
    required this.pickupLocation,
    required this.dropoffLocation,
    this.status = 'pending',
    DateTime? createdAt,
    this.respondedAt,
    this.completedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory RideRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RideRequestModel(
      id: doc.id,
      passengerId: data['passengerId'] ?? '',
      passengerName: data['passengerName'] ?? '',
      passengerPhoto: data['passengerPhoto'],
      passengerRating: (data['passengerRating'] ?? 0.0).toDouble(),
      rideId: data['rideId'] ?? '',
      driverId: data['driverId'] ?? '',
      pickupLocation: LocationPoint.fromMap(data['pickupLocation'] ?? {}),
      dropoffLocation: LocationPoint.fromMap(data['dropoffLocation'] ?? {}),
      status: data['status'] ?? 'pending',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      respondedAt: (data['respondedAt'] as Timestamp?)?.toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'passengerId': passengerId,
      'passengerName': passengerName,
      'passengerPhoto': passengerPhoto,
      'passengerRating': passengerRating,
      'rideId': rideId,
      'driverId': driverId,
      'pickupLocation': pickupLocation.toMap(),
      'dropoffLocation': dropoffLocation.toMap(),
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'respondedAt':
          respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }
}
