import 'package:cloud_firestore/cloud_firestore.dart';

class RatingModel {
  final String id;
  final String fromUserId;
  final String fromUserName;
  final String toUserId;
  final String rideId;
  final double rating;
  final String? comment;
  final String rideType; // 'driver' or 'passenger' (who was rated)
  final DateTime createdAt;

  RatingModel({
    required this.id,
    required this.fromUserId,
    required this.fromUserName,
    required this.toUserId,
    required this.rideId,
    required this.rating,
    this.comment,
    required this.rideType,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory RatingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RatingModel(
      id: doc.id,
      fromUserId: data['fromUserId'] ?? '',
      fromUserName: data['fromUserName'] ?? '',
      toUserId: data['toUserId'] ?? '',
      rideId: data['rideId'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      comment: data['comment'],
      rideType: data['rideType'] ?? 'driver',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fromUserId': fromUserId,
      'fromUserName': fromUserName,
      'toUserId': toUserId,
      'rideId': rideId,
      'rating': rating,
      'comment': comment,
      'rideType': rideType,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
