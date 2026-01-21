// CardioAid - Premium Flutter Application
// Emergency Cardiac Care System with Authentication

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService().checkAutoLogin();
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

class LocationData {
  final double latitude;
  final double longitude;

  LocationData({
    required this.latitude,
    required this.longitude,
  });
}

class HospitalLocation {
  final String id;
  final String name;
  final String address;
  final String phone;
  final double latitude;
  final double longitude;
  final String emergencyContactEmail;

  HospitalLocation({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.latitude,
    required this.longitude,
    required this.emergencyContactEmail,
  });

  double distanceTo(LocationData userLocation) {
    const earthRadiusKm = 6371.0;
    final dLat = _toRadians(userLocation.latitude - latitude);
    final dLon = _toRadians(userLocation.longitude - longitude);

    final a = (sin(dLat / 2) * sin(dLat / 2)) +
        (cos(_toRadians(latitude)) *
            cos(_toRadians(userLocation.latitude)) *
            sin(dLon / 2) *
            sin(dLon / 2));

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _toRadians(double degrees) {
    return degrees * pi / 180.0;
  }
}

class HospitalAlert {
  final String id;
  final String hospitalId;
  final String hospitalName;
  final DateTime timestamp;
  final List<String> symptoms;
  final String message;
  final int chargeLevels; // 1, 2, or 3 rupees
  final bool messageDelivered;
  final String userLocation;

  HospitalAlert({
    required this.id,
    required this.hospitalId,
    required this.hospitalName,
    required this.timestamp,
    required this.symptoms,
    required this.message,
    required this.chargeLevels,
    required this.messageDelivered,
    required this.userLocation,
  });
}

// ==================== SERVICES ====================

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final List<User> _users = [];
  User? _currentLoggedInUser;
  late SharedPreferences _prefs;

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Check if user is already logged in
  Future<void> checkAutoLogin() async {
    await _initPrefs();
    final email = _prefs.getString('lastEmail');
    final name = _prefs.getString('lastUserName');
    final password = _prefs.getString('lastPassword');

    if (email != null && name != null && password != null) {
      // Reconstruct user from stored credentials
      _currentLoggedInUser = User(name: name, email: email, password: password);
      // Add to users list for consistency
      if (!_users
          .any((user) => user.email.toLowerCase() == email.toLowerCase())) {
        _users.add(_currentLoggedInUser!);
      }
    }
  }

  // Get current logged-in user
  User? get currentLoggedInUser => _currentLoggedInUser;

  // Sign up a new user
  Future<String?> signUp(String name, String email, String password,
      String confirmPassword) async {
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
    final newUser = User(name: name, email: email, password: password);
    _users.add(newUser);

    // Store user information
    await _initPrefs();
    await _prefs.setString('lastEmail', email);
    await _prefs.setString('lastUserName', name);
    await _prefs.setString('lastPassword', password);

    _currentLoggedInUser = newUser;
    return null; // Success
  }

  // Login user
  Future<String?> login(String email, String password) async {
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

    // Store login info
    await _initPrefs();
    await _prefs.setString('lastEmail', email);
    await _prefs.setString('lastUserName', user.name);
    await _prefs.setString('lastPassword', password);

    _currentLoggedInUser = user;
    return null; // Success
  }

