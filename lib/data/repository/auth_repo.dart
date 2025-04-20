import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../failure.dart';

abstract class AuthRepository {
  Future<Either<Failure, String>> signInWithGoogle();
  Future<Either<Failure, void>> signOut();
  String? get currentUserId;
  String? get currentUserEmail;
  bool get isLoggedIn;
}

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  AuthRepositoryImpl(this._auth, this._googleSignIn);

  @override
  Future<Either<Failure, String>> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();
      // Start the Google Sign-In process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return Left(AuthFailure('Google sign-in cancelled'));
      }

      // Obtain the auth details from the Google sign-in
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final result = await _auth.signInWithCredential(credential);
      if (result.user == null) {
        return Left(AuthFailure('Authentication failed'));
      }
      final user = result.user!;

      return Right(user.uid);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Authentication failed'));
    } catch (e, st) {
      debugPrintStack(stackTrace: st);
      return Left(AuthFailure('Unexpected error occurred during Google sign-in'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      // Sign out from Google
      await _googleSignIn.signOut();
      // Sign out from Firebase
      await _auth.signOut();
      return const Right(null);
    } catch (e, st) {
      debugPrintStack(stackTrace: st);
      return Left(AuthFailure('Logout failed'));
    }
  }

  @override
  String? get currentUserId => _auth.currentUser?.uid;

  @override
  String? get currentUserEmail => _auth.currentUser?.email;

  @override
  bool get isLoggedIn => _auth.currentUser != null;
}

class AuthFailure extends Failure {
  AuthFailure(String message) : super(message);
}