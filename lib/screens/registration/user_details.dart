import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:laundry_app/user_pref.dart';

import '../../bloc/user_bloc.dart';
import '../../components/custom_text_field.dart';
import '../../constants/colors.dart';
import '../../data/model/user_data.dart';
import '../../getit.dart';
import '../../routes.dart';

class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({super.key});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  late final UserInfoBloc _bloc;
  late final UserPreferencesManager _pref;
  final _formKey = GlobalKey<FormState>();

  // Form data
  String? _phone;
  String? _address;

  // Get from authentication
  late String _userId;
  late String _name;
  late String _photoUrl;

  @override
  void initState() {
    super.initState();
    _bloc = sl<UserInfoBloc>();
    _pref = sl<UserPreferencesManager>();
    _getUserAuthData();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  void _getUserAuthData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userId = user.uid;
      _name = user.displayName ?? 'User';
      _photoUrl = user.photoURL ?? '';

      _bloc.add(GetUserInfo(_userId));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not authenticated, please log in again'),
          backgroundColor: Colors.red,
        ),
      );
      // Navigate to login screen
      Future.delayed(const Duration(seconds: 2), () {
        if (context.mounted) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.login);
        }
      });
    }
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (value.length != 10 || !RegExp(r'^[0-9]{10}$').hasMatch(value)) {
      return 'Enter valid 10-digit phone number';
    }
    return null;
  }

  String? _validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address is required';
    }
    if (value.length < 10) {
      return 'Please enter a complete address';
    }
    return null;
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      if (_userId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User ID not found, please log in again'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final userData = UserData(
        userId: _userId,
        name: _name,
        phone: _phone!,
        address: _address!,
        photoUrl: _photoUrl,
      );

      _bloc.add(SaveUserInfo(userData));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<UserInfoBloc, UserInfoState>(
          bloc: _bloc,
          listener: (context, state) {
            if (state is UserInfoSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Information saved successfully!'),
                  duration: Duration(seconds: 1),
                ),
              );
              _pref.isUserProfileComplete = true;
              Future.delayed(const Duration(seconds: 1), () {
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed(
                    AppRoutes.home,
                  );
                }
              });
            } else if (state is UserInfoError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            // Prefill form if data exists
            if (state is UserInfoSuccess && state.user != null) {
              _phone = state.user!.phone;
              _address = state.user!.address;
            }

            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Complete Your Profile',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.title,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please provide your contact details so we can serve you better',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 24),

                        _buildProfileSection(),

                        _buildSectionTitle('Phone Number'),
                        CustomTextformField(
                          hintText: 'Enter your 10-digit phone number',
                          isPhoneField: true,
                          maxLength: 10,
                          onSaved: (value) {
                            _phone = value;
                          },
                          validator: _validatePhone,
                        ),

                        _buildSectionTitle('Complete Address'),
                        CustomTextformField(
                          hintText: 'Wing, Building name, Street, Area',
                          onSaved: (value) {
                            _address = value;
                          },
                          validator: _validateAddress,
                        ),

                        const SizedBox(height: 32),
                        _buildSubmitButton(state is UserInfoLoading),
                      ],
                    ),
                  ),
                ),
                if (state is UserInfoLoading)
                  Container(
                    color: Colors.black.withOpacity(0.1),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.title,
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 24.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.secondary.withOpacity(0.2),
              backgroundImage: _photoUrl.isNotEmpty ? NetworkImage(_photoUrl) : null,
              child: _photoUrl.isEmpty
                  ? const Icon(Icons.person, size: 60, color: AppColors.primary)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              _name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.title,
              ),
            ),
            const SizedBox(height: 4),

          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          isLoading ? 'Saving...' : 'Continue',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}