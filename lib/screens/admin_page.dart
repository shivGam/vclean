import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../bloc/order_bloc.dart';
import '../constants/colors.dart';
import '../data/model/order_data.dart';
import '../getit.dart';
import '../routes.dart';
import '../user_pref.dart';

class OrderHistoryAdminPage extends StatefulWidget {
  const OrderHistoryAdminPage({super.key});

  @override
  State<OrderHistoryAdminPage> createState() => _OrderHistoryAdminPageState();
}

class _OrderHistoryAdminPageState extends State<OrderHistoryAdminPage> {
  @override
  void initState() {
    super.initState();
    // Start a stream of all orders when the page loads
    context.read<OrderBloc>().add(StartOrdersStream());
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      await launchUrl(launchUri);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch phone dialer')),
      );
    }
  }

  void _updateOrderStatus(Order order) {
    // Create a copy with updated priority to toggle between Completed and Pending
    final updatedOrder = order.copyWith(
      status: OrderStatus.complete,
    );

    // Save the updated order
    context.read<OrderBloc>().add(UpdateOrder(updatedOrder));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order History',style: TextStyle(
          color: AppColors.primary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<OrderBloc, OrderState>(
              listener: (context, state) {
                if (state is OrderError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                } else if (state is OrderOperationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                  if (context.read<OrderBloc>().state is! OrdersLoaded) {
                    context.read<OrderBloc>().add(StartOrdersStream());
                  }
                }
              },
              builder: (context, state) {
                if (state is OrderLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is OrdersLoaded) {
                  final orders = state.orders;

                  // Sort orders by timestamp, most recent first
                  orders.sort((a, b) {
                    final aTime = a.timestamp;
                    final bTime = b.timestamp;
                    if (aTime == null) return 1;
                    if (bTime == null) return -1;
                    return bTime.compareTo(aTime);
                  });

                  if (orders.isEmpty) {
                    return const Center(
                      child: Text(
                        'No orders found',
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListView.builder(
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return AdminOrderCard(
                          order: order,
                          onCallPressed: () => _makePhoneCall(order.customerPhone),
                          onStatusChange: () => _updateOrderStatus(order),
                        );
                      },
                    ),
                  );
                }

                // Default empty state
                return const Center(
                  child: Text(
                    'No order history available',
                    style: TextStyle(fontSize: 18),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handleLogout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Log out',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
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

class AdminOrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onCallPressed;
  final VoidCallback onStatusChange;

  const AdminOrderCard({
    super.key,
    required this.order,
    required this.onCallPressed,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    // Format timestamp
    String timeStamp = 'N/A';
    if (order.timestamp != null) {
      timeStamp = DateFormat('MMM d, y • hh:mm a').format(order.timestamp!);
    }

    Color getColors(PriorityList priority) {
      switch (order.priorities) {
        case PriorityList.urgent:
          return Colors.red.withOpacity(0.5);
        case PriorityList.usual:
          return Colors.grey.withOpacity(0.1);
      }
    }

    // Determine status based on priority
    bool isCompleted = order.status == OrderStatus.complete;

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: getColors(order.priorities),
          width: 1
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.local_laundry_service,
                        color: Colors.blue,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.serviceName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            order.amount,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      timeStamp,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  order.customerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  order.customerAddress,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onCallPressed,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.phone,
                          size: 18,
                          color: Colors.blue[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Call',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: onStatusChange,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Colors.green.withOpacity(0.1)
                          : Colors.blue.withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Text(
                      isCompleted ? 'Completed' : 'Pending',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isCompleted ? Colors.green : Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}