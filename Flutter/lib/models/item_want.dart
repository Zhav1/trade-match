import 'package:trade_match/models/category.dart';

class ItemWant {
  final int id;
  final int itemId;
  final int wantedCategoryId;
  final Category? category;

  ItemWant({
    required this.id,
    required this.itemId,
    required this.wantedCategoryId,
    this.category,
  });

  factory ItemWant.fromJson(Map<String, dynamic> json) {
    return ItemWant(
      id: int.parse(json['id'].toString()),
      itemId: int.parse(json['item_id'].toString()),
      wantedCategoryId: int.parse(json['wanted_category_id'].toString()),
      category: json['category'] != null
          ? Category.fromJson(json['category'])
          : null,
    );
  }
}
