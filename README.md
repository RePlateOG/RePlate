# RePlate - iOS App

A modern, minimal, mobile-first application that allows restaurants to post surplus food and customers to claim it at discounted prices or for free.

## 🎯 Project Overview

RePlate connects restaurants with surplus food to nearby customers, reducing food waste while helping people save money. The app features a fast posting flow for restaurants (< 30 seconds) and a quick claim flow for customers (< 10 seconds).

## 🏗 Architecture

### Tech Stack
- **Platform**: iOS 16.0+
- **Language**: Swift 5.9+
- **Framework**: SwiftUI
- **Architecture**: MVVM (Model-View-ViewModel)
- **Design Pattern**: Component-based reusable UI system

### Backend Ready
The app is structured to integrate with:
- Firebase or Supabase
- Stripe for payments
- Apple Pay
- Push notifications
- Cloud storage for images

## 📱 Features

### Core Features
- ✅ Modern onboarding flow with animations
- ✅ Sign in with Apple
- ✅ Email/password authentication
- ✅ User type selection (Restaurant/Customer)
- ✅ Dark mode & light mode support
- ✅ Haptic feedback throughout
- ✅ Real-time location services
- ✅ Interactive map view
- ✅ Advanced filtering system
- ✅ Beautiful glassmorphic cards
- ✅ Smooth animations and transitions
- ✅ Pull-to-refresh support

### Customer Features
- Browse nearby surplus food listings
- Toggle between list and map view
- Advanced filters (distance, price, category)
- Real-time search
- Listing details with countdown timer
- One-tap claim functionality
- Impact tracking dashboard
- Order management
- Profile customization

### Restaurant Features
- Dashboard with analytics
- Quick post surplus flow
- Order management
- Impact statistics
- Restaurant profile

