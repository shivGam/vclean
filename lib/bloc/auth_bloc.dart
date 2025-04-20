import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repository/auth_repo.dart';
import '../data/repository/admin_repo.dart';
import '../user_pref.dart';

abstract class AuthEvent {}
class GoogleSignInEvent extends AuthEvent {}
class SignOutEvent extends AuthEvent {}
class CheckAdminStatusEvent extends AuthEvent {}

abstract class AuthState {}

class AuthInitial extends AuthState {}
class AuthLoadingState extends AuthState {}
class AuthenticatedState extends AuthState {
  final String userId;
  final String email;
  final bool isAdmin;

  AuthenticatedState(this.userId, this.email, {this.isAdmin = false});
}
class UnauthenticatedState extends AuthState {}
class AuthErrorState extends AuthState {
  final String message;
  AuthErrorState(this.message);
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final AdminRepository _adminRepository;
  final UserPreferencesManager _preferencesManager;

  AuthBloc(
      this._authRepository,
      this._adminRepository,
      this._preferencesManager
      ) : super(AuthInitial()) {
    on<GoogleSignInEvent>(_onGoogleSignIn);
    on<SignOutEvent>(_onSignOut);
    on<CheckAdminStatusEvent>(_onCheckAdminStatus);

    // Initialize the state based on current auth status
    _initializeAuthState();
  }

  void _initializeAuthState() {
    if (_authRepository.isLoggedIn) {
      final userId = _authRepository.currentUserId;
      final email = _authRepository.currentUserEmail;

      if (userId != null && email != null) {
        add(CheckAdminStatusEvent());
      } else {
        emit(UnauthenticatedState());
      }
    } else {
      emit(UnauthenticatedState());
    }
  }

  Future<void> _onGoogleSignIn(GoogleSignInEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    final result = await _authRepository.signInWithGoogle();

    await result.fold(
          (failure) async {
        emit(AuthErrorState(failure.message));
      },
          (userId) async {
        final userEmail = _authRepository.currentUserEmail;

        if (userEmail != null) {
          await _preferencesManager.updateProfileStatus();
          final adminResult = await _adminRepository.isUserAdmin(userEmail);

          await adminResult.fold(
                  (failure) async {
                // If admin check fails, still authenticate but not as admin
                await _preferencesManager.setAdminStatus(false);
                emit(AuthenticatedState(userId, userEmail, isAdmin: false));
              },
                  (isAdmin) async {
                await _preferencesManager.setAdminStatus(isAdmin);
                emit(AuthenticatedState(userId, userEmail, isAdmin: isAdmin));
              }
          );
        } else {
          await _preferencesManager.setAdminStatus(false);
          emit(AuthenticatedState(userId, '', isAdmin: false));
        }
      },
    );
  }

  Future<void> _onSignOut(SignOutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    await _preferencesManager.signOut();
    emit(UnauthenticatedState());
  }

  Future<void> _onCheckAdminStatus(CheckAdminStatusEvent event, Emitter<AuthState> emit) async {
    final userId = _authRepository.currentUserId;
    final email = _authRepository.currentUserEmail;

    if (userId != null && email != null) {
      emit(AuthLoadingState());
      await _preferencesManager.updateProfileStatus();
      final result = await _adminRepository.isUserAdmin(email);
      await result.fold(
            (failure) async {
          await _preferencesManager.setAdminStatus(false);
          emit(AuthenticatedState(userId, email, isAdmin: false));
        },
            (isAdmin) async {
          await _preferencesManager.setAdminStatus(isAdmin);
          emit(AuthenticatedState(userId, email, isAdmin: isAdmin));
        },
      );
    } else {
      emit(UnauthenticatedState());
    }
  }
}