import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:laundry_app/bloc/service_bloc.dart';
import 'package:laundry_app/bloc/user_bloc.dart';
import 'package:laundry_app/data/repository/service_repo.dart';
import 'package:laundry_app/data/repository/user_repo.dart';
import 'package:laundry_app/user_pref.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bloc/auth_bloc.dart';
import 'data/repository/auth_repo.dart';

final sl = GetIt.instance;

Future<void> init() async {
  final prefs = await SharedPreferences.getInstance();
  final auth = FirebaseAuth.instance;
  sl.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn());
  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(sl<FirebaseAuth>(), sl<GoogleSignIn>()),
  );
  sl.registerLazySingleton<UserRepository>(
      ()=> UserRepository(sl<FirebaseFirestore>())
  );
  sl.registerLazySingleton<LaundryServiceRepository>(
      ()=> LaundryServiceRepository(sl<FirebaseFirestore>())
  );
  sl.registerLazySingleton<UserPreferencesManager>(() => UserPreferencesManager(prefs, auth,sl<UserRepository>()));
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerFactory(() => LaundryServiceBloc(sl<LaundryServiceRepository>()));
  sl.registerFactory(() => AuthBloc(sl<AuthRepository>()));
  sl.registerFactory(() => UserInfoBloc(sl<UserRepository>(),sl<UserPreferencesManager>()));
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
}