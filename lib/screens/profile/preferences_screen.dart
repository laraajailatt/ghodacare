import 'package:flutter/material.dart';
import 'package:app_ghoda/constants/app_constants.dart';
import 'package:app_ghoda/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  bool _notificationsEnabled = true;
  bool _useMetricSystem = true;
  String _selectedLanguage = 'English';
  bool _autoUploadData = true;

  final List<String> _availableLanguages = [
    'English',
    'Spanish',
    'French',
    'Hindi',
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferences'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Appearance'),
              _buildThemeToggle(themeProvider),
              const SizedBox(height: 24),
              
              _buildSectionHeader('Language'),
              _buildLanguageDropdown(),
              const SizedBox(height: 24),
              
              _buildSectionHeader('Units'),
              _buildUnitToggle(),
              const SizedBox(height: 24),
              
              _buildSectionHeader('Notifications'),
              _buildNotificationToggle(),
              const SizedBox(height: 24),
              
              _buildSectionHeader('Privacy & Data'),
              _buildPrivacySettings(),
              const SizedBox(height: 24),
              
              _buildSectionHeader('About'),
              _buildAboutSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppConstants.primaryColor,
        ),
      ),
    );
  }

  Widget _buildThemeToggle(ThemeProvider themeProvider) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: SwitchListTile(
        title: const Text('Dark Mode'),
        subtitle: const Text('Use dark theme throughout the app'),
        value: themeProvider.isDarkMode,
        onChanged: (value) {
          themeProvider.setDarkMode(value);
        },
        secondary: Icon(
          themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
          color: AppConstants.primaryColor,
        ),
      ),
    );
  }

  Widget _buildLanguageDropdown() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Language',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              value: _selectedLanguage,
              items: _availableLanguages.map((language) {
                return DropdownMenuItem(
                  value: language,
                  child: Text(language),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedLanguage = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitToggle() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: SwitchListTile(
        title: const Text('Use Metric System'),
        subtitle: Text(
          _useMetricSystem 
              ? 'Using kilograms, centimeters' 
              : 'Using pounds, inches'
        ),
        value: _useMetricSystem,
        onChanged: (value) {
          setState(() {
            _useMetricSystem = value;
          });
        },
        secondary: Icon(
          Icons.straighten,
          color: AppConstants.primaryColor,
        ),
      ),
    );
  }

  Widget _buildNotificationToggle() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Enable Notifications'),
            subtitle: const Text('Receive reminders and health alerts'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
            secondary: Icon(
              Icons.notifications,
              color: AppConstants.primaryColor,
            ),
          ),
          if (_notificationsEnabled)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
                  ListTile(
                    title: Text('Medication Reminders'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                  ListTile(
                    title: Text('Appointment Alerts'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                  ListTile(
                    title: Text('Health Tips'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPrivacySettings() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Auto-upload Health Data'),
            subtitle: const Text('Automatically sync data with your healthcare provider'),
            value: _autoUploadData,
            onChanged: (value) {
              setState(() {
                _autoUploadData = value;
              });
            },
            secondary: Icon(
              Icons.cloud_upload,
              color: AppConstants.primaryColor,
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Export My Data'),
            subtitle: const Text('Download all your health records'),
            leading: Icon(
              Icons.download,
              color: AppConstants.primaryColor,
            ),
            onTap: () {
              // Implement export functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exporting data...')),
              );
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Delete My Account'),
            subtitle: const Text('Permanently remove all your data'),
            leading: const Icon(
              Icons.delete_forever,
              color: Colors.red,
            ),
            onTap: () {
              _showDeleteAccountDialog();
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
          'This action cannot be undone. All your data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement account deletion
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deletion requested')),
              );
            },
            child: const Text(
              'DELETE',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          ListTile(
            title: const Text('App Version'),
            subtitle: const Text('1.0.0'),
            leading: Icon(
              Icons.info_outline,
              color: AppConstants.primaryColor,
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Terms of Service'),
            leading: Icon(
              Icons.description,
              color: AppConstants.primaryColor,
            ),
            onTap: () {
              // Navigate to Terms of Service
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Privacy Policy'),
            leading: Icon(
              Icons.privacy_tip,
              color: AppConstants.primaryColor,
            ),
            onTap: () {
              // Navigate to Privacy Policy
            },
          ),
        ],
      ),
    );
  }
} 