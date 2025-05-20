import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:laundry_app/user_pref.dart';
import 'package:uuid/uuid.dart';
import '../bloc/order_bloc.dart';
import '../data/model/order_data.dart';
import '../data/model/service_data.dart';
import '../getit.dart';

class ServiceDetailSheet extends StatefulWidget {
  final LaundryService service;

  const ServiceDetailSheet({Key? key, required this.service}) : super(key: key);

  @override
  State<ServiceDetailSheet> createState() => _ServiceDetailSheetState();
}

class _ServiceDetailSheetState extends State<ServiceDetailSheet> {
  // Track the current user rating
  int _userRating = 0;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedPriority = 'Usual';
  final OrderBloc _orderBloc = sl<OrderBloc>();
  final UserPreferencesManager _prefsManager = sl<UserPreferencesManager>();

  @override
  void initState() {
    super.initState();
    // Initialize with the existing rating if available
    _userRating = int.tryParse(widget.service.rating) ?? 0;
  }

  // Method to handle star rating
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }


  // Place order method
  void _placeOrder() async {
    final userInfo = _prefsManager.currentUser;

    if (userInfo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to place an order'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select pickup date and time'), backgroundColor: Colors.red),
      );
      return;
    }

    final DateTime pickupDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    // Create a new order
    final Order order = Order(
      orderId: const Uuid().v4(), // Generate a unique ID
      timestamp: DateTime.now(),
      serviceName: widget.service.name,
      pickupTime: pickupDateTime,
      amount: widget.service.price,
      customerName: userInfo.name ?? 'Unknown',
      customerAddress: userInfo.address ?? 'Not provided',
      customerPhone: userInfo.phone ?? 'Not provided',
      branch: [''] ,//[widget.service.branch ?? 'Main Branch'],
      priorities: _mapStringToPriority(_selectedPriority),
      customerId: userInfo.userId ?? 'Not provided',
    );
    print(order.pickupTime);
    // Save the order using the OrderBloc
    _orderBloc.add(SaveOrder(order));

    // Close the bottom sheet
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderBloc, OrderState>(
      bloc: _orderBloc,
      listener: (context, state) {
        if (state is OrderOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is OrderError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top indicator bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            // Service name and rating badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.service.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF004D67),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF004D67),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        widget.service.rating,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Service description
            Text(
              widget.service.desc,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 10),

            // Price display
            Container(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200)
              ),
              child: Text(
                'Price starts from: ${widget.service.price}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade800,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Row containing Estimated time and Priority
            Row(
              children: [
                // Estimated time section
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: Colors.blue.shade800,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Time',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          widget.service.period,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // Priority dropdown with improved appearance
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        PopupMenuButton<String>(
                          initialValue: _selectedPriority,
                          position: PopupMenuPosition.under,
                          offset: const Offset(0, 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          onSelected: (String value) {
                            setState(() {
                              _selectedPriority = value;
                            });
                          },
                          itemBuilder: (context) => [
                            _buildPriorityItem('Urgent'),
                            _buildPriorityItem('Normal')
                          ],
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.grey.shade700,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _selectedPriority,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: _getPriorityColor(_selectedPriority),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Interactive Rating section
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _selectDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, size: 20, color: Colors.blue.shade800),
                          const SizedBox(width: 8),
                          Text(
                            _selectedDate != null
                                ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                : 'Select Pickup Date',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: _selectTime,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          Icon(Icons.access_time, size: 20, color: Colors.blue.shade800),
                          const SizedBox(width: 8),
                          Text(
                            _selectedTime != null
                                ? '${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                                : 'Select Pickup Time',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Place Order button
            BlocBuilder<OrderBloc, OrderState>(
              bloc: _orderBloc,
              builder: (context, state) {
                bool isLoading = state is OrderLoading;

                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _placeOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'Place Order',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  PriorityList _mapStringToPriority(String priority) {
    switch (priority) {
      case 'Urgent':
        return PriorityList.urgent;
      case 'Normal':
      default:
        return PriorityList.usual;
    }
  }

// Update priority color mapping
  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Urgent':
        return Colors.red.shade700;
      case 'Normal':
      default:
        return Colors.orange.shade700;
    }
  }

// Helper method for priority items
  PopupMenuItem<String> _buildPriorityItem(String priority) {
    return PopupMenuItem(
      value: priority,
      height: 36,
      child: Text(
        priority,
        style: TextStyle(
          color: _getPriorityColor(priority),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}