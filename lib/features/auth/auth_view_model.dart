import 'package:blog_app/core/errors/app_error_mapper.dart';
import 'package:blog_app/services/profile_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel({FirebaseAuth? auth, ProfileStorage? profileStorage})
    : _auth = auth ?? FirebaseAuth.instance,
      _profileStorage = profileStorage ?? ProfileStorage() {
    _auth.authStateChanges().listen((_) => notifyListeners());
  }

  final FirebaseAuth _auth;
  final ProfileStorage _profileStorage;

  bool isLoading = false;
  String? lastError;

  User? get user => _auth.currentUser;

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    lastError = null;
    try {
      isLoading = true;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      final msg = AppErrorMapper.fromFirebaseAuth(e);
      lastError = msg;
      return msg;
    } catch (e, st) {
      final msg = AppErrorMapper.fromUnknown(
        e,
        st,
        fallback: 'Sign in failed.',
      );
      lastError = msg;
      return msg;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> signInWithGoogle() async {
    lastError = null;
    try {
      isLoading = true;
      notifyListeners();

      final account = await GoogleSignIn.instance.authenticate();
      final googleAuth = account.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      return null;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return 'Sign in was cancelled';
      }
      final msg = e.description ?? 'Google sign-in failed';
      lastError = msg;
      return msg;
    } on FirebaseAuthException catch (e) {
      final msg = AppErrorMapper.fromFirebaseAuth(e);
      lastError = msg;
      return msg;
    } catch (e, st) {
      final msg = AppErrorMapper.fromUnknown(
        e,
        st,
        fallback: 'Google sign-in failed.',
      );
      lastError = msg;
      return msg;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> signup({
    required String name,
    required String email,
    required String mobile,
    required String password,
  }) async {
    lastError = null;
    try {
      isLoading = true;
      notifyListeners();

      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await cred.user?.updateDisplayName(name.trim());
      await cred.user?.reload();
      try {
        await _profileStorage.setMobile(mobile.trim());
      } catch (e, st) {
        final msg = AppErrorMapper.fromUnknown(
          e,
          st,
          fallback: 'Account created, but saving your profile failed.',
        );
        lastError = msg;
        return msg;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      final msg = AppErrorMapper.fromFirebaseAuth(e);
      lastError = msg;
      return msg;
    } catch (e, st) {
      final msg = AppErrorMapper.fromUnknown(e, st, fallback: 'Signup failed.');
      lastError = msg;
      return msg;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> logout() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (e, st) {
      assert(() {
        debugPrint('GoogleSignIn.signOut: $e\n$st');
        return true;
      }());
    }
    try {
      await _profileStorage.clear();
      await _auth.signOut();
      return null;
    } on FirebaseAuthException catch (e) {
      return AppErrorMapper.fromFirebaseAuth(e);
    } catch (e, st) {
      return AppErrorMapper.fromUnknown(e, st, fallback: 'Could not sign out.');
    }
  }
}
