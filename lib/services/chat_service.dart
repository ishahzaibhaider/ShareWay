import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class SwMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;

  SwMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
  });

  factory SwMessage.fromMap(Map<String, dynamic> map, String id) {
    return SwMessage(
      id: id,
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'senderId': senderId,
    'text': text,
    'timestamp': FieldValue.serverTimestamp(),
  };
}

class ChatService extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool useMock = true;

  Stream<List<SwMessage>> getMessages(String rideId) {
    if (useMock) {
      return Stream.value([
        SwMessage(
          id: '1',
          senderId: 'driver-001',
          text: "Hi! I'm Aymen, your driver for today.",
          timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        ),
        SwMessage(
          id: '2',
          senderId: 'me',
          text: "Great! I'll be waiting near the main gate.",
          timestamp: DateTime.now().subtract(const Duration(minutes: 9)),
        ),
      ]);
    }

    return _db
        .collection('rides')
        .doc(rideId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => SwMessage.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> sendMessage(String rideId, String senderId, String text) async {
    if (useMock) {
      debugPrint('Mock Send: $text');
      return;
    }

    await _db
        .collection('rides')
        .doc(rideId)
        .collection('messages')
        .add({
      'senderId': senderId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
