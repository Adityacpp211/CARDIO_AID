// CardioAid - Premium Flutter Application
// Emergency Cardiac Care System with Authentication

import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const CardioAidApp());
}

// ==================== MODELS ====================

class User {
  final String name;
  final String email;
  final String password;

  User({
    required this.name,
    required this.email,
    required this.password,
  });
}

class Hospital {
  final String name;
  final String address;
  final String phone;
  final String distance;

  Hospital({
    required this.name,
    required this.address,
    required this.phone,
    required this.distance,
  });
}

class PatientRecord {
  final String id;
  final String name;
  final int age;
  final String bloodType;
  final String condition;
  final String admissionDate;
  final String roomNumber;

  PatientRecord({
    required this.id,
    required this.name,
    required this.age,
    required this.bloodType,
    required this.condition,
    required this.admissionDate,
    required this.roomNumber,
  });
}

class VitalSigns {
  final String patientId;
  final String patientName;
  final int heartRate;
  final String bloodPressure;
  final double temperature;
  final int oxygenLevel;
  final String timestamp;

  VitalSigns({
    required this.patientId,
    required this.patientName,
    required this.heartRate,
    required this.bloodPressure,
    required this.temperature,
    required this.oxygenLevel,
    required this.timestamp,
  });
}

class EmergencyRecord {
  final String id;
  final String timestamp;
  final bool responsiveness;
  final bool breathing;
  final bool pulse;
  final bool heartRhythm;
  final String status; // Critical, Stable, Resolved

  EmergencyRecord({
    required this.id,
    required this.timestamp,
    required this.responsiveness,
    required this.breathing,
    required this.pulse,
    required this.heartRhythm,
    required this.status,
  });
}

class MedicalReport {
  final String id;
  final String patientName;
  final String reportType;
  final String date;
  final String summary;
  final String doctor;

  MedicalReport({
    required this.id,
    required this.patientName,
    required this.reportType,
    required this.date,
    required this.summary,
    required this.doctor,
  });
}

class UserProfile {
  final String name;
  final String email;
  final String role;
  final String employeeId;
  final String department;
  final String phone;
  final String profileImage;

  UserProfile({
    required this.name,
    required this.email,
    required this.role,
    required this.employeeId,
    required this.department,
    required this.phone,
    required this.profileImage,
  });
}

