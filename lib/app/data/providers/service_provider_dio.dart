
// ============ service_provider_dio.dart ============
import 'package:dio/dio.dart';
import '../models/service_model.dart';

class ServiceProviderDio {
  static const String baseUrl = 'https://68fc985496f6ff19b9f5a39b.mockapi.io/api/v1';
  
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Future<List<ServiceModel>> getServices() async {
    try {
      final response = await _dio.get('/service');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = response.data;
        return jsonData.map((json) => ServiceModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load services: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Receive timeout');
      } else {
        throw Exception('Error fetching services: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<ServiceModel> getServiceById(String id) async {
    try {
      final response = await _dio.get('/service/$id');

      if (response.statusCode == 200) {
        return ServiceModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load service: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Receive timeout');
      } else {
        throw Exception('Error fetching service: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}