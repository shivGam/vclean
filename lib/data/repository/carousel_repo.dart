import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../failure.dart';
import '../model/carousel_data.dart';

abstract class ICarouselRepository {
  Future<Either<Failure, List<Carousel>>> getCarousels();
  Future<Either<Failure, String>> saveCarousel(Carousel carousel);
}

class CarouselRepository implements ICarouselRepository {
  final FirebaseFirestore _firestore;
  final String _collectionName = 'carousel_info';

  CarouselRepository(this._firestore);

  @override
  Future<Either<Failure, List<Carousel>>> getCarousels() async {
    try {
      final querySnapshot = await _firestore.collection(_collectionName).get();

      if (querySnapshot.docs.isEmpty) {
        return Left(DatabaseFailure('No carousels found'));
      }

      final carousels = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Add document ID to the data
        return Carousel.fromJson(data);
      }).toList();

      return Right(carousels);
    } catch (e) {
      return Left(DatabaseFailure('Failed to fetch carousels: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> saveCarousel(Carousel carousel) async {
    try {
      final docRef = await _firestore.collection(_collectionName).add(carousel.toJson());
      return Right(docRef.id);
    } catch (e) {
      return Left(DatabaseFailure('Failed to save carousel: ${e.toString()}'));
    }
  }
}