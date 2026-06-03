# 🛡️ ShieldX - Smart Rider Safety System

## Overview

ShieldX is an IoT-based smart rider safety system designed to enhance rider protection through real-time monitoring, accident detection, GPS tracking, and emergency alert management.

The system combines an ESP32-based smart jacket with a Flutter mobile application and Firebase backend to provide continuous rider safety monitoring.

---

## Features


### Mobile Application

* Real-time Heart Rate Monitoring
* Live GPS Tracking
* Emergency Contact Management
* Rider Profile Management
* Accident Detection Alerts
* Smart Jacket Device Monitoring
* Emergency SOS System
* Firebase Cloud Synchronization

### Smart Jacket

* ESP32 Controller
* Heart Rate Sensor Integration
* GPS Module Integration
* LED Visibility Control
* Buzzer Alert System
* Accident Detection Mechanism

---
# 📸 Project Screenshots

## System Architecture

![System Architecture](screenshots/System%20Architecture.png)

---

## Data Flow Diagram (DFD)

![DFD Diagram](screenshots/DFD%20Diagram.png)

---

## Smart Jacket Design

![Jacket Design](screenshots/Jacket%20Design.png)

---

## Mobile Application UI

### Home Dashboard

![UI Page 1](screenshots/UI%20page%201.png)

### Device Monitoring

![UI Page 2](screenshots/UI%20Page%202.png)

### Settings & Emergency Features

![UI Page 3](screenshots/UI%20Page%203.png)


## Technology Stack

### Frontend

* Flutter
* Dart

### Backend

* Firebase Realtime Database
* Firebase Authentication
* Firebase Cloud Functions

### Notifications

* Twilio SMS API

### Hardware

* ESP32
* GPS Module
* Heart Rate Sensor
* LEDs
* Buzzer

---

## System Architecture

ESP32 Smart Jacket
↓
Firebase Realtime Database
↓
Flutter Mobile Application
↓
Cloud Functions
↓
Emergency SMS Alerts

---

## Screens

### Landing Screen

Modern glassmorphism-based onboarding interface.

### Home Dashboard

Displays:

* Heart Rate
* GPS Tracking
* LED Brightness
* Rider Status

### Device Page

Provides:

* Live Device Monitoring
* Heartbeat Visualization
* ECG Animation
* Smart Jacket Status

### Settings Page

Allows:

* Profile Management
* SMS Alert Control
* Emergency Contact Management

---

## Firebase Structure

deviceData

* bpm
* latitude
* longitude
* accident
* ledBrightness

users

* profile
* contacts
* settings

---

## Installation

1. Clone repository

```bash
git clone https://github.com/indrajithkss/shieldx-app.git
```

2. Install dependencies

```bash
flutter pub get
```

3. Configure Firebase

Add:

* google-services.json
* GoogleService-Info.plist

4. Run application

```bash
flutter run
```

---

## Future Enhancements

* AI-based accident prediction
* Voice Assistant Integration
* Live Navigation
* Smart Helmet Integration
* Cloud Analytics Dashboard

---

## Author

Indrajith K S



Project: ShieldX Smart Rider Safety System
