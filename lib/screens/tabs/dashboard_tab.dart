import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:app_ghoda/constants/app_constants.dart';
import 'package:app_ghoda/api/api_service.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<dynamic> _symptoms = [];
  List<dynamic> _bloodworkHistory = [];
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Dummy symptoms data
      _symptoms = [
        {
          'date': '2024-03-15',
          'description': 'Fatigue and tiredness',
          'severity': 'Moderate',
          'duration': '2 days',
          'notes': 'Felt more tired than usual, especially in the afternoon'
        },
        {
          'date': '2024-03-10',
          'description': 'Weight gain',
          'severity': 'Mild',
          'duration': '1 week',
          'notes': 'Gained 2kg over the past week'
        },
        {
          'date': '2024-03-05',
          'description': 'Cold sensitivity',
          'severity': 'Severe',
          'duration': '3 days',
          'notes': 'Feeling extremely cold even in warm weather'
        }
      ];

      // Dummy bloodwork data
      _bloodworkHistory = [
        {
          'date': '2024-03-15',
          'tests': [
            {'name': 'TSH', 'value': '2.5', 'unit': 'mIU/L'},
            {'name': 'Free T4', 'value': '1.2', 'unit': 'ng/dL'},
            {'name': 'Free T3', 'value': '3.2', 'unit': 'pg/mL'}
          ]
        },
        {
          'date': '2024-02-15',
          'tests': [
            {'name': 'TSH', 'value': '3.8', 'unit': 'mIU/L'},
            {'name': 'Free T4', 'value': '1.0', 'unit': 'ng/dL'},
            {'name': 'Free T3', 'value': '2.8', 'unit': 'pg/mL'}
          ]
        },
        {
          'date': '2024-01-15',
          'tests': [
            {'name': 'TSH', 'value': '4.5', 'unit': 'mIU/L'},
            {'name': 'Free T4', 'value': '0.9', 'unit': 'ng/dL'},
            {'name': 'Free T3', 'value': '2.5', 'unit': 'pg/mL'}
          ]
        }
      ];
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Could show an error snackbar here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppConstants.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppConstants.primaryColor,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Symptoms'),
            Tab(text: 'Bloodwork'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildSymptomsTab(),
                _buildBloodworkTab(),
              ],
            ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TSH level trend if bloodwork data exists
          if (_bloodworkHistory.isNotEmpty) ...[
            _buildTrendCard(
              title: 'TSH Level Trend',
              subtitle: 'Recent bloodwork results',
              chartData: _getBloodworkChartData(),
              minY: 0,
              maxY: 5,
              gradientColors: [
                AppConstants.primaryColor,
                AppConstants.primaryLightColor,
              ],
            ),
            const SizedBox(height: 24),
          ] else ...[
            _buildEmptyStateCard(
              "No bloodwork data available",
              "Add bloodwork test results to see your trends and analysis",
              Icons.science_outlined
            ),
            const SizedBox(height: 24),
          ],
          
          // Recent symptoms list
          _buildRecentSymptomsList(),
        ],
      ),
    );
  }

  Widget _buildEmptyStateCard(String title, String message, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 48,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _getBloodworkChartData() {
    // Ensure we have data and convert it to FlSpot format for the chart
    if (_bloodworkHistory.isEmpty) {
      return []; // Return empty list if no data
    }
    
    // Sort bloodwork by date if needed
    _bloodworkHistory.sort((a, b) {
      final dateA = DateTime.parse(a['date'] ?? '2023-01-01');
      final dateB = DateTime.parse(b['date'] ?? '2023-01-01');
      return dateA.compareTo(dateB);
    });
    
    // Limit to last 6 results and convert to chart format
    final recentBloodwork = _bloodworkHistory.length > 6 
        ? _bloodworkHistory.sublist(_bloodworkHistory.length - 6) 
        : _bloodworkHistory;
        
    return List.generate(recentBloodwork.length, (index) {
      final item = recentBloodwork[index];
      // Use TSH value or fallback to 0 if not available
      final tsh = double.tryParse(item['tests']?[0]?['value']?.toString() ?? '0') ?? 0;
      return FlSpot(index + 1, tsh);
    });
  }

  Widget _buildSymptomsTab() {
    return _symptoms.isEmpty
        ? Center(
            child: _buildEmptyStateCard(
              'No symptoms recorded',
              'Add your first symptom to start tracking your health',
              Icons.healing_outlined
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _symptoms.length,
            itemBuilder: (context, index) {
              final symptom = _symptoms[index];
              final date = symptom['date'] != null 
                ? DateTime.parse(symptom['date']).toString().substring(0, 10)
                : 'Unknown date';
                
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            date,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          _buildSeverityBadge(symptom['severity'] ?? 'Moderate'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        symptom['description'] ?? 'No description',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (symptom['duration'] != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Duration: ${symptom['duration']}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                      if (symptom['notes'] != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          symptom['notes'],
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
  }

  Widget _buildBloodworkTab() {
    return _bloodworkHistory.isEmpty
        ? Center(
            child: _buildEmptyStateCard(
              'No bloodwork recorded',
              'Add your bloodwork test results to track your thyroid health',
              Icons.science_outlined
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _bloodworkHistory.length,
            itemBuilder: (context, index) {
              final bloodwork = _bloodworkHistory[index];
              final date = bloodwork['date'] != null 
                ? DateTime.parse(bloodwork['date']).toString().substring(0, 10)
                : 'Unknown date';
                
              // Safely extract test values
              var tshValue = 0.0;
              var ft4Value = 0.0;
              var ft3Value = 0.0;
              
              if (bloodwork['tests'] != null && bloodwork['tests'] is List) {
                final tests = bloodwork['tests'] as List;
                for (final test in tests) {
                  if (test['name'] == 'TSH') {
                    tshValue = double.tryParse(test['value'].toString()) ?? 0.0;
                  } else if (test['name'] == 'Free T4') {
                    ft4Value = double.tryParse(test['value'].toString()) ?? 0.0;
                  } else if (test['name'] == 'Free T3') {
                    ft3Value = double.tryParse(test['value'].toString()) ?? 0.0;
                  }
                }
              }
              
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildBloodworkItem('TSH', '$tshValue mIU/L', _getTshStatus(tshValue)),
                      const Divider(),
                      _buildBloodworkItem('Free T4', '$ft4Value ng/dL', _getT4Status(ft4Value)),
                      const Divider(),
                      _buildBloodworkItem('Free T3', '$ft3Value pg/mL', _getT3Status(ft3Value)),
                    ],
                  ),
                ),
              );
            },
          );
  }
  
  Widget _buildTrendCard({
    required String title,
    required String subtitle,
    required List<FlSpot> chartData,
    required double minY,
    required double maxY,
    required List<Color> gradientColors,
  }) {
    // Handle empty chart data
    if (chartData.isEmpty) {
      return _buildEmptyStateCard(
        "No data available",
        "Add bloodwork to see your trends",
        Icons.show_chart
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.3),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        // Only show a label for each data point
                        if (value >= 1 && value <= chartData.length && value.toInt() == value) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox();
                        return Text(
                          value.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 1,
                maxX: chartData.length.toDouble(),
                minY: minY,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: chartData,
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: gradientColors,
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: gradientColors[0],
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: gradientColors
                            .map((color) => color.withOpacity(0.3))
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRecentSymptomsList() {
    if (_symptoms.isEmpty) {
      return _buildEmptyStateCard(
        'No symptoms recorded',
        'Add your first symptom to start tracking your health',
        Icons.healing_outlined
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Symptoms',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _symptoms.length > 3 ? 3 : _symptoms.length,
          itemBuilder: (context, index) {
            final symptom = _symptoms[index];
            final date = symptom['date'] != null 
              ? DateTime.parse(symptom['date']).toString().substring(0, 10)
              : 'Unknown date';
              
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _getSeverityColor(symptom['severity'] ?? 'Moderate'),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            symptom['description'] ?? 'No description',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            date,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildSeverityBadge(symptom['severity'] ?? 'Moderate'),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        if (_symptoms.length > 3)
          TextButton(
            onPressed: () {
              _tabController.animateTo(1); // Switch to symptoms tab
            },
            child: const Text('View all symptoms'),
          ),
      ],
    );
  }

  Widget _buildSeverityBadge(String severity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getSeverityColor(severity).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        severity,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: _getSeverityColor(severity),
        ),
      ),
    );
  }
  
  Widget _buildBloodworkItem(String label, String value, Widget status) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(value),
        ),
        Expanded(
          flex: 1,
          child: status,
        ),
      ],
    );
  }
  
  Widget _getTshStatus(double tsh) {
    if (tsh < 0.4) {
      return _buildStatusIndicator('Low', Colors.orange);
    } else if (tsh > 4.0) {
      return _buildStatusIndicator('High', Colors.red);
    } else {
      return _getNormalStatus();
    }
  }
  
  Widget _getT4Status(double ft4) {
    if (ft4 < 0.8) {
      return _buildStatusIndicator('Low', Colors.orange);
    } else if (ft4 > 1.8) {
      return _buildStatusIndicator('High', Colors.red);
    } else {
      return _getNormalStatus();
    }
  }
  
  Widget _getT3Status(double ft3) {
    if (ft3 < 2.3) {
      return _buildStatusIndicator('Low', Colors.orange);
    } else if (ft3 > 4.2) {
      return _buildStatusIndicator('High', Colors.red);
    } else {
      return _getNormalStatus();
    }
  }
  
  Widget _getNormalStatus() {
    return _buildStatusIndicator('Normal', Colors.green);
  }
  
  Widget _buildStatusIndicator(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'mild':
        return Colors.green;
      case 'moderate':
        return Colors.orange;
      case 'severe':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
} 