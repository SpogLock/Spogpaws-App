class Clinic {
  const Clinic({
    required this.id,
    required this.name,
    required this.city,
    required this.area,
    required this.addressLine,
    required this.contactPhone,
    required this.emergencyPhone,
    required this.openingTime,
    required this.closingTime,
    required this.services,
    required this.about,
    required this.is24Hours,
    required this.isActive,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String city;
  final String area;
  final String addressLine;
  final String contactPhone;
  final String emergencyPhone;
  final String openingTime;
  final String closingTime;
  final List<String> services;
  final String about;
  final bool is24Hours;
  final bool isActive;
  final DateTime? createdAt;

  String get fullLocation {
    final trimmedArea = area.trim();
    if (trimmedArea.isEmpty) {
      return '$addressLine, $city';
    }
    return '$addressLine, $trimmedArea, $city';
  }

  String get hoursLabel {
    if (is24Hours) {
      return 'Open 24 hours';
    }
    return '$openingTime - $closingTime';
  }

  factory Clinic.fromMap(Map<String, dynamic> map) {
    final rawServices = map['services'];
    final services = rawServices is List
        ? rawServices.map((item) => item.toString()).toList()
        : const <String>[];

    return Clinic(
      id: (map['id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      city: (map['city'] ?? '').toString(),
      area: (map['area'] ?? '').toString(),
      addressLine: (map['address_line'] ?? '').toString(),
      contactPhone: (map['contact_phone'] ?? '').toString(),
      emergencyPhone: (map['emergency_phone'] ?? '').toString(),
      openingTime: (map['opening_time'] ?? '').toString(),
      closingTime: (map['closing_time'] ?? '').toString(),
      services: services,
      about: (map['about'] ?? '').toString(),
      is24Hours: map['is_24_hours'] == true,
      isActive: map['is_active'] != false,
      createdAt: DateTime.tryParse((map['created_at'] ?? '').toString()),
    );
  }
}
