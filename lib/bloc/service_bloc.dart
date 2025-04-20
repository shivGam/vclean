import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/model/service_data.dart';
import '../data/repository/service_repo.dart';

// Events
abstract class LaundryServiceEvent {}

class LoadLaundryServices extends LaundryServiceEvent {}

class SaveLaundryService extends LaundryServiceEvent {
  final LaundryService service;
  SaveLaundryService(this.service);
}

abstract class LaundryServiceState {}

class LaundryServiceInitial extends LaundryServiceState {}

class LaundryServiceLoading extends LaundryServiceState {}

class LaundryServicesLoaded extends LaundryServiceState {
  final List<LaundryService> services;
  LaundryServicesLoaded(this.services);
}

class LaundryServiceOperationSuccess extends LaundryServiceState {
  final String message;
  LaundryServiceOperationSuccess(this.message);
}

class LaundryServiceError extends LaundryServiceState {
  final String message;
  LaundryServiceError(this.message);
}

// Bloc
class LaundryServiceBloc extends Bloc<LaundryServiceEvent, LaundryServiceState> {
  final ILaundryServiceRepository _repository;

  LaundryServiceBloc(this._repository) : super(LaundryServiceInitial()) {
    on<LoadLaundryServices>(_onLoadServices);
    on<SaveLaundryService>(_onSaveService);
  }

  Future<void> _onLoadServices(
      LoadLaundryServices event,
      Emitter<LaundryServiceState> emit,
      ) async {
    emit(LaundryServiceLoading());
    try {
      final result = await _repository.getServices();

      result.fold(
            (failure) => emit(LaundryServiceError(failure.message)),
            (services) => emit(LaundryServicesLoaded(services)),
      );
    } catch (e) {
      emit(LaundryServiceError(e.toString()));
    }
  }

  Future<void> _onSaveService(
      SaveLaundryService event,
      Emitter<LaundryServiceState> emit,
      ) async {
    emit(LaundryServiceLoading());
    try {
      final result = await _repository.saveService(event.service);

      result.fold(
            (failure) => emit(LaundryServiceError(failure.message)),
            (serviceId) {
          emit(LaundryServiceOperationSuccess('Service saved successfully'));
          add(LoadLaundryServices()); // Reload services after saving
        },
      );
    } catch (e) {
      emit(LaundryServiceError(e.toString()));
    }
  }
}