class Category {
  final int id;
  final String name;
  final int? parentId;
  final String? iconUrl;
  final List<Category>? children;

  Category({
    required this.id,
    required this.name,
    this.parentId,
    this.iconUrl,
    this.children,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: int.parse(json['id'].toString()),
      name: json['name'],
      parentId: json['parent_id'] != null ? int.parse(json['parent_id'].toString()) : null,
      iconUrl: json['icon_url'],
      children: json['children'] != null
          ? (json['children'] as List)
              .map((category) => Category.fromJson(category))
              .toList()
          : null,
    );
  }
}
