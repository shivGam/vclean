import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../failure.dart';
import '../model/service_data.dart';

abstract class ILaundryServiceRepository {
  Future<Either<Failure, List<LaundryService>>> getServices();
  Future<Either<Failure, String>> saveService(LaundryService service);
}

class LaundryServiceRepository implements ILaundryServiceRepository {
  final FirebaseFirestore _firestore;
  final String _collectionName = 'service_info';

  LaundryServiceRepository(this._firestore);

  @override
  Future<Either<Failure, List<LaundryService>>> getServices() async {
    try {
      final querySnapshot = await _firestore.collection(_collectionName).get();

      if (querySnapshot.docs.isEmpty) {
        return Left(DatabaseFailure('No services found'));
      }

      final services = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Add document ID to the data
        return LaundryService.fromJson(data);
      }).toList();

      return Right(services);
    } catch (e) {
      return Left(DatabaseFailure('Failed to fetch services: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> saveService(LaundryService service) async {
    try {
      final docRef = await _firestore.collection(_collectionName).add(service.toJson());
      return Right(docRef.id);
    } catch (e) {
      return Left(DatabaseFailure('Failed to save service: ${e.toString()}'));
    }
  }
}