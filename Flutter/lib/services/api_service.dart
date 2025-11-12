import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/barter_item.dart';
import 'constants.dart';

class ApiService {
  Future<List<BarterItem>> getFeed() async {
    final response = await http.get(
      Uri.parse('$API_BASE/api/explore'),
      headers: {
        'Authorization': 'Bearer $AUTH_TOKEN',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<BarterItem> items = body.map((dynamic item) => BarterItem.fromJson(item)).toList();
      return items;
    } else {
      throw Exception('Failed to load items');
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
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String phone, String password) async {
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
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to register');
    }
  }
}

