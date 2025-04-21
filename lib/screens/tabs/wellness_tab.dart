import 'package:flutter/material.dart';
import 'package:app_ghoda/api/api_service.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class WellnessCategory {
  final String title;
  final IconData icon;
  final Color color;
  final List<WellnessTip> tips;

  WellnessCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.tips,
  });

  factory WellnessCategory.fromJson(Map<String, dynamic> json) {
    return WellnessCategory(
      title: json['title'] ?? '',
      icon: _getIconFromString(json['icon'] ?? 'restaurant'),
      color: _getColorFromString(json['color'] ?? '#8A70BE'),
      tips: (json['tips'] as List?)?.map((tip) => WellnessTip.fromJson(tip)).toList() ?? [],
    );
  }

  static IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'spa':
        return Icons.spa;
      case 'medical_services':
        return Icons.medical_services;
      default:
        return Icons.article;
    }
  }

  static Color _getColorFromString(String colorString) {
    if (colorString.startsWith('#')) {
      return Color(int.parse('FF${colorString.substring(1)}', radix: 16));
    }
    return const Color(0xFF8A70BE); // Default purple
  }
}

class WellnessTip {
  final String title;
  final String content;

  WellnessTip({
    required this.title,
    required this.content,
  });

  factory WellnessTip.fromJson(Map<String, dynamic> json) {
    return WellnessTip(
      title: json['title'] ?? '',
      content: json['content'] ?? '',
    );
  }
}

class WellnessTab extends StatefulWidget {
  const WellnessTab({super.key});

  @override
  State<WellnessTab> createState() => _WellnessTabState();
}

class _WellnessTabState extends State<WellnessTab> {
  final ApiService _apiService = ApiService();
  List<WellnessCategory> _categories = [];
  bool _isLoading = true;
  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadWellnessData();
  }

  Future<void> _loadWellnessData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // First try to load from API
      // If that fails, use cached data
      // If no cached data, use default categories
      await _fetchWellnessData();
    } catch (e) {
      // If API call fails, try to load from cache
      await _loadFromCache();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchWellnessData() async {
    try {
      // Load wellness categories from API
      final response = await _apiService.getWellnessCategories();
      
      if (response != null && response['success'] == true && response['data'] != null) {
        // Parse categories from API response
        final categoriesData = response['data']['categories'] as List<dynamic>;
        _categories = categoriesData.map((data) => WellnessCategory.fromJson(data)).toList();
      } else {
        // If API returns empty data, keep categories empty
        _categories = [];
      }
      
      // Save to cache for offline use
      _saveToCache();
    } catch (e) {
      throw Exception('Failed to fetch wellness data: $e');
    }
  }

  void _initializeDefaultCategories() {
    // No default categories - will be populated from Firebase
    _categories = [];
  }

  Future<void> _saveToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final categoriesJson = _categories.map((category) {
        return {
          'title': category.title,
          'icon': _getIconString(category.icon),
          'color': _getColorString(category.color),
          'tips': category.tips.map((tip) => {
            'title': tip.title,
            'content': tip.content,
          }).toList(),
        };
      }).toList();
      
      await prefs.setString('wellness_categories', jsonEncode(categoriesJson));
    } catch (e) {
      // Silent fail - this is just caching
      debugPrint('Failed to save wellness data to cache: $e');
    }
  }

  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('wellness_categories');
      
      if (jsonString != null) {
        final List<dynamic> categoriesJson = jsonDecode(jsonString);
        _categories = categoriesJson.map((json) => WellnessCategory.fromJson(json)).toList();
      } else {
        // If no cached data, use defaults
        _initializeDefaultCategories();
      }
    } catch (e) {
      // If cache loading fails, use defaults
      _initializeDefaultCategories();
    }
  }

  String _getIconString(IconData icon) {
    if (icon == Icons.restaurant) return 'restaurant';
    if (icon == Icons.fitness_center) return 'fitness_center';
    if (icon == Icons.spa) return 'spa';
    if (icon == Icons.medical_services) return 'medical_services';
    return 'article';
  }

  String _getColorString(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 50, bottom: 20),
            decoration: const BoxDecoration(
              color: Color(0xFF6A48AD),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Wellness',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Tips for your thyroid health journey',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 20),
                // Categories
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = index == _selectedCategoryIndex;
                      
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategoryIndex = index;
                          });
                        },
                        child: Container(
                          width: 80,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                category.icon,
                                color: isSelected ? category.color : Colors.white,
                                size: 28,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                category.title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isSelected ? category.color : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Tips
          if (_categories.isNotEmpty && _selectedCategoryIndex < _categories.length)
            Expanded(
              child: _categories[_selectedCategoryIndex].tips.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _categories[_selectedCategoryIndex].tips.length,
                    itemBuilder: (context, index) {
                      final tip = _categories[_selectedCategoryIndex].tips[index];
                      return _buildTipCard(tip, _categories[_selectedCategoryIndex].color);
                    },
                  ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            size: 48,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No tips available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for wellness tips',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(WellnessTip tip, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              color.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.lightbulb_outline,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tip.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              tip.content,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    // Show details or full article
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: color,
                  ),
                  child: const Text('Learn More'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 