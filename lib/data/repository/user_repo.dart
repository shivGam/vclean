import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../failure.dart';
import '../model/user_data.dart';

abstract class IUserRepository {
  Future<Either<Failure, String>> saveUserInfo(UserData user);
  Future<Either<Failure, UserData>> getUserInfo(String userId);
}

class UserRepository implements IUserRepository {
  final FirebaseFirestore _firestore;
  UserRepository(this._firestore);

  @override
  Future<Either<Failure, String>> saveUserInfo(UserData user) async {
    try {
      final docRef = _firestore.collection('user_info').doc(user.userId);
      await docRef.set(user.toJson());
      return Right(user.userId);
    } catch (e) {
      return Left(DatabaseFailure('Failed to save user info: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserData>> getUserInfo(String userId) async {
    try {
      final docSnapshot = await _firestore.collection('user_info').doc(userId).get();
      if (!docSnapshot.exists) {
        return Left(DatabaseFailure('User not found'));
      }
      return Right(UserData.fromJson(docSnapshot.data()!));
    } catch (e) {
      return Left(DatabaseFailure('Failed to get user info: ${e.toString()}'));
    }
  }
}