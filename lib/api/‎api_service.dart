import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../utils/shared_pref_util.dart';
import 'dart:async';
import '../models/infermedica_models.dart';
import 'mock_api_service.dart';

class ApiService {
  final Dio _dio = Dio();
  final Dio _infermedicaDio = Dio();
  final String baseUrl = AppConstants.baseUrl;
  final bool _useMockData = AppConstants.kUseMockData;

  ApiService() {
    // Setup for your app's backend API
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.responseType = ResponseType.json;

    // Setup for Infermedica API
    _infermedicaDio.options.baseUrl = "https://api.infermedica.com/v3";
    _infermedicaDio.options.connectTimeout = const Duration(seconds: 15);
    _infermedicaDio.options.receiveTimeout = const Duration(seconds: 15);
    _infermedicaDio.options.headers = {
      'App-Id': 'your_app_id',
      'App-Key': 'your_app_key',
      'Content-Type': 'application/json',
    };

    // Add interceptor for authentication token
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await SharedPrefUtil.getUserToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        options.headers['Content-Type'] = 'application/json';
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // Handle 401 Unauthorized errors
        if (e.response?.statusCode == 401) {
          // Implement token refresh or redirect to login
        }
        return handler.next(e);
      },
    ));
  }

  // Helper for error handling
  Map<String, dynamic> _handleError(DioException e) {
    String message = 'Something went wrong. Please try again.';

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      message =
          'Network error. Please check your connection. If using an emulator, this may be because the server is not running locally at ${_dio.options.baseUrl}';
    } else if (e.response != null) {
      // Server responded with error
      message = e.response?.data['message'] ?? message;
    }

    return {
      'success': false,
      'message': message,
    };
  }

  // User Authentication APIs

  // Register a new user
  Future<Map<String, dynamic>> registerUser(
      String name, String email, String password, String phone) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
      });
      return response.data;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // Login user
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      return response.data;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // Forgot password
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await _dio.post('/auth/forgot-password', data: {
        'email': email,
      });
      return response.data;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // Reset password
  Future<Map<String, dynamic>> resetPassword(
      String token, String password) async {
    try {
      final response = await _dio.post('/auth/reset-password', data: {
        'token': token,
        'password': password,
      });
      return response.data;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // Symptom Tracking APIs

  // Get user symptoms
  Future<List<dynamic>> getSymptoms() async {
    if (_useMockData) {
      return MockApiService.getSymptoms();
    }

    try {
      final response = await _dio.get('/symptoms');
      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get specific symptom by ID
  Future<Map<String, dynamic>> getSymptomById(String symptomId) async {
    try {
      final response = await _dio.get('/symptoms/$symptomId');
      return response.data['data'] ?? {};
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Add a new symptom
  Future<Map<String, dynamic>> addSymptom(
      Map<String, dynamic> symptomData) async {
    // Always use mock data for now
    return MockApiService.addSymptom(symptomData);
  }

  // Update a symptom
  Future<Map<String, dynamic>> updateSymptom(
      String symptomId, Map<String, dynamic> symptomData) async {
    try {
      final response =
          await _dio.put('/symptoms/$symptomId', data: symptomData);
      return response.data;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // Delete a symptom
  Future<Map<String, dynamic>> deleteSymptom(String symptomId) async {
    // Always use mock data for now
    return MockApiService.deleteSymptom(symptomId);
  }

  // Bloodwork Tracking APIs

  // Get user bloodwork
  Future<List<dynamic>> getBloodworks() async {
    if (_useMockData) {
      return MockApiService.getBloodworks();
    }

    try {
      final response = await _dio.get('/bloodwork');
      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get specific bloodwork by ID
  Future<Map<String, dynamic>> getBloodworkById(String bloodworkId) async {
    try {
      final response = await _dio.get('/bloodwork/$bloodworkId');
      return response.data['data'] ?? {};
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Add new bloodwork
  Future<Map<String, dynamic>> addBloodwork(
      Map<String, dynamic> bloodworkData) async {
    if (_useMockData) {
      return MockApiService.addBloodwork(bloodworkData);
    }

    try {
      final response = await _dio.post('/bloodwork', data: bloodworkData);
      return response.data;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // Update bloodwork
  Future<Map<String, dynamic>> updateBloodwork(
      String bloodworkId, Map<String, dynamic> bloodworkData) async {
    try {
      final response =
          await _dio.put('/bloodwork/$bloodworkId', data: bloodworkData);
      return response.data;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // Delete bloodwork
  Future<Map<String, dynamic>> deleteBloodwork(String bloodworkId) async {
    if (_useMockData) {
      return MockApiService.deleteBloodwork(bloodworkId);
    }

    try {
      final response = await _dio.delete('/bloodwork/$bloodworkId');
      return response.data;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // Infermedica API Methods

  // Get info about available conditions
  Future<List<InfermedicaCondition>> getConditions(
      {String language = 'en'}) async {
    try {
      final response =
          await _infermedicaDio.get('/conditions?language=$language');
      final List<dynamic> data = response.data;
      return data.map((json) => InfermedicaCondition.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get info about available symptoms
  Future<List<InfermedicaSymptom>> getInfermedicaSymptoms(
      {String language = 'en'}) async {
    // Always use mock data for now
    return MockApiService.getInfermedicaSymptoms();
  }

  // Get risk factors
  Future<List<InfermedicaRiskFactor>> getRiskFactors(
      {String language = 'en'}) async {
    try {
      final response =
          await _infermedicaDio.get('/risk_factors?language=$language');
      final List<dynamic> data = response.data;
      return data.map((json) => InfermedicaRiskFactor.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Analyze patient symptoms to suggest diagnosis
  Future<InfermedicaDiagnosisResponse> analyzeSymptoms(
      InfermedicaDiagnosisRequest request) async {
    try {
      final response =
          await _infermedicaDio.post('/diagnosis', data: request.toJson());
      return InfermedicaDiagnosisResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get next question to refine diagnosis
  Future<InfermedicaDiagnosisResponse> getNextQuestion(
      InfermedicaDiagnosisRequest request) async {
    try {
      final response =
          await _infermedicaDio.post('/diagnosis', data: request.toJson());
      return InfermedicaDiagnosisResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Explain diagnosis
  Future<Map<String, dynamic>> explainDiagnosis(String conditionId,
      {String language = 'en'}) async {
    try {
      final response = await _infermedicaDio
          .get('/explain?id=$conditionId&language=$language');
      return {
        'success': true,
        'data': response.data,
      };
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // User Profile APIs

  // Get user profile
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await _dio.get('/profile');
      return response.data;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // Update user profile
  Future<Map<String, dynamic>> updateUserProfile(
      Map<String, dynamic> profileData) async {
    try {
      final response = await _dio.put('/profile', data: profileData);
      return response.data;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // Health Metrics APIs

  // Get user health metrics
  Future<Map<String, dynamic>> getHealthMetrics() async {
    try {
      final response = await _dio.get('/health-metrics');
      return response.data;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // Add health metrics
  Future<Map<String, dynamic>> addHealthMetric(
      Map<String, dynamic> metricData) async {
    try {
      final response = await _dio.post('/health-metrics', data: metricData);
      return response.data;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // Add medication data
  Future<Map<String, dynamic>> addMedication(
      Map<String, dynamic> medicationData) async {
    try {
      final response = await _dio.post('/medications', data: medicationData);
      return response.data;
    } on DioException catch (e) {
      return _handleError(e);
    }
  }
}