// ==================== SERVICES ====================

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final List<User> _users = [];

  // Sign up a new user
  String? signUp(
      String name, String email, String password, String confirmPassword) {
    // Validate inputs
    if (name.trim().isEmpty) {
      return 'Name is required';
    }
    if (!_isValidEmail(email)) {
      return 'Please enter a valid email';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }

    // Check if email already exists
    if (_users.any((user) => user.email.toLowerCase() == email.toLowerCase())) {
      return 'Email already registered';
    }

    // Create new user
    _users.add(User(name: name, email: email, password: password));
    return null; // Success
  }

  // Login user
  String? login(String email, String password) {
    if (email.trim().isEmpty) {
      return 'Email is required';
    }
    if (password.trim().isEmpty) {
      return 'Password is required';
    }

    final user = _users.firstWhere(
      (user) => user.email.toLowerCase() == email.toLowerCase(),
      orElse: () => User(name: '', email: '', password: ''),
    );

    if (user.email.isEmpty) {
      return 'No account found with this email';
    }

    if (user.password != password) {
      return 'Incorrect password';
    }

    return null; // Success
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Get registered users count (for debugging)
  int get userCount => _users.length;
}

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal() {
    _initializeSampleData();
  }

  final List<PatientRecord> _patients = [];
  final List<VitalSigns> _vitalSigns = [];
  final List<EmergencyRecord> _emergencyRecords = [];
  final List<MedicalReport> _reports = [];
  UserProfile? _currentUser;

  // Getters
  List<PatientRecord> get patients => List.unmodifiable(_patients);
  List<VitalSigns> get vitalSigns => List.unmodifiable(_vitalSigns);
  List<EmergencyRecord> get emergencyRecords =>
      List.unmodifiable(_emergencyRecords);
  List<MedicalReport> get reports => List.unmodifiable(_reports);
  UserProfile? get currentUser => _currentUser;

  void _initializeSampleData() {
    // Initialize User Profile
    _currentUser = UserProfile(
      name: 'Dr. Sarah Johnson',
      email: 'sarah.johnson@cardioaid.com',
      role: 'Emergency Physician',
      employeeId: 'EMP-2024-001',
      department: 'Emergency Medicine',
      phone: '+1 (555) 987-6543',
      profileImage: 'assets/profile_placeholder.png',
    );

    // Initialize Patient Records
    _patients.addAll([
      PatientRecord(
        id: 'P001',
        name: 'John Anderson',
        age: 65,
        bloodType: 'O+',
        condition: 'Stable - Post MI',
        admissionDate: '2026-01-10',
        roomNumber: '301',
      ),
      PatientRecord(
        id: 'P002',
        name: 'Maria Garcia',
        age: 52,
        bloodType: 'A+',
        condition: 'Critical - Cardiac Arrest',
        admissionDate: '2026-01-14',
        roomNumber: 'ICU-2',
      ),
      PatientRecord(
        id: 'P003',
        name: 'Robert Chen',
        age: 71,
        bloodType: 'B-',
        condition: 'Monitoring - Heart Failure',
        admissionDate: '2026-01-12',
        roomNumber: '215',
      ),
      PatientRecord(
        id: 'P004',
        name: 'Jennifer Williams',
        age: 48,
        bloodType: 'AB+',
        condition: 'Stable - Chest Pain Evaluation',
        admissionDate: '2026-01-13',
        roomNumber: '402',
      ),
      PatientRecord(
        id: 'P005',
        name: 'Michael Brown',
        age: 58,
        bloodType: 'O-',
        condition: 'Critical - Unstable Angina',
        admissionDate: '2026-01-14',
        roomNumber: 'ICU-5',
      ),
      PatientRecord(
        id: 'P006',
        name: 'Linda Martinez',
        age: 63,
        bloodType: 'A-',
        condition: 'Stable - Arrhythmia',
        admissionDate: '2026-01-11',
        roomNumber: '318',
      ),
      PatientRecord(
        id: 'P007',
        name: 'David Lee',
        age: 55,
        bloodType: 'B+',
        condition: 'Monitoring - Hypertension',
        admissionDate: '2026-01-13',
        roomNumber: '225',
      ),
      PatientRecord(
        id: 'P008',
        name: 'Patricia Davis',
        age: 69,
        bloodType: 'O+',
        condition: 'Stable - Recovering',
        admissionDate: '2026-01-09',
        roomNumber: '412',
      ),
      PatientRecord(
        id: 'P009',
        name: 'James Wilson',
        age: 76,
        bloodType: 'A+',
        condition: 'Critical - Heart Attack',
        admissionDate: '2026-01-15',
        roomNumber: 'ICU-1',
      ),
      PatientRecord(
        id: 'P010',
        name: 'Elizabeth Taylor',
        age: 44,
        bloodType: 'AB-',
        condition: 'Stable - Observation',
        admissionDate: '2026-01-14',
        roomNumber: '307',
      ),
    ]);

    // Initialize Vital Signs
    _vitalSigns.addAll([
      VitalSigns(
          patientId: 'P001',
          patientName: 'John Anderson',
          heartRate: 72,
          bloodPressure: '120/80',
          temperature: 98.6,
          oxygenLevel: 98,
          timestamp: '10:15 AM'),
      VitalSigns(
          patientId: 'P002',
          patientName: 'Maria Garcia',
          heartRate: 145,
          bloodPressure: '160/95',
          temperature: 99.2,
          oxygenLevel: 89,
          timestamp: '10:20 AM'),
      VitalSigns(
          patientId: 'P003',
          patientName: 'Robert Chen',
          heartRate: 88,
          bloodPressure: '135/85',
          temperature: 98.4,
          oxygenLevel: 94,
          timestamp: '10:25 AM'),
      VitalSigns(
          patientId: 'P004',
          patientName: 'Jennifer Williams',
          heartRate: 78,
          bloodPressure: '118/75',
          temperature: 98.7,
          oxygenLevel: 97,
          timestamp: '10:30 AM'),
      VitalSigns(
          patientId: 'P005',
          patientName: 'Michael Brown',
          heartRate: 132,
          bloodPressure: '155/92',
          temperature: 99.8,
          oxygenLevel: 91,
          timestamp: '10:35 AM'),
      VitalSigns(
          patientId: 'P006',
          patientName: 'Linda Martinez',
          heartRate: 76,
          bloodPressure: '125/82',
          temperature: 98.5,
          oxygenLevel: 96,
          timestamp: '10:40 AM'),
      VitalSigns(
          patientId: 'P007',
          patientName: 'David Lee',
          heartRate: 82,
          bloodPressure: '142/88',
          temperature: 98.8,
          oxygenLevel: 95,
          timestamp: '10:45 AM'),
      VitalSigns(
          patientId: 'P008',
          patientName: 'Patricia Davis',
          heartRate: 70,
          bloodPressure: '115/72',
          temperature: 98.3,
          oxygenLevel: 99,
          timestamp: '10:50 AM'),
      VitalSigns(
          patientId: 'P009',
          patientName: 'James Wilson',
          heartRate: 156,
          bloodPressure: '170/98',
          temperature: 100.1,
          oxygenLevel: 87,
          timestamp: '10:55 AM'),
      VitalSigns(
          patientId: 'P010',
          patientName: 'Elizabeth Taylor',
          heartRate: 74,
          bloodPressure: '122/78',
          temperature: 98.6,
          oxygenLevel: 97,
          timestamp: '11:00 AM'),
      VitalSigns(
          patientId: 'P001',
          patientName: 'John Anderson',
          heartRate: 68,
          bloodPressure: '118/76',
          temperature: 98.4,
          oxygenLevel: 99,
          timestamp: '11:15 AM'),
      VitalSigns(
          patientId: 'P002',
          patientName: 'Maria Garcia',
          heartRate: 138,
          bloodPressure: '158/93',
          temperature: 99.4,
          oxygenLevel: 90,
          timestamp: '11:20 AM'),
      VitalSigns(
          patientId: 'P003',
          patientName: 'Robert Chen',
          heartRate: 85,
          bloodPressure: '132/83',
          temperature: 98.3,
          oxygenLevel: 95,
          timestamp: '11:25 AM'),
      VitalSigns(
          patientId: 'P005',
          patientName: 'Michael Brown',
          heartRate: 128,
          bloodPressure: '152/90',
          temperature: 99.6,
          oxygenLevel: 92,
          timestamp: '11:35 AM'),
      VitalSigns(
          patientId: 'P009',
          patientName: 'James Wilson',
          heartRate: 148,
          bloodPressure: '165/96',
          temperature: 99.9,
          oxygenLevel: 88,
          timestamp: '11:55 AM'),
    ]);

    // Initialize Emergency Records
    _emergencyRecords.addAll([
      EmergencyRecord(
          id: 'E001',
          timestamp: '2026-01-15 09:15 AM',
          responsiveness: true,
          breathing: true,
          pulse: true,
          heartRhythm: false,
          status: 'Stable'),
      EmergencyRecord(
          id: 'E002',
          timestamp: '2026-01-15 08:45 AM',
          responsiveness: false,
          breathing: false,
          pulse: true,
          heartRhythm: false,
          status: 'Critical'),
      EmergencyRecord(
          id: 'E003',
          timestamp: '2026-01-14 11:30 PM',
          responsiveness: true,
          breathing: true,
          pulse: true,
          heartRhythm: true,
          status: 'Resolved'),
      EmergencyRecord(
          id: 'E004',
          timestamp: '2026-01-14 06:20 PM',
          responsiveness: true,
          breathing: false,
          pulse: true,
          heartRhythm: false,
          status: 'Critical'),
      EmergencyRecord(
          id: 'E005',
          timestamp: '2026-01-14 02:15 PM',
          responsiveness: true,
          breathing: true,
          pulse: true,
          heartRhythm: true,
          status: 'Stable'),
      EmergencyRecord(
          id: 'E006',
          timestamp: '2026-01-13 09:45 AM',
          responsiveness: true,
          breathing: true,
          pulse: false,
          heartRhythm: false,
          status: 'Critical'),
      EmergencyRecord(
          id: 'E007',
          timestamp: '2026-01-13 07:30 AM',
          responsiveness: true,
          breathing: true,
          pulse: true,
          heartRhythm: true,
          status: 'Resolved'),
    ]);

    // Initialize Medical Reports
    _reports.addAll([
      MedicalReport(
        id: 'R001',
        patientName: 'John Anderson',
        reportType: 'ECG Analysis',
        date: '2026-01-14',
        summary:
            'Normal sinus rhythm. No acute ST changes. Previous MI evidence present.',
        doctor: 'Dr. Sarah Johnson',
      ),
      MedicalReport(
        id: 'R002',
        patientName: 'Maria Garcia',
        reportType: 'Emergency Assessment',
        date: '2026-01-15',
        summary:
            'Cardiac arrest protocol initiated. ROSC achieved after 4 minutes. Critical condition.',
        doctor: 'Dr. Michael Roberts',
      ),
      MedicalReport(
        id: 'R003',
        patientName: 'Robert Chen',
        reportType: 'Cardiology Consult',
        date: '2026-01-13',
        summary:
            'Heart failure exacerbation. Diuretic therapy adjusted. Close monitoring required.',
        doctor: 'Dr. Emily Chen',
      ),
      MedicalReport(
        id: 'R004',
        patientName: 'Jennifer Williams',
        reportType: 'Chest Pain Evaluation',
        date: '2026-01-13',
        summary:
            'Troponin negative. Stress test scheduled. Non-cardiac chest pain likely.',
        doctor: 'Dr. Sarah Johnson',
      ),
      MedicalReport(
        id: 'R005',
        patientName: 'Michael Brown',
        reportType: 'Cardiac Catheterization',
        date: '2026-01-14',
        summary:
            '90% LAD stenosis identified. Stent placement recommended. High-risk patient.',
        doctor: 'Dr. David Martinez',
      ),
      MedicalReport(
        id: 'R006',
        patientName: 'Linda Martinez',
        reportType: 'Holter Monitor Results',
        date: '2026-01-12',
        summary:
            'Intermittent atrial fibrillation detected. Anticoagulation initiated.',
        doctor: 'Dr. Emily Chen',
      ),
      MedicalReport(
        id: 'R007',
        patientName: 'David Lee',
        reportType: 'Blood Pressure Management',
        date: '2026-01-13',
        summary:
            'Hypertension poorly controlled. Medication regimen adjusted. Follow-up in 2 weeks.',
        doctor: 'Dr. Sarah Johnson',
      ),
      MedicalReport(
        id: 'R008',
        patientName: 'James Wilson',
        reportType: 'STEMI Protocol',
        date: '2026-01-15',
        summary:
            'Anterior wall STEMI. Emergent PCI performed. Patient stabilized in ICU.',
        doctor: 'Dr. Michael Roberts',
      ),
    ]);
  }

  // Add methods (for future functionality)
  void addPatient(PatientRecord patient) => _patients.add(patient);
  void addVitalSigns(VitalSigns vitals) => _vitalSigns.add(vitals);
  void addEmergencyRecord(EmergencyRecord record) =>
      _emergencyRecords.add(record);
  void addReport(MedicalReport report) => _reports.add(report);
}

