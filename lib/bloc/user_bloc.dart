import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/model/user_data.dart';
import '../data/repository/user_repo.dart';
import '../user_pref.dart';

abstract class UserInfoState {}

class UserInfoInitial extends UserInfoState {}

class UserInfoLoading extends UserInfoState {}

class UserInfoSuccess extends UserInfoState {
  final String userId;
  final UserData? user;

  UserInfoSuccess(this.userId, {this.user});

  bool get isUserInfoComplete {
    if (user == null) return false;
    return user!.name.isNotEmpty &&
        user!.phone.isNotEmpty &&
        user!.address.isNotEmpty;
  }
}

class UserInfoError extends UserInfoState {
  final String message;
  UserInfoError(this.message);
}

// user_info_event.dart
abstract class UserInfoEvent {}

class SaveUserInfo extends UserInfoEvent {
  final UserData user;
  SaveUserInfo(this.user);
}

class GetUserInfo extends UserInfoEvent {
  final String userId;
  GetUserInfo(this.userId);
}

class UserInfoBloc extends Bloc<UserInfoEvent, UserInfoState> {
  final IUserRepository _repository;
  final UserPreferencesManager _prefsManager;

  UserInfoBloc(this._repository, this._prefsManager) : super(UserInfoInitial()) {
    on<SaveUserInfo>(_onSaveUserInfo);
    on<GetUserInfo>(_onGetUserInfo);
  }

  Future<void> _onSaveUserInfo(
      SaveUserInfo event,
      Emitter<UserInfoState> emit,
      ) async {
    emit(UserInfoLoading());
    try {
      await _prefsManager.setCurrentUser(event.user);
      final result = await _repository.saveUserInfo(event.user);

      result.fold(
            (failure) => emit(UserInfoError(failure.message)),
            (userId) => emit(UserInfoSuccess(userId, user: event.user)),
      );
    } catch (e) {
      emit(UserInfoError(e.toString()));
    }
  }

  Future<void> _onGetUserInfo(
      GetUserInfo event,
      Emitter<UserInfoState> emit,
      ) async {
    emit(UserInfoLoading());
    try {
      final result = await _repository.getUserInfo(event.userId);
      await result.fold(
            (failure) async => emit(UserInfoError(failure.message)),
            (user) async {
          await _prefsManager.setCurrentUser(user);
          if (!emit.isDone) {
            emit(UserInfoSuccess(user.userId, user: user));
          }
        },
      );
    } catch (e) {
      if (!emit.isDone) {
        emit(UserInfoError(e.toString()));
      }
    }
  }
}