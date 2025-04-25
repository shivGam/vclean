import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../failure.dart';
import '../model/review_data.dart';

abstract class IReviewRepository {
  Future<Either<Failure, List<Review>>> getReviews();
  Future<Either<Failure, String>> addReview(Review review);
  Future<Either<Failure, void>> deleteReview(String reviewId);
}

class ReviewRepository implements IReviewRepository {
  final FirebaseFirestore _firestore;
  final String _collectionName = 'reviews';

  ReviewRepository(this._firestore);

  @override
  Future<Either<Failure, List<Review>>> getReviews() async {
    try {
      final querySnapshot = await _firestore.collection(_collectionName).orderBy('timestamp', descending: true).get();

      if (querySnapshot.docs.isEmpty) {
        return Right([]); // Return empty list instead of failure if no reviews
      }

      final reviews = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Add document ID to the data
        return Review.fromJson(data);
      }).toList();

      return Right(reviews);
    } catch (e) {
      return Left(DatabaseFailure('Failed to fetch reviews: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> addReview(Review review) async {
    try {
      // If the review is from a specific user, use their ID as the document ID
      final docRef = await _firestore.collection(_collectionName).doc(review.userId).set(review.toJson());
      return Right(review.userId);
    } catch (e) {
      return Left(DatabaseFailure('Failed to add review: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteReview(String reviewId) async {
    try {
      await _firestore.collection(_collectionName).doc(reviewId).delete();
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete review: ${e.toString()}'));
    }
  }
}