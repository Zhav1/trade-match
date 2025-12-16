import 'package:flutter/foundation.dart' hide Category;
import 'package:trade_match/models/user.dart';
import 'package:trade_match/models/category.dart';
import 'package:trade_match/models/item_image.dart';
import 'package:trade_match/models/item_want.dart';

class BarterItem {
  final int id;
  final String title;
  final String description;
  final String condition;
  final double? estimatedValue;
  final String currency;
  final String locationCity;
  final double locationLat;
  final double locationLon;
  final String wantsDescription;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User user;
  final Category category;
  final List<ItemImage> images;
  final List<ItemWant> wants;

  BarterItem({
    required this.id,
    required this.title,
    required this.description,
    required this.condition,
    this.estimatedValue,
    required this.currency,
    required this.locationCity,
    required this.locationLat,
    required this.locationLon,
    required this.wantsDescription,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    required this.category,
    required this.images,
    required this.wants,
  });

  factory BarterItem.fromJson(Map<String, dynamic> json) {
    return BarterItem(
      id: int.parse(json['id'].toString()),
      title: json['title'],
      description: json['description'],
      condition: json['condition'],
      estimatedValue: json['estimated_value'] != null ? double.parse(json['estimated_value'].toString()) : null,
      currency: json['currency'],
      locationCity: json['location_city'],
      locationLat: double.parse(json['location_lat'].toString()),
      locationLon: double.parse(json['location_lon'].toString()),
      wantsDescription: json['wants_description'] ?? '',
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      user: User.fromJson(json['user']),
      category: Category.fromJson(json['category']),
      images: (json['images'] as List<dynamic>)
          .map((imageJson) => ItemImage.fromJson(imageJson))
          .toList(),
      wants: (json['wants'] as List<dynamic>)
          .map((wantJson) => ItemWant.fromJson(wantJson))
          .toList(),
    );
  }
}

class BarterMatch {
  final int id;
  final int itemAId;
  final int itemBId;
  final String status;
  final bool itemAOwnerConfirmed;
  final bool itemBOwnerConfirmed;
  final BarterItem itemA;
  final BarterItem itemB;
  final ChatMessage? latestMessage;
  final DateTime updatedAt;

  BarterMatch({
    required this.id,
    required this.itemAId,
    required this.itemBId,
    required this.status,
    required this.itemAOwnerConfirmed,
    required this.itemBOwnerConfirmed,
    required this.itemA,
    required this.itemB,
    this.latestMessage,
    required this.updatedAt,
  });

  factory BarterMatch.fromJson(Map<String, dynamic> json) {
    return BarterMatch(
      id: json['id'],
      itemAId: json['item_a_id'],
      itemBId: json['item_b_id'],
      status: json['status'] ?? 'active',
      itemAOwnerConfirmed: json['item_a_owner_confirmed'] == 1 || json['item_a_owner_confirmed'] == true,
      itemBOwnerConfirmed: json['item_b_owner_confirmed'] == 1 || json['item_b_owner_confirmed'] == true,
      itemA: BarterItem.fromJson(json['item_a']),
      itemB: BarterItem.fromJson(json['item_b']),
      latestMessage: json['latest_message'] != null 
          ? ChatMessage.fromJson(json['latest_message']) 
          : null,
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

/// Simple model for chat message preview in swap list
class ChatMessage {
  final int id;
  final String messageText;
  final String type;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.messageText,
    required this.type,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      messageText: json['message_text'] ?? '',
      type: json['type'] ?? 'text',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}