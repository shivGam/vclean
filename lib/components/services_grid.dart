import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:laundry_app/components/service_bottom_sheet.dart';

import '../bloc/service_bloc.dart';
import '../data/model/service_data.dart';

class ServiceOptions extends StatefulWidget {
  const ServiceOptions({Key? key}) : super(key: key);

  @override
  State<ServiceOptions> createState() => _ServiceOptionsState();
}

class _ServiceOptionsState extends State<ServiceOptions> {
  @override
  void initState() {
    super.initState();
    // Load services when the widget initializes
    context.read<LaundryServiceBloc>().add(LoadLaundryServices());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LaundryServiceBloc, LaundryServiceState>(
      builder: (context, state) {
        if (state is LaundryServiceLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is LaundryServiceError) {
          return Center(child: Text('Error: ${state.message}'));
        } else if (state is LaundryServicesLoaded) {
          // If we have services, display them in a grid
          return _buildServicesGrid(state.services);
        }
        // Initial state or other states
        return const Center(child: Text('No services available'));
      },
    );
  }

  Widget _buildServicesGrid(List<LaundryService> services) {
    // If there are no services or only one, handle appropriately
    if (services.isEmpty) {
      return const Center(child: Text('No services available'));
    }

    // For grid with 2 columns
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85, // Adjust based on your design
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return _buildServiceOption(
          icon: Icons.dry_cleaning,//_getIconForService(service.type),
          title: service.name,
          description: service.desc,
          color: Colors.blue.shade100,//_getColorForService(service.type),
          service: service,
        );
      },
    );
  }

  IconData _getIconForService(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'wash':
        return Icons.local_laundry_service;
      case 'dry':
        return Icons.dry_cleaning;
      case 'iron':
        return Icons.iron;
      case 'fold':
        return Icons.design_services;
      default:
        return Icons.cleaning_services;
    }
  }

  Color _getColorForService(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'wash':
        return Colors.blue.shade100;
      case 'dry':
        return Colors.amber.shade100;
      case 'iron':
        return Colors.red.shade100;
      case 'fold':
        return Colors.green.shade100;
      default:
        return Colors.purple.shade100;
    }
  }

  Widget _buildServiceOption({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required LaundryService service,
  }) {
    return GestureDetector(
      onTap: () {
        // Handle service selection
        // You could navigate to a detail page or show a dialog
        _onServiceSelected(service);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.blue.shade800,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "${service.price}",
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onServiceSelected(LaundryService service) {
    // Show a bottom sheet or navigate to details page
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ServiceDetailSheet(service: service),
    );
  }
}
