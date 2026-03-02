import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/messages_provider.dart';
import '../../providers/ride_requests_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/ride/ride_request_card.dart';
import '../../models/ride_model.dart';
import '../../providers/rides_provider.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatRooms = ref.watch(chatRoomsProvider);
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    final incomingRequests = ref.watch(incomingRequestsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Messages'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Chats'),
              Tab(text: 'Requests'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Chats Tab
            chatRooms.when(
              loading: () => const LoadingIndicator(),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (rooms) {
                if (rooms.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            size: 64, color: Colors.white.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        const Text('No conversations yet'),
                        const SizedBox(height: 8),
                        Text(
                          'Start by finding or offering a ride',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    final room = rooms[index];
                    final otherUserId = room.participants.firstWhere(
                      (id) => id != currentUser?.uid,
                      orElse: () => '',
                    );

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            AppTheme.primaryColor.withOpacity(0.1),
                        child: const Icon(Icons.person,
                            color: AppTheme.primaryColor),
                      ),
                      title: FutureBuilder(
                        future: ref
                            .read(firestoreServiceProvider)
                            .getUser(otherUserId),
                        builder: (context, snapshot) {
                          return Text(
                            snapshot.data?.name ?? 'Loading...',
                            style:
                                const TextStyle(fontWeight: FontWeight.w600),
                          );
                        },
                      ),
                      subtitle: Text(
                        room.lastMessage ?? 'No messages yet',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                      trailing: room.lastMessageTime != null
                          ? Text(
                              timeago.format(room.lastMessageTime!),
                              style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12),
                            )
                          : null,
                      onTap: () => context.push('/chat/${room.id}'),
                    );
                  },
                );
              },
            ),

            // Requests Tab
            incomingRequests.when(
              loading: () => const LoadingIndicator(),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (requests) {
                if (requests.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox_outlined,
                            size: 64, color: Colors.white.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        const Text('No pending requests'),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final request = requests[index];
                    return RideRequestCard(
                      request: request,
                      isIncoming: true,
                      onAccept: () async {
                        final firestoreService =
                            ref.read(firestoreServiceProvider);
                        final passenger = RidePassenger(
                          passengerId: request.passengerId,
                          status: 'accepted',
                          pickupLat: request.pickupLocation.lat,
                          pickupLng: request.pickupLocation.lng,
                          dropoffLat: request.dropoffLocation.lat,
                          dropoffLng: request.dropoffLocation.lng,
                          pickupAddress: request.pickupLocation.address,
                          dropoffAddress: request.dropoffLocation.address,
                          acceptedAt: DateTime.now(),
                        );
                        await firestoreService.acceptRideRequest(
                          requestId: request.id,
                          rideId: request.rideId,
                          passenger: passenger,
                        );
                      },
                      onReject: () async {
                        await ref
                            .read(firestoreServiceProvider)
                            .rejectRideRequest(request.id);
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
