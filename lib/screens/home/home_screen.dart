import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ride_requests_provider.dart';
import '../home/find_ride_screen.dart';
import '../home/offer_ride_screen.dart';
import '../chat/chat_list_screen.dart';
import '../ride/ride_history_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final _screens = const [
    FindRideScreen(),
    OfferRideScreen(),
    ChatListScreen(),
    RideHistoryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final incomingRequests = ref.watch(incomingRequestsProvider);
    final requestCount = incomingRequests.valueOrNull?.length ?? 0;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Find Ride',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Offer Ride',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: requestCount > 0,
              label: Text('$requestCount'),
              child: const Icon(Icons.chat_bubble_outline),
            ),
            label: 'Messages',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
