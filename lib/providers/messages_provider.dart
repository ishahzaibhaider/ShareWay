import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message_model.dart';
import 'rides_provider.dart';
import 'auth_provider.dart';

// Chat rooms for current user
final chatRoomsProvider = StreamProvider<List<ChatRoom>>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return Stream.value([]);
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getChatRooms(user.uid);
});

// Messages for a specific chat room
final messagesProvider =
    StreamProvider.family<List<MessageModel>, String>((ref, chatRoomId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getMessages(chatRoomId);
});
