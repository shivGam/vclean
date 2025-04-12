import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repository/auth_repo.dart';

abstract class AuthEvent {}
class GoogleSignInEvent extends AuthEvent {}

class SignOutEvent extends AuthEvent {}

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthenticatedState extends AuthState {
  final String userId;
  AuthenticatedState(this.userId);
}

class UnauthenticatedState extends AuthState {}

class AuthErrorState extends AuthState {
  final String message;
  AuthErrorState(this.message);
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;

  AuthBloc(this._repository) : super(AuthInitial()) {
    on<GoogleSignInEvent>(_onGoogleSignIn);
    on<SignOutEvent>(_onSignOut);
  }

  Future<void> _onGoogleSignIn(GoogleSignInEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    final result = await _repository.signInWithGoogle();
    result.fold(
          (failure) => emit(AuthErrorState(failure.message)),
          (userId) => emit(AuthenticatedState(userId)),
    );
  }

  Future<void> _onSignOut(SignOutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    final result = await _repository.signOut();
    result.fold(
          (failure) => emit(AuthErrorState(failure.message)),
          (_) => emit(UnauthenticatedState()),
    );
  }
}