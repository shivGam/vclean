import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../failure.dart';

abstract class AdminRepository {
  Future<Either<Failure, bool>> isUserAdmin(String email);
}

class AdminRepositoryImpl implements AdminRepository {
  final FirebaseFirestore _firestore;

  AdminRepositoryImpl(this._firestore);

  @override
  Future<Either<Failure, bool>> isUserAdmin(String email) async {
    try {
      final DocumentSnapshot adminDoc = await _firestore
          .collection('admins')
          .doc('emails')
          .get();

      if (!adminDoc.exists) {
        return Left(DatabaseFailure('Admin document not found'));
      }

      final data = adminDoc.data() as Map<String, dynamic>?;
      if (data == null) {
        return const Right(false);
      }

      final List<dynamic> adminEmails = data['list'] ?? [];
      print(data);
      return Right(adminEmails.contains(email));
    } catch (e, st) {
      debugPrintStack(stackTrace: st);
      return Left(DatabaseFailure('Failed to check admin status: ${e.toString()}'));
    }
  }
}