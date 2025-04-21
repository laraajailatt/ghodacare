import 'package:flutter/material.dart';
import 'package:app_ghoda/constants/app_constants.dart';
import 'package:app_ghoda/api/api_service.dart';
import 'package:app_ghoda/models/bloodwork_model.dart';
import 'package:intl/intl.dart';

class BloodworkListScreen extends StatefulWidget {
  const BloodworkListScreen({super.key});

  @override
  State<BloodworkListScreen> createState() => _BloodworkListScreenState();
}

class _BloodworkListScreenState extends State<BloodworkListScreen> {
  final ApiService _apiService = ApiService();
  List<BloodworkModel> _bloodworks = [];
  List<BloodworkModel> _filteredBloodworks = [];
  bool _isLoading = true;
  String _filterType = 'all'; // all, normal, abnormal, recent
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadBloodworks();
  }

  Future<void> _loadBloodworks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final bloodworks = await _apiService.getBloodworks();
      
      setState(() {
        _bloodworks = bloodworks.map((data) => BloodworkModel.fromJson(data)).toList();
        _applyFilter(_filterType);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load bloodwork data: ${e.toString()}';
      });
    }
  }

  void _applyFilter(String filterType) {
    setState(() {
      _filterType = filterType;
      
      switch (filterType) {
        case 'normal':
          _filteredBloodworks = _bloodworks.where((item) => item.isNormal).toList();
          break;
        case 'abnormal':
          _filteredBloodworks = _bloodworks.where((item) => !item.isNormal).toList();
          break;
        case 'recent':
          // Show last 3 months of bloodwork
          final threeMonthsAgo = DateTime.now().subtract(const Duration(days: 90));
          _filteredBloodworks = _bloodworks
              .where((item) => item.date.isAfter(threeMonthsAgo))
              .toList();
          break;
        default: // 'all'
          _filteredBloodworks = List.from(_bloodworks);
      }
      
      // Sort by date (newest first)
      _filteredBloodworks.sort((a, b) => b.date.compareTo(a.date));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bloodwork History',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadBloodworks,
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/add_bloodwork');
          if (result == true) {
            _loadBloodworks();
          }
        },
        backgroundColor: AppConstants.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppConstants.errorColor,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadBloodworks,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_filteredBloodworks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.science_outlined,
              color: Colors.grey,
              size: 60,
            ),
            const SizedBox(height: 16),
            const Text(
              'No bloodwork records found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _filterType != 'all'
                  ? 'Try changing your filter selection'
                  : 'Add your first bloodwork record to start tracking',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            if (_filterType != 'all')
              ElevatedButton(
                onPressed: () => _applyFilter('all'),
                child: const Text('Show All Records'),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredBloodworks.length,
      itemBuilder: (context, index) {
        final bloodwork = _filteredBloodworks[index];
        return _buildBloodworkCard(bloodwork);
      },
    );
  }

  Widget _buildBloodworkCard(BloodworkModel bloodwork) {
    final abnormalValues = bloodwork.getAbnormalThyroidValues();
    final hasAbnormalValues = abnormalValues.isNotEmpty;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: hasAbnormalValues 
              ? AppConstants.errorColor.withOpacity(0.3) 
              : Colors.green.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _navigateToDetailScreen(bloodwork),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMMM d, yyyy').format(bloodwork.date),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: hasAbnormalValues
                          ? AppConstants.errorColor.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      hasAbnormalValues ? 'Abnormal' : 'Normal',
                      style: TextStyle(
                        color: hasAbnormalValues
                            ? AppConstants.errorColor
                            : Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Lab: ${bloodwork.labName}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              _buildKeyValuePair(
                'TSH',
                bloodwork.thyroidValues['tsh']?.toString() ?? '-',
                bloodwork.isValueAbnormal('tsh'),
              ),
              if (bloodwork.thyroidValues.containsKey('ft4'))
                _buildKeyValuePair(
                  'Free T4',
                  bloodwork.thyroidValues['ft4']?.toString() ?? '-',
                  bloodwork.isValueAbnormal('ft4'),
                ),
              if (bloodwork.thyroidValues.containsKey('ft3'))
                _buildKeyValuePair(
                  'Free T3',
                  bloodwork.thyroidValues['ft3']?.toString() ?? '-',
                  bloodwork.isValueAbnormal('ft3'),
                ),
              const SizedBox(height: 8),
              if (abnormalValues.isNotEmpty) ...[
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Abnormal values: ${abnormalValues.length}',
                  style: TextStyle(
                    color: AppConstants.errorColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              if (bloodwork.aiAnalysis != null) ...[
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  'AI Analysis Available',
                  style: TextStyle(
                    color: AppConstants.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeyValuePair(String key, String value, bool isAbnormal) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            key,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isAbnormal ? AppConstants.errorColor : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Bloodwork',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildFilterOption('all', 'All Results'),
              _buildFilterOption('recent', 'Recent (Last 3 Months)'),
              _buildFilterOption('normal', 'Normal Results'),
              _buildFilterOption('abnormal', 'Abnormal Results'),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(String filterType, String label) {
    return ListTile(
      title: Text(label),
      leading: Radio<String>(
        value: filterType,
        groupValue: _filterType,
        onChanged: (value) {
          Navigator.pop(context);
          if (value != null) {
            _applyFilter(value);
          }
        },
        activeColor: AppConstants.primaryColor,
      ),
      dense: true,
      onTap: () {
        Navigator.pop(context);
        _applyFilter(filterType);
      },
    );
  }

  void _navigateToDetailScreen(BloodworkModel bloodwork) async {
    final result = await Navigator.pushNamed(
      context,
      '/bloodwork_detail',
      arguments: bloodwork.id,
    );
    
    if (result == true) {
      _loadBloodworks();
    }
  }
} 