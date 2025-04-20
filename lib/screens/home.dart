import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:laundry_app/user_pref.dart';
import '../bloc/service_bloc.dart';
import '../bloc/user_bloc.dart';
import '../components/address_appbar.dart';
import '../components/carousel.dart';
import '../components/services_grid.dart';
import '../constants/colors.dart';
import '../getit.dart';

class LaundryHomePage extends StatefulWidget {
  @override
  _LaundryHomePageState createState() => _LaundryHomePageState();
}

class _LaundryHomePageState extends State<LaundryHomePage> {
  final UserPreferencesManager _pref = sl<UserPreferencesManager>();
  late final String homeAddress;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() async {
    final userId = sl<FirebaseAuth>().currentUser!.uid;
    if (userId != null) {
      context.read<UserInfoBloc>().add(GetUserInfo(userId));
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<LaundryServiceBloc>(),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Component
                  HomeHeader(location: _pref.currentUser?.address ?? "Loading"),

                  const SizedBox(height: 24),

                  // Latest Offers Section
                  Text(
                    "Special For You",
                    style: TextStyle(
                      color: AppColors.title,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Offer Carousel
                  OfferCarousel(),

                  const SizedBox(height: 24),

                  // Services Section
                  const Text(
                    "What do you want to get done today?",
                    style: TextStyle(
                      color: AppColors.title,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Service Options with BLoC
                  const ServiceOptions(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}