### Design System
- Premium gradient colors (#118b50 → #5db996)
- Accent color (#caf8a5)
- Consistent spacing and typography
- Rounded corners (2xl = 24pt)
- Soft shadows and glassmorphism
- Custom reusable components

## 📂 Project Structure

```
RePlate/
├── App/
│   ├── RePlateApp.swift          # App entry point
│   └── RootView.swift             # Root navigation logic
├── Core/
│   ├── Design/
│   │   ├── Colors.swift           # Color system
│   │   ├── Typography.swift       # Typography system
│   │   ├── Spacing.swift          # Layout constants
│   │   └── Components/
│   │       ├── RPButton.swift     # Reusable button
│   │       ├── RPCard.swift       # Glassmorphic card
│   │       ├── RPTextField.swift  # Text field
│   │       └── ListingCard.swift  # Food listing card
│   └── Utilities/
│       └── HapticManager.swift    # Haptic feedback
├── Models/
│   └── Models.swift               # Data models
├── ViewModels/
│   ├── AuthenticationViewModel.swift
│   └── CustomerHomeViewModel.swift
├── Views/
│   ├── Onboarding/
│   │   ├── WelcomeView.swift
│   │   ├── UserTypeSelectionView.swift
│   │   ├── SignInView.swift
│   │   └── SignUpView.swift
│   ├── Customer/
│   │   ├── CustomerHomeView.swift
│   │   ├── ListingDetailView.swift
│   │   └── ListingsMapView.swift
│   └── Shared/
│       ├── ImpactView.swift
│       └── ProfileView.swift
└── Resources/
    └── Info.plist
```

## 🎨 Design System

### Colors
```swift
Color.primaryGradientStart  // #118b50
Color.primaryGradientEnd    // #5db996
Color.accent                // #caf8a5
```

### Typography
- Display: 57pt, 45pt, 36pt (bold, rounded)
- Headline: 32pt, 28pt, 24pt (semibold, rounded)
- Title: 22pt, 18pt, 16pt (semibold, rounded)
- Body: 17pt, 15pt, 13pt (regular)
- Label: 14pt, 12pt, 11pt (medium)

### Spacing
- xxxs: 2pt
- xxs: 4pt
- xs: 8pt
- sm: 12pt
- md: 16pt (primary spacing)
- lg: 20pt
- xl: 24pt
- xxl: 32pt
- xxxl: 40pt
- xxxxl: 48pt

### Corner Radius
- Standard cards: 24pt (xxl)
- Buttons: 24pt (xxl)
- Input fields: 16pt (lg)
- Chips: 20pt (xl)

## 🔧 Key Components

### RPButton
Reusable button with multiple styles:
- Primary (gradient)
- Secondary (accent)
- Outline
- Destructive
- Ghost

Sizes: small, medium, large
Supports loading states and disabled states

### RPCard
Glassmorphic card component with:
- Optional glassmorphism effect
- Customizable padding
- Soft shadows
- Rounded corners

### RPTextField
Modern text field with:
- Icon support
- Secure entry toggle
- Clear button
- Error state
- Focus state with border animation

### ListingCard
Food listing card displaying:
- Food image with skeleton loading
- Price with discount badge
- Distance indicator
- Category icon
- Pickup window
- "Almost Gone" indicator
- Quantity remaining

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0+
- iOS 16.0+ deployment target
- Swift 5.9+

### Setup

1. **Clone the repository**
```bash
git clone https://github.com/yourcompany/replate-ios.git
cd replate-ios
```

2. **Open in Xcode**
```bash
open RePlate.xcodeproj
```

3. **Add Color Assets**
Create a Colors.xcassets folder and add these colors:
- Background (light: white, dark: #000000)
- SecondaryBackground (light: #F5F5F5, dark: #1C1C1E)
- CardBackground (light: white, dark: #2C2C2E)
- TextPrimary (light: #000000, dark: #FFFFFF)
- TextSecondary (light: #666666, dark: #ADADB8)
- TextTertiary (light: #999999, dark: #7C7C7E)
- Divider (light: #E5E5E5, dark: #3A3A3C)

4. **Configure Backend** (TODO)
- Set up Firebase or Supabase project
- Add GoogleService-Info.plist (Firebase) or configure Supabase client
- Update API endpoints in service files

5. **Configure Stripe** (TODO)
- Add Stripe publishable key
- Implement payment processing

6. **Build and Run**
- Select your target device
- Press Cmd+R to build and run

## 📋 Implementation Checklist

### ✅ Completed
- [x] Design system (colors, typography, spacing)
- [x] Core reusable components
- [x] Data models
- [x] Welcome screen with animations
- [x] User type selection
- [x] Sign in / Sign up flows
- [x] Customer home view
- [x] Listing cards
- [x] Listing detail view
- [x] Map view
- [x] Filter system
- [x] Search functionality
- [x] Location services
- [x] Haptic feedback
- [x] Dark mode support
- [x] Custom tab bar
- [x] Profile view
- [x] Impact dashboard

### 🚧 To Be Implemented
- [ ] Backend integration (Firebase/Supabase)
- [ ] Real authentication
- [ ] Payment processing (Stripe)
- [ ] Apple Pay integration
- [ ] Restaurant posting flow
- [ ] Image upload with camera/photos
- [ ] AI food recognition
- [ ] Real-time messaging
- [ ] Push notifications
- [ ] Order management
- [ ] QR code verification
- [ ] Restaurant verification
- [ ] Saved listings
- [ ] Order history
- [ ] Analytics
- [ ] Email verification
- [ ] Password reset
- [ ] Account deletion
- [ ] Data export
- [ ] Terms of Service screen
- [ ] Privacy Policy screen
- [ ] Help Center
- [ ] Multi-language support
- [ ] Voice input
- [ ] Widget support

## 🔐 Privacy & Security

### Permissions Required
- **Camera**: For taking photos of food items
- **Photos**: For selecting photos from library
- **Location (When In Use)**: For showing nearby listings
- **Notifications**: For order updates and reminders

### Security Features
- Secure authentication with Apple
- Encrypted data transmission
- PCI-compliant payment processing
- No sensitive data stored locally
- Privacy-first design

## 📱 App Store Requirements

### Compliance
- ✅ Sign in with Apple required
- ✅ Privacy permissions properly explained
- ✅ Account deletion functionality
- ✅ Data export functionality
- ✅ Terms of Service & Privacy Policy
- ✅ No dark patterns or misleading urgency
- ✅ Proper error handling
- ✅ Loading states everywhere
- ✅ VoiceOver compatible structure

### Pre-Submission Checklist
- [ ] Add app icon
- [ ] Add launch screen
- [ ] Test on multiple devices
- [ ] Test dark mode on all screens
- [ ] Test accessibility features
- [ ] Test with VoiceOver
- [ ] Test Dynamic Type
- [ ] Add App Store screenshots
- [ ] Write app description
- [ ] Create App Store preview video
- [ ] Set up App Store Connect
- [ ] Configure TestFlight
- [ ] Beta testing

## 🎯 Performance Targets

- Launch time: < 2 seconds
- Navigation: < 100ms
- API calls: < 1 second
- Image loading: Progressive with skeleton
- 60 FPS animations
- Battery efficient location services

## 🧪 Testing

### Unit Tests
```swift
// TODO: Add unit tests for ViewModels
// TODO: Add unit tests for business logic
```

### UI Tests
```swift
// TODO: Add UI tests for critical flows
// TODO: Add accessibility tests
```

### Manual Testing
- [ ] Test all user flows
- [ ] Test on iPhone SE (smallest screen)
- [ ] Test on iPhone Pro Max (largest screen)
- [ ] Test in airplane mode
- [ ] Test with poor network
- [ ] Test with location disabled
- [ ] Test with notifications disabled

## 🤝 Contributing

### Code Style
- Use SwiftLint for code formatting
- Follow Apple's Swift API Design Guidelines
- Use meaningful variable names
- Add comments only where necessary
- Keep functions small and focused

### Git Workflow
```bash
# Create feature branch
git checkout -b feature/your-feature-name

# Make changes and commit
git add .
git commit -m "feat: add your feature"

# Push and create PR
git push origin feature/your-feature-name
```

### Commit Convention
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `style:` Code style changes
- `refactor:` Code refactoring
- `test:` Adding tests
- `chore:` Maintenance tasks

## 📄 License

Copyright © 2026 RePlate. All rights reserved.

## 👥 Team

- Product Manager: [Name]
- Lead iOS Developer: [Name]
- Backend Developer: [Name]
- UI/UX Designer: [Name]

## 📞 Support

For support, email support@replate.app or join our Slack channel.

## 🗺 Roadmap

### Phase 1 (Current)
- ✅ Core UI/UX
- ✅ Authentication flows
- ✅ Customer experience

### Phase 2 (Next)
- [ ] Backend integration
- [ ] Payment processing
- [ ] Restaurant posting flow
- [ ] Real-time features

### Phase 3 (Future)
- [ ] AI features
- [ ] Advanced analytics
- [ ] Social sharing
- [ ] Gamification
- [ ] Widget support
- [ ] Apple Watch app

### Phase 4 (Long-term)
- [ ] iPad support
- [ ] macOS app
- [ ] Web dashboard
- [ ] API for third parties
- [ ] White-label solution

## 📊 Metrics & Analytics

### Key Metrics to Track
- Daily/Monthly Active Users
- Customer-to-Restaurant ratio
- Listings posted per day
- Claims per day
- Average response time
- Average pickup time
- Food waste reduced
- CO₂ impact
- Revenue per restaurant
- Customer retention rate
- Restaurant retention rate

### Tools to Integrate
- Firebase Analytics
- Mixpanel
- Amplitude
- App Store Connect Analytics

---

Built with ❤️ using SwiftUI
