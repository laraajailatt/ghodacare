import 'dart:async';
import '../models/infermedica_models.dart';

class MockApiService {
  // Simulate API delay
  static const _simulatedDelay = Duration(milliseconds: 800);

  // Get user symptoms - mock data
  static Future<List<dynamic>> getSymptoms() async {
    await Future.delayed(_simulatedDelay);
    return [];
  }

  // Get user bloodwork - mock data
  static Future<List<dynamic>> getBloodworks() async {
    await Future.delayed(_simulatedDelay);
    return [];
  }

  // Add a new symptom - mock data
  static Future<Map<String, dynamic>> addSymptom(
      Map<String, dynamic> symptomData) async {
    await Future.delayed(_simulatedDelay);

    // Create a fake ID for the new symptom
    final symptomId = 'symptom_${DateTime.now().millisecondsSinceEpoch}';

    return {
      'success': true,
      'message': 'Symptom added successfully',
      'data': {
        'id': symptomId,
        ...symptomData,
        'created_at': DateTime.now().toIso8601String(),
      }
    };
  }

  // Add new bloodwork - mock data
  static Future<Map<String, dynamic>> addBloodwork(
      Map<String, dynamic> bloodworkData) async {
    await Future.delayed(_simulatedDelay);

    // Create a fake ID for the new bloodwork
    final bloodworkId = 'bloodwork_${DateTime.now().millisecondsSinceEpoch}';

    return {
      'success': true,
      'message': 'Bloodwork added successfully',
      'data': {
        'id': bloodworkId,
        ...bloodworkData,
        'created_at': DateTime.now().toIso8601String(),
      }
    };
  }

  // Delete a symptom - mock data
  static Future<Map<String, dynamic>> deleteSymptom(String symptomId) async {
    await Future.delayed(_simulatedDelay);

    return {
      'success': true,
      'message': 'Symptom deleted successfully',
    };
  }

  // Delete bloodwork - mock data
  static Future<Map<String, dynamic>> deleteBloodwork(
      String bloodworkId) async {
    await Future.delayed(_simulatedDelay);

    return {
      'success': true,
      'message': 'Bloodwork deleted successfully',
    };
  }

  // Get user health metrics - mock data
  static Future<Map<String, dynamic>> getHealthMetrics() async {
    await Future.delayed(_simulatedDelay);

    return {
      'success': true,
      'data': {
        'metrics': [],
      }
    };
  }

  // Add health metrics - mock data
  static Future<Map<String, dynamic>> addHealthMetric(
      Map<String, dynamic> metricData) async {
    await Future.delayed(_simulatedDelay);

    // Create a fake ID for the new health metric
    final metricId = 'metric_${DateTime.now().millisecondsSinceEpoch}';

    return {
      'success': true,
      'message': 'Health metric added successfully',
      'data': {
        'id': metricId,
        ...metricData,
        'created_at': DateTime.now().toIso8601String(),
      }
    };
  }

  // Add medication data - mock data
  static Future<Map<String, dynamic>> addMedication(
      Map<String, dynamic> medicationData) async {
    await Future.delayed(_simulatedDelay);

    // Create a fake ID for the new medication
    final medicationId = 'medication_${DateTime.now().millisecondsSinceEpoch}';

    return {
      'success': true,
      'message': 'Medication added successfully',
      'data': {
        'id': medicationId,
        ...medicationData,
        'created_at': DateTime.now().toIso8601String(),
      }
    };
  }

  // Get user profile - mock data
  static Future<Map<String, dynamic>> getUserProfile() async {
    await Future.delayed(_simulatedDelay);

    return {
      'success': true,
      'data': {
        'name': 'Demo User',
        'email': 'demo@example.com',
        'height': '170',
        'weight': '70',
        'birth_date': '1990-01-01',
      }
    };
  }

  // Update user profile - mock data
  static Future<Map<String, dynamic>> updateUserProfile(
      Map<String, dynamic> profileData) async {
    await Future.delayed(_simulatedDelay);

    return {
      'success': true,
      'message': 'Profile updated successfully',
      'data': profileData,
    };
  }

  // Get Infermedica symptoms (sample data)
  static Future<List<InfermedicaSymptom>> getInfermedicaSymptoms() async {
    await Future.delayed(_simulatedDelay);

    return [
      InfermedicaSymptom(id: 's_1', name: 'Headache', commonName: 'Headache'),
      InfermedicaSymptom(id: 's_2', name: 'Fever', commonName: 'Fever'),
      InfermedicaSymptom(id: 's_3', name: 'Cough', commonName: 'Cough'),
      InfermedicaSymptom(
          id: 's_4',
          name: 'Shortness of breath',
          commonName: 'Shortness of breath'),
      InfermedicaSymptom(id: 's_5', name: 'Fatigue', commonName: 'Fatigue'),
      InfermedicaSymptom(
          id: 's_6', name: 'Abdominal pain', commonName: 'Abdominal pain'),
    ];
  }
}
