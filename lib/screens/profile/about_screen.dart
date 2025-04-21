import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../providers/language_provider.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    
    return Directionality(
      textDirection: languageProvider.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: Text(languageProvider.get('about')),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppInfoSection(context, languageProvider),
              const SizedBox(height: 24),
              _buildTeamSection(context, languageProvider),
              const SizedBox(height: 24),
              _buildMissionSection(context, languageProvider),
              const SizedBox(height: 24),
              _buildLegalSection(context, languageProvider),
              const SizedBox(height: 24),
              _buildVersionSection(context, languageProvider),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildAppInfoSection(BuildContext context, LanguageProvider languageProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: double.infinity),
        Image.asset(
          'assets/images/logo.png',
          height: 100,
          width: 100,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.healing,
                size: 60,
                color: AppConstants.primaryColor,
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Text(
          'GhodaCare',
          style: AppConstants.headingStyle.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          languageProvider.get('aboutDescription'),
          textAlign: TextAlign.center,
          style: AppConstants.bodyTextStyle,
        ),
      ],
    );
  }
  
  Widget _buildSectionHeader(String title, LanguageProvider languageProvider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            color: AppConstants.primaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            languageProvider.get(title),
            style: AppConstants.subHeadingStyle.copyWith(
              color: AppConstants.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTeamSection(BuildContext context, LanguageProvider languageProvider) {
    final List<Map<String, String>> teamMembers = [
      {
        'name': 'Lara Ajailat',
        'role': languageProvider.isEnglish ? 'Lead Developer' : 'مطور رئيسي',
      },
      {
        'name': 'Dr. Ahmad Khan',
        'role': languageProvider.isEnglish ? 'Medical Advisor' : 'مستشار طبي',
      },
      {
        'name': 'Sarah Johnson',
        'role': languageProvider.isEnglish ? 'UX Designer' : 'مصمم تجربة المستخدم',
      },
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('ourTeam', languageProvider),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: teamMembers.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                child: Text(
                  teamMembers[index]['name']![0],
                  style: const TextStyle(
                    color: AppConstants.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                teamMembers[index]['name']!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(teamMembers[index]['role']!),
            );
          },
        ),
      ],
    );
  }
  
  Widget _buildMissionSection(BuildContext context, LanguageProvider languageProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('ourMission', languageProvider),
        const SizedBox(height: 8),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Icon(
                  Icons.healing,
                  color: AppConstants.primaryColor,
                  size: 40,
                ),
                const SizedBox(height: 16),
                Text(
                  languageProvider.isEnglish
                      ? 'Our mission is to empower users to take control of their health through easy-to-use tools and personalized insights. We believe that better health tracking leads to better health outcomes.'
                      : 'مهمتنا هي تمكين المستخدمين من التحكم في صحتهم من خلال أدوات سهلة الاستخدام ورؤى مخصصة. نحن نؤمن بأن تتبع الصحة بشكل أفضل يؤدي إلى نتائج صحية أفضل.',
                  textAlign: TextAlign.center,
                  style: AppConstants.bodyTextStyle,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildLegalSection(BuildContext context, LanguageProvider languageProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          languageProvider.isEnglish ? 'Legal' : 'قانوني',
          style: AppConstants.subHeadingStyle.copyWith(
            color: AppConstants.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        _buildLegalItem(
          icon: Icons.description_outlined,
          title: languageProvider.get('termsOfService'),
          onTap: () {
            // Navigate to Terms of Service
          },
        ),
        _buildLegalItem(
          icon: Icons.privacy_tip_outlined,
          title: languageProvider.get('privacyPolicy'),
          onTap: () {
            // Navigate to Privacy Policy
          },
        ),
      ],
    );
  }
  
  Widget _buildLegalItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppConstants.primaryColor),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
  
  Widget _buildVersionSection(BuildContext context, LanguageProvider languageProvider) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${languageProvider.get('version')}: ',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                '1.0.0',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '© 2023 GhodaCare',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
} 