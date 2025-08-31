# Shoulder Abduction Page Implementation

## Overview

The `ShoulderAbductionPage` is a fully responsive Flutter screen designed for shoulder abduction rehabilitation exercises. It features a modern, accessible UI with soft card shadows, rounded corners, and responsive design that works seamlessly on both phones and tablets.

## Features Implemented

### ✅ Core Requirements Met

1. **Screen Structure**
   - Scaffold with light background (#FAFAFA)
   - SafeArea enabled for top/bottom
   - SingleChildScrollView with ClampingScrollPhysics
   - Responsive horizontal padding (24dp phone, 32dp tablet, 40dp large tablet)
   - Vertical spacing between sections (20-24dp phone, 24-28dp tablet)

2. **Design Tokens** (`lib/constants/design_tokens.dart`)
   - Radius values: cardRadius (24), buttonPillRadius (28), fieldRadius (16)
   - Color palette: textPrimary (#121212), textSecondary (#424242), textMuted (#6B6B6B), etc.
   - Soft shadow: rgba(0,0,0,0.12), blur 12, spread 0, offset (0, 2)
   - Responsive breakpoints and helper methods

3. **Title Section**
   - "Shoulder Abduction" heading
   - Responsive font sizes (28px phone, 32px tablet)
   - Font weight 600, Montserrat font family
   - Proper spacing and text overflow handling

4. **Hero Card with Placeholder Images**
   - Rounded rectangle with cardRadius (24)
   - Responsive sizing: phone (220-320dp), tablet (400-500dp)
   - Background gradient with placeholder icon
   - Foreground arm overlay representation
   - Full-bleed image design with ClipRRect

5. **Metric Cards Row**
   - Two cards: "Angle" and "Set Target Angle"
   - Responsive layout: Row on wide screens, Column on narrow (<360dp)
   - Current values: -12.5° and -20.0°
   - CTA buttons: "Calibrate" and "Set Angle"
   - Soft shadows and proper spacing

6. **Input Cards Row**
   - Three cards: "Timer", "Hold Time", "Repetitions"
   - Responsive layout: Row on wide screens, Column on narrow (<380dp)
   - DropdownButtonFormField with custom styling
   - Options: Timer (NA, 15s, 30s, 45s, 60s), Hold Time (0-20), Repetitions (10-50)

7. **Primary CTA Button**
   - "Start Program »" with double chevron icons
   - Full-width pill button with responsive height
   - Disabled state when form is invalid
   - Proper shadow and styling

8. **Interactive Features**
   - Calibrate modal bottom sheet
   - Set Angle dialog with numeric validation (-90° to +90°)
   - Dropdown state management via ChangeNotifier
   - Form validation and error handling

9. **Accessibility & Responsiveness**
   - Semantic labels for screen readers
   - Text scaling support (0.9-1.3 clamp)
   - High contrast ratios for AA compliance
   - Responsive breakpoints: <600dp (phone), 600-1024dp (tablet), ≥1024dp (large tablet)

## File Structure

```
lib/
├── constants/
│   └── design_tokens.dart          # Design tokens and responsive helpers
├── controllers/
│   └── shoulder_abduction_controller.dart  # State management
├── screens/
│   └── shoulder_abduction_page.dart        # Main screen implementation
└── widgets/
    └── shoulder_abduction_test_widget.dart  # Navigation test widget
```

## Usage

### Basic Navigation

```dart
import 'package:biostim/screens/shoulder_abduction_page.dart';

// Navigate to the screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const ShoulderAbductionPage(),
  ),
);
```

### State Management

The screen uses a `ShoulderAbductionController` for state management:

```dart
final controller = ShoulderAbductionController();

// Access current values
print(controller.currentAngle);        // -12.5
print(controller.targetAngle);         // -20.0
print(controller.selectedTimer);       // "NA"

// Update values
controller.setTargetAngle(45.0);
controller.setSelectedTimer("30s");
```

### Design Tokens Usage

```dart
import 'package:biostim/constants/design_tokens.dart';

// Get responsive values
double padding = DesignTokens.getHorizontalPadding(screenWidth);
double fontSize = DesignTokens.getTitleFontSize(screenWidth);

// Use predefined styles
Text(
  'Title',
  style: DesignTokens.titleStyle,
)
```

## Responsive Design

### Breakpoints
- **Phone**: < 600dp width
- **Tablet**: 600-1024dp width  
- **Large Tablet**: ≥ 1024dp width

### Responsive Features
- **Padding**: 24dp → 32dp → 40dp
- **Font Sizes**: 28px → 32px (title), 42px → 48px (values)
- **Button Heights**: 44px → 48px (pills), 56px → 64px (primary)
- **Card Padding**: 20dp → 24dp
- **Layout**: Stacks vertically on narrow screens (<360dp for metrics, <380dp for inputs)

## Accessibility Features

- **Semantic Labels**: All interactive elements have descriptive labels
- **Text Scaling**: Respects system text size with safety clamping
- **Contrast**: High contrast ratios for AA compliance
- **Screen Reader**: Proper semantic structure for assistive technologies

## Placeholder Images

The hero card uses placeholder elements that can be easily replaced:

```dart
// Current placeholder (background)
Icon(Icons.image, size: 80, color: Colors.grey[400])

// Current placeholder (foreground arm overlay)
Container(
  width: 60,
  height: 120,
  decoration: BoxDecoration(
    color: Colors.blue.withOpacity(0.3),
    borderRadius: BorderRadius.circular(30),
  ),
  child: Icon(Icons.accessibility_new, color: Colors.blue, size: 40),
)
```

### Replacing with Real Assets

1. **Background Image**: Replace the `Icon(Icons.image)` with:
   ```dart
   Image.asset(
     'assets/images/shoulder_abduction_background.png',
     fit: BoxFit.cover,
     width: double.infinity,
     height: double.infinity,
   )
   ```

2. **Arm Overlay**: Replace the placeholder container with:
   ```dart
   Image.asset(
     'assets/images/arm_overlay.png',
     fit: BoxFit.contain,
   )
   ```

3. **Add to pubspec.yaml**:
   ```yaml
   assets:
     - assets/images/shoulder_abduction_background.png
     - assets/images/arm_overlay.png
   ```

## Testing

### Test Widget
Use the provided test widget to verify functionality:

```dart
import 'package:biostim/widgets/shoulder_abduction_test_widget.dart';

// In your app
home: const ShoulderAbductionTestWidget(),
```

### Manual Testing Checklist

- [ ] Screen renders correctly on phone (360×800)
- [ ] Screen renders correctly on tablet (≥800dp width)
- [ ] All dropdowns are interactive and update state
- [ ] Calibrate button opens modal bottom sheet
- [ ] Set Angle button opens dialog with validation
- [ ] Start Program button is disabled when form invalid
- [ ] Text scaling works (0.9-1.3 range)
- [ ] No layout overflow on small screens
- [ ] Shadows and rounded corners match design
- [ ] Accessibility features work with screen readers

## Customization

### Colors
Modify `lib/constants/design_tokens.dart`:

```dart
static const Color textPrimary = Color(0xFF121212);
static const Color primaryDark = Color(0xFF3A3A3A);
// ... other colors
```

### Typography
Update font sizes and weights in the design tokens:

```dart
static double getTitleFontSize(double screenWidth) {
  return screenWidth >= phoneBreakpoint ? 32.0 : 28.0;
}
```

### Spacing
Adjust responsive spacing values:

```dart
static double getHorizontalPadding(double screenWidth) {
  if (screenWidth >= tabletBreakpoint) return 40.0;
  if (screenWidth >= phoneBreakpoint) return 32.0;
  return 24.0;
}
```

## Performance Considerations

- Uses `ChangeNotifier` for minimal UI rebuilds
- Responsive calculations are cached per build
- Text scaling is clamped to prevent layout issues
- ConstrainedBox prevents infinite sizing issues
- Efficient widget tree with proper key usage

## Browser/Platform Support

- ✅ Android (tested on SM T510)
- ✅ iOS (Flutter iOS support)
- ✅ Web (Flutter web support)
- ✅ Desktop (Flutter desktop support)

## Dependencies

The implementation uses only Flutter core packages:
- `flutter/material.dart`
- `flutter/services.dart`

No additional dependencies required beyond the existing project setup.

## Future Enhancements

1. **Real-time Angle Updates**: Connect to actual sensor data
2. **Animation**: Smooth transitions for angle changes
3. **Progress Tracking**: Save and display exercise history
4. **Customization**: User-configurable exercise parameters
5. **Offline Support**: Local storage for settings
6. **Analytics**: Track usage patterns and improvements

## Support

For questions or issues with the implementation, refer to:
- Flutter documentation: https://flutter.dev/docs
- Material Design guidelines: https://material.io/design
- Accessibility guidelines: https://flutter.dev/docs/development/accessibility-and-localization/accessibility
