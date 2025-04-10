import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:laundry_app/routes.dart';
import 'package:laundry_app/screens/account.dart';
import 'package:laundry_app/screens/home.dart';
import 'package:laundry_app/screens/order_history.dart';

import 'components/bottom_nav.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.from(
          colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFFF5963))),
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
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
