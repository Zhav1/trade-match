class BarterItem {
  final String namaBarang;
  final String kondisi;
  final String namaUser;
  final String imageUrl;
  final String jarak;
  final String description;
  final String estimatedValue;
  final List<String> lookingFor;
  final String location;
  final String memberSince;
  final double rating;

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
}