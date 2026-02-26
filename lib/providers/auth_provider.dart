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

  CurrentUserNotifier(this._ref) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    _ref.listen(authStateProvider, (previous, next) {
      next.when(
        data: (user) async {
          if (user == null) {
            state = const AsyncValue.data(null);
          } else {
            await loadUser(user.uid);
          }
        },
        loading: () => state = const AsyncValue.loading(),
        error: (e, s) => state = AsyncValue.error(e, s),
      );
    });
  }

  Future<void> loadUser(String uid) async {
    try {
      state = const AsyncValue.loading();
      final authService = _ref.read(firebaseAuthServiceProvider);
      final user = await authService.getUserProfile(uid);
      state = AsyncValue.data(user);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
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
      final authService = _ref.read(firebaseAuthServiceProvider);
      final user = await authService.signUpWithEmail(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );
      state = AsyncValue.data(user);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final authService = _ref.read(firebaseAuthServiceProvider);
      final user = await authService.signInWithEmail(
        email: email,
        password: password,
      );
      state = AsyncValue.data(user);
    } catch (e, s) {
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
}
