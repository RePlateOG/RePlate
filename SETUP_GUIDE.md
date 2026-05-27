# RePlate - Complete Setup Guide

## 📋 Overview

This guide will walk you through setting up the RePlate iOS app from scratch in Xcode.

## 🎯 Step-by-Step Setup

### 1. Create New Xcode Project

1. Open Xcode
2. Select "Create a new Xcode project"
3. Choose "iOS" → "App"
4. Configure:
   - Product Name: `RePlate`
   - Team: Your development team
   - Organization Identifier: `com.yourcompany`
   - Interface: `SwiftUI`
   - Language: `Swift`
   - Storage: None (we'll use our own architecture)
   - Include Tests: Yes

### 2. Configure Project Settings

#### General Settings
- **Deployment Target**: iOS 16.0
- **Supported Destinations**: iPhone
- **Supported Orientations**: Portrait only

#### Signing & Capabilities
Add the following capabilities:
1. Push Notifications
2. Sign in with Apple
3. Background Modes (Location updates, Remote notifications)
4. Maps

#### Build Settings
- **Swift Language Version**: Swift 5
- **Enable Testability**: Yes (Debug only)

### 3. Create Folder Structure

Create the following folder structure in Xcode:

```
RePlate/
├── App/
├── Core/
│   ├── Design/
│   │   └── Components/
│   ├── Extensions/
│   └── Utilities/
├── Models/
├── ViewModels/
├── Views/
│   ├── Onboarding/
│   ├── Customer/
│   ├── Restaurant/
│   ├── Shared/
│   └── Settings/
├── Services/
│   ├── Authentication/
│   ├── API/
│   ├── Location/
│   ├── Notifications/
│   └── Payment/
└── Resources/
    └── Assets.xcassets/
```

### 4. Add All Source Files

Copy all the `.swift` files from this implementation into their respective folders.

**Core Files:**
- `App/RePlateApp.swift`
- `App/RootView.swift`
- `Core/Design/Colors.swift`
- `Core/Design/Typography.swift`
- `Core/Design/Spacing.swift`
- `Core/Design/Components/RPButton.swift`
- `Core/Design/Components/RPCard.swift`
- `Core/Design/Components/RPTextField.swift`
- `Core/Design/Components/ListingCard.swift`
- `Core/Utilities/HapticManager.swift`

**Models:**
- `Models/Models.swift`

**ViewModels:**
- `ViewModels/AuthenticationViewModel.swift`
- `ViewModels/CustomerHomeViewModel.swift`

**Views:**
- `Views/Onboarding/WelcomeView.swift`
- `Views/Onboarding/UserTypeSelectionView.swift`
- `Views/Onboarding/SignInView.swift`
- `Views/Onboarding/SignUpView.swift`
- `Views/Customer/CustomerHomeView.swift`
- `Views/Customer/ListingDetailView.swift`
- `Views/Customer/ListingsMapView.swift`

### 5. Configure Asset Catalog

#### Create Color Set

In `Assets.xcassets`, create a new folder called "Colors" and add these color sets:

**Background**
- Light Appearance: #FFFFFF (White)
- Dark Appearance: #000000 (Black)

**SecondaryBackground**
- Light Appearance: #F5F5F5
- Dark Appearance: #1C1C1E

**CardBackground**
- Light Appearance: #FFFFFF (White)
- Dark Appearance: #2C2C2E

**TextPrimary**
- Light Appearance: #000000 (Black)
- Dark Appearance: #FFFFFF (White)

**TextSecondary**
- Light Appearance: #666666
- Dark Appearance: #ADADB8

**TextTertiary**
- Light Appearance: #999999
- Dark Appearance: #7C7C7E

**Divider**
- Light Appearance: #E5E5E5
- Dark Appearance: #3A3A3C

To add a color:
1. Right-click in Assets.xcassets
2. Select "New Color Set"
3. Name it (e.g., "Background")
4. In Attributes Inspector, set "Appearances" to "Any, Dark"
5. Select "Any Appearance" and set the color
6. Select "Dark Appearance" and set the dark color

#### Add App Icon

1. Create an app icon (1024x1024px)
2. Use a tool like AppIconMaker to generate all sizes
3. Drag into AppIcon asset
4. Or manually add each size in Assets.xcassets

**Icon Design Suggestions:**
- Green gradient background (#118b50 → #5db996)
- White leaf or plate symbol
- Simple, minimal design

### 6. Configure Info.plist

Replace the default Info.plist with the provided one, or add these keys manually:

```xml
<!-- Privacy Permissions -->
<key>NSCameraUsageDescription</key>
<string>RePlate needs access to your camera to take photos of food items you want to list.</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>RePlate needs access to your photo library to select photos of food items.</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>RePlate uses your location to show you nearby surplus food listings and help customers find your restaurant.</string>

<key>NSUserNotificationsUsageDescription</key>
<string>RePlate sends notifications about new listings, order updates, and pickup reminders.</string>
```

### 7. Build and Test

1. Select a simulator (iPhone 15 Pro recommended)
2. Press `Cmd + B` to build
3. Press `Cmd + R` to run
4. Test the onboarding flow
5. Test dark mode (Cmd + Shift + A in simulator)

### 8. Fix Any Build Errors

Common issues and solutions:

**Issue: Cannot find type 'X' in scope**
- Make sure all files are added to the target
- Check file imports

**Issue: Preview crashes**
- Make sure preview data is valid
- Check for force-unwrapped optionals

**Issue: Colors not found**
- Verify color names match exactly
- Check Assets.xcassets is included in target

## 🔧 Additional Configuration

### Enable SwiftLint (Optional)

1. Install SwiftLint:
```bash
brew install swiftlint
```

2. Add Run Script Phase in Build Phases:
```bash
if which swiftlint >/dev/null; then
  swiftlint
else
  echo "warning: SwiftLint not installed"
fi
```

### Add SwiftFormat (Optional)

1. Install SwiftFormat:
```bash
brew install swiftformat
```

2. Create `.swiftformat` config file in project root:
```
--swiftversion 5.9
--indent 4
--maxwidth 120
--wraparguments before-first
--wrapcollections before-first
```

### Configure Git

Create `.gitignore`:
```
# Xcode
xcuserdata/
*.xcworkspace
!default.xcworkspace
DerivedData/
.DS_Store

# Swift Package Manager
.build/
Packages/
*.resolved

# CocoaPods
Pods/
*.lock

# Carthage
Carthage/Build/

# fastlane
fastlane/report.xml
fastlane/Preview.html
fastlane/screenshots
fastlane/test_output

# Environment
.env
*.env

# API Keys
GoogleService-Info.plist
Secrets.plist
```

## 🧪 Testing Setup

### Unit Tests

Create test file: `RePlateTests/ViewModelTests.swift`

```swift
import XCTest
@testable import RePlate

final class AuthenticationViewModelTests: XCTestCase {
    var viewModel: AuthenticationViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = AuthenticationViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    func testEmailValidation() {
        viewModel.email = "invalid-email"
        // Add validation test
    }
}
```

### UI Tests

Create test file: `RePlateUITests/OnboardingTests.swift`

```swift
import XCTest

final class OnboardingTests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    func testWelcomeScreen() {
        let getStartedButton = app.buttons["Get Started"]
        XCTAssertTrue(getStartedButton.exists)
    }
}
```

## 📦 Dependencies (Future)

When ready to add backend integration, add these packages:

### Swift Package Manager

1. In Xcode: File → Add Packages...
2. Add URLs:

**Firebase** (Option 1)
```
https://github.com/firebase/firebase-ios-sdk
```
Select:
- FirebaseAuth
- FirebaseFirestore
- FirebaseStorage
- FirebaseMessaging

**Supabase** (Option 2)
```
https://github.com/supabase/supabase-swift
```

**Stripe**
```
https://github.com/stripe/stripe-ios
```

## 🚀 Running on Device

### 1. Connect iPhone

1. Connect iPhone via USB or WiFi
2. Select device in Xcode toolbar
3. Build and run

### 2. Troubleshooting

**"Unable to install"**
- Check bundle identifier is unique
- Verify signing certificate
- Free space on device

**"Untrusted Developer"**
- Settings → General → VPN & Device Management
- Trust your certificate

## 🎨 Customization

### Change Brand Colors

Edit `Core/Design/Colors.swift`:
```swift
static let primaryGradientStart = Color(hex: "YOUR_COLOR")
static let primaryGradientEnd = Color(hex: "YOUR_COLOR")
static let accent = Color(hex: "YOUR_COLOR")
```

### Change Typography

Edit `Core/Design/Typography.swift`:
```swift
static let displayLarge = Font.system(size: 57, weight: .bold, design: .rounded)
```

## 📱 TestFlight Deployment

### 1. Archive Build

1. Select "Any iOS Device" in Xcode
2. Product → Archive
3. Wait for build to complete
4. Organizer opens automatically

### 2. Upload to App Store Connect

1. Click "Distribute App"
2. Select "App Store Connect"
3. Choose "Upload"
4. Wait for processing

### 3. Configure TestFlight

1. Log in to App Store Connect
2. Go to TestFlight tab
3. Add internal/external testers
4. Submit for review (external only)

## 🎯 Pre-Launch Checklist

- [ ] All features working
- [ ] No placeholder text/images
- [ ] Dark mode tested
- [ ] Different screen sizes tested
- [ ] Permissions working
- [ ] Error handling complete
- [ ] Loading states everywhere
- [ ] App icon set
- [ ] Launch screen configured
- [ ] Privacy policy uploaded
- [ ] Terms of service uploaded
- [ ] App Store screenshots ready
- [ ] App description written
- [ ] Keywords optimized
- [ ] Backend deployed
- [ ] Payment processing tested
- [ ] Push notifications working

## 🆘 Common Issues

### Issue: "Build failed"
**Solution**: Clean build folder (Cmd + Shift + K), then rebuild

### Issue: "Simulator not responding"
**Solution**: Reset simulator: Device → Erase All Content and Settings

### Issue: "Preview failed"
**Solution**: Ensure preview code is valid, restart Xcode

### Issue: "Colors not appearing"
**Solution**: Check color asset names match code exactly

### Issue: "App crashes on launch"
**Solution**: Check console for error, verify all assets exist

## 📚 Resources

- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [TestFlight Guide](https://developer.apple.com/testflight/)

## 🤝 Getting Help

If you encounter issues:

1. Check the console output
2. Review the README.md
3. Search Apple Developer Forums
4. Check Stack Overflow
5. Contact the development team

## ✅ Next Steps

After setup is complete:

1. Test all onboarding flows
2. Implement backend integration
3. Add payment processing
4. Implement restaurant features
5. Add push notifications
6. Set up analytics
7. Create App Store listing
8. Submit for review

---

Good luck with your RePlate app! 🎉
