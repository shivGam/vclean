import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/model/carousel_data.dart';
import '../data/repository/carousel_repo.dart';

// Events
abstract class CarouselEvent {}

class LoadCarousels extends CarouselEvent {}

class SaveCarousel extends CarouselEvent {
  final Carousel carousel;
  SaveCarousel(this.carousel);
}

// States
abstract class CarouselState {}

class CarouselInitial extends CarouselState {}

class CarouselLoading extends CarouselState {}

class CarouselsLoaded extends CarouselState {
  final List<Carousel> carousels;
  CarouselsLoaded(this.carousels);
}

class CarouselOperationSuccess extends CarouselState {
  final String message;
  CarouselOperationSuccess(this.message);
}

class CarouselError extends CarouselState {
  final String message;
  CarouselError(this.message);
}

// Bloc
class CarouselBloc extends Bloc<CarouselEvent, CarouselState> {
  final ICarouselRepository _repository;

  CarouselBloc(this._repository) : super(CarouselInitial()) {
    on<LoadCarousels>(_onLoadCarousels);
    on<SaveCarousel>(_onSaveCarousel);
  }

  Future<void> _onLoadCarousels(
      LoadCarousels event,
      Emitter<CarouselState> emit,
      ) async {
    emit(CarouselLoading());
    try {
      final result = await _repository.getCarousels();

      result.fold(
            (failure) => emit(CarouselError(failure.message)),
            (carousels) => emit(CarouselsLoaded(carousels)),
      );
    } catch (e) {
      emit(CarouselError(e.toString()));
    }
  }

  Future<void> _onSaveCarousel(
      SaveCarousel event,
      Emitter<CarouselState> emit,
      ) async {
    emit(CarouselLoading());
    try {
      final result = await _repository.saveCarousel(event.carousel);

      result.fold(
            (failure) => emit(CarouselError(failure.message)),
            (carouselId) {
          emit(CarouselOperationSuccess('Carousel saved successfully'));
          add(LoadCarousels());
        },
      );
    } catch (e) {
      emit(CarouselError(e.toString()));
    }
  }
}