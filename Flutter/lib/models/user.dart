class User {
  final int id;
  final String name;
  final String email;
  final String? profilePhotoUrl; // Kept for backward compatibility
  final String? location; // Kept for backward compatibility
  final double? averageRating; // Kept for backward compatibility
  
  // Fields from BarterItem's User
  final String? profilePictureUrl;
  final String? defaultLocationCity;
  final double? defaultLat;
  final double? defaultLon;
  final double? rating;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profilePhotoUrl,
    this.location,
    this.averageRating,
    this.profilePictureUrl,
    this.defaultLocationCity,
    this.defaultLat,
    this.defaultLon,
    this.rating,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: int.parse(json['id'].toString()),
      name: json['name'],
      email: json['email'],
      profilePhotoUrl: json['profile_photo_url'],
      location: json['location'],
      averageRating: json['average_rating'] != null ? double.tryParse(json['average_rating'].toString()) : null,
      profilePictureUrl: json['profile_picture_url'],
      defaultLocationCity: json['default_location_city'],
      defaultLat: json['default_lat'] != null ? double.tryParse(json['default_lat'].toString()) : null,
      defaultLon: json['default_lon'] != null ? double.tryParse(json['default_lon'].toString()) : null,
      rating: json['rating'] != null ? double.tryParse(json['rating'].toString()) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }
}
