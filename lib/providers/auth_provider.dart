import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/firebase/firebase_auth_service.dart';

final firebaseAuthServiceProvider = Provider((ref) => FirebaseAuthService());

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthServiceProvider).authStateChanges;
});

final currentUserProvider =
    StateNotifierProvider<CurrentUserNotifier, AsyncValue<UserModel?>>((ref) {
  return CurrentUserNotifier(ref);
});

class CurrentUserNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final Ref _ref;
  bool _isManualAuth = false;

  CurrentUserNotifier(this._ref) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    _ref.listen(authStateProvider, (previous, next) {
      final user = next.valueOrNull;
      if (_isManualAuth) {
        // Skip — signIn/signUp already set the state
        _isManualAuth = false;
        return;
      }
      if (user == null) {
        state = const AsyncValue.data(null);
      } else {
        _loadUser(user.uid);
      }
    });
  }

  Future<void> _loadUser(String uid) async {
    try {
      state = const AsyncValue.loading();
      final authService = _ref.read(firebaseAuthServiceProvider);
      UserModel? user;
      for (int attempt = 0; attempt < 3; attempt++) {
        try {
          user = await authService.getUserProfile(uid);
          break;
        } catch (e) {
          if (attempt == 2) rethrow;
          await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
        }
      }
      if (mounted) state = AsyncValue.data(user);
    } catch (e, s) {
      if (mounted) state = AsyncValue.error(e, s);
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    state = const AsyncValue.loading();
    try {
      _isManualAuth = true;
      final authService = _ref.read(firebaseAuthServiceProvider);
      final user = await authService.signUpWithEmail(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );
      state = AsyncValue.data(user);
    } catch (e, s) {
      _isManualAuth = false;
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      _isManualAuth = true;
      final authService = _ref.read(firebaseAuthServiceProvider);
      final user = await authService.signInWithEmail(
        email: email,
        password: password,
      );
      state = AsyncValue.data(user);
    } catch (e, s) {
      _isManualAuth = false;
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> signOut() async {
    final authService = _ref.read(firebaseAuthServiceProvider);
    await authService.signOut();
    state = const AsyncValue.data(null);
  }

  Future<void> updateProfile(UserModel user) async {
    final authService = _ref.read(firebaseAuthServiceProvider);
    await authService.updateUserProfile(user);
    state = AsyncValue.data(user);
  }

  Future<void> reload() async {
    final firebaseUser = _ref.read(authStateProvider).valueOrNull;
    if (firebaseUser != null) {
      await _loadUser(firebaseUser.uid);
    }
  }
}