// ==================== RESPONSIVE UTILITIES ====================

class ResponsiveHelper {
  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;

  // Screen type detection
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  // Responsive padding
  static double getPadding(BuildContext context) {
    if (isMobile(context)) return 16.0;
    if (isTablet(context)) return 24.0;
    return 32.0;
  }

  static double getCardPadding(BuildContext context) {
    if (isMobile(context)) return 20.0;
    if (isTablet(context)) return 28.0;
    return 32.0;
  }

  // Responsive font sizes
  static double getHeadlineSize(BuildContext context) {
    if (isMobile(context)) return 28.0;
    if (isTablet(context)) return 30.0;
    return 32.0;
  }

  static double getTitleSize(BuildContext context) {
    if (isMobile(context)) return 20.0;
    if (isTablet(context)) return 22.0;
    return 24.0;
  }

  static double getBodySize(BuildContext context) {
    if (isMobile(context)) return 14.0;
    if (isTablet(context)) return 15.0;
    return 16.0;
  }

  static double getCaptionSize(BuildContext context) {
    if (isMobile(context)) return 12.0;
    return 14.0;
  }

  // Responsive icon sizes
  static double getIconSize(BuildContext context, double baseSize) {
    if (isMobile(context)) return baseSize * 0.85;
    return baseSize;
  }

  // Card max width
  static double getCardMaxWidth(BuildContext context) {
    if (isMobile(context)) return double.infinity;
    if (isTablet(context)) return 500;
    return 450;
  }

  // Grid columns for dashboard
  static int getDashboardColumns(BuildContext context) {
    if (isMobile(context)) return 1;
    return 2;
  }

  // Responsive spacing
  static double getSpacing(BuildContext context) {
    if (isMobile(context)) return 12.0;
    return 16.0;
  }
}

// ==================== MAIN APP ====================

class CardioAidApp extends StatelessWidget {
  const CardioAidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CardioAid',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFE63946),
        scaffoldBackgroundColor: const Color(0xFF0A0E27),
        fontFamily: 'Inter',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
              fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          headlineMedium: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          bodyLarge: TextStyle(fontSize: 16, color: Colors.white70),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.white60),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// ==================== SPLASH SCREEN ====================

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();

    // Navigate to login after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0E27),
              Color(0xFF1A1F3A),
              Color(0xFF2D1B4E),
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated heart icon with glow effect - Responsive
                  Container(
                    padding: EdgeInsets.all(
                        ResponsiveHelper.isMobile(context) ? 20 : 30),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFE63946).withOpacity(0.3),
                          const Color(0xFFE63946).withOpacity(0.1),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE63946).withOpacity(0.5),
                          blurRadius:
                              ResponsiveHelper.isMobile(context) ? 30 : 40,
                          spreadRadius:
                              ResponsiveHelper.isMobile(context) ? 5 : 10,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.favorite,
                      color: const Color(0xFFE63946),
                      size: ResponsiveHelper.getIconSize(context, 80),
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.getSpacing(context) * 2),
                  // App name - Responsive
                  Text(
                    'CardioAid',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.isMobile(context) ? 36 : 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.getSpacing(context)),
                  // Subtitle - Responsive
                  Text(
                    'Emergency Cardiac Care System',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getBodySize(context),
                      color: Colors.white.withOpacity(0.7),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 50),
                  // Loading indicator
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        const Color(0xFFE63946).withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== SIGN UP SCREEN ====================

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignUp() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    final error = _authService.signUp(
      _nameController.text,
      _emailController.text,
      _passwordController.text,
      _confirmPasswordController.text,
    );

    setState(() => _isLoading = false);

    if (error != null) {
      setState(() => _errorMessage = error);
    } else {
      // Success - navigate to login
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully! Please login.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0E27),
              Color(0xFF1A1F3A),
              Color(0xFF2D1B4E),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(ResponsiveHelper.getPadding(context)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Header - Responsive
                  Icon(
                    Icons.person_add,
                    size: ResponsiveHelper.getIconSize(context, 60),
                    color: const Color(0xFFE63946),
                  ),
                  SizedBox(height: ResponsiveHelper.getSpacing(context)),
                  Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getHeadlineSize(context),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.getSpacing(context) * 0.5),
                  Text(
                    'Sign up to get started',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getBodySize(context),
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.getSpacing(context) * 2.5),

                  // Sign Up Box - Responsive
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: ResponsiveHelper.getCardMaxWidth(context),
                    ),
                    padding: EdgeInsets.all(
                        ResponsiveHelper.getCardPadding(context)),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(
                          ResponsiveHelper.isMobile(context) ? 20 : 24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Name field
                          _buildTextField(
                            controller: _nameController,
                            label: 'Full Name',
                            icon: Icons.person_outline,
                          ),
                          const SizedBox(height: 20),

                          // Email field
                          _buildTextField(
                            controller: _emailController,
                            label: 'Email',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 20),

                          // Password field
                          _buildTextField(
                            controller: _passwordController,
                            label: 'Password',
                            icon: Icons.lock_outline,
                            isPassword: true,
                          ),
                          const SizedBox(height: 20),

                          // Confirm Password field
                          _buildTextField(
                            controller: _confirmPasswordController,
                            label: 'Confirm Password',
                            icon: Icons.lock_outline,
                            isPassword: true,
                          ),
                          const SizedBox(height: 12),

                          // Password hint
                          Row(
                            children: [
                              Icon(Icons.info_outline,
                                  size: 14,
                                  color: Colors.white.withOpacity(0.5)),
                              const SizedBox(width: 6),
                              Text(
                                'Password must be at least 6 characters',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.5)),
                              ),
                            ],
                          ),

                          // Error message
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: Colors.red.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline,
                                      color: Colors.red, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: const TextStyle(
                                          color: Colors.red, fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 28),

                          // Sign Up button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleSignUp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE63946),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 8,
                                shadowColor:
                                    const Color(0xFFE63946).withOpacity(0.5),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : const Text(
                                      'Sign Up',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(color: Colors.white.withOpacity(0.7)),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()),
                          );
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: Color(0xFFE63946),
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
        prefixIcon: Icon(icon, color: const Color(0xFFE63946)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE63946), width: 2),
        ),
      ),
    );
  }
}

