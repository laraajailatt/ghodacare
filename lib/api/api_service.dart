import 'package:ghodacare/models/infermedica_models.dart';

class ApiService {
  // This is a mock API service for demonstration purposes

  Future<Map<String, dynamic>> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock successful login
    return {
      'success': true,
      'user': {
        'id': '12345',
        'firstName': 'John',
        'lastName': 'Doe',
        'email': email,
      },
      'token': 'mock_token_12345'
    };
  }

  Future<Map<String, dynamic>> register(
      String firstName, String lastName, String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock successful registration
    return {
      'success': true,
      'user': {
        'id': '12345',
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
      }
    };
  }

  Future<List<Map<String, dynamic>>> getBloodworkHistory() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Return mock bloodwork history
    return [
      {
        'id': '1',
        'date': '2024-04-01',
        'tests': [
          {'name': 'TSH', 'value': '2.5', 'unit': 'mIU/L'},
          {'name': 'Free T4', 'value': '1.2', 'unit': 'ng/dL'},
          {'name': 'Free T3', 'value': '3.2', 'unit': 'pg/mL'}
        ]
      },
      {
        'id': '2',
        'date': '2024-03-01',
        'tests': [
          {'name': 'TSH', 'value': '3.8', 'unit': 'mIU/L'},
          {'name': 'Free T4', 'value': '1.0', 'unit': 'ng/dL'},
          {'name': 'Free T3', 'value': '2.8', 'unit': 'pg/mL'}
        ]
      },
      {
        'id': '3',
        'date': '2024-02-01',
        'tests': [
          {'name': 'TSH', 'value': '4.5', 'unit': 'mIU/L'},
          {'name': 'Free T4', 'value': '0.9', 'unit': 'ng/dL'},
          {'name': 'Free T3', 'value': '2.5', 'unit': 'pg/mL'}
        ]
      }
    ];
  }

  Future<Map<String, dynamic>> addBloodwork(
      Map<String, dynamic> bloodworkData) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock successful addition
    return {'success': true, 'id': '${DateTime.now().millisecondsSinceEpoch}'};
  }

  Future<List<Map<String, dynamic>>> getSymptoms() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Return mock symptoms
    return [
      {
        'id': '1',
        'date': '2024-04-02',
        'description': 'Fatigue and tiredness',
        'severity': 'Moderate',
        'duration': '2 days',
        'triggers': ['Stress', 'Poor Sleep'],
        'time_of_day': 'Morning',
        'notes': 'Felt more tired than usual, especially in the afternoon',
        'has_family_thyroid_history': true,
        'family_members_with_thyroid': ['Mother', 'Grandparent']
      },
      {
        'id': '2',
        'date': '2024-03-28',
        'description': 'Weight gain',
        'severity': 'Mild',
        'duration': '1 week',
        'triggers': ['Diet'],
        'time_of_day': 'All day',
        'notes': 'Gained 2kg over the past week'
      },
      {
        'id': '3',
        'date': '2024-03-20',
        'description': 'Cold sensitivity',
        'severity': 'Severe',
        'duration': '3 days',
        'triggers': ['Weather'],
        'time_of_day': 'Evening',
        'notes': 'Feeling extremely cold even in warm weather',
        'has_family_thyroid_history': true,
        'family_members_with_thyroid': ['Father', 'Sibling']
      }
    ];
  }

  Future<Map<String, dynamic>> addSymptom(
      Map<String, dynamic> symptomData) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock successful addition
    return {'success': true, 'id': '${DateTime.now().millisecondsSinceEpoch}'};
  }

  Future<Map<String, dynamic>> saveToCache(String key, dynamic data) async {
    // Simulate cache save
    await Future.delayed(const Duration(milliseconds: 300));
    return {'success': true};
  }

  Future<dynamic> loadFromCache(String key) async {
    // Simulate cache load
    await Future.delayed(const Duration(milliseconds: 300));
    return null; // Indicate no cached data
  }

  // Alias for getBloodworkHistory - used by add_bloodwork_screen.dart
  Future<List<Map<String, dynamic>>> getBloodworks() async {
    return getBloodworkHistory();
  }

  Future<Map<String, dynamic>> getBloodworkById(String id) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Sample bloodwork data based on ID
    final bloodworkData = {
      'id': id,
      'date': '2024-04-01',
      'tests': [
        {'name': 'TSH', 'value': '2.5', 'unit': 'mIU/L'},
        {'name': 'Free T4', 'value': '1.2', 'unit': 'ng/dL'},
        {'name': 'Free T3', 'value': '3.2', 'unit': 'pg/mL'}
      ],
      'notes': 'Regular check-up bloodwork',
      'labName': 'Central Lab'
    };

    return bloodworkData;
  }

  Future<Map<String, dynamic>> deleteBloodwork(String id) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock successful deletion
    return {'success': true, 'message': 'Bloodwork deleted successfully'};
  }

  Future<List<InfermedicaSymptom>> getInfermedicaSymptoms() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Return mock symptom data
    List<Map<String, dynamic>> rawData = [
      {'id': 's1', 'name': 'Fatigue', 'common_name': 'Fatigue'},
      {'id': 's2', 'name': 'Weight gain', 'common_name': 'Weight gain'},
      {'id': 's3', 'name': 'Cold sensitivity', 'common_name': 'Feeling cold'},
      {'id': 's4', 'name': 'Dry skin', 'common_name': 'Dry skin'},
      {'id': 's5', 'name': 'Hair loss', 'common_name': 'Hair loss'},
      {'id': 's6', 'name': 'Constipation', 'common_name': 'Constipation'},
      {'id': 's7', 'name': 'Depression', 'common_name': 'Depression'},
      {'id': 's8', 'name': 'Muscle weakness', 'common_name': 'Muscle weakness'},
      {'id': 's9', 'name': 'Memory problems', 'common_name': 'Memory problems'},
      {
        'id': 's10',
        'name': 'Elevated heart rate',
        'common_name': 'Fast heartbeat'
      },
    ];

    return rawData.map((data) => InfermedicaSymptom.fromJson(data)).toList();
  }

  Future<Map<String, dynamic>> addHealthMetric(
      Map<String, dynamic> metricsData) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock successful addition
    return {
      'success': true,
      'id': '${DateTime.now().millisecondsSinceEpoch}',
      'message': 'Health metrics added successfully'
    };
  }

  Future<Map<String, dynamic>> addMedication(
      Map<String, dynamic> medicationData) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock successful addition
    return {
      'success': true,
      'id': '${DateTime.now().millisecondsSinceEpoch}',
      'message': 'Medication added successfully'
    };
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock user profile data - always returns success for demo
    return {
      'success': true,
      'profile': {
        'id': '12345',
        'firstName': 'John',
        'lastName': 'Doe',
        'email': 'john.doe@example.com',
        'phone': '+1 (555) 123-4567',
        'dateOfBirth': '01/15/1985',
        'gender': 'Male',
        'medicalConditions': ['Hypothyroidism'],
        'medications': ['Levothyroxine']
      }
    };
  }

  Future<Map<String, dynamic>> updateUserProfile(
      Map<String, dynamic> profileData) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock successful update
    return {'success': true, 'message': 'Profile updated successfully'};
  }

  Future<Map<String, dynamic>> getSymptomById(String symptomId) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Sample symptom data based on ID
    return {
      'success': true,
      'symptom': {
        'id': symptomId,
        'date': '2024-04-02',
        'description': 'Fatigue and tiredness',
        'severity': 'Moderate',
        'duration': '2 days',
        'notes': 'Felt more tired than usual, especially in the afternoon',
        'has_family_thyroid_history': true,
        'family_members_with_thyroid': ['Mother', 'Father']
      }
    };
  }

  Future<Map<String, dynamic>> deleteSymptom(String symptomId) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock successful deletion
    return {'success': true, 'message': 'Symptom deleted successfully'};
  }
}
