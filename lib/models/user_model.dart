import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleDetails {
  final String make;
  final String model;
  final String color;
  final String plate;
  final int seats;
  final String verificationStatus;

  VehicleDetails({
    required this.make,
    required this.model,
    required this.color,
    required this.plate,
    required this.seats,
    this.verificationStatus = 'unverified',
  });

  factory VehicleDetails.fromMap(Map<String, dynamic> map) {
    return VehicleDetails(
      make: map['make'] ?? '',
      model: map['model'] ?? '',
      color: map['color'] ?? '',
      plate: map['plate'] ?? '',
      seats: map['seats'] ?? 4,
      verificationStatus: map['verificationStatus'] ?? 'unverified',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'make': make,
      'model': model,
      'color': color,
      'plate': plate,
      'seats': seats,
      'verificationStatus': verificationStatus,
    };
  }
}

class PaymentPreferences {
  final String? easypaisa;
  final String? jazzcash;
  final bool acceptsCash;
  final String? bankAccount;

  PaymentPreferences({
    this.easypaisa,
    this.jazzcash,
    this.acceptsCash = true,
    this.bankAccount,
  });

  factory PaymentPreferences.fromMap(Map<String, dynamic> map) {
    return PaymentPreferences(
      easypaisa: map['easypaisa'],
      jazzcash: map['jazzcash'],
      acceptsCash: map['acceptsCash'] ?? true,
      bankAccount: map['bankAccount'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'easypaisa': easypaisa,
      'jazzcash': jazzcash,
      'acceptsCash': acceptsCash,
      'bankAccount': bankAccount,
    };
  }

  List<String> get availableMethods {
    final methods = <String>[];
    if (acceptsCash) methods.add('Cash');
    if (easypaisa != null && easypaisa!.isNotEmpty) methods.add('Easypaisa');
    if (jazzcash != null && jazzcash!.isNotEmpty) methods.add('JazzCash');
    if (bankAccount != null && bankAccount!.isNotEmpty) {
      methods.add('Bank Transfer');
    }
    return methods;
  }
}

class UserModel {
  final String uid;
  final String email;
  final String phone;
  final String name;
  final String? profilePhoto;
  final String userType; // 'driver', 'passenger', 'both'
  final VehicleDetails? vehicleDetails;
  final double averageRating;
  final int totalRides;
  final PaymentPreferences paymentPreferences;
  final DateTime createdAt;
  final DateTime lastActive;
  final bool isVerified;

  UserModel({
    required this.uid,
    required this.email,
    required this.phone,
    required this.name,
    this.profilePhoto,
    this.userType = 'passenger',
    this.vehicleDetails,
    this.averageRating = 0.0,
    this.totalRides = 0,
    PaymentPreferences? paymentPreferences,
    DateTime? createdAt,
    DateTime? lastActive,
    this.isVerified = false,
  })  : paymentPreferences = paymentPreferences ?? PaymentPreferences(),
        createdAt = createdAt ?? DateTime.now(),
        lastActive = lastActive ?? DateTime.now();

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      name: data['name'] ?? '',
      profilePhoto: data['profilePhoto'],
      userType: data['userType'] ?? 'passenger',
      vehicleDetails: data['vehicleDetails'] != null
          ? VehicleDetails.fromMap(data['vehicleDetails'])
          : null,
      averageRating: (data['averageRating'] ?? 0.0).toDouble(),
      totalRides: data['totalRides'] ?? 0,
      paymentPreferences: data['paymentPreferences'] != null
          ? PaymentPreferences.fromMap(data['paymentPreferences'])
          : PaymentPreferences(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActive:
          (data['lastActive'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isVerified: data['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'phone': phone,
      'name': name,
      'profilePhoto': profilePhoto,
      'userType': userType,
      'vehicleDetails': vehicleDetails?.toMap(),
      'averageRating': averageRating,
      'totalRides': totalRides,
      'paymentPreferences': paymentPreferences.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActive': Timestamp.fromDate(lastActive),
      'isVerified': isVerified,
    };
  }

  UserModel copyWith({
    String? email,
    String? phone,
    String? name,
    String? profilePhoto,
    String? userType,
    VehicleDetails? vehicleDetails,
    double? averageRating,
    int? totalRides,
    PaymentPreferences? paymentPreferences,
    bool? isVerified,
  }) {
    return UserModel(
      uid: uid,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      userType: userType ?? this.userType,
      vehicleDetails: vehicleDetails ?? this.vehicleDetails,
      averageRating: averageRating ?? this.averageRating,
      totalRides: totalRides ?? this.totalRides,
      paymentPreferences: paymentPreferences ?? this.paymentPreferences,
      createdAt: createdAt,
      lastActive: DateTime.now(),
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
