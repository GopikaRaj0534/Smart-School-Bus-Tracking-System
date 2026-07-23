class BusModel {
  final String id;
  final String busNumber;
  final String registrationNumber;
  final String driverName;
  final String routeName;
  final int capacity;

  BusModel({
    required this.id,
    required this.busNumber,
    required this.registrationNumber,
    required this.driverName,
    required this.routeName,
    required this.capacity,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bus_number': busNumber,
      'registration_number': registrationNumber,
      'driver_name': driverName,
      'route_name': routeName,
      'capacity': capacity,
    };
  }

  factory BusModel.fromJson(Map<String, dynamic> json) {
    return BusModel(
      id: json['id']?.toString() ?? '',
      busNumber: json['bus_number'] ?? '',
      registrationNumber: json['registration_number'] ?? '',
      driverName: json['driver_name'] ?? '',
      routeName: json['route_name'] ?? '',
      capacity: json['capacity'] is int ? json['capacity'] : int.tryParse(json['capacity']?.toString() ?? '0') ?? 0,
    );
  }

  // Helper method to copy with modifications
  BusModel copyWith({
    String? id,
    String? busNumber,
    String? registrationNumber,
    String? driverName,
    String? routeName,
    int? capacity,
  }) {
    return BusModel(
      id: id ?? this.id,
      busNumber: busNumber ?? this.busNumber,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      driverName: driverName ?? this.driverName,
      routeName: routeName ?? this.routeName,
      capacity: capacity ?? this.capacity,
    );
  }
}
