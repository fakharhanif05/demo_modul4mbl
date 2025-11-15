// ============ service_provider_http.dart ============
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/service_model.dart';

class ServiceProviderHttp {
  static const String baseUrl = 'https://68fc985496f6ff19b9f5a39b.mockapi.io/api/v1';

  Future<List<ServiceModel>> getServices() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/service'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => ServiceModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load services: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching services: $e');
    }
  }

  Future<ServiceModel> getServiceById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/service/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ServiceModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to load service: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching service: $e');
    }
  }
}