import 'package:flutter/material.dart';
import 'package:app_ghoda/api/api_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  bool _showIntroScreen = true;
  
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _notesController = TextEditingController();
  final _apiService = ApiService();
  
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  
  bool _isLoading = false;
  TimeOfDay _selectedTime = TimeOfDay.now();
  
  final List<String> _selectedDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  final List<String> _dayOptions = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  String _frequency = 'Daily';
  final List<String> _frequencyOptions = ['Daily', 'Weekly', 'As Needed'];
  
  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }
  
  Future<void> _initializeNotifications() async {
    tz_data.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }
  
  Future<void> _scheduleNotification(String medicationName, TimeOfDay time, List<String> days) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'medication_channel',
      'Medication Reminders',
      channelDescription: 'Channel for medication reminders',
      importance: Importance.max,
      priority: Priority.high,
    );
    
    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);
    
    // Schedule notifications for selected days
    for (String day in days) {
      int dayIndex = _dayOptions.indexOf(day);
      if (dayIndex != -1) {
        DateTime now = DateTime.now();
        DateTime scheduledDate = _getNextDayOfWeek(now, dayIndex + 1); // +1 because Monday is 1, Sunday is 7
        scheduledDate = DateTime(
          scheduledDate.year, 
          scheduledDate.month, 
          scheduledDate.day, 
          time.hour, 
          time.minute
        );
        
        if (scheduledDate.isBefore(now)) {
          scheduledDate = scheduledDate.add(const Duration(days: 7));
        }
        
        await flutterLocalNotificationsPlugin.zonedSchedule(
          dayIndex,
          'Medication Reminder',
          'Time to take your $medicationName',
          tz.TZDateTime.from(scheduledDate, tz.local),
          platformDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
    }
  }
  
  DateTime _getNextDayOfWeek(DateTime date, int dayOfWeek) {
    return date.add(Duration(days: (dayOfWeek - date.weekday) % 7));
  }
  
  
  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _instructionsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _addMedication() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare data for API request
      final medicationData = {
        'name': _nameController.text.trim(),
        'dosage': _dosageController.text.trim(),
        'frequency': _frequency,
        'time': '${_selectedTime.hour}:${_selectedTime.minute}',
        'days': _selectedDays,
        'instructions': _instructionsController.text.trim(),
        'notes': _notesController.text.trim(),
      };

      final response = await _apiService.addMedication(medicationData);

      // Schedule notifications
      try {
        await _scheduleNotification(
          _nameController.text.trim(),
          _selectedTime,
          _selectedDays,
        );
      } catch (notificationError) {
        // Handle notification scheduling error silently
      }

      setState(() {
        _isLoading = false;
      });

      if (response['success'] == true) {
        if (!mounted) return;
        
        // Show success message and go back
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medication added successfully! Reminders have been set.'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.of(context).pop();
      } else {
        if (!mounted) return;
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to add medication. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add medication: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showIntroScreen) {
      return _buildIntroScreen();
    }
    
    return _buildMedicationForm();
  }
  
  Widget _buildIntroScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: Colors.black87,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Medication image
              Expanded(
                child: Stack(
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/images/medicationicon.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.medication,
                            size: 150,
                            color: Colors.purple.withOpacity(0.2),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Title
              const Text(
                'Medication Tracker',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Feature list
              _buildFeatureItem(Icons.alarm, 'Get reminders when it\'s time to take your medications'),
              const SizedBox(height: 16),
              _buildFeatureItem(Icons.calendar_today, 'Set custom schedules for different days of the week'),
              const SizedBox(height: 16),
              _buildFeatureItem(Icons.history, 'Track your medication history and adherence'),
              
              const SizedBox(height: 32),
              
              // Add Medication button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showIntroScreen = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF814CEB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Add Medication',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFE8E7F7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF814CEB),
            size: 18,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildMedicationForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            setState(() {
              _showIntroScreen = true;
            });
          },
        ),
        title: const Text(
          'Add Medication',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Medication Name Card
            _buildSectionCard(
              title: 'Medication Name',
              color: const Color(0xFFE8E7F7),
              child: TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter medication name',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(16),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter medication name';
                  }
                  return null;
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Dosage Card
            _buildSectionCard(
              title: 'Dosage',
              color: const Color(0xFFE0F5F3),
              child: TextFormField(
                controller: _dosageController,
                decoration: InputDecoration(
                  hintText: 'e.g., 50mg, 1 tablet, 2 pills',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(16),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter dosage';
                  }
                  return null;
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Frequency Card
            _buildSectionCard(
              title: 'Frequency',
              color: const Color(0xFFFFF1F1),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _frequencyOptions.map((frequency) {
                  return ChoiceChip(
                    label: Text(frequency),
                    selected: _frequency == frequency,
                    selectedColor: const Color(0xFF814CEB),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: _frequency == frequency 
                            ? Colors.transparent 
                            : Colors.grey.shade300,
                      ),
                    ),
                    labelStyle: TextStyle(
                      color: _frequency == frequency ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _frequency = frequency;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Time Picker Card
            _buildSectionCard(
              title: 'Time',
              color: const Color(0xFFE8E7F7),
              child: InkWell(
                onTap: () async {
                  final TimeOfDay? timeOfDay = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime,
                    builder: (BuildContext context, Widget? child) {
                      return Theme(
                        data: ThemeData.light().copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: Color(0xFF814CEB),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  
                  if (timeOfDay != null) {
                    setState(() {
                      _selectedTime = timeOfDay;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: Color(0xFF814CEB),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _selectedTime.format(context),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Days of Week Card
            _buildSectionCard(
              title: 'Days of Week',
              color: const Color(0xFFE0F5F3),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _dayOptions.map((day) {
                  return FilterChip(
                    label: Text(day.substring(0, 3)),
                    selected: _selectedDays.contains(day),
                    selectedColor: const Color(0xFF61C8B9),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: _selectedDays.contains(day) 
                            ? Colors.transparent 
                            : Colors.grey.shade300,
                      ),
                    ),
                    labelStyle: TextStyle(
                      color: _selectedDays.contains(day) ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedDays.add(day);
                        } else {
                          _selectedDays.remove(day);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Instructions Card
            _buildSectionCard(
              title: 'Instructions',
              color: const Color(0xFFFFF1F1),
              child: TextFormField(
                controller: _instructionsController,
                decoration: InputDecoration(
                  hintText: 'e.g., Take with food, take before bed',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(16),
                ),
                maxLines: 2,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Additional Notes Card
            _buildSectionCard(
              title: 'Additional Notes',
              color: const Color(0xFFE8E7F7),
              child: TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  hintText: 'Add any additional notes here...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(16),
                ),
                maxLines: 3,
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _addMedication,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF814CEB),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Save Medication',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSectionCard({
    required String title,
    required Color color,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: child,
          ),
        ],
      ),
    );
  }
} 