class AppConstants {
  static const String appName = 'ShareWay';
  static const String appVersion = '1.0.0';

  // Matching Algorithm Weights
  static const double routeSimilarityWeight = 0.4;
  static const double timeOverlapWeight = 0.3;
  static const double ratingWeight = 0.2;
  static const double distanceWeight = 0.1;

  // Matching Thresholds
  static const double maxPickupDistanceKm = 5.0;
  static const int timeWindowMinutes = 30;
  static const double minimumMatchScore = 0.3;

  // Ride Defaults
  static const double defaultFarePerKm = 15.0; // PKR per km
  static const int maxSeats = 4;

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String ridesCollection = 'rides';
  static const String rideRequestsCollection = 'rideRequests';
  static const String messagesCollection = 'messages';
  static const String ratingsCollection = 'ratings';
  static const String transactionsCollection = 'transactions';

  // Payment Methods
  static const List<String> paymentMethods = [
    'Cash',
    'Easypaisa',
    'JazzCash',
    'Bank Transfer',
  ];
}
