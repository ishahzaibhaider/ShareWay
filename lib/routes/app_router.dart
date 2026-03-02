import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/ride/ride_details_screen.dart';
import '../screens/ride/ride_tracking_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/vehicle_details_screen.dart';
import '../screens/rating/rating_screen.dart';

/// A Listenable that notifies GoRouter when auth state changes
class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier(Ref ref) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = _AuthNotifier(ref);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation == '/forgot-password';

      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }

      if (isLoggedIn && isAuthRoute) {
        return '/';
      }

      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Home (with bottom nav)
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),

      // Ride details
      GoRoute(
        path: '/ride/:rideId',
        builder: (context, state) => RideDetailsScreen(
          rideId: state.pathParameters['rideId']!,
        ),
      ),

      // Ride tracking
      GoRoute(
        path: '/ride-tracking/:rideId',
        builder: (context, state) => RideTrackingScreen(
          rideId: state.pathParameters['rideId']!,
        ),
      ),

      // Chat
      GoRoute(
        path: '/chat/:chatRoomId',
        builder: (context, state) => ChatScreen(
          chatRoomId: state.pathParameters['chatRoomId']!,
        ),
      ),

      // Profile
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/vehicle-details',
        builder: (context, state) => const VehicleDetailsScreen(),
      ),

      // Rating
      GoRoute(
        path: '/rate/:rideId',
        builder: (context, state) => RatingScreen(
          rideId: state.pathParameters['rideId']!,
        ),
      ),
    ],
  );
});
