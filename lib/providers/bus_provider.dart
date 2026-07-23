import 'package:flutter/material.dart';
import '../models/bus_model.dart';
import '../services/api_service.dart';

class BusProvider with ChangeNotifier {
  final List<BusModel> _buses = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<BusModel> get buses {
    if (_searchQuery.trim().isEmpty) {
      return List.unmodifiable(_buses);
    }
    final query = _searchQuery.toLowerCase();
    return _buses.where((bus) {
      return bus.busNumber.toLowerCase().contains(query) ||
          bus.registrationNumber.toLowerCase().contains(query) ||
          bus.driverName.toLowerCase().contains(query) ||
          bus.routeName.toLowerCase().contains(query);
    }).toList();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  final ApiService _apiService = ApiService();

  // Populate mock data initially
  Future<void> fetchBuses() async {
    if (_buses.isNotEmpty) return; // Keep existing cache if populated
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final responseList = await _apiService.getBuses();
      if (responseList.isNotEmpty) {
        _buses.clear();
        for (var item in responseList) {
          _buses.add(BusModel.fromJson(item));
        }
      } else {
        // Fallback to initial dummy data
        _buses.addAll([
          BusModel(id: '1', busNumber: '01', registrationNumber: 'NY-1021', driverName: 'John Doe', routeName: 'Route A', capacity: 40),
          BusModel(id: '2', busNumber: '02', registrationNumber: 'NY-3045', driverName: 'Jane Smith', routeName: 'Route B', capacity: 35),
          BusModel(id: '3', busNumber: '03', registrationNumber: 'NY-8890', driverName: 'David Johnson', routeName: 'Route C', capacity: 50),
          BusModel(id: '4', busNumber: '04', registrationNumber: 'NY-4412', driverName: 'Emma Wilson', routeName: 'Route D', capacity: 30),
        ]);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load buses.';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update search query filter
  void searchBuses(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Validation: Check duplicate bus numbers
  bool isDuplicateBusNumber(String busNumber, {String? excludeId}) {
    return _buses.any((bus) => 
      bus.busNumber.trim().toLowerCase() == busNumber.trim().toLowerCase() && 
      bus.id != excludeId
    );
  }

  // Add Bus
  Future<bool> addBus(BusModel bus) async {
    if (isDuplicateBusNumber(bus.busNumber)) {
      _errorMessage = 'Bus Number "${bus.busNumber}" is already assigned to another bus.';
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _apiService.addBus(bus.toJson());
      if (result['success'] == true) {
        // Generate new local ID if mock
        final newId = DateTime.now().millisecondsSinceEpoch.toString();
        final newBus = bus.copyWith(id: newId);
        _buses.add(newBus);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Failed to add bus';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (_) {
      _errorMessage = 'Network error while adding bus.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update Bus
  Future<bool> updateBus(BusModel updatedBus) async {
    if (isDuplicateBusNumber(updatedBus.busNumber, excludeId: updatedBus.id)) {
      _errorMessage = 'Bus Number "${updatedBus.busNumber}" is already assigned to another bus.';
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _apiService.updateBus(updatedBus.id, updatedBus.toJson());
      if (result['success'] == true) {
        final index = _buses.indexWhere((b) => b.id == updatedBus.id);
        if (index != -1) {
          _buses[index] = updatedBus;
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Failed to update bus';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (_) {
      _errorMessage = 'Network error while updating bus.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete Bus
  Future<bool> deleteBus(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _apiService.deleteBus(id);
      if (result['success'] == true) {
        _buses.removeWhere((b) => b.id == id);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Failed to delete bus';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (_) {
      _errorMessage = 'Network error while deleting bus.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
