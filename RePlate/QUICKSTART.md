# Quick Start Guide

## Getting Started in 5 Minutes

### Step 1: Open the Project
1. Open Xcode (15.0 or later)
2. Open `RePlate.xcodeproj`
3. Wait for indexing to complete

### Step 2: Select Target
1. Click on the scheme selector (top left)
2. Choose "RePlate"
3. Select "iPhone 15 Pro" simulator (or any recent iPhone)

### Step 3: Run the App
1. Press `⌘R` or click the Play button
2. Wait for build to complete
3. App launches in simulator

## First-Time Experience

### What You'll See
1. **Onboarding** - Three beautiful intro screens
2. **Account Selection** - Choose Customer or Restaurant
3. **Sign Up** - Create account (demo data, no real backend needed)
4. **Main App** - Full functional interface

### Quick Test Flows

#### As a Customer
```
1. Launch app
2. Tap "Skip" on onboarding
3. Select "Customer"
4. Tap "Sign Up"
5. Fill in any demo info (test@test.com / password123)
6. Agree to terms
7. Tap "Create Account"
8. → You're in! Browse listings, search, view orders
```

#### As a Restaurant
```
1. Launch app
2. Tap "Skip" on onboarding
3. Select "Restaurant"
4. Tap "Sign Up"
5. Fill in restaurant name and info
6. Tap "Create Account"
7. → Dashboard appears with quick actions
8. Tap FAB (+ button) to post listing
9. Follow 5-step wizard
```

## Testing Features

### Customer Side
- ✅ Browse home feed with listings
- ✅ Tap any listing to see details
- ✅ Search for food (type anything)
- ✅ Apply filters (tap filter icon)
- ✅ View orders (Orders tab)
- ✅ Check messages (Messages tab)
- ✅ View profile and stats (Profile tab)
- ✅ Change appearance (Profile → Settings)

### Restaurant Side
- ✅ View dashboard metrics
- ✅ Tap FAB to post listing
- ✅ Upload photos (from Photos app)
- ✅ Complete posting wizard
- ✅ Manage active listings
- ✅ View pending orders

## Key Interactions to Try

### 1. Claim Food Flow
```
Home → Listing Card → Details → Adjust Quantity → Claim Now → Checkout
```

### 2. Post Food Flow
```
Dashboard → FAB → Photos → Details → Pricing → Pickup → Review → Post
```

### 3. Search & Filter
```
Search Tab → Type "salad" → See results → Tap Filter → Select categories → Done
```

### 4. Dark Mode Toggle
```
Profile → Settings → Appearance → Select "Dark" or "System"
```

### 5. Impact Stats
```
Home → Scroll to Community Impact → See animated counters
Profile → Your Impact → View personal stats
```

## What Works Right Now

### ✅ Fully Functional
- All navigation
- All UI elements
- Mock data displays
- Animations and transitions
- Dark/light mode
- Form validation
- State management
- Loading states
- Empty states
- Error handling (UI)

### 🔄 Needs Backend
- Real authentication
- Database operations
- Image uploads
- Payments
- Push notifications
- Real-time updates

## Common Actions

### Sign Out
```
Profile → Scroll down → Sign Out
```

### Post a Listing (Restaurant)
```
Tap FAB (+) → Follow 5 steps → Post Listing
```

### Search with Filters
```
Search Tab → Tap filter icon → Select options → Done
```

### View Order Details
```
Orders Tab → Tap any order → See full details
```

## Tips for Demo

### Best Features to Show
1. **Smooth onboarding** - Professional first impression
2. **Home feed** - Beautiful cards with badges
3. **Listing details** - Complete information display
4. **Post wizard** - Step-by-step with progress
5. **Impact stats** - Social good metrics
6. **Dark mode** - Instant theme switching
7. **Search filters** - Advanced filtering
8. **Profile stats** - Personal impact tracking

### Pro Tips
- Pull down to refresh on any list
- Watch for "Almost Gone" and "Expiring Soon" badges
- Notice haptic feedback on interactions
- Try different account types for different experiences
- Toggle dark mode to see complete theme support

## Troubleshooting

### Build Issues
**Problem**: Build fails
**Solution**: 
1. Clean build folder (⌘⇧K)
2. Close and reopen Xcode
3. Delete derived data

**Problem**: Simulator not responding
**Solution**:
1. Quit simulator
2. Relaunch from Xcode
3. Try different simulator device

### Runtime Issues
**Problem**: Images not showing
**Solution**: Expected - mock data uses system images or empty placeholders

**Problem**: Authentication "fails"
**Solution**: Expected - demo mode creates local user instantly

## Next Steps

### To Make It Real
1. Read `IMPLEMENTATION.md`
2. Choose backend (Firebase or Supabase)
3. Integrate authentication
4. Connect database
5. Set up image storage
6. Integrate payments
7. Add push notifications
8. Test on device
9. Prepare App Store assets
10. Submit for review

### File to Modify First
```
AppState.swift - Update AuthService with real backend
APIService.swift - Create this for API calls
ViewModels.swift - Replace mock data with API calls
```

## Support

### Documentation
- `README.md` - Project overview
- `IMPLEMENTATION.md` - Complete integration guide
- `PROJECT_SUMMARY.md` - What's been built

### Code Comments
- Check inline comments for explanations
- Look for `// TODO:` for integration points
- See `// MARK:` for code organization

## Keyboard Shortcuts

- `⌘R` - Run app
- `⌘.` - Stop app
- `⌘⇧K` - Clean build
- `⌘B` - Build
- `⌘/` - Comment/uncomment
- `⌃I` - Re-indent code

## That's It! 🎉

You're ready to explore RePlate. The app is fully functional with mock data and ready for backend integration. Enjoy exploring the codebase!

**Questions?** Review the documentation files or explore the well-organized code structure.

**Ready to ship?** Follow IMPLEMENTATION.md for backend integration steps.

**Want to learn?** The code demonstrates modern SwiftUI best practices throughout.

---

Happy coding! 🚀
