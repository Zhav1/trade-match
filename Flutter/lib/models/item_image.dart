class ItemImage {
  final int id;
  final int itemId;
  final String imageUrl;
  final int sortOrder;

  ItemImage({
    required this.id,
    required this.itemId,
    required this.imageUrl,
    required this.sortOrder,
  });

  factory ItemImage.fromJson(Map<String, dynamic> json) {
    return ItemImage(
      id: int.parse(json['id'].toString()),
      itemId: int.parse(json['item_id'].toString()),
      imageUrl: json['image_url'] ?? '',
      // Supabase uses 'display_order', fallback to 'sort_order' for compatibility
      sortOrder: int.tryParse((json['display_order'] ?? json['sort_order'] ?? 0).toString()) ?? 0,
    );
  }
}
