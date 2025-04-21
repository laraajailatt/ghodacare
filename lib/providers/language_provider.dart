import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  bool _isEnglish = true;

  bool get isEnglish => _isEnglish;

  void toggleLanguage() {
    _isEnglish = !_isEnglish;
    notifyListeners();
  }

  void setLanguage(bool isEnglish) {
    _isEnglish = isEnglish;
    notifyListeners();
  }

  Locale get locale => _isEnglish ? const Locale('en', 'US') : const Locale('ar', 'JO');

  // English translations
  static const Map<String, String> _englishTexts = {
    // Home
    'home': 'Home',
    'welcome': 'Welcome',
    'today': 'Today',
    
    // Wellness
    'wellness': 'Wellness',
    'wellnessCategories': 'Wellness Categories',
    'nutrition': 'Nutrition',
    'exercise': 'Exercise',
    'stress': 'Stress Management',
    'meditation': 'Meditation',
    
    // Common
    'save': 'Save',
    'cancel': 'Cancel',
    'delete': 'Delete',
    'edit': 'Edit',
    'add': 'Add',
    'search': 'Search',
    'submit': 'Submit',
    'comingSoon': 'Coming Soon!',
    
    // Symptom tracking
    'symptoms': 'Symptoms',
    'symptomTracking': 'Symptom Tracking',
    'addSymptom': 'Add Symptom',
    'symptomHistory': 'Symptom History',
    'severity': 'Severity',
    'mild': 'Mild',
    'moderate': 'Moderate',
    'severe': 'Severe',
    'duration': 'Duration',
    'triggers': 'Triggers',
    'notes': 'Notes',
    
    // Profile
    'profile': 'Profile',
    'account': 'Account',
    'personalInfo': 'Personal Information',
    'changePassword': 'Change Password',
    'notifications': 'Notifications',
    'preferences': 'Preferences',
    'language': 'Language',
    'darkMode': 'Dark Mode',
    'privacySettings': 'Privacy Settings',
    'support': 'Support',
    'helpCenter': 'Help Center',
    'about': 'About',
    'logout': 'Logout',
    'contactUs': 'Contact Us',
    'version': 'Version',
    'logoutConfirmation': 'Logout Confirmation',
    'logoutMessage': 'Are you sure you want to logout?',
    'displaySettings': 'Display Settings',
    'pushNotifications': 'Push Notifications',
    'emailNotifications': 'Email Notifications',
    'dataAndPrivacy': 'Data & Privacy',
    'dataManagement': 'Data Management',
    
    // Forms
    'name': 'Name',
    'email': 'Email',
    'phone': 'Phone',
    'birthday': 'Birthday',
    'gender': 'Gender',
    'male': 'Male',
    'female': 'Female',
    'other': 'Other',
    'currentPassword': 'Current Password',
    'newPassword': 'New Password',
    'confirmPassword': 'Confirm Password',
    'passwordChanged': 'Password changed successfully',
    'passwordError': 'Error changing password',
    
    // Messages
    'errorMessage': 'Something went wrong. Please try again.',
    'successMessage': 'Operation completed successfully.',
    'networkError': 'Network error. Please check your connection.',
    'requiredField': 'This field is required',
    'invalidEmail': 'Please enter a valid email address',
    'passwordMismatch': 'Passwords do not match',
    'passwordLength': 'Password must be at least 8 characters',
    
    // Help Center
    'helpCenterText': 'For any questions or support, please email us at:',
    'contactEmail': 'lara.ajailat@gmail.com',
    
    // About
    'aboutTitle': 'About GhodaCare',
    'aboutDescription': 'GhodaCare is a modern healthcare application designed to help users track and manage their symptoms, medications, and overall health. Our mission is to empower users to take control of their health through easy-to-use tools and personalized insights.',
    'ourTeam': 'Our Team',
    'ourMission': 'Our Mission',
    'termsOfService': 'Terms of Service',
    'privacyPolicy': 'Privacy Policy',
  };
  
  // Arabic translations
  static const Map<String, String> _arabicTexts = {
    // Home
    'home': 'الرئيسية',
    'welcome': 'مرحباً',
    'today': 'اليوم',
    
    // Wellness
    'wellness': 'العافية',
    'wellnessCategories': 'فئات العافية',
    'nutrition': 'التغذية',
    'exercise': 'التمارين',
    'stress': 'إدارة الضغط',
    'meditation': 'التأمل',
    
    // Common
    'save': 'حفظ',
    'cancel': 'إلغاء',
    'delete': 'حذف',
    'edit': 'تعديل',
    'add': 'إضافة',
    'search': 'بحث',
    'submit': 'إرسال',
    'comingSoon': 'قريباً!',
    
    // Symptom tracking
    'symptoms': 'الأعراض',
    'symptomTracking': 'تتبع الأعراض',
    'addSymptom': 'إضافة عرض',
    'symptomHistory': 'سجل الأعراض',
    'severity': 'الشدة',
    'mild': 'خفيف',
    'moderate': 'متوسط',
    'severe': 'شديد',
    'duration': 'المدة',
    'triggers': 'المحفزات',
    'notes': 'ملاحظات',
    
    // Profile
    'profile': 'الملف الشخصي',
    'account': 'الحساب',
    'personalInfo': 'المعلومات الشخصية',
    'changePassword': 'تغيير كلمة المرور',
    'notifications': 'الإشعارات',
    'preferences': 'التفضيلات',
    'language': 'اللغة',
    'darkMode': 'الوضع المظلم',
    'privacySettings': 'إعدادات الخصوصية',
    'support': 'الدعم',
    'helpCenter': 'مركز المساعدة',
    'about': 'حول',
    'logout': 'تسجيل الخروج',
    'contactUs': 'اتصل بنا',
    'version': 'الإصدار',
    'logoutConfirmation': 'تأكيد تسجيل الخروج',
    'logoutMessage': 'هل أنت متأكد أنك تريد تسجيل الخروج؟',
    'displaySettings': 'إعدادات العرض',
    'pushNotifications': 'إشعارات الدفع',
    'emailNotifications': 'إشعارات البريد الإلكتروني',
    'dataAndPrivacy': 'البيانات والخصوصية',
    'dataManagement': 'إدارة البيانات',
    
    // Forms
    'name': 'الاسم',
    'email': 'البريد الإلكتروني',
    'phone': 'الهاتف',
    'birthday': 'تاريخ الميلاد',
    'gender': 'الجنس',
    'male': 'ذكر',
    'female': 'أنثى',
    'other': 'آخر',
    'currentPassword': 'كلمة المرور الحالية',
    'newPassword': 'كلمة المرور الجديدة',
    'confirmPassword': 'تأكيد كلمة المرور',
    'passwordChanged': 'تم تغيير كلمة المرور بنجاح',
    'passwordError': 'خطأ في تغيير كلمة المرور',
    
    // Messages
    'errorMessage': 'حدث خطأ ما. يرجى المحاولة مرة أخرى.',
    'successMessage': 'تمت العملية بنجاح.',
    'networkError': 'خطأ في الشبكة. يرجى التحقق من اتصالك.',
    'requiredField': 'هذا الحقل مطلوب',
    'invalidEmail': 'يرجى إدخال عنوان بريد إلكتروني صالح',
    'passwordMismatch': 'كلمات المرور غير متطابقة',
    'passwordLength': 'يجب أن تتكون كلمة المرور من 8 أحرف على الأقل',
    
    // Help Center
    'helpCenterText': 'لأية أسئلة أو دعم، يرجى مراسلتنا على البريد الإلكتروني:',
    'contactEmail': 'lara.ajailat@gmail.com',
    
    // About
    'aboutTitle': 'حول GhodaCare',
    'aboutDescription': 'GhodaCare هو تطبيق رعاية صحية حديث مصمم لمساعدة المستخدمين على تتبع وإدارة أعراضهم وأدويتهم وصحتهم العامة. مهمتنا هي تمكين المستخدمين من التحكم في صحتهم من خلال أدوات سهلة الاستخدام ورؤى مخصصة.',
    'ourTeam': 'فريقنا',
    'ourMission': 'مهمتنا',
    'termsOfService': 'شروط الخدمة',
    'privacyPolicy': 'سياسة الخصوصية',
  };
  
  String get(String key) {
    if (_isEnglish) {
      return _englishTexts[key] ?? key;
    } else {
      return _arabicTexts[key] ?? key;
    }
  }
  
  TextDirection get textDirection => _isEnglish ? TextDirection.ltr : TextDirection.rtl;
} 