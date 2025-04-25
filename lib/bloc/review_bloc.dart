import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/model/review_data.dart';
import '../data/repository/review_repo.dart';

// Events
abstract class ReviewEvent {}

class LoadReviews extends ReviewEvent {}

class AddReview extends ReviewEvent {
  final Review review;
  AddReview(this.review);
}

class DeleteReview extends ReviewEvent {
  final String reviewId;
  DeleteReview(this.reviewId);
}

// States
abstract class ReviewState {}

class ReviewInitial extends ReviewState {}

class ReviewLoading extends ReviewState {}

class ReviewsLoaded extends ReviewState {
  final List<Review> reviews;
  ReviewsLoaded(this.reviews);
}

class ReviewOperationSuccess extends ReviewState {
  final String message;
  ReviewOperationSuccess(this.message);
}

class ReviewError extends ReviewState {
  final String message;
  ReviewError(this.message);
}

// Bloc
class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final IReviewRepository _repository;

  ReviewBloc(this._repository) : super(ReviewInitial()) {
    on<LoadReviews>(_onLoadReviews);
    on<AddReview>(_onAddReview);
    on<DeleteReview>(_onDeleteReview);
  }

  Future<void> _onLoadReviews(
      LoadReviews event,
      Emitter<ReviewState> emit,
      ) async {
    emit(ReviewLoading());
    try {
      final result = await _repository.getReviews();

      result.fold(
            (failure) => emit(ReviewError(failure.message)),
            (reviews) => emit(ReviewsLoaded(reviews)),
      );
    } catch (e) {
      emit(ReviewError(e.toString()));
    }
  }

  Future<void> _onAddReview(
      AddReview event,
      Emitter<ReviewState> emit,
      ) async {
    emit(ReviewLoading());
    try {
      final result = await _repository.addReview(event.review);

      result.fold(
            (failure) => emit(ReviewError(failure.message)),
            (reviewId) {
          emit(ReviewOperationSuccess('Review added successfully'));
          add(LoadReviews()); // Reload reviews after adding
        },
      );
    } catch (e) {
      emit(ReviewError(e.toString()));
    }
  }

  Future<void> _onDeleteReview(
      DeleteReview event,
      Emitter<ReviewState> emit,
      ) async {
    emit(ReviewLoading());
    try {
      final result = await _repository.deleteReview(event.reviewId);

      result.fold(
            (failure) => emit(ReviewError(failure.message)),
            (_) {
          emit(ReviewOperationSuccess('Review deleted successfully'));
          add(LoadReviews()); // Reload reviews after deleting
        },
      );
    } catch (e) {
      emit(ReviewError(e.toString()));
    }
  }
}