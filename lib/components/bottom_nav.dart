import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../constants/colors.dart';

abstract class NavigationEvent {}

class NavigationTabChanged extends NavigationEvent {
  final int index;

  NavigationTabChanged(this.index);
}

class NavigationState {
  final int currentIndex;

  NavigationState(this.currentIndex);
}

// Navigation BLoC
class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(NavigationState(0)) {
    on<NavigationTabChanged>((event, emit) {
      emit(NavigationState(event.index));
    });
  }
}

// Bottom Navigation UI Widget
class BottomNavigation extends StatelessWidget {
  const BottomNavigation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context,
                  0,
                  Icons.iron_outlined,
                  'Home',
                  Colors.grey,
                  state.currentIndex == 0,
                ),
                _buildNavItem(
                  context,
                  1,
                  Icons.access_time,
                  'Orders',
                  Colors.grey,
                  state.currentIndex == 1,
                ),
                _buildNavItem(
                  context,
                  2,
                  Icons.person,
                  'Account',
                  Colors.grey,
                  state.currentIndex == 2,
                ),

              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon,
      String label, Color defaultColor, bool isSelected) {
    final Color itemColor = isSelected ? AppColors.primary : defaultColor;

    return InkWell(
      onTap: () {
        context.read<NavigationBloc>().add(NavigationTabChanged(index));
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: itemColor,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: itemColor,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}