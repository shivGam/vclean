import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:laundry_app/user_pref.dart';
import '../bloc/order_bloc.dart';
import '../constants/colors.dart';
import '../data/model/order_data.dart';
import '../getit.dart';

class OrderHistoryPage extends StatefulWidget {

  const OrderHistoryPage({
    super.key,
  });

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  @override
  void initState() {
    super.initState();
    final userId = sl<FirebaseAuth>().currentUser!.uid;
    context.read<OrderBloc>().add(StartUserOrdersStream(userId));
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
      body: BlocConsumer<OrderBloc, OrderState>(
        listener: (context, state) {
          if (state is OrderError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
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
                  return OrderHistoryCard(order: order);
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
    );
  }
}

class OrderHistoryCard extends StatelessWidget {
  final Order order;

  const OrderHistoryCard({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    // Format timestamp
    String timeStamp = 'N/A';
    if (order.timestamp != null) {
      timeStamp = DateFormat('MMM d, y • hh:mm a').format(order.timestamp!);
    }

    String statusText;
    Color statusColor;

    switch (order.status) {
      case OrderStatus.complete:
        statusText = 'Completed';
        statusColor = Colors.green;
        break;
      case OrderStatus.cancelled:
        statusText = 'Cancelled';
        statusColor = Colors.red;
        break;
      case OrderStatus.pending:
        statusText = 'Pending';
        statusColor = Colors.blue;
        break;
    }


    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
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
                  child: Icon(
                    Icons.local_laundry_service,
                    color: Colors.blue[400],
                    size: 24,
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
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

}