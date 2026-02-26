import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String rideId;
  final String driverId;
  final String passengerId;
  final double amount;
  final String paymentMethod; // 'cash', 'easypaisa', 'jazzcash', 'bank_transfer'
  final String status; // 'pending', 'completed', 'disputed'
  final String? notes;
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.rideId,
    required this.driverId,
    required this.passengerId,
    required this.amount,
    required this.paymentMethod,
    this.status = 'pending',
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      rideId: data['rideId'] ?? '',
      driverId: data['driverId'] ?? '',
      passengerId: data['passengerId'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      paymentMethod: data['paymentMethod'] ?? 'cash',
      status: data['status'] ?? 'pending',
      notes: data['notes'],
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rideId': rideId,
      'driverId': driverId,
      'passengerId': passengerId,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'status': status,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
