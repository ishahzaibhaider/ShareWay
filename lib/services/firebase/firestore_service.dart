import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/ride_model.dart';
import '../../models/ride_request_model.dart';
import '../../models/message_model.dart';
import '../../models/rating_model.dart';
import '../../models/transaction_model.dart';
import '../../models/user_model.dart';
import '../../config/app_constants.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ============ RIDES ============

  // Create a new ride offer
  Future<String> createRide(RideModel ride) async {
    final doc = await _db
        .collection(AppConstants.ridesCollection)
        .add(ride.toMap());
    return doc.id;
  }

  // Get active rides stream (simplified query to avoid composite index requirement)
  Stream<List<RideModel>> getActiveRides() {
    return _db
        .collection(AppConstants.ridesCollection)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) {
      final now = DateTime.now();
      final rides = snapshot.docs
          .map((doc) => RideModel.fromFirestore(doc))
          .where((ride) => ride.departureTime.isAfter(now))
          .toList();
      rides.sort((a, b) => a.departureTime.compareTo(b.departureTime));
      return rides;
    });
  }

  // Get rides by driver
  Stream<List<RideModel>> getDriverRides(String driverId) {
    return _db
        .collection(AppConstants.ridesCollection)
        .where('driverId', isEqualTo: driverId)
        .snapshots()
        .map((snapshot) {
      final rides = snapshot.docs
          .map((doc) => RideModel.fromFirestore(doc))
          .toList();
      rides.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return rides;
    });
  }

  // Get rides where user is a passenger
  Stream<List<RideModel>> getPassengerRides(String passengerId) {
    return _db
        .collection(AppConstants.ridesCollection)
        .snapshots()
        .map((snapshot) {
      final rides = snapshot.docs
          .map((doc) => RideModel.fromFirestore(doc))
          .where((ride) => ride.passengers.any((p) => p.passengerId == passengerId))
          .toList();
      rides.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return rides;
    });
  }

  // Get single ride
  Future<RideModel?> getRide(String rideId) async {
    final doc = await _db
        .collection(AppConstants.ridesCollection)
        .doc(rideId)
        .get();
    if (!doc.exists) return null;
    return RideModel.fromFirestore(doc);
  }

  // Get single ride stream
  Stream<RideModel?> getRideStream(String rideId) {
    return _db
        .collection(AppConstants.ridesCollection)
        .doc(rideId)
        .snapshots()
        .map((doc) => doc.exists ? RideModel.fromFirestore(doc) : null);
  }

  // Update ride
  Future<void> updateRide(String rideId, Map<String, dynamic> data) async {
    data['updatedAt'] = Timestamp.now();
    await _db
        .collection(AppConstants.ridesCollection)
        .doc(rideId)
        .update(data);
  }

  // ============ RIDE REQUESTS ============

  // Create ride request (with duplicate check)
  Future<String> createRideRequest(RideRequestModel request) async {
    // Check for existing pending request from same passenger for same ride
    final existing = await _db
        .collection(AppConstants.rideRequestsCollection)
        .where('passengerId', isEqualTo: request.passengerId)
        .where('rideId', isEqualTo: request.rideId)
        .where('status', isEqualTo: 'pending')
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception('You already have a pending request for this ride');
    }

    final doc = await _db
        .collection(AppConstants.rideRequestsCollection)
        .add(request.toMap());
    return doc.id;
  }

  // Get incoming requests for a driver (simplified: single where + client filter)
  Stream<List<RideRequestModel>> getIncomingRequests(String driverId) {
    return _db
        .collection(AppConstants.rideRequestsCollection)
        .where('driverId', isEqualTo: driverId)
        .snapshots()
        .map((snapshot) {
      final requests = snapshot.docs
          .map((doc) => RideRequestModel.fromFirestore(doc))
          .where((r) => r.status == 'pending')
          .toList();
      requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return requests;
    });
  }

  // Get sent requests by passenger
  Stream<List<RideRequestModel>> getSentRequests(String passengerId) {
    return _db
        .collection(AppConstants.rideRequestsCollection)
        .where('passengerId', isEqualTo: passengerId)
        .snapshots()
        .map((snapshot) {
      final requests = snapshot.docs
          .map((doc) => RideRequestModel.fromFirestore(doc))
          .toList();
      requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return requests;
    });
  }

  // Update ride request status
  Future<void> updateRideRequest(
      String requestId, Map<String, dynamic> data) async {
    await _db
        .collection(AppConstants.rideRequestsCollection)
        .doc(requestId)
        .update(data);
  }

  // Accept ride request (transaction)
  Future<void> acceptRideRequest({
    required String requestId,
    required String rideId,
    required RidePassenger passenger,
  }) async {
    await _db.runTransaction((transaction) async {
      final rideRef =
          _db.collection(AppConstants.ridesCollection).doc(rideId);
      final requestRef =
          _db.collection(AppConstants.rideRequestsCollection).doc(requestId);

      final rideDoc = await transaction.get(rideRef);
      final ride = RideModel.fromFirestore(rideDoc);

      if (ride.status != 'active') {
        throw Exception('This ride is no longer active');
      }

      if (ride.availableSeats <= 0) {
        throw Exception('No seats available');
      }

      // Update ride: add passenger, decrease seats
      final updatedPassengers = [
        ...ride.passengers.map((p) => p.toMap()),
        passenger.toMap(),
      ];

      transaction.update(rideRef, {
        'passengers': updatedPassengers,
        'availableSeats': ride.availableSeats - 1,
        'updatedAt': Timestamp.now(),
      });

      // Update request status
      transaction.update(requestRef, {
        'status': 'accepted',
        'respondedAt': Timestamp.now(),
      });
    });
  }

  // Reject ride request
  Future<void> rejectRideRequest(String requestId) async {
    await _db
        .collection(AppConstants.rideRequestsCollection)
        .doc(requestId)
        .update({
      'status': 'rejected',
      'respondedAt': Timestamp.now(),
    });
  }

  // ============ MESSAGES ============

  // Create or get chat room
  Future<String> getOrCreateChatRoom({
    required String userId1,
    required String userId2,
    String? rideId,
  }) async {
    // Check if chat room exists
    final existing = await _db
        .collection(AppConstants.messagesCollection)
        .where('participants', arrayContains: userId1)
        .get();

    for (final doc in existing.docs) {
      final participants = List<String>.from(doc['participants'] ?? []);
      if (participants.contains(userId2)) {
        return doc.id;
      }
    }

    // Create new chat room with a non-null lastMessageTime so it shows in queries
    final chatRoom = ChatRoom(
      id: '',
      participants: [userId1, userId2],
      rideId: rideId,
      lastMessageTime: DateTime.now(),
      lastMessage: '',
    );

    final doc = await _db
        .collection(AppConstants.messagesCollection)
        .add(chatRoom.toMap());
    return doc.id;
  }

  // Get chat rooms for user (simplified: single where + client sort)
  Stream<List<ChatRoom>> getChatRooms(String userId) {
    return _db
        .collection(AppConstants.messagesCollection)
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      final rooms = snapshot.docs
          .map((doc) => ChatRoom.fromFirestore(doc))
          .toList();
      rooms.sort((a, b) {
        final aTime = a.lastMessageTime ?? DateTime(2000);
        final bTime = b.lastMessageTime ?? DateTime(2000);
        return bTime.compareTo(aTime);
      });
      return rooms;
    });
  }

  // Send message
  Future<void> sendMessage({
    required String chatRoomId,
    required MessageModel message,
  }) async {
    final batch = _db.batch();

    // Add message to subcollection
    final messageRef = _db
        .collection(AppConstants.messagesCollection)
        .doc(chatRoomId)
        .collection('messages')
        .doc();
    batch.set(messageRef, message.toMap());

    // Update chat room with last message
    final chatRoomRef =
        _db.collection(AppConstants.messagesCollection).doc(chatRoomId);
    batch.update(chatRoomRef, {
      'lastMessage': message.text,
      'lastMessageTime': Timestamp.fromDate(message.timestamp),
    });

    await batch.commit();
  }

  // Get messages stream
  Stream<List<MessageModel>> getMessages(String chatRoomId) {
    return _db
        .collection(AppConstants.messagesCollection)
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromFirestore(doc))
            .toList());
  }

  // ============ RATINGS ============

  // Create rating
  Future<void> createRating(RatingModel rating) async {
    await _db.runTransaction((transaction) async {
      // Add rating
      final ratingRef =
          _db.collection(AppConstants.ratingsCollection).doc();
      transaction.set(ratingRef, rating.toMap());

      // Update user's average rating
      final userRef =
          _db.collection(AppConstants.usersCollection).doc(rating.toUserId);
      final userDoc = await transaction.get(userRef);
      final userData = userDoc.data() as Map<String, dynamic>;

      final currentRating = (userData['averageRating'] ?? 0.0).toDouble();
      final totalRatings = (userData['totalRatings'] ?? userData['totalRides'] ?? 0) as int;
      final newAverage =
          ((currentRating * totalRatings) + rating.rating) / (totalRatings + 1);

      transaction.update(userRef, {
        'averageRating': newAverage,
        'totalRatings': totalRatings + 1,
      });
    });
  }

  // Get ratings for user
  Future<List<RatingModel>> getUserRatings(String userId) async {
    final snapshot = await _db
        .collection(AppConstants.ratingsCollection)
        .where('toUserId', isEqualTo: userId)
        .get();
    final ratings = snapshot.docs
        .map((doc) => RatingModel.fromFirestore(doc))
        .toList();
    ratings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return ratings;
  }

  // ============ TRANSACTIONS ============

  Future<void> createTransaction(TransactionModel txn) async {
    await _db
        .collection(AppConstants.transactionsCollection)
        .add(txn.toMap());
  }

  // ============ USER ============

  Future<UserModel?> getUser(String uid) async {
    final doc = await _db
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Stream<UserModel?> getUserStream(String uid) {
    return _db
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }
}
