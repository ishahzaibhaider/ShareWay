class Ride {
  final String id;
  final String destination;
  final String pickup;
  final String driverName;
  final String driverAvatar; // emoji placeholder
  final double rating;
  final int totalRatings;
  final String departureTime;
  final String arrivalTime;
  final String duration;
  final double distanceKm;
  final double price;
  final String carModel;
  final String carPlate;
  final int availableSeats;
  final int totalSeats;
  final List<String> tags;
  final bool isRecurring;
  final String category; // 'economy' | 'premium' | 'women'
  final double pickupLat;
  final double pickupLng;
  final double destLat;
  final double destLng;

  const Ride({
    required this.id,
    required this.destination,
    required this.pickup,
    required this.driverName,
    this.driverAvatar = '👤',
    required this.rating,
    this.totalRatings = 0,
    required this.departureTime,
    this.arrivalTime = '',
    this.duration = '',
    this.distanceKm = 0,
    required this.price,
    required this.carModel,
    this.carPlate = '',
    this.availableSeats = 3,
    this.totalSeats = 4,
    this.tags = const [],
    this.isRecurring = false,
    this.category = 'economy',
    this.pickupLat = 0,
    this.pickupLng = 0,
    this.destLat = 0,
    this.destLng = 0,
  });

  double get savingsEstimate => price * 2.5;

  factory Ride.fromMap(Map<String, dynamic> map) {
    return Ride(
      id: map['id'] ?? '',
      destination: map['destination'] ?? '',
      pickup: map['pickup'] ?? '',
      driverName: map['driverName'] ?? 'Unknown',
      driverAvatar: map['driverAvatar'] ?? '👤',
      rating: (map['rating'] as num?)?.toDouble() ?? 5.0,
      totalRatings: (map['totalRatings'] as num?)?.toInt() ?? 0,
      departureTime: map['departureTime'] is String ? map['departureTime'] : 'TBA',
      arrivalTime: map['arrivalTime'] ?? '',
      duration: map['duration'] ?? '',
      distanceKm: (map['distanceKm'] as num?)?.toDouble() ?? 0,
      price: (map['price'] as num?)?.toDouble() ?? 0,
      carModel: map['carModel'] ?? '',
      carPlate: map['carPlate'] ?? '',
      availableSeats: (map['availableSeats'] as num?)?.toInt() ?? 0,
      totalSeats: (map['totalSeats'] as num?)?.toInt() ?? 4,
      tags: List<String>.from(map['tags'] ?? []),
      isRecurring: map['isRecurring'] ?? false,
      category: map['category'] ?? 'economy',
      pickupLat: (map['pickupLat'] as num?)?.toDouble() ?? 0,
      pickupLng: (map['pickupLng'] as num?)?.toDouble() ?? 0,
      destLat: (map['destLat'] as num?)?.toDouble() ?? 0,
      destLng: (map['destLng'] as num?)?.toDouble() ?? 0,
    );
  }

  static List<Ride> getMockRides() {
    return const [
      Ride(
        id: '1',
        destination: 'COMSATS University',
        pickup: 'I-8 Markaz, Islamabad',
        driverName: 'Aymen Ali',
        driverAvatar: '👨',
        rating: 4.9,
        totalRatings: 134,
        departureTime: '7:30 AM',
        arrivalTime: '7:55 AM',
        duration: '25 min',
        distanceKm: 8.3,
        price: 250,
        carModel: 'Tesla Model 3',
        carPlate: 'ABC-1234',
        availableSeats: 2,
        totalSeats: 4,
        tags: ['Daily', 'AC', '3 Seats'],
        isRecurring: true,
        category: 'premium',
        pickupLat: 33.6685, pickupLng: 73.0754,
        destLat: 33.6518, destLng: 73.1561,
      ),
      Ride(
        id: '2',
        destination: 'Islamabad Airport',
        pickup: 'F-7 Markaz',
        driverName: 'Sara Tahseen',
        driverAvatar: '👩',
        rating: 4.8,
        totalRatings: 87,
        departureTime: '9:00 AM',
        arrivalTime: '9:35 AM',
        duration: '35 min',
        distanceKm: 14.2,
        price: 850,
        carModel: 'Honda Civic',
        carPlate: 'XYZ-5678',
        availableSeats: 3,
        totalSeats: 4,
        tags: ['One-Time', 'Music Off'],
        isRecurring: false,
        category: 'economy',
        pickupLat: 33.7215, pickupLng: 73.0567,
        destLat: 33.5492, destLng: 72.8272,
      ),
      Ride(
        id: '3',
        destination: 'Blue Area Office',
        pickup: 'G-9 Sector',
        driverName: 'Zain Malik',
        driverAvatar: '🧑',
        rating: 4.7,
        totalRatings: 52,
        departureTime: '8:00 AM',
        arrivalTime: '8:20 AM',
        duration: '20 min',
        distanceKm: 5.6,
        price: 180,
        carModel: 'Toyota Prius',
        carPlate: 'LMN-9012',
        availableSeats: 3,
        totalSeats: 4,
        tags: ['Eco', 'Daily'],
        isRecurring: true,
        category: 'economy',
        pickupLat: 33.6825, pickupLng: 73.0287,
        destLat: 33.7115, destLng: 73.0642,
      ),
    ];
  }
}
