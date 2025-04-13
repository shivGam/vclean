import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:laundry_app/constants/colors.dart';
import 'package:laundry_app/data/model/user_data.dart';
import 'package:laundry_app/routes.dart';
import 'package:laundry_app/user_pref.dart';

import '../bloc/user_bloc.dart';
import '../getit.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  void initState() {
    super.initState();
    final userId = sl<FirebaseAuth>().currentUser!.uid;
    if (userId != null) {
      context.read<UserInfoBloc>().add(GetUserInfo(userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<UserInfoBloc, UserInfoState>(
        builder: (context, state) {
          if (state is UserInfoLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UserInfoError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is UserInfoSuccess && state.user != null) {
            return _buildUserProfile(context, state.user!);
          } else {
            return const Center(child: Text('No user data available'));
          }
        },
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context, UserData userData) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // Header with user name and profile image
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Expanded(
            //       child: Text(
            //         userData.name,
            //         style: const TextStyle(
            //           fontSize: 22,
            //           fontWeight: FontWeight.bold,
            //           color: Color(0xFF026670),
            //         ),
            //         overflow: TextOverflow.ellipsis,
            //       ),
            //     ),
            //     const SizedBox(width: 16),
            //     CircleAvatar(
            //       radius: 30,
            //       backgroundColor: Colors.grey[200],
            //       backgroundImage: userData.photoUrl.isNotEmpty
            //           ? NetworkImage(userData.photoUrl)
            //           : null,
            //       child: userData.photoUrl.isEmpty
            //           ? const Icon(Icons.person, size: 30)
            //           : null,
            //     ),
            //   ],
            // ),

            _buildProfileSection(userData.photoUrl, userData.name),

            const SizedBox(height: 32),

            // User information cards
            _buildInfoCard('Name', userData.name),
            const SizedBox(height: 16),

            _buildInfoCard(
              'Phone',
              userData.phone,
            ),
            const SizedBox(height: 16),

            _buildInfoCard('Address', userData.address),

            const Spacer(),

            // Logout button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => _handleLogout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'log out',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(String _photoUrl,String _name) {
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

  Widget _buildInfoCard(String? label, String value, {Widget? leadingWidget}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leadingWidget != null) leadingWidget,
          if (label != null) ...[
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.secondary,
              ),
            ),
            const Spacer(),
          ],
          Expanded(
            flex: label != null ? 2 : 1,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: label != null ? TextAlign.end : TextAlign.start,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performLogout(context);
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _performLogout(BuildContext context) async {
    try {
      await sl<FirebaseAuth>().signOut();
      await sl<UserPreferencesManager>().signOut();

      // Navigate to login screen
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.login,
            (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: $e')),
      );
    }
  }
}