// ==================== LOGIN SCREEN ====================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    final error = _authService.login(
      _emailController.text,
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (error != null) {
      setState(() => _errorMessage = error);
    } else {
      // Success - navigate to dashboard
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Dashboard()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0E27),
              Color(0xFF1A1F3A),
              Color(0xFF2D1B4E),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(ResponsiveHelper.getPadding(context)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Header - Responsive
                  Icon(
                    Icons.favorite,
                    size: ResponsiveHelper.getIconSize(context, 60),
                    color: const Color(0xFFE63946),
                  ),
                  SizedBox(height: ResponsiveHelper.getSpacing(context)),
                  Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getHeadlineSize(context),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.getSpacing(context) * 0.5),
                  Text(
                    'Login to continue',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getBodySize(context),
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.getSpacing(context) * 2.5),

                  // Login Box - Responsive
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: ResponsiveHelper.getCardMaxWidth(context),
                    ),
                    padding: EdgeInsets.all(
                        ResponsiveHelper.getCardPadding(context)),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(
                          ResponsiveHelper.isMobile(context) ? 20 : 24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Email field
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle:
                                TextStyle(color: Colors.white.withOpacity(0.6)),
                            prefixIcon: const Icon(Icons.email_outlined,
                                color: Color(0xFFE63946)),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.05),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.1)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.1)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Color(0xFFE63946), width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Password field
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle:
                                TextStyle(color: Colors.white.withOpacity(0.6)),
                            prefixIcon: const Icon(Icons.lock_outline,
                                color: Color(0xFFE63946)),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.05),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.1)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.1)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Color(0xFFE63946), width: 2),
                            ),
                          ),
                        ),

                        // Error message
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: Colors.red.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline,
                                    color: Colors.red, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                        color: Colors.red, fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 28),

                        // Login button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE63946),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 8,
                              shadowColor:
                                  const Color(0xFFE63946).withOpacity(0.5),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Sign up link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Colors.white.withOpacity(0.7)),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SignUpScreen()),
                          );
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Color(0xFFE63946),
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== DASHBOARD ====================

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  Widget _buildCard(
      BuildContext ctx, String title, IconData icon, Widget page, Color color) {
    return GestureDetector(
      onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => page)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.15),
              color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 40),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0E27),
              Color(0xFF1A1F3A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App bar - Responsive
              Padding(
                padding: EdgeInsets.all(ResponsiveHelper.getPadding(context)),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE63946).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.favorite,
                        color: const Color(0xFFE63946),
                        size: ResponsiveHelper.isMobile(context) ? 24 : 28,
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.getSpacing(context)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CardioAid',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getTitleSize(context),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          DatabaseService().currentUser?.name ??
                              'Dr. Sarah Johnson',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getCaptionSize(context),
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const UserProfileScreen()),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7B68EE).withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.account_circle,
                          color: const Color(0xFF7B68EE),
                          size: ResponsiveHelper.isMobile(context) ? 28 : 32,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Grid - Responsive
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(ResponsiveHelper.getPadding(context)),
                  child: GridView.count(
                    crossAxisCount:
                        ResponsiveHelper.getDashboardColumns(context),
                    crossAxisSpacing: ResponsiveHelper.getSpacing(context),
                    mainAxisSpacing: ResponsiveHelper.getSpacing(context),
                    childAspectRatio:
                        ResponsiveHelper.isMobile(context) ? 1.8 : 1.0,
                    children: [
                      _buildCard(
                        context,
                        'Emergency Mode',
                        Icons.warning_rounded,
                        const EmergencyScreen(),
                        const Color(0xFFE63946),
                      ),
                      _buildCard(
                        context,
                        'Monitoring & Tests',
                        Icons.monitor_heart_rounded,
                        MonitoringScreen(),
                        const Color(0xFF457B9D),
                      ),
                      _buildCard(
                        context,
                        'Patients',
                        Icons.people_rounded,
                        PatientScreen(),
                        const Color(0xFF06A77D),
                      ),
                      _buildCard(
                        context,
                        'Hospital Alert',
                        Icons.local_hospital_rounded,
                        const HospitalAlertScreen(),
                        const Color(0xFF7B68EE),
                      ),
                      _buildCard(
                        context,
                        'Reports',
                        Icons.description_rounded,
                        ReportScreen(),
                        const Color(0xFFF4A261),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== EMERGENCY SCREEN ====================

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  final _db = DatabaseService();
  bool _responsiveness = false;
  bool _breathing = false;
  bool _pulse = false;
  bool _heartRhythm = false;

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Critical':
        return const Color(0xFFE63946);
      case 'Stable':
        return const Color(0xFF06A77D);
      case 'Resolved':
        return const Color(0xFF457B9D);
      default:
        return Colors.grey;
    }
  }

  Widget _buildEmergencyCard(EmergencyRecord record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getStatusColor(record.status).withOpacity(0.15),
            _getStatusColor(record.status).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getStatusColor(record.status).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.white70),
                  const SizedBox(width: 8),
                  Text(
                    record.timestamp,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(record.status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  record.status,
                  style: TextStyle(
                    color: _getStatusColor(record.status),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildIndicator('Responsive', record.responsiveness),
              const SizedBox(width: 12),
              _buildIndicator('Breathing', record.breathing),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildIndicator('Pulse', record.pulse),
              const SizedBox(width: 12),
              _buildIndicator('Heart Rhythm', record.heartRhythm),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(String label, bool value) {
    return Row(
      children: [
        Icon(
          value ? Icons.check_circle : Icons.cancel,
          size: 16,
          color: value ? const Color(0xFF06A77D) : const Color(0xFFE63946),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final records = _db.emergencyRecords;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0E27),
              Color(0xFF1A1F3A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Emergency Mode',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Recent assessments header
                    const Text(
                      'Recent Emergency Assessments',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Emergency records
                    ...records.map((record) => _buildEmergencyCard(record)),

                    const SizedBox(height: 24),

                    // New assessment form
                    const Text(
                      'New Assessment',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildCheckbox('Responsiveness', _responsiveness, (val) {
                      setState(() => _responsiveness = val ?? false);
                    }),
                    const SizedBox(height: 12),
                    _buildCheckbox('Breathing', _breathing, (val) {
                      setState(() => _breathing = val ?? false);
                    }),
                    const SizedBox(height: 12),
                    _buildCheckbox('Pulse', _pulse, (val) {
                      setState(() => _pulse = val ?? false);
                    }),
                    const SizedBox(height: 12),
                    _buildCheckbox('Heart Rhythm', _heartRhythm, (val) {
                      setState(() => _heartRhythm = val ?? false);
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(String title, bool value, Function(bool?) onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: CheckboxListTile(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFFE63946),
        checkColor: Colors.white,
      ),
    );
  }
}

// ==================== MONITORING SCREEN ====================

class MonitoringScreen extends StatelessWidget {
  MonitoringScreen({super.key});

  final _db = DatabaseService();

  Color _getVitalsColor(VitalSigns vitals) {
    // Determine status based on vital signs
    if (vitals.heartRate > 120 ||
        vitals.heartRate < 60 ||
        vitals.oxygenLevel < 90 ||
        vitals.temperature > 99.5) {
      return const Color(0xFFE63946); // Critical - Red
    } else if (vitals.heartRate > 100 || vitals.oxygenLevel < 95) {
      return const Color(0xFFF4A261); // Warning - Orange
    }
    return const Color(0xFF06A77D); // Normal - Green
  }

  Widget _buildVitalsCard(VitalSigns vitals) {
    final color = _getVitalsColor(vitals);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF457B9D).withOpacity(0.15),
            const Color(0xFF457B9D).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF457B9D).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                vitals.patientName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: color),
                    const SizedBox(width: 6),
                    Text(
                      vitals.timestamp,
                      style: TextStyle(color: color, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildVitalIndicator(
                  Icons.favorite,
                  'Heart Rate',
                  '${vitals.heartRate} bpm',
                  vitals.heartRate > 120 || vitals.heartRate < 60,
                ),
              ),
              Expanded(
                child: _buildVitalIndicator(
                  Icons.air,
                  'Oxygen',
                  '${vitals.oxygenLevel}%',
                  vitals.oxygenLevel < 90,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildVitalIndicator(
                  Icons.thermostat,
                  'Temp',
                  '${vitals.temperature}°F',
                  vitals.temperature > 99.5,
                ),
              ),
              Expanded(
                child: _buildVitalIndicator(
                  Icons.monitor_heart,
                  'BP',
                  vitals.bloodPressure,
                  false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVitalIndicator(
      IconData icon, String label, String value, bool isAbnormal) {
    final color =
        isAbnormal ? const Color(0xFFE63946) : const Color(0xFF06A77D);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style:
                  TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final vitals = _db.vitalSigns;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0E27),
              Color(0xFF1A1F3A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Monitoring & Tests',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const Text(
                      'Real-Time Vital Signs',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...vitals.map((vital) => _buildVitalsCard(vital)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== PATIENT SCREEN ====================

class PatientScreen extends StatelessWidget {
  PatientScreen({super.key});

  final _db = DatabaseService();

  Color _getConditionColor(String condition) {
    if (condition.contains('Critical')) {
      return const Color(0xFFE63946);
    } else if (condition.contains('Monitoring')) {
      return const Color(0xFFF4A261);
    }
    return const Color(0xFF06A77D);
  }

  Widget _buildPatientCard(PatientRecord patient) {
    final color = _getConditionColor(patient.condition);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF06A77D).withOpacity(0.15),
            const Color(0xFF06A77D).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF06A77D).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  patient.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Room ${patient.roomNumber}',
                  style: TextStyle(
                      color: color, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.person, size: 14, color: Colors.white70),
              const SizedBox(width: 6),
              Text(
                '${patient.age} years • ${patient.bloodType}',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.7), fontSize: 14),
              ),
              const SizedBox(width: 16),
              Icon(Icons.calendar_today, size: 14, color: Colors.white70),
              const SizedBox(width: 6),
              Text(
                'Admitted: ${patient.admissionDate}',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.7), fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.medical_services, size: 16, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    patient.condition,
                    style: TextStyle(
                        color: color,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final patients = _db.patients;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0E27),
              Color(0xFF1A1F3A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Patients',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Patient Records',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF06A77D).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${patients.length} Total',
                            style: const TextStyle(
                                color: Color(0xFF06A77D),
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...patients.map((patient) => _buildPatientCard(patient)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== REPORT SCREEN ====================

class ReportScreen extends StatelessWidget {
  ReportScreen({super.key});

  final _db = DatabaseService();

  Widget _buildReportCard(MedicalReport report) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF4A261).withOpacity(0.15),
            const Color(0xFFF4A261).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF4A261).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4A261).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  report.reportType,
                  style: const TextStyle(
                    color: Color(0xFFF4A261),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 14, color: Colors.white70),
                  const SizedBox(width: 6),
                  Text(
                    report.date,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            report.patientName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.medical_information,
                  size: 14, color: Colors.white70),
              const SizedBox(width: 6),
              Text(
                'Dr. ${report.doctor.split(' ').last}',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.7), fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              report.summary,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 13,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reports = _db.reports;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0E27),
              Color(0xFF1A1F3A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Reports',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const Text(
                      'Medical Reports',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...reports.map((report) => _buildReportCard(report)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== HOSPITAL ALERT SCREEN ====================

class HospitalAlertScreen extends StatefulWidget {
  const HospitalAlertScreen({super.key});

  @override
  State<HospitalAlertScreen> createState() => _HospitalAlertScreenState();
}

class _HospitalAlertScreenState extends State<HospitalAlertScreen> {
  // Sample hospitals data
  final List<Hospital> _hospitals = [
    Hospital(
      name: 'City Medical Center',
      address: '123 Main Street, Downtown',
      phone: '+1 (555) 123-4567',
      distance: '2.3 km',
    ),
    Hospital(
      name: 'General Hospital',
      address: '456 Oak Avenue, Central District',
      phone: '+1 (555) 234-5678',
      distance: '3.1 km',
    ),
    Hospital(
      name: 'St. Mary\'s Hospital',
      address: '789 Pine Road, North Side',
      phone: '+1 (555) 345-6789',
      distance: '4.5 km',
    ),
    Hospital(
      name: 'Metropolitan Hospital',
      address: '321 Elm Street, West End',
      phone: '+1 (555) 456-7890',
      distance: '5.2 km',
    ),
    Hospital(
      name: 'Regional Medical Center',
      address: '654 Cedar Lane, East Quarter',
      phone: '+1 (555) 567-8901',
      distance: '6.8 km',
    ),
  ];

  // Patient condition checkboxes
  bool _cardiacArrest = false;
  bool _heartAttack = false;
  bool _chestPain = false;
  bool _difficultyBreathing = false;
  bool _lossOfConsciousness = false;

  void _sendAlert() {
    // Get selected conditions
    List<String> selectedConditions = [];
    if (_cardiacArrest) selectedConditions.add('Cardiac Arrest');
    if (_heartAttack) selectedConditions.add('Heart Attack');
    if (_chestPain) selectedConditions.add('Chest Pain');
    if (_difficultyBreathing) selectedConditions.add('Difficulty Breathing');
    if (_lossOfConsciousness) selectedConditions.add('Loss of Consciousness');

    if (selectedConditions.isEmpty) {
      // Show error if no conditions selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one condition'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF7B68EE).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.check_circle,
                color: Color(0xFF7B68EE),
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Alert Sent',
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Emergency alert sent to:',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._hospitals.map((hospital) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.local_hospital,
                          color: Color(0xFF7B68EE), size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          hospital.name,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 16),
            const Text(
              'Conditions reported:',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...selectedConditions.map((condition) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.warning,
                          color: Color(0xFFE63946), size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          condition,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              backgroundColor: const Color(0xFF7B68EE),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalCard(Hospital hospital) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF7B68EE).withOpacity(0.15),
            const Color(0xFF7B68EE).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF7B68EE).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7B68EE).withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF7B68EE).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.local_hospital,
                  color: Color(0xFF7B68EE),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hospital.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: Color(0xFF7B68EE),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          hospital.distance,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.pin_drop_outlined,
                size: 16,
                color: Colors.white54,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hospital.address,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.phone,
                size: 16,
                color: Colors.white54,
              ),
              const SizedBox(width: 8),
              Text(
                hospital.phone,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckbox(String title, bool value, Function(bool?) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value
              ? const Color(0xFFE63946).withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
        ),
      ),
      child: CheckboxListTile(
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: ResponsiveHelper.getBodySize(context),
            fontWeight: value ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFFE63946),
        checkColor: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0E27),
              Color(0xFF1A1F3A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(ResponsiveHelper.getPadding(context)),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      iconSize: ResponsiveHelper.isMobile(context) ? 24 : 28,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Hospital Alert',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getTitleSize(context),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(ResponsiveHelper.getPadding(context)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hospitals section
                      Text(
                        'Nearby Hospitals',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getTitleSize(context) - 2,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._hospitals
                          .map((hospital) => _buildHospitalCard(hospital)),

                      const SizedBox(height: 24),

                      // Patient condition section
                      Text(
                        'Patient Condition',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getTitleSize(context) - 2,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildCheckbox('Cardiac Arrest', _cardiacArrest, (val) {
                        setState(() => _cardiacArrest = val ?? false);
                      }),
                      _buildCheckbox('Heart Attack', _heartAttack, (val) {
                        setState(() => _heartAttack = val ?? false);
                      }),
                      _buildCheckbox('Chest Pain', _chestPain, (val) {
                        setState(() => _chestPain = val ?? false);
                      }),
                      _buildCheckbox(
                          'Difficulty Breathing', _difficultyBreathing, (val) {
                        setState(() => _difficultyBreathing = val ?? false);
                      }),
                      _buildCheckbox(
                          'Loss of Consciousness', _lossOfConsciousness, (val) {
                        setState(() => _lossOfConsciousness = val ?? false);
                      }),

                      const SizedBox(height: 24),

                      // Send Alert button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _sendAlert,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7B68EE),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 8,
                            shadowColor:
                                const Color(0xFF7B68EE).withOpacity(0.5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.send,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Send Alert',
                                style: TextStyle(
                                  fontSize:
                                      ResponsiveHelper.getBodySize(context) + 2,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== USER PROFILE SCREEN ====================

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF7B68EE).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF7B68EE), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = DatabaseService().currentUser;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0E27),
              Color(0xFF1A1F3A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'My Profile',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Profile Picture
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF7B68EE).withOpacity(0.5),
                              const Color(0xFF7B68EE).withOpacity(0.1),
                            ],
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7B68EE).withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 80,
                            color: Color(0xFF7B68EE),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Name
                      Text(
                        user?.name ?? 'Unknown User',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user?.role ?? 'Staff Member',
                        style: TextStyle(
                          color: const Color(0xFF7B68EE).withOpacity(0.9),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Information Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.08),
                              Colors.white.withOpacity(0.03),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              Icons.email,
                              'Email',
                              user?.email ?? 'N/A',
                            ),
                            Divider(color: Colors.white.withOpacity(0.1)),
                            _buildInfoRow(
                              Icons.badge,
                              'Employee ID',
                              user?.employeeId ?? 'N/A',
                            ),
                            Divider(color: Colors.white.withOpacity(0.1)),
                            _buildInfoRow(
                              Icons.business,
                              'Department',
                              user?.department ?? 'N/A',
                            ),
                            Divider(color: Colors.white.withOpacity(0.1)),
                            _buildInfoRow(
                              Icons.phone,
                              'Phone',
                              user?.phone ?? 'N/A',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Edit Profile Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            // Edit profile functionality (UI only for now)
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Edit profile feature coming soon!'),
                                backgroundColor: Color(0xFF7B68EE),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7B68EE),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 8,
                            shadowColor:
                                const Color(0xFF7B68EE).withOpacity(0.5),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.edit, color: Colors.white, size: 20),
                              SizedBox(width: 12),
                              Text(
                                'Edit Profile',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
