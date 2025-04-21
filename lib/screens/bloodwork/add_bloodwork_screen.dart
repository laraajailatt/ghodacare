import 'package:flutter/material.dart';
import 'package:app_ghoda/api/api_service.dart';
import 'package:intl/intl.dart';

class AddBloodworkScreen extends StatefulWidget {
  const AddBloodworkScreen({super.key});

  @override
  State<AddBloodworkScreen> createState() => _AddBloodworkScreenState();
}

class _AddBloodworkScreenState extends State<AddBloodworkScreen> {
  bool _showIntroScreen = true;
  
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _labNameController = TextEditingController();
  final _apiService = ApiService();

  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();
  String? _selectedDay;
  
  // Thyroid test controllers
  final _tshController = TextEditingController();
  final _ft4Controller = TextEditingController();
  final _ft3Controller = TextEditingController();
  final _t4Controller = TextEditingController();
  final _t3Controller = TextEditingController();
  final _tpoController = TextEditingController();
  final _tgController = TextEditingController();
  final _tsiController = TextEditingController();
  
  // Reference ranges for each test
  final Map<String, Map<String, dynamic>> _referenceRanges = {
    'tsh': {
      'name': 'TSH',
      'unit': 'mIU/L',
      'min': 0.4,
      'max': 4.0,
      'controller': null,
      'description': 'Thyroid Stimulating Hormone',
    },
    'ft4': {
      'name': 'Free T4',
      'unit': 'ng/dL',
      'min': 0.8,
      'max': 1.8,
      'controller': null,
      'description': 'Free Thyroxine',
    },
    'ft3': {
      'name': 'Free T3',
      'unit': 'pg/mL',
      'min': 2.3,
      'max': 4.2,
      'controller': null,
      'description': 'Free Triiodothyronine',
    },
    't4': {
      'name': 'Total T4',
      'unit': 'μg/dL',
      'min': 5.0,
      'max': 12.0,
      'controller': null,
      'description': 'Total Thyroxine',
    },
    't3': {
      'name': 'Total T3',
      'unit': 'ng/dL',
      'min': 80.0,
      'max': 200.0,
      'controller': null,
      'description': 'Total Triiodothyronine',
    },
    'tpo': {
      'name': 'TPO Antibodies',
      'unit': 'IU/mL',
      'min': 0.0,
      'max': 35.0,
      'controller': null,
      'description': 'Thyroid Peroxidase Antibodies',
    },
    'tg': {
      'name': 'Thyroglobulin',
      'unit': 'ng/mL',
      'min': 0.0,
      'max': 55.0,
      'controller': null,
      'description': 'Thyroglobulin',
    },
    'tsi': {
      'name': 'TSI',
      'unit': '%',
      'min': 0.0,
      'max': 140.0,
      'controller': null,
      'description': 'Thyroid Stimulating Immunoglobulin',
    },
  };

  @override
  void initState() {
    super.initState();
    _initControllers();
    _selectedDay = _buildWeekDays()[_selectedDate.weekday % 7]['day'];
  }

  List<Map<String, String>> _buildWeekDays() {
    final now = DateTime.now();
    return List.generate(7, (index) {
      final day = now.add(Duration(days: index - now.weekday + 1));
      return {
        'weekday': DateFormat('E').format(day),
        'day': day.day.toString(),
        'fullDate': DateFormat('MMM d').format(day),
      };
    });
  }

  void _initControllers() {
    _referenceRanges['tsh']?['controller'] = _tshController;
    _referenceRanges['ft4']?['controller'] = _ft4Controller;
    _referenceRanges['ft3']?['controller'] = _ft3Controller;
    _referenceRanges['t4']?['controller'] = _t4Controller;
    _referenceRanges['t3']?['controller'] = _t3Controller;
    _referenceRanges['tpo']?['controller'] = _tpoController;
    _referenceRanges['tg']?['controller'] = _tgController;
    _referenceRanges['tsi']?['controller'] = _tsiController;
  }

