import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ── User Model ───────────────────────────────────────────────────────────────
class SwUser {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final double rating;
  final int totalRides;
  final bool isVerified;
  final String? carModel;
  final String? carPlate;
  final double balance;

  const SwUser({
    required this.uid,
    required this.name,
    required this.email,
    this.phone = '',
    this.rating = 5.0,
    this.totalRides = 0,
    this.isVerified = false,
    this.carModel,
    this.carPlate,
    this.balance = 0.0,
  });

  Map<String, dynamic> toMap() => {
    'uid': uid, 'name': name, 'email': email,
    'phone': phone, 'rating': rating,
    'totalRides': totalRides, 'isVerified': isVerified,
    'carModel': carModel, 'carPlate': carPlate,
    'balance': balance,
  };

  factory SwUser.fromMap(Map<String, dynamic> map) => SwUser(
    uid: map['uid'] ?? '',
    name: map['name'] ?? '',
    email: map['email'] ?? '',
    phone: map['phone'] ?? '',
    rating: (map['rating'] as num?)?.toDouble() ?? 5.0,
    totalRides: (map['totalRides'] as num?)?.toInt() ?? 0,
    isVerified: map['isVerified'] ?? false,
    carModel: map['carModel'],
    carPlate: map['carPlate'],
    balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
  );
}

// ── Auth Service ─────────────────────────────────────────────────────────────
class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  SwUser? _currentUser;
  SwUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  // Set this to false once your Firebase project is ready
  bool useMock = true;

  AuthService() {
    _auth.authStateChanges().listen((user) async {
      if (user != null && !useMock) {
        final doc = await _db.collection('users').doc(user.uid).get();
        if (doc.exists) {
          _currentUser = SwUser.fromMap(doc.data()!);
          notifyListeners();
        }
      }
    });
  }

  // ── Sign In with Email ────────────────────────────────────────────────────
  Future<AuthResult> signInWithEmail(String email, String password) async {
    try {
      if (useMock) {
        await Future.delayed(const Duration(milliseconds: 800));
        _currentUser = const SwUser(
          uid: 'mock-uid-001',
          name: 'Aymen Ali',
          email: 'fa23-bai-011@comsats.edu.pk',
          isVerified: true,
          totalRides: 47,
          rating: 4.9,
          balance: 3850.0,
        );
        notifyListeners();
        return AuthResult.success;
      }

      final credential = await _auth.signInWithEmailAndPassword(
        email: email, password: password,
      );
      
      final doc = await _db.collection('users').doc(credential.user!.uid).get();
      if (doc.exists) {
        _currentUser = SwUser.fromMap(doc.data()!);
        notifyListeners();
        return AuthResult.success;
      }
      return AuthResult.error;
    } catch (e) {
      debugPrint('SignIn error: $e');
      return AuthResult.error;
    }
  }

  // ── Register ──────────────────────────────────────────────────────────────
  Future<AuthResult> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      if (useMock) {
        await Future.delayed(const Duration(milliseconds: 1000));
        _currentUser = SwUser(uid: 'mock-uid-new', name: name, email: email, phone: phone);
        notifyListeners();
        return AuthResult.success;
      }

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email, password: password,
      );
      
      final user = SwUser(
        uid: credential.user!.uid, 
        name: name, 
        email: email, 
        phone: phone,
      );
      
      await _db.collection('users').doc(user.uid).set(user.toMap());
      _currentUser = user;
      notifyListeners();
      return AuthResult.success;
    } catch (e) {
      debugPrint('Register error: $e');
      return AuthResult.error;
    }
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    if (!useMock) await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }
}

enum AuthResult { success, error, emailInUse, wrongPassword }
