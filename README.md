# BioStim WiFi Pairing App

A Flutter application for pairing BioStim devices via WiFi with a complete UI flow and state management.

## 🚀 Features

### Complete WiFi Pairing Flow
1. **Scanning Screen** - Searches for "Biostim+" WiFi network
2. **Device Found Screen** - Shows device with animated ripples
3. **Connecting Screen** - Displays connection progress with animated dots
4. **Connection Success Screen** - Shows successful connection with green lines
5. **Device Not Found Screen** - Error handling with retry options
6. **Connection Failed Screen** - Connection failure with troubleshooting

### Key Features
- ✅ **Responsive Design** - Works perfectly on phones and tablets
- ✅ **Montserrat Font** - Consistent typography throughout
- ✅ **GetX State Management** - Efficient state management and navigation
- ✅ **Timer Management** - 60-second timeouts for scanning and connection
- ✅ **Error Handling** - Graceful fallbacks for missing assets
- ✅ **WiFi Integration** - Real WiFi scanning and connection logic
- ✅ **App Settings Integration** - Direct access to device settings

## 📱 Screen Flow

```
Intro Screen → Device Instructions → WiFi Pairing Flow
                                           ↓
Scanning → Device Found → Connecting → Success/Failed
    ↓           ↓            ↓
Not Found ← Retry ← Connection Failed
```

## 🛠️ Setup Instructions

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Android Studio / VS Code
- Android/iOS device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd biostim
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Add required assets**
   Create the following directory structure and add your assets:
   ```
   assets/
   ├── gifs/
   │   ├── searching_radius.gif
   │   ├── loading.gif
   │   └── correct.gif
   ├── images/
   │   ├── device_icon_small.png
   │   ├── image.png
   │   ├── search_failed.png
   │   └── failed.png
   └── onboarding/
       └── device_icon.png
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 📦 Dependencies

### Core Dependencies
- `get: ^4.6.6` - State management and navigation
- `wifi_scan: ^0.4.0+3` - WiFi network scanning
- `app_settings: ^5.1.1` - Open device settings
- `permission_handler: ^11.3.1` - Handle permissions

### Fonts
- Montserrat (Regular, Bold) - Primary font family

## 🎨 UI Components

### Responsive Design
- **Phone**: Width ≤ 600px
- **Tablet**: Width 601-900px  
- **Large Tablet**: Width > 900px

### Color Scheme
- **Primary**: #424242 (Dark Grey)
- **Success**: Green (#4CAF50)
- **Error**: Red (#F44336)
- **Background**: White (#FFFFFF)

## 🔧 Configuration

### WiFi Settings
- **Target SSID**: "Biostim+"
- **Password**: "biostim@123"
- **Scan Timeout**: 60 seconds
- **Connection Timeout**: 60 seconds

### Permissions Required
- Location Permission (for WiFi scanning)
- WiFi Permission (for network access)

## 📁 Project Structure

```
lib/
├── controllers/
│   └── wifi_pairing_controller.dart
├── screens/
│   └── wifi_pairing_screen.dart
├── widgets/
│   ├── scanning_screen.dart
│   ├── device_found_screen.dart
│   ├── connecting_screen.dart
│   ├── connection_success_screen.dart
│   ├── device_not_found_screen.dart
│   └── connection_failed_screen.dart
└── onboarding/
    ├── intro_screen.dart
    └── device_instruction_screen.dart
```

## 🚀 Usage

1. **Start the app** - Shows intro screen
2. **Tap "Get Started"** - Navigate to device instructions
3. **Follow device instructions** - Turn on device and enter pairing mode
4. **Tap "Next"** - Start WiFi pairing flow
5. **Wait for scanning** - App searches for "Biostim+" network
6. **Tap device when found** - Initiate connection
7. **Wait for connection** - 60-second connection attempt
8. **Success/Failure handling** - Appropriate error screens with retry options

## 🔄 State Management

The app uses GetX for state management with the following observables:
- `isScanning` - Scanning status
- `isConnecting` - Connection status
- `deviceFound` - Device discovery status
- `connectionSuccess` - Connection result
- `currentScreen` - Current screen in the flow

## 🐛 Troubleshooting

### Common Issues
1. **Permission Denied** - Grant location permission for WiFi scanning
2. **Device Not Found** - Ensure device is in pairing mode
3. **Connection Failed** - Check WiFi password and signal strength
4. **Assets Missing** - Add required GIF and image files

### Debug Mode
Enable debug logging by setting `debugPrint` statements in the controller.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 📞 Support

For support and questions, please contact the development team.

---

**Note**: This app requires actual WiFi hardware and permissions to function properly. Test on real devices for full functionality.