  @override
  void dispose() {
    _notesController.dispose();
    _labNameController.dispose();
    _tshController.dispose();
    _ft4Controller.dispose();
    _ft3Controller.dispose();
    _t4Controller.dispose();
    _t3Controller.dispose();
    _tpoController.dispose();
    _tgController.dispose();
    _tsiController.dispose();
    super.dispose();
  }

  // Track user-entered test values
  final Map<String, double> _enteredValues = {};
  
  void _showTestInputDialog(String testName) {
    final TextEditingController valueController = TextEditingController();
    final TextEditingController unitController = TextEditingController(text: 'mg/dL');
    
    // If we already have a value for this test, pre-fill it
    if (_enteredValues.containsKey(testName)) {
      valueController.text = _enteredValues[testName].toString();
    }
    
    // Find matching reference range if available
    Map<String, dynamic>? referenceRange;
    _referenceRanges.forEach((key, data) {
      if (data['name'].toString().toLowerCase() == testName.toLowerCase()) {
        referenceRange = data;
        unitController.text = data['unit'];
      }
    });
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Add $testName'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: valueController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Value',
                    hintText: 'Enter value',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: unitController,
                  decoration: InputDecoration(
                    labelText: 'Unit',
                    hintText: 'e.g., mg/dL',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                if (referenceRange != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Reference Range: ${referenceRange?['min']} - ${referenceRange?['max']} ${referenceRange?['unit']}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final value = double.tryParse(valueController.text);
                  if (value != null) {
                    setState(() {
                      _enteredValues[testName] = value;
                    });
                  }
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showIntroScreen) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Add Bloodwork'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/bloodwork.png',
                width: 200,
                height: 200,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 200,
                    height: 200,
                    color: const Color(0xFFE8E7F7),
                    child: Icon(
                      Icons.healing,
                      size: 80,
                      color: Theme.of(context).primaryColor,
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              const Text(
                'Track Your Bloodwork',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Keep track of your bloodwork results to monitor your health over time.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showIntroScreen = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Get Started'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Bloodwork'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              // Show confirmation dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Save Changes?'),
                  content: const Text('Do you want to save your changes before leaving?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Go back
                      },
                      child: const Text('Discard'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        _submitForm();
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              );
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _labNameController,
                      decoration: const InputDecoration(
                        labelText: 'Lab Name',
                        hintText: 'Enter the name of the laboratory',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the lab name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Test Date',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 7,
                        itemBuilder: (context, index) {
                          final weekDay = _buildWeekDays()[index];
                          final isSelected = weekDay['day'] == _selectedDay;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedDay = weekDay['day'];
                                _selectedDate = DateTime.now()
                                    .add(Duration(days: index - DateTime.now().weekday + 1));
                              });
                            },
                            child: Container(
                              width: 60,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    weekDay['weekday']!,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    weekDay['day']!,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Test Results',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.5,
                      ),
                      itemCount: _referenceRanges.length,
                      itemBuilder: (context, index) {
                        final test = _referenceRanges.entries.elementAt(index);
                        final hasValue = _enteredValues.containsKey(test.value['name']);
                        return GestureDetector(
                          onTap: () => _showTestInputDialog(test.value['name']),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: hasValue ? Colors.green.shade50 : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: hasValue ? Colors.green.shade200 : Colors.grey.shade300,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  test.value['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (hasValue)
                                  Text(
                                    '${_enteredValues[test.value['name']]} ${test.value['unit']}',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )
                                else
                                  Text(
                                    'Tap to add',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        hintText: 'Add any additional notes or observations',
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Save Results'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final bloodworkData = {
          'lab_name': _labNameController.text,
          'test_date': DateFormat('yyyy-MM-dd').format(_selectedDate),
          'notes': _notesController.text,
          'results': _enteredValues.map((key, value) => MapEntry(key, {
                'value': value,
                'unit': _referenceRanges[key]?['unit'],
              })),
        };

        final response = await _apiService.addBloodwork(bloodworkData);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Bloodwork added successfully'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true);
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load real data from API service
      final symptomsResponse = await _apiService.getSymptoms();
      final bloodworkResponse = await _apiService.getBloodworks();
      
      setState(() {
        _symptoms = symptomsResponse;
        _bloodworkHistory = bloodworkResponse;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Could show an error snackbar here
    }
  }
} 