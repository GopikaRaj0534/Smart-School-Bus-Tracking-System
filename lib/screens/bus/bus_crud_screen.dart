import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/bus_model.dart';
import '../../providers/bus_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../utils/validation_helper.dart';

class BusCrudScreen extends StatefulWidget {
  const BusCrudScreen({Key? key}) : super(key: key);

  @override
  State<BusCrudScreen> createState() => _BusCrudScreenState();
}

class _BusCrudScreenState extends State<BusCrudScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.override("initState");
    // Fetch initial bus data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BusProvider>(context, listen: false).fetchBuses();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _recordActivity(BuildContext context) {
    Provider.of<AuthProvider>(context, listen: false).recordActivity();
  }

  void _openAddEditBottomSheet({BusModel? bus}) {
    _recordActivity(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) => BusFormBottomSheet(bus: bus),
    );
  }

  void _confirmDelete(String id) {
    _recordActivity(context);
    showDialog(
      context: context,
      builder: (dialogCtx) => ConfirmationDialog(
        title: 'Delete Bus',
        content: 'Are you sure you want to permanently delete this bus from the fleet?',
        confirmText: 'Delete',
        confirmColor: AppTheme.errorColor,
        onConfirm: () async {
          final busProvider = Provider.of<BusProvider>(context, listen: false);
          final success = await busProvider.deleteBus(id);
          
          if (context.mounted) {
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bus deleted successfully!'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(busProvider.errorMessage ?? 'Failed to delete bus'),
                  backgroundColor: AppTheme.errorColor,
                ),
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final busProvider = Provider.of<BusProvider>(context);
    final busList = busProvider.buses;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fleet Management'),
      ),
      body: Column(
        children: [
          // Search Header Area
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 15),
              onChanged: (value) {
                _recordActivity(context);
                busProvider.searchBuses(value);
              },
              decoration: InputDecoration(
                hintText: 'Search by bus number, driver, or route...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.textLight),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppTheme.textLight),
                        onPressed: () {
                          _searchController.clear();
                          busProvider.searchBuses('');
                          _recordActivity(context);
                        },
                      )
                    : null,
              ),
            ),
          ),
          
          // Bus List Body
          Expanded(
            child: busProvider.isLoading && busList.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : busList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.directions_bus_rounded,
                              size: 64,
                              color: AppTheme.textLight.withOpacity(0.3),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'No buses found',
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Try adjusting your search query or add a new bus.',
                              style: TextStyle(fontSize: 12, color: AppTheme.textLight),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: busList.length,
                        itemBuilder: (context, index) {
                          final bus = busList[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12.0),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: AppTheme.primaryColor.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              'Bus ${bus.busNumber}',
                                              style: const TextStyle(
                                                color: AppTheme.primaryColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            bus.registrationNumber,
                                            style: const TextStyle(
                                              color: AppTheme.textLight,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryColor, size: 20),
                                            onPressed: () => _openAddEditBottomSheet(bus: bus),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.errorColor, size: 20),
                                            onPressed: () => _confirmDelete(bus.id),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  const Divider(height: 20),
                                  Row(
                                    children: [
                                      const Icon(Icons.person_outline_rounded, size: 18, color: AppTheme.textLight),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Driver: ',
                                        style: TextStyle(fontSize: 13, color: AppTheme.textLight, fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        bus.driverName,
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.route_outlined, size: 18, color: AppTheme.textLight),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Route: ',
                                        style: TextStyle(fontSize: 13, color: AppTheme.textLight, fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        bus.routeName,
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.people_outline_rounded, size: 18, color: AppTheme.textLight),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Capacity: ',
                                        style: TextStyle(fontSize: 13, color: AppTheme.textLight, fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        '${bus.capacity} seats',
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddEditBottomSheet(),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class BusFormBottomSheet extends StatefulWidget {
  final BusModel? bus;

  const BusFormBottomSheet({Key? key, this.bus}) : super(key: key);

  @override
  State<BusFormBottomSheet> createState() => _BusFormBottomSheetState();
}

class _BusFormBottomSheetState extends State<BusFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _busNumberController = TextEditingController();
  final _regNumberController = TextEditingController();
  final _driverNameController = TextEditingController();
  final _routeController = TextEditingController();
  final _capacityController = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.bus != null) {
      _busNumberController.text = widget.bus!.busNumber;
      _regNumberController.text = widget.bus!.registrationNumber;
      _driverNameController.text = widget.bus!.driverName;
      _routeController.text = widget.bus!.routeName;
      _capacityController.text = widget.bus!.capacity.toString();
    }
  }

  @override
  void dispose() {
    _busNumberController.dispose();
    _regNumberController.dispose();
    _driverNameController.dispose();
    _routeController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _saveBus() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final busProvider = Provider.of<BusProvider>(context, listen: false);
    final capacityVal = int.tryParse(_capacityController.text.trim()) ?? 0;

    final busData = BusModel(
      id: widget.bus?.id ?? '',
      busNumber: _busNumberController.text.trim(),
      registrationNumber: _regNumberController.text.trim(),
      driverName: _driverNameController.text.trim(),
      routeName: _routeController.text.trim(),
      capacity: capacityVal,
    );

    bool success;
    if (widget.bus != null) {
      success = await busProvider.updateBus(busData);
    } else {
      success = await busProvider.addBus(busData);
    }

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.bus != null ? 'Bus updated successfully!' : 'Bus added successfully!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(busProvider.errorMessage ?? 'Operation failed'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24.0,
        right: 24.0,
        top: 24.0,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.bus != null ? 'Edit Bus' : 'Add New Bus',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
              
              // Bus Number
              CustomTextField(
                labelText: 'Bus Number',
                hintText: 'e.g. 05 or 14',
                controller: _busNumberController,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.directions_bus_outlined,
                validator: (v) => ValidationHelper.validateRequired(v, 'Bus number'),
              ),
              const SizedBox(height: 16),

              // Registration Number
              CustomTextField(
                labelText: 'Registration Number',
                hintText: 'e.g. NY-5489',
                controller: _regNumberController,
                prefixIcon: Icons.badge_outlined,
                validator: (v) => ValidationHelper.validateRequired(v, 'Registration number'),
              ),
              const SizedBox(height: 16),

              // Driver Name
              CustomTextField(
                labelText: 'Driver Name',
                hintText: 'Enter driver name',
                controller: _driverNameController,
                prefixIcon: Icons.person_outline_rounded,
                validator: (v) => ValidationHelper.validateRequired(v, 'Driver name'),
              ),
              const SizedBox(height: 16),

              // Route Name
              CustomTextField(
                labelText: 'Route Name',
                hintText: 'e.g. Route B',
                controller: _routeController,
                prefixIcon: Icons.route_outlined,
                validator: (v) => ValidationHelper.validateRequired(v, 'Route name'),
              ),
              const SizedBox(height: 16),

              // Capacity
              CustomTextField(
                labelText: 'Bus Capacity',
                hintText: 'e.g. 30',
                controller: _capacityController,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.people_outline_rounded,
                validator: (v) {
                  final req = ValidationHelper.validateRequired(v, 'Bus capacity');
                  if (req != null) return req;
                  final parsed = int.tryParse(v!.trim());
                  if (parsed == null || parsed <= 0) {
                    return 'Capacity must be a positive integer';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              CustomButton(
                text: widget.bus != null ? 'Save Changes' : 'Add Bus',
                isLoading: _isSaving,
                onPressed: _saveBus,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
