import 'package:flutter/material.dart';
import 'package:laundry_app/screens/account.dart';
import 'package:laundry_app/screens/admin_page.dart';
import 'package:laundry_app/screens/order_history.dart';
import 'package:laundry_app/screens/registration/login.dart';
import 'package:laundry_app/screens/registration/user_details.dart';

import 'main.dart';

class AppRoutes {
  static const String home = '/home';
  static const String account = '/account';
  static const String login = '/login';
  static const String order = '/order';
  static const String userdetails = '/userdetails';
  static const String admin = '/admin';


  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case home:
        return MaterialPageRoute(builder: (_) => MainScreen());
      case account:
        return MaterialPageRoute(builder: (_) => AccountPage());
      case order:
        return MaterialPageRoute(builder: (_) => OrderHistoryPage());
      case userdetails:
        return MaterialPageRoute(builder: (_) => UserDetailsScreen());
      case admin:
        return MaterialPageRoute(builder: (_) => OrderHistoryAdminPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text("No routes defined"),
            ),
          ),
        );
    }
  }
}
