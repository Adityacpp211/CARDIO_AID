# CardioAid 🫀

> Emergency Cardiac Care System - A comprehensive cross-platform mobile application for real-time patient monitoring and emergency response

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?style=flat&logo=flutter)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=flat&logo=dart)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-blue.svg)](https://flutter.dev/)

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Screenshots](#screenshots)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Running the App](#running-the-app)
- [Build & Deployment](#build--deployment)
- [Project Structure](#project-structure)
- [Core Components](#core-components)
- [Data Models](#data-models)
- [Contributing](#contributing)
- [Team](#team)
- [Roadmap](#roadmap)
- [License](#license)
- [Contact](#contact)

---

## 🎯 Overview

**CardioAid** is a professional-grade emergency cardiac care system designed to revolutionize how medical professionals monitor and respond to cardiac emergencies. Built with Flutter for cross-platform compatibility, CardioAid provides real-time patient monitoring, vital signs tracking, emergency response coordination, and comprehensive medical record management.

### Why CardioAid?

- ⚡ **Real-time Monitoring**: Live vital signs tracking with instant alerts
- 🚨 **Emergency Response**: Quick access to critical patient information
- 📊 **Comprehensive Records**: Detailed patient histories and medical reports
- 🔒 **Secure Authentication**: Role-based access control for medical staff
- 📱 **Cross-Platform**: Single codebase runs on 6+ platforms
- 🎨 **Professional UI**: Dark theme optimized for emergency situations

---

## ✨ Features

### Core Features

- **🔐 User Authentication**
  - Secure login and registration
  - Email validation
  - Password strength requirements
  - Role-based access control

- **👥 Patient Record Management**
  - Comprehensive patient demographics
  - Medical history tracking
  - Room assignment and bed management
  - Blood type and allergy information

- **💓 Real-time Vital Signs Monitoring**
  - Heart Rate (BPM)
  - Blood Pressure
  - Oxygen Saturation (SpO2)
  - Body Temperature
  - Color-coded alerts for abnormal readings

- **🚨 Emergency Response System**
  - Cardiac arrest protocol
  - Emergency event logging
  - Timestamp tracking
  - Response status monitoring

- **📋 Medical Reports**
  - ECG analysis reports
  - Diagnostic summaries
  - Treatment records
  - Doctor notes and observations

- **🏥 Hospital Integration**
  - Hospital directory
  - Distance calculation
  - Contact information
  - Quick dial access

- **👤 User Profile Management**
  - Staff profiles
  - Role assignment
  - Department tracking
  - Contact details

### Smart Features

- **🔴 Automated Alerts**: Intelligent detection of abnormal vital signs
- **📊 Dashboard Overview**: Quick access to critical patient information
- **🎨 Responsive Design**: Optimized for mobile, tablet, and desktop
- **🌓 Dark Theme**: Reduced eye strain for extended use
- **⚡ Fast Performance**: In-memory data management for instant access

---

## 📸 Screenshots

> *Add screenshots of your application here*

| Login Screen | Dashboard | Patient Records | Vital Signs |
|--------------|-----------|-----------------|-------------|
| ![Login](#) | ![Dashboard](#) | ![Records](#) | ![Vitals](#) |

---

## 🛠️ Tech Stack

### Frontend Framework
- **Flutter** - Cross-platform UI toolkit
- **Dart** - Modern programming language

### Design System
- **Material Design 3** - Google's latest design system
- **Custom Dark Theme** - Professional medical interface

### Architecture
- **MVC Pattern** - Model-View-Controller
- **Singleton Pattern** - Service management
- **Service Layer** - Business logic separation

### Data Management
- **In-Memory Database** - Fast data access
- **DatabaseService** - Centralized data management
- **AuthService** - Authentication handling

### Build Tools
- **Gradle** - Build automation
- **Android SDK** - Android platform support
- **Flutter SDK** - Cross-platform compilation

---

## 🏗️ Architecture

CardioAid follows a clean, layered architecture:

```
┌─────────────────────────────────────┐
│         Presentation Layer          │
│   (UI Components & Screens)         │
├─────────────────────────────────────┤
│         Business Logic Layer        │
│   (AuthService, DatabaseService)    │
├─────────────────────────────────────┤
│         Data Layer                   │
│   (Models & Data Structures)        │
└─────────────────────────────────────┘
```

### Design Patterns

- **Singleton Pattern**: Ensures single instance of services
- **Factory Pattern**: Object creation
- **Observer Pattern**: State management
- **Repository Pattern**: Data access abstraction

---

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (3.0.0 or higher)
  ```bash
  flutter --version
  ```

- **Dart SDK** (3.0.0 or higher)
  ```bash
  dart --version
  ```

- **Android Studio** or **VS Code** with Flutter extensions

- **Git** for version control

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/cardio_aid.git
   cd cardio_aid
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Verify Flutter setup**
   ```bash
   flutter doctor
   ```

4. **Connect a device or start an emulator**
   ```bash
   flutter devices
   ```

### Running the App

#### Development Mode

```bash
flutter run
```

#### Specific Platform

```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Web
flutter run -d chrome

# Windows
flutter run -d windows

# Linux
flutter run -d linux

# macOS
flutter run -d macos
```

#### Hot Reload

Press `r` in the terminal to hot reload changes  
Press `R` to hot restart the app

---

## 📦 Build & Deployment

### Android APK

```bash
# Build release APK
flutter build apk --release

# Output location
# build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (for Play Store)

```bash
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

### Web

```bash
flutter build web --release
```

### Desktop

```bash
# Windows
flutter build windows --release

# Linux
flutter build linux --release

# macOS
flutter build macos --release
```

### Build Details

- **App Size**: ~19.2 MB
- **Build Time**: ~65 seconds
- **Optimizations**: Tree-shaking enabled (99.7% icon size reduction)
- **Status**: Production Ready ✓

---

## 📁 Project Structure

```
cardio_aid/
│
├── android/                 # Android platform files
├── ios/                     # iOS platform files
├── web/                     # Web platform files
├── windows/                 # Windows platform files
├── linux/                   # Linux platform files
├── macos/                   # macOS platform files
│
├── lib/
│   ├── main.dart           # Application entry point (3,225 lines)
│   └── main_backup.dart    # Backup version
│
├── test/                    # Unit and widget tests
│   └── widget_test.dart
│
├── build/                   # Build outputs
│
├── pubspec.yaml            # Project dependencies
├── pubspec.lock            # Locked dependencies
├── analysis_options.yaml   # Linter rules
├── README.md               # Project documentation
└── .gitignore              # Git ignore rules
```

---

## 🧩 Core Components

### Models

- **User** - User account information
- **Hospital** - Hospital directory data
- **PatientRecord** - Patient demographics and medical info
- **VitalSigns** - Real-time health metrics
- **EmergencyRecord** - Emergency event data
- **MedicalReport** - Diagnostic reports
- **UserProfile** - Staff profile information

### Services

#### AuthService
- User registration with validation
- Email format verification
- Password strength checking
- Login authentication
- Duplicate account prevention

#### DatabaseService
- Patient record management
- Vital signs storage
- Emergency record tracking
- Medical report generation
- User profile management
- Sample data initialization

### UI Components

- **SplashScreen** - Animated app intro
- **LoginScreen** - User authentication
- **SignUpScreen** - New user registration
- **DashboardScreen** - Main overview
- **PatientsScreen** - Patient list
- **VitalSignsScreen** - Live monitoring
- **EmergencyScreen** - Emergency response
- **ReportsScreen** - Medical reports
- **ProfileScreen** - User profile
- **HospitalsScreen** - Hospital directory

---

## 📊 Data Models

### Patient Record
```dart
PatientRecord(
  id: String,           // Unique identifier
  name: String,         // Patient name
  age: int,             // Patient age
  bloodType: String,    // Blood type (A+, O-, etc.)
  condition: String,    // Current condition
  admissionDate: String,// Admission date
  roomNumber: String    // Room assignment
)
```

### Vital Signs
```dart
VitalSigns(
  patientId: String,    // Patient reference
  heartRate: int,       // BPM (60-100 normal)
  bloodPressure: String,// Systolic/Diastolic
  temperature: double,  // °F (98.6 normal)
  oxygenLevel: int,     // SpO2 percentage (>90%)
  timestamp: String     // Reading time
)
```

### Alert Thresholds

| Metric | Normal Range | Alert Condition |
|--------|--------------|-----------------|
| Heart Rate | 60-100 BPM | <60 or >120 BPM |
| Oxygen Level | >95% | <90% |
| Temperature | 97.0-99.5°F | >99.5°F |
| Blood Pressure | 120/80 | >140/90 |

---

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/AmazingFeature
   ```
3. **Commit your changes**
   ```bash
   git commit -m 'Add some AmazingFeature'
   ```
4. **Push to the branch**
   ```bash
   git push origin feature/AmazingFeature
   ```
5. **Open a Pull Request**

### Coding Standards

- Follow [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Add comments for complex logic
- Write tests for new features
- Update documentation

---

## 👥 Team

This project was developed by a team of 5 specialized members:

| Role | Responsibilities |
|------|------------------|
| **Backend & Architecture** | Framework setup, architecture design, data models |
| **Authentication & User Management** | AuthService, validation, security |
| **Database & Data Management** | DatabaseService, data structures, sample data |
| **UI/UX & Dashboard** | Interface design, responsive layouts, user experience |
| **Build & Deployment** | Build optimization, cross-platform testing, deployment |

---

## 🗺️ Roadmap

### Phase 1: Foundation ✓
- [x] Core architecture setup
- [x] Authentication system
- [x] Patient record management
- [x] Vital signs monitoring
- [x] Emergency response system

### Phase 2: Enhancement (In Progress)
- [ ] Cloud database integration (Firebase/Supabase)
- [ ] Push notification system
- [ ] Real-time data synchronization
- [ ] Advanced search and filtering
- [ ] Export reports as PDF

### Phase 3: Advanced Features
- [ ] AI-based diagnostic assistance
- [ ] ECG waveform visualization
- [ ] Multi-language support
- [ ] Offline mode support
- [ ] Integration with medical devices

### Phase 4: Deployment
- [ ] Google Play Store release
- [ ] Apple App Store release
- [ ] Web deployment
- [ ] Desktop distribution

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2026 CardioAid Team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
```

---

## 📞 Contact

- **Project Link**: [https://github.com/yourusername/cardio_aid](https://github.com/yourusername/cardio_aid)
- **Email**: support@cardioaid.com
- **Website**: [www.cardioaid.com](https://www.cardioaid.com)

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Material Design team for design guidelines
- Medical professionals for domain expertise
- Open source community for inspiration

---

## ⚠️ Disclaimer

**CardioAid is currently a demonstration/educational project and should NOT be used for actual medical purposes without proper validation, certification, and compliance with healthcare regulations (HIPAA, GDPR, etc.).**

For production medical use:
- Obtain necessary certifications (FDA, CE marking, etc.)
- Implement HIPAA compliance measures
- Conduct thorough security audits
- Ensure data encryption and privacy
- Follow medical device regulations

---

<div align="center">

### Built with ❤️ by the CardioAid Team

**Making Emergency Cardiac Care Accessible to Everyone**

[⬆ Back to Top](#cardioaid-)

</div>
