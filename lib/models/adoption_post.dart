class AdoptionPost {
  const AdoptionPost({
    required this.id,
    required this.userId,
    required this.petType,
    required this.petName,
    required this.breed,
    required this.age,
    required this.vaccinated,
    required this.aboutPet,
    required this.city,
    required this.nearbyArea,
    required this.status,
    required this.contactName,
    required this.contactPhone,
    required this.contactEmail,
    required this.createdAt,
    this.photoUrls = const [],
  });

  final String id;
  final String userId;
  final String petType;
  final String petName;
  final String breed;
  final String age;
  final String vaccinated;
  final String aboutPet;
  final String city;
  final String nearbyArea;
  final String status;
  final String contactName;
  final String contactPhone;
  final String contactEmail;
  final DateTime? createdAt;
  final List<String> photoUrls;

  factory AdoptionPost.fromMap(Map<String, dynamic> map) {
    final urls = (map['photo_urls'] as List?)
            ?.map((item) => item.toString())
            .toList() ??
        const <String>[];

    return AdoptionPost(
      id: (map['id'] ?? '').toString(),
      userId: (map['user_id'] ?? '').toString(),
      petType: (map['pet_type'] ?? '').toString(),
      petName: (map['pet_name'] ?? '').toString(),
      breed: (map['breed'] ?? '').toString(),
      age: (map['age'] ?? '').toString(),
      vaccinated: (map['vaccinated'] ?? '').toString(),
      aboutPet: (map['about_pet'] ?? '').toString(),
      city: (map['city'] ?? '').toString(),
      nearbyArea: (map['nearby_area'] ?? '').toString(),
      status: (map['status'] ?? 'under_review').toString(),
      contactName: (map['contact_name'] ?? '').toString(),
      contactPhone: (map['contact_phone'] ?? '').toString(),
      contactEmail: (map['contact_email'] ?? '').toString(),
      createdAt: DateTime.tryParse((map['created_at'] ?? '').toString()),
      photoUrls: urls,
    );
  }
}

