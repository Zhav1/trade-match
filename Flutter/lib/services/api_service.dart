import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:trade_match/models/item.dart';
import 'package:trade_match/models/category.dart';
import 'package:trade_match/models/barter_item.dart' hide Category;
import 'constants.dart';

class ApiService {
  Future<List<BarterMatch>> getSwaps() async {
    final response = await http.get(
      Uri.parse('$API_BASE/api/swaps'),
      headers: {
        'Authorization': 'Bearer $AUTH_TOKEN',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body)['swaps'];
      List<BarterMatch> swaps = body.map((dynamic item) => BarterMatch.fromJson(item)).toList();
      return swaps;
    } else {
      throw Exception('Failed to load swaps');
    }
  }

  Future<List<BarterItem>> getExploreItems() async {
    final response = await http.get(
      Uri.parse('$API_BASE/api/explore'),
      headers: {
        'Authorization': 'Bearer $AUTH_TOKEN',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body)['items'];
      return body.map((dynamic item) => BarterItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load explore items');
    }
  }

  Future<List<BarterItem>> getLikes() async {
    // Assuming an endpoint for likes exists or using a placeholder
    // If no endpoint, we might return empty or mock
    // For now, let's assume GET /api/likes exists
    final response = await http.get(
      Uri.parse('$API_BASE/api/likes'),
      headers: {
        'Authorization': 'Bearer $AUTH_TOKEN',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body)['likes'];
      return body.map((dynamic item) => BarterItem.fromJson(item)).toList();
    } else {
      // Fallback to empty list if endpoint doesn't exist yet
      return []; 
    }
  }

  Future<List<Category>> getCategories() async {
    final response = await http.get(
      Uri.parse('$API_BASE/api/categories'),
      headers: {
        'Authorization': 'Bearer $AUTH_TOKEN',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body)['categories'];
      List<Category> categories = body.map((dynamic item) => Category.fromJson(item)).toList();
      return categories;
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<String> uploadImage(File imageFile) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$API_BASE/api/upload/image'),
    );
    request.headers['Authorization'] = 'Bearer $AUTH_TOKEN';
    request.headers['Accept'] = 'application/json';
    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      ),
    );

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      return jsonDecode(responseBody)['url'];
    } else {
      throw Exception('Failed to upload image');
    }
  }

  Future<Item> createItem(Map<String, dynamic> itemData) async {
    final response = await http.post(
      Uri.parse('$API_BASE/api/items'),
      headers: {
        'Authorization': 'Bearer $AUTH_TOKEN',
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: jsonEncode(itemData),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 201) {
      return Item.fromJson(jsonDecode(response.body)['item']);
    } else {
      throw Exception('Failed to create item');
    }
  }

  Future<Item> updateItem(int id, Map<String, dynamic> itemData) async {
    final response = await http.put(
      Uri.parse('$API_BASE/api/items/\$id'),
      headers: {
        'Authorization': 'Bearer $AUTH_TOKEN',
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: jsonEncode(itemData),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return Item.fromJson(jsonDecode(response.body)['item']);
    } else {
      throw Exception('Failed to update item: \${response.body}');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$API_BASE/api/login'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': password}),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<List<Item>> getUserItems() async {
    final response = await http.get(
      Uri.parse('$API_BASE/api/items'),
      headers: {
        'Authorization': 'Bearer $AUTH_TOKEN',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body)['items'];
      return body.map((dynamic item) => Item.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load items');
    }
  }

  Future<void> deleteItem(int id) async {
    final response = await http.delete(
      Uri.parse('$API_BASE/api/items/\$id'),
      headers: {
        'Authorization': 'Bearer $AUTH_TOKEN',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to delete item');
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String phone, String password) async {
    print('Attempting to register user: $email');
    try {
      final response = await http.post(
        Uri.parse('$API_BASE/api/register'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'password_confirmation': password
        }),
      ).timeout(const Duration(seconds: 10));

      print('Register response status: ${response.statusCode}');
      print('Register response body: ${response.body}');

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to register: ${response.body}');
      }
    } catch (e) {
      print('Register error: $e');
      rethrow;
    }
  }

  Future<void> swipe(int swiperItemId, int swipedOnItemId, String action) async {
    final response = await http.post(
      Uri.parse('$API_BASE/api/swipe'),
      headers: {
        'Authorization': 'Bearer $AUTH_TOKEN',
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'swiper_item_id': swiperItemId,
        'swiped_on_item_id': swipedOnItemId,
        'action': action,
      }),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Failed to swipe');
    }
  }
  final _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
    AUTH_TOKEN = token;
  }

  Future<String?> getToken() async {
    final token = await _storage.read(key: 'auth_token');
    if (token != null) {
      AUTH_TOKEN = token;
    }
    return token;
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
    AUTH_TOKEN = '';
  }

  Future<Map<String, dynamic>> getUser() async {
    final response = await http.get(
      Uri.parse('$API_BASE/api/user'),
      headers: {
        'Authorization': 'Bearer $AUTH_TOKEN',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get user');
    }
  }

  Future<Map<String, dynamic>> googleLogin(String idToken) async {
    print('Attempting Google Login with token: ${idToken.substring(0, 10)}...');
    try {
      final response = await http.post(
        Uri.parse('$API_BASE/api/auth/google'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode({'id_token': idToken}),
      ).timeout(const Duration(seconds: 10));

      print('Google Login response status: ${response.statusCode}');
      print('Google Login response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to login with Google: ${response.body}');
      }
    } catch (e) {
      print('Google Login error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> googleRegister(String idToken) async {
    print('Attempting Google Registration with token: ${idToken.substring(0, 10)}...');
    try {
      final response = await http.post(
        Uri.parse('$API_BASE/api/auth/google/register'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode({'id_token': idToken}),
      ).timeout(const Duration(seconds: 10));

      print('Google Register response status: ${response.statusCode}');
      print('Google Register response body: ${response.body}');

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 409) {
        throw Exception('User already exists. Please login instead.');
      } else {
        throw Exception('Failed to register with Google: ${response.body}');
      }
    } catch (e) {
      print('Google Register error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('$API_BASE/api/logout'),
        headers: {
          'Authorization': 'Bearer $AUTH_TOKEN',
          'Accept': 'application/json',
        },
      );
    } catch (e) {
      // Ignore errors on logout
    }
    await deleteToken();
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$API_BASE/api/user/profile'),
      headers: {
        'Authorization': 'Bearer $AUTH_TOKEN',
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: jsonEncode(data),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update profile');
    }
  }

  Future<Map<String, dynamic>> uploadProfilePicture(File imageFile) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$API_BASE/api/user/profile-picture'),
    );
    request.headers['Authorization'] = 'Bearer $AUTH_TOKEN';
    request.headers['Accept'] = 'application/json';
    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      ),
    );

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      return jsonDecode(responseBody);
    } else {
      throw Exception('Failed to upload profile picture');
    }
  }
}