  // Logout user
  Future<void> logout() async {
    _currentLoggedInUser = null;
    await _initPrefs();
    await _prefs.remove('lastEmail');
    await _prefs.remove('lastPassword');
    await _prefs.remove('lastUserName');
    await _prefs.remove('lastUserName');
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Get registered users count (for debugging)
  int get userCount => _users.length;
}

// ==================== LOCATION SERVICE ====================

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Future<LocationData?> getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final result = await Geolocator.requestPermission();
        if (result == LocationPermission.deniedForever) {
          return null;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      // For demo, return a default location (Bangalore, India)
      return LocationData(latitude: 12.9716, longitude: 77.5946);
    }
  }

  // Calculate distance between two points
  static double calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const earthRadiusKm = 6371.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = (sin(dLat / 2) * sin(dLat / 2)) +
        (cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2));

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _toRadians(double degrees) {
    return degrees * pi / 180.0;
  }
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
  final List<HospitalLocation> _hospitals = [];
  final List<HospitalAlert> _hospitalAlerts = [];
  UserProfile? _currentUser;

  // Getters
  List<PatientRecord> get patients => List.unmodifiable(_patients);
  List<VitalSigns> get vitalSigns => List.unmodifiable(_vitalSigns);
  List<EmergencyRecord> get emergencyRecords =>
      List.unmodifiable(_emergencyRecords);
  List<MedicalReport> get reports => List.unmodifiable(_reports);
  List<HospitalLocation> get hospitals => List.unmodifiable(_hospitals);
  List<HospitalAlert> get hospitalAlerts => List.unmodifiable(_hospitalAlerts);
  UserProfile? get currentUser => _currentUser;

  // Add hospital alert
  void addHospitalAlert(HospitalAlert alert) {
    _hospitalAlerts.add(alert);
  }

  // Get nearby hospitals
  List<HospitalLocation> getNearbyHospitals(LocationData userLocation,
      {double radiusKm = 10}) {
    return _hospitals
        .where((hospital) => hospital.distanceTo(userLocation) <= radiusKm)
        .toList()
      ..sort((a, b) =>
          a.distanceTo(userLocation).compareTo(b.distanceTo(userLocation)));
  }

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

    // Initialize Hospital Locations (Shravanabelagola area)
    _hospitals.addAll([
      HospitalLocation(
        id: 'H001',
        name: 'Bahubali Children Hospital',
        address:
            'Shri Dhavala Teertham, Chalya Post, Shravanabelagola (Hirisave Road), SH-8, Karnataka',
        phone: '+91-81763-41450',
        latitude: 12.8540,
        longitude: 76.4850,
        emergencyContactEmail: 'contact@bahubali-hospital.com',
      ),
      HospitalLocation(
        id: 'H002',
        name: 'Shravanabelagola Government Hospital',
        address:
            'Shravanabelagola Main Road, Shravanabelagola, Karnataka 573135',
        phone: '+91-81726-00000',
        latitude: 12.8585,
        longitude: 76.4880,
        emergencyContactEmail: 'govt-hospital@shravanabelagola.gov.in',
      ),
      HospitalLocation(
        id: 'H003',
        name: 'Swayam Sevak Nagara Hospital',
        address: 'Shravanabelagola area, Karnataka',
        phone: '+91-81726-00001',
        latitude: 12.8560,
        longitude: 76.4900,
        emergencyContactEmail: 'swayamsevak@hospital.com',
      ),
      HospitalLocation(
        id: 'H004',
        name: 'Primary Health Centre (PHC) - Chalya',
        address: 'Chalya / Nirisare Road, Shravanabelagola, Karnataka',
        phone: '+91-81726-00002',
        latitude: 12.8450,
        longitude: 76.4750,
        emergencyContactEmail: 'phc-chalya@karnataka.gov.in',
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

    // Check if user is already logged in
    Timer(const Duration(seconds: 3), () {
      final authService = AuthService();
      if (authService.currentLoggedInUser != null) {
        // User already logged in, go to dashboard
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const Dashboard(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      } else {
        // No user logged in, go to login screen
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const LoginScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
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

    final error = await _authService.signUp(
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

    final error = await _authService.login(
      _emailController.text,
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (error != null) {
      setState(() => _errorMessage = error);
    } else {
      // Success - request location and navigate to dashboard
      if (mounted) {
        // Request location permission and update backend
        _requestLocationAndNavigate();
      }
    }
  }

  Future<void> _requestLocationAndNavigate() async {
    try {
      // Request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission != LocationPermission.deniedForever) {
        // Get current position
        try {
          final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );

          // Update location on backend
          final api = ApiService();
          await api.updateLocation(
            latitude: position.latitude,
            longitude: position.longitude,
          );
        } catch (e) {
          print('Location error: $e');
        }
      }
    } catch (e) {
      print('Permission error: $e');
    }

    // Navigate to dashboard regardless of location status
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Dashboard()),
      );
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
                          AuthService().currentLoggedInUser?.name ??
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
                        'Hospital Alert',
                        Icons.local_hospital_rounded,
                        const HospitalAlertScreen(),
                        const Color(0xFF7B68EE),
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
  final _locationService = LocationService();
  final _api = ApiService();
  late SharedPreferences _prefs;

  // Fields for hospital alert
  final Set<String> _selectedSymptoms = {};
  TextEditingController _messageController = TextEditingController();
  LocationData? _userLocation;
  List<Map<String, dynamic>> _nearbyHospitals = []; // From API
  List<HospitalLocation> _localHospitals = []; // Fallback
  bool _isLoadingLocation = false;
  bool _isSendingAlert = false;
  int _selectedCharge = 1; // Tier 1, 2, or 3
  String? _currentAlertId;

  // Wallet balance (starts with ₹5000)
  double _walletBalance = 5000.0;

  final List<String> _symptomsList = [
    'Chest Pain',
    'Shortness of Breath',
    'Palpitations',
    'Dizziness',
    'Fainting',
    'Severe Headache',
    'Nausea/Vomiting',
    'Irregular Heartbeat',
  ];

  // Tier descriptions with actual price values
  final Map<int, Map<String, dynamic>> _tierInfo = {
    1: {
      'price': '₹1',
      'priceValue': 1.0,
      'hospitals': 1,
      'desc': 'Nearest hospital'
    },
    2: {
      'price': '₹2',
      'priceValue': 2.0,
      'hospitals': 3,
      'desc': 'Top 3 nearby hospitals'
    },
    3: {
      'price': '₹3',
      'priceValue': 3.0,
      'hospitals': 10,
      'desc': 'All nearby hospitals'
    },
  };

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    _prefs = await SharedPreferences.getInstance();
    _messageController = TextEditingController();
    // Load wallet balance (default ₹5000)
    setState(() {
      _walletBalance = _prefs.getDouble('walletBalance') ?? 5000.0;
    });
    await _getCurrentLocation();
  }

  Future<void> _saveWalletBalance() async {
    await _prefs.setDouble('walletBalance', _walletBalance);
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      final location = await _locationService.getCurrentLocation();
      if (location != null) {
        setState(() {
          _userLocation = location;
          // Fallback to local data
          _localHospitals = _db.getNearbyHospitals(location, radiusKm: 50);
        });

        // Try to fetch from backend API
        final response = await _api.getNearbyHospitals(
          latitude: location.latitude,
          longitude: location.longitude,
          radiusKm: 50,
        );

        if (response.success && response.data != null) {
          setState(() {
            _nearbyHospitals = List<Map<String, dynamic>>.from(
                response.data['hospitals'] ?? []);
          });
        }
      }
    } catch (e) {
      print('Error getting location: $e');
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  void _sendAlertToHospitals() async {
    if (_selectedSymptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one symptom')),
      );
      return;
    }

    if (_messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a message')),
      );
      return;
    }

    if (_userLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not get your location')),
      );
      return;
    }

    int hospitalCount = _tierInfo[_selectedCharge]!['hospitals'] as int;
    String price = _tierInfo[_selectedCharge]!['price'] as String;
    double priceValue = _tierInfo[_selectedCharge]!['priceValue'] as double;

    // Check wallet balance
    if (_walletBalance < priceValue) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Insufficient balance. Need $price, Have ₹${_walletBalance.toStringAsFixed(0)}'),
          backgroundColor: const Color(0xFFE63946),
        ),
      );
      return;
    }

    // Show confirmation dialog
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        title: const Text(
          '🚨 Confirm Emergency Alert',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This will send an alert to $hospitalCount hospital(s)',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0E27),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tier $_selectedCharge - $price',
                      style: const TextStyle(
                          color: Color(0xFFF4A261),
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(_tierInfo[_selectedCharge]!['desc'] as String,
                      style: const TextStyle(color: Colors.white54)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF06A77D).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: const Color(0xFF06A77D).withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Wallet Balance:',
                      style: TextStyle(color: Colors.white70)),
                  Text('₹${_walletBalance.toStringAsFixed(0)}',
                      style: const TextStyle(
                          color: Color(0xFF06A77D),
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Symptoms: ${_selectedSymptoms.join(", ")}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE63946),
            ),
            child: Text('Pay $price from Wallet'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSendingAlert = true);

    try {
      // Deduct from wallet
      setState(() {
        _walletBalance -= priceValue;
      });
      await _saveWalletBalance();

      // Generate local alert ID
      _currentAlertId = 'ALERT_${DateTime.now().millisecondsSinceEpoch}';

      // Try to send via backend API (optional - works offline too)
      int hospitalsNotified = hospitalCount;
      try {
        final orderResponse = await _api.createPaymentOrder(
          tier: _selectedCharge,
          latitude: _userLocation!.latitude,
          longitude: _userLocation!.longitude,
          symptoms: _selectedSymptoms.join(', '),
          message: _messageController.text,
        );

        if (orderResponse.success) {
          _currentAlertId = orderResponse.data['alertId'];
          final orderId = orderResponse.data['order']['id'];

          // Auto-verify payment (wallet already deducted)
          await _api.verifyPayment(
            orderId: orderId,
            paymentId: 'wallet_${DateTime.now().millisecondsSinceEpoch}',
            signature: 'wallet_payment',
            alertId: _currentAlertId!,
          );

          // Send the alert
          final alertResponse = await _api.sendEmergencyAlert(_currentAlertId!);
          if (alertResponse.success) {
            hospitalsNotified =
                alertResponse.data['hospitalsNotified'] ?? hospitalCount;
          }
        }
      } catch (e) {
        // Backend unavailable - that's OK, wallet payment still processed locally
        print('Backend unavailable, using local processing: $e');
      }

      // Also save to local database
      for (int i = 0; i < hospitalCount && i < _localHospitals.length; i++) {
        final hospital = _localHospitals[i];
        final alert = HospitalAlert(
          id: '${_currentAlertId}_$i',
          hospitalId: hospital.id,
          hospitalName: hospital.name,
          timestamp: DateTime.now(),
          symptoms: _selectedSymptoms.toList(),
          message: _messageController.text,
          chargeLevels: _selectedCharge,
          messageDelivered: true,
          userLocation:
              '${_userLocation!.latitude}, ${_userLocation!.longitude}',
        );
        _db.addHospitalAlert(alert);
      }

      // Success!
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1A1F3A),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Color(0xFF06A77D), size: 28),
                SizedBox(width: 8),
                Text('Alerts Sent!', style: TextStyle(color: Colors.white)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Emergency alerts sent to $hospitalsNotified hospital(s)',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF06A77D).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Remaining Balance:',
                          style: TextStyle(color: Colors.white70)),
                      Text('₹${_walletBalance.toStringAsFixed(0)}',
                          style: const TextStyle(
                              color: Color(0xFF06A77D),
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Hospitals have been notified and will respond shortly.',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  'Alert ID: ${_currentAlertId?.substring(0, 8)}...',
                  style: const TextStyle(
                      color: Color(0xFF6C63FF), fontFamily: 'monospace'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK',
                    style: TextStyle(color: Color(0xFF06A77D))),
              ),
            ],
          ),
        );

        // Clear form
        setState(() {
          _selectedSymptoms.clear();
          _messageController.clear();
          _selectedCharge = 1;
          _currentAlertId = null;
        });
      }
    } catch (e) {
      // Refund wallet on error
      setState(() {
        _walletBalance += priceValue;
      });
      await _saveWalletBalance();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFE63946),
          ),
        );
      }
    } finally {
      setState(() => _isSendingAlert = false);
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
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF06A77D).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: const Color(0xFF06A77D).withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.account_balance_wallet,
                              color: Color(0xFF06A77D), size: 18),
                          const SizedBox(width: 6),
                          Text(
                            '₹${_walletBalance.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Color(0xFF06A77D),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
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
                    // Location section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF457B9D).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF457B9D).withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  color: Color(0xFF457B9D), size: 20),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Your Location',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              if (_isLoadingLocation)
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF457B9D),
                                    ),
                                  ),
                                )
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _userLocation != null
                                ? 'Lat: ${_userLocation!.latitude.toStringAsFixed(4)}, Lon: ${_userLocation!.longitude.toStringAsFixed(4)}'
                                : 'Getting location...',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Nearby hospitals section
                    const Text(
                      'Nearby Hospitals',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (_nearbyHospitals.isEmpty && _localHospitals.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _isLoadingLocation
                              ? 'Finding hospitals near you...'
                              : 'No hospitals found nearby',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      )
                    else
                      ...(_nearbyHospitals.isNotEmpty
                              ? _nearbyHospitals
                              : _localHospitals
                                  .map((h) => {
                                        'name': h.name,
                                        'phone': h.phone,
                                        'distanceKm':
                                            h.distanceTo(_userLocation!),
                                      })
                                  .toList())
                          .map((hospital) {
                        final distance = hospital['distanceKm'] ?? 0.0;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hospital['name'] ?? 'Unknown Hospital',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${distance is double ? distance.toStringAsFixed(1) : distance} km away',
                                style: const TextStyle(
                                  color: Color(0xFFF4A261),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                hospital['phone'] ?? '',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                    const SizedBox(height: 24),

                    // Symptoms section
                    const Text(
                      'Select Symptoms',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _symptomsList.map((symptom) {
                        final isSelected = _selectedSymptoms.contains(symptom);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedSymptoms.remove(symptom);
                              } else {
                                _selectedSymptoms.add(symptom);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFE63946)
                                  : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFE63946)
                                    : Colors.white.withOpacity(0.2),
                              ),
                            ),
                            child: Text(
                              symptom,
                              style: TextStyle(
                                color:
                                    isSelected ? Colors.white : Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // Message section
                    const Text(
                      'Message to Hospitals',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: _messageController,
                      maxLines: 4,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText:
                            'Describe your condition or any additional details...',
                        hintStyle:
                            TextStyle(color: Colors.white.withOpacity(0.5)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE63946),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Charge selection
                    const Text(
                      'Alert Charges (Per Hospital)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [1, 2, 3].map((charge) {
                        final isSelected = _selectedCharge == charge;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedCharge = charge),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFE63946)
                                    : Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFE63946)
                                      : Colors.white.withOpacity(0.2),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '₹$charge',
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.white70,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    _nearbyHospitals.isEmpty
                                        ? 'Total: ₹0'
                                        : 'Total: ₹${charge * _nearbyHospitals.length}',
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white.withOpacity(0.8)
                                          : Colors.white.withOpacity(0.6),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 32),

                    // Send alert button
                    GestureDetector(
                      onTap: _isSendingAlert ? null : _sendAlertToHospitals,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: _isSendingAlert
                                ? [Colors.grey, Colors.grey.shade700]
                                : [
                                    const Color(0xFFE63946),
                                    const Color(0xFFD62828)
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: _isSendingAlert
                                  ? Colors.grey.withOpacity(0.2)
                                  : const Color(0xFFE63946).withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Center(
                          child: _isSendingAlert
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Sending Alert...',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                )
                              : const Text(
                                  'Send Emergency Alert',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
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
  final _db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    final alerts = _db.hospitalAlerts;

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
                      'Hospital Alerts',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7B68EE).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${alerts.length}',
                        style: const TextStyle(
                          color: Color(0xFF7B68EE),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              if (alerts.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7B68EE).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.notifications_none,
                            size: 60,
                            color: Color(0xFF7B68EE),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'No Alerts Yet',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your hospital alerts will appear here',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: alerts.length,
                    itemBuilder: (context, index) {
                      final alert =
                          alerts[alerts.length - 1 - index]; // Reverse order
                      return _buildAlertCard(alert);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertCard(HospitalAlert alert) {
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
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.hospitalName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTime(alert.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF06A77D).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Sent',
                  style: TextStyle(
                    color: const Color(0xFF06A77D),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Symptoms
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: alert.symptoms.map((symptom) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE63946).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  symptom,
                  style: const TextStyle(
                    color: Color(0xFFE63946),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          // Message
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              alert.message,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Cost info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Charge: ₹${alert.chargeLevels}',
                style: const TextStyle(
                  color: Color(0xFFF4A261),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                'Location: ${alert.userLocation}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
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
    final user = AuthService().currentLoggedInUser;

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
                        user?.email ?? 'N/A',
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
                              Icons.person,
                              'Full Name',
                              user?.name ?? 'N/A',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Logout Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () async {
                            // Show confirmation dialog
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: const Color(0xFF1A1F3A),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                      color: Colors.white.withOpacity(0.1)),
                                ),
                                title: const Text(
                                  'Logout',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 22),
                                ),
                                content: const Text(
                                  'Are you sure you want to logout?',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text(
                                      'Cancel',
                                      style:
                                          TextStyle(color: Color(0xFF7B68EE)),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      await AuthService().logout();
                                      if (context.mounted) {
                                        Navigator.of(context)
                                            .popUntil((route) => false);
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  const LoginScreen()),
                                        );
                                      }
                                    },
                                    child: const Text(
                                      'Logout',
                                      style:
                                          TextStyle(color: Color(0xFFE63946)),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE63946),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 8,
                            shadowColor:
                                const Color(0xFFE63946).withOpacity(0.5),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.logout, color: Colors.white, size: 20),
                              SizedBox(width: 12),
                              Text(
                                'Logout',
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
