import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'screens/onboarding.dart';
import 'screens/login.dart';
import 'screens/home.dart';
import 'screens/ride_details.dart';
import 'screens/host_ride.dart';
import 'screens/booking_confirmation.dart';
import 'screens/chat.dart';
import 'screens/wallet.dart';
import 'screens/profile.dart';
import 'services/auth_service.dart';
import 'services/ride_service.dart';
import 'services/chat_service.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (Requires google-services.json / GoogleService-Info.plist)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    debugPrint('Ensure you have added your google-services.json or GoogleService-Info.plist');
  }

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => RideService()),
        ChangeNotifierProvider(create: (_) => ChatService()),
      ],
      child: const ShareWayApp(),
    ),
  );
}

class ShareWayApp extends StatelessWidget {
  const ShareWayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShareWay',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: '/',
      routes: {
        '/':        (context) => const OnboardingScreen(),
        '/login':   (context) => const LoginScreen(),
        '/home':    (context) => const HomeScreen(),
        '/details': (context) => const RideDetailsScreen(),
        '/host':    (context) => const HostRideScreen(),
        '/booking': (context) => const BookingConfirmationScreen(),
        '/chat':    (context) => const ChatScreen(),
        '/wallet':  (context) => const WalletScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
