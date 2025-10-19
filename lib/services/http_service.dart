import 'package:dio/dio.dart';
import 'dart:convert';
import '../utils/constants.dart';

/// HTTP Service for direct communication with ESP32
class HttpService {
  static HttpService? _instance;
  late Dio _dio;
  
  HttpService._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.espBaseUrl,
        connectTimeout: AppConstants.apiTimeout,
        receiveTimeout: AppConstants.apiTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    
    // Add interceptors
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }
  
  /// Get singleton instance
  static HttpService get instance {
    _instance ??= HttpService._();
    return _instance!;
  }
  
  /// Get Dio instance
  Dio get dio => _dio;
  
  // ========== Generic HTTP Methods ==========
  
  /// GET request
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// POST request
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// PUT request
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// DELETE request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // ========== Door Control Methods ==========
  
  /// Open door
  Future<Map<String, dynamic>> openDoor({
    String? doorId,
    int duration = 3000,
  }) async {
    return await post(
      AppConstants.endpointDoorOpen,
      data: {
        'door_id': doorId,
        'duration': duration,
        'command': 'open',
      },
    );
  }
  
  /// Close door
  Future<Map<String, dynamic>> closeDoor({String? doorId}) async {
    return await post(
      AppConstants.endpointDoorClose,
      data: {
        'door_id': doorId,
        'command': 'close',
      },
    );
  }
  
  /// Get door status
  Future<Map<String, dynamic>> getDoorStatus({String? doorId}) async {
    return await get(
      AppConstants.endpointDoorStatus,
      queryParameters: doorId != null ? {'door_id': doorId} : null,
    );
  }
  
  // ========== Configuration Methods ==========
  
  /// Get ESP32 configuration
  Future<Map<String, dynamic>> getConfig() async {
    return await get(AppConstants.endpointConfig);
  }
  
  /// Update ESP32 configuration
  Future<Map<String, dynamic>> updateConfig(
    Map<String, dynamic> config,
  ) async {
    return await post(
      AppConstants.endpointConfig,
      data: config,
    );
  }
  
  /// Set device base URL (for switching between devices)
  void setBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }
  
  /// Get current base URL
  String get baseUrl => _dio.options.baseUrl;
  
  // ========== Custom Endpoints ==========
  
  /// Generic custom request
  Future<Map<String, dynamic>> customRequest({
    required String method,
    required String endpoint,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.request(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: Options(method: method),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // ========== Error Handling ==========
  
  Exception _handleError(DioException e) {
    String message;
    
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = AppConstants.errorTimeout;
        break;
      
      case DioExceptionType.badResponse:
        message = 'Server error: ${e.response?.statusCode}';
        break;
      
      case DioExceptionType.cancel:
        message = 'Request cancelled';
        break;
      
      default:
        message = AppConstants.errorNetworkConnection;
    }
    
    return Exception(message);
  }
}
