import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:laundry_app/bloc/carousel_bloc.dart';
import 'package:laundry_app/bloc/order_bloc.dart';
import 'package:laundry_app/bloc/service_bloc.dart';
import 'package:laundry_app/constants/colors.dart';
import 'package:laundry_app/data/repository/admin_repo.dart';
import 'package:laundry_app/data/repository/carousel_repo.dart';
import 'package:laundry_app/data/repository/order_repo.dart';
import 'package:laundry_app/data/repository/service_repo.dart';
import 'package:laundry_app/routes.dart';
import 'package:laundry_app/screens/account.dart';
import 'package:laundry_app/screens/admin_page.dart';
import 'package:laundry_app/screens/home.dart';
import 'package:laundry_app/screens/order_history.dart';
import 'package:laundry_app/user_pref.dart';

import 'bloc/auth_bloc.dart';
import 'bloc/user_bloc.dart';
import 'components/bottom_nav.dart';
import 'data/repository/auth_repo.dart';
import 'data/repository/user_repo.dart';
import 'getit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await init();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(sl<AuthRepository>(),sl<AdminRepository>(),sl<UserPreferencesManager>()),
        ),
        BlocProvider(
          create: (context) => UserInfoBloc(sl<UserRepository>(), sl<UserPreferencesManager>()),
        ),
        BlocProvider(
            create: (context) => LaundryServiceBloc(sl<LaundryServiceRepository>())
        ),
        BlocProvider(
            create: (context) => OrderBloc(sl<IOrderRepository>())
        ),
        BlocProvider(
          create: (context) => CarouselBloc(sl<CarouselRepository>()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.from(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary)),
      debugShowCheckedModeBanner: false,
      home: InitialScreenDecider(),
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
class InitialScreenDecider extends StatelessWidget {
  const InitialScreenDecider({super.key});

  @override
  Widget build(BuildContext context) {
    final pref = sl<UserPreferencesManager>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (pref.isAdmin) {
        Navigator.pushReplacementNamed(context, AppRoutes.admin);
      } else if (!pref.isReadyForMain){
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    });
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
class MainScreen extends StatelessWidget {
  final List<Widget> _screens = [
    LaundryHomePage(),
    OrderHistoryPage(),
    AccountPage()
  ];

  MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NavigationBloc(),
      child: BlocBuilder<NavigationBloc, NavigationState>(
        builder: (context, state) {
          return Scaffold(
            body: _screens[state.currentIndex],
            bottomNavigationBar: const BottomNavigation(),
          );
        },
      ),
    );
  }
}
