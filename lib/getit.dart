import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'bloc/auth_bloc.dart';
import 'data/repository/auth_repo.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn());
  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(sl<FirebaseAuth>(), sl<GoogleSignIn>()),
  );
  sl.registerLazySingleton(() => FirebaseAuth.instance);

  sl.registerFactory(() => AuthBloc(sl<AuthRepository>()));

  sl.registerLazySingleton(() => FirebaseFirestore.instance);
}