class BarterItem {
  String namaBarang;
  String kondisi;
  String namaUser;
  String imageUrl;
  String jarak;
  String description;
  String estimatedValue;
  List<String> lookingFor;
  String location;
  String memberSince;
  double rating;

  BarterItem({
    required this.namaBarang,
    required this.kondisi,
    required this.namaUser,
    required this.imageUrl,
    required this.jarak,
    this.description = '',
    this.estimatedValue = '',
    this.lookingFor = const [],
    this.location = '',
    this.memberSince = '',
    this.rating = 0.0,
  });

  factory BarterItem.fromJson(Map<String, dynamic> json) {
    return BarterItem(
      namaBarang: json['title'] ?? '',
      kondisi: json['condition'] ?? '',
      namaUser: json['userName'] ?? '',
      imageUrl: (json['images'] as List).isNotEmpty ? json['images'][0] : '',
      jarak: json['distance']?.toString() ?? 'N/A', // Assuming distance is provided
      description: json['description'] ?? '',
      estimatedValue: json['estimatedValue']?.toString() ?? '',
      lookingFor: (json['preferredItems'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      location: json['location'] ?? '',
      memberSince: json['user']?['memberSince'] ?? '', // Assuming nested user object
      rating: (json['user']?['rating'] as num?)?.toDouble() ?? 0.0, // Assuming nested user object
    );
  }
}