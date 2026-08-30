# Premium Redesign - Quick Start Guide

## 🚀 Getting Started with Your New Premium Design

Your RePlate app has been completely redesigned with a premium UI/UX system. Here's how to start using it immediately.

---

## ✅ What's Already Done

### 1. Design System (`Theme.swift`)
All design tokens are centralized and ready to use:
- Colors, gradients, and semantic colors
- Typography scale (20+ text styles)
- Spacing system (11 values)
- Corner radius scale
- Shadow system
- Animation timing

### 2. Component Library (`PremiumComponents.swift`)
15+ premium components ready to use:
- Buttons (primary, secondary, FAB, animated)
- Cards (4 variants)
- Badges (4 styles)
- Text fields
- Empty states
- Loading states
- Tab bar
- Headers
- Toast notifications

### 3. Restaurant Dashboard (LIVE)
The Restaurant Dashboard is **fully redesigned** and functional:
- Premium stats cards
- Quick action grid
- Enhanced listing cards
- Order management cards
- Environmental impact section
- Floating action button

### 4. Listing Views (`PremiumListingViews.swift`)
Customer-facing listing components:
- Premium food listing cards
- Full listing detail view
- Image carousel
- Claim flow

---

## 🎯 How to Apply to Other Screens

### Step 1: Replace Components

**Old Component** → **New Premium Component**

```swift
// Before
DashboardStatCard(icon: "bag.fill", value: "10", label: "Orders", color: .blue)

// After
PremiumStatCard(icon: "bag.fill", value: "10", label: "Orders", color: Theme.Colors.info, showGlow: true)
```

```swift
// Before
EmptyStateView(icon: "fork.knife", title: "No Items", message: "Try adding some")

// After
PremiumEmptyState(icon: "fork.knife", title: "No Items", message: "Try adding some")
```

```swift
// Before
PrimaryButton("Continue") { /* action */ }

// After
AnimatedButton("Continue", icon: "arrow.right", style: .primary) { /* action */ }
```

### Step 2: Update Spacing

Replace hardcoded values with theme spacing:

```swift
// Before
.padding(16)
.padding(.vertical, 24)

// After
.padding(Theme.Spacing.base)
.padding(.vertical, Theme.Spacing.xl)
```

### Step 3: Use Premium Typography

```swift
// Before
.font(.system(size: 24, weight: .bold))

// After
.font(Theme.Typography.title2)
```

### Step 4: Apply Shadows

```swift
// Before
.shadow(radius: 5)

// After
.shadow(color: Color.black.opacity(0.06), radius: 12, y: 4)
```

### Step 5: Use Corner Radius

```swift
// Before
.cornerRadius(12)

// After
.cornerRadius(Theme.CornerRadius.card)
```

---

## 📱 Screen-by-Screen Migration Guide

### Customer Browse/Home View

**Current State**: Needs redesign
**Components to Use**:
- `HeroHeader` for search section
- `SectionHeader` for "Nearby" / "Popular"
- `PremiumFoodListingCard` for listings
- `FloatingTabBar` for navigation

**Pattern**:
```swift
ScrollView {
    VStack(spacing: Theme.Spacing.sectionSpacing) {
        // Search hero
        searchSection
        
        // Filters
        filterChipsSection
        
        // Listings
        SectionHeader(title: "Nearby Restaurants")
        ForEach(listings) { listing in
            PremiumFoodListingCard(listing: listing, distance: 0.5) {
                // Navigate to detail
            }
            .padding(.horizontal, Theme.Spacing.screenPadding)
        }
    }
}
```

### Search/Filter View

**Components to Use**:
- `CustomTextField` for search input
- `PremiumBadge` for filter chips
- Animated transitions

### Profile View

**Components to Use**:
- `HeroHeader` with user greeting
- `PremiumStatCard` for user stats (meals saved, CO₂ reduced)
- `ImpactStatCard` for environmental metrics
- `PremiumCard` for settings sections
- `AnimatedButton` for sign out

**Pattern**:
```swift
ScrollView {
    VStack(spacing: Theme.Spacing.sectionSpacing) {
        // Profile header with avatar
        profileHeader
        
        // Impact stats
        SectionHeader(title: "Your Impact")
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
            ImpactStatCard(icon: "leaf.fill", value: "127", label: "Meals Saved", color: Theme.Colors.impactGreen)
            ImpactStatCard(icon: "arrow.down.circle.fill", value: "318kg", label: "CO₂ Reduced", color: Theme.Colors.impactBlue)
        }
        
        // Settings sections
        SectionHeader(title: "Settings")
        PremiumCard(style: .elevated) {
            // Settings items
        }
    }
    .padding(.horizontal, Theme.Spacing.screenPadding)
}
```

### Order Tracking

**Components to Use**:
- `PremiumCard` for order status
- `ProgressStepIndicator` for order progress
- `PremiumBadge` for status
- Monospaced font for pickup code

### Onboarding Flow

**Components to Use**:
- `HeroHeader` with gradient title
- Full-screen image backgrounds
- `AnimatedButton` for CTAs
- `ProgressStepIndicator` for pagination

---

## 🎨 Common Patterns

### Full-Width Button at Bottom
```swift
.overlay(alignment: .bottom) {
    VStack(spacing: 0) {
        Divider()
        AnimatedButton("Continue", style: .primary) {
            // Action
        }
        .padding(Theme.Spacing.screenPadding)
        .background(.ultraThinMaterial)
    }
}
```

### Section with Header and Content
```swift
VStack(spacing: Theme.Spacing.itemSpacing) {
    SectionHeader(title: "Section Title", actionTitle: "See All") {
        // Action
    }
    
    // Content here
}
```

### Grid of Stat Cards
```swift
LazyVGrid(
    columns: [GridItem(.flexible()), GridItem(.flexible())],
    spacing: Theme.Spacing.itemSpacing
) {
    PremiumStatCard(...)
    PremiumStatCard(...)
}
.padding(.horizontal, Theme.Spacing.screenPadding)
```

### Empty State
```swift
if items.isEmpty {
    PremiumEmptyState(
        icon: "tray",
        title: "Nothing Here",
        message: "Try adding some items",
        actionTitle: "Add Item"
    ) {
        // Action
    }
    .padding(.horizontal, Theme.Spacing.screenPadding)
}
```

### Loading State
```swift
if isLoading {
    VStack(spacing: Theme.Spacing.compactSpacing) {
        ForEach(0..<3, id: \.self) { _ in
            ShimmerView(cornerRadius: Theme.CornerRadius.cardLarge)
                .frame(height: 140)
        }
    }
    .padding(.horizontal, Theme.Spacing.screenPadding)
}
```

---

## 🎯 Priority Updates

### Immediate (High Impact)
1. **Customer Home/Browse** - Main discovery screen
2. **Profile View** - User dashboard
3. **Onboarding** - First impression
4. **Tab Bar** - Replace with `FloatingTabBar`

### Next (Medium Impact)
5. **Search/Filter** - Better UX
6. **Order Tracking** - Enhanced status display
7. **Messaging** - If implemented
8. **Settings** - Consistent styling

### Later (Low Impact)
9. **Help/Support** - Standard forms
10. **Legal Pages** - Simple text views

---

## 💡 Pro Tips

### 1. Use Semantic Spacing
```swift
// Good ✅
.padding(Theme.Spacing.screenPadding)
.padding(.vertical, Theme.Spacing.sectionSpacing)

// Avoid ❌
.padding(20)
.padding(.vertical, 32)
```

### 2. Leverage Gradients
```swift
// For important text
Text("Welcome")
    .foregroundStyle(Theme.Colors.primaryGradient)

// For backgrounds
.background(Theme.Colors.primaryGradient)
```

### 3. Add Haptic Feedback
```swift
Button("Tap Me") {
    hapticFeedback(.light)  // For secondary actions
    hapticFeedback(.medium) // For primary actions
    // Your action
}
```

### 4. Use Consistent Shadows
```swift
// Don't mix shadow styles
// Pick card, floating, elevated, or subtle based on context

// Example: Card
.shadow(color: Color.black.opacity(0.06), radius: 12, y: 4)
```

### 5. Animate with Spring
```swift
withAnimation(Theme.Animation.springBouncy) {
    // State change
}
```

---

## 🐛 Common Issues & Fixes

### Issue: Component not found
**Fix**: Import or check file is in project

### Issue: Color looks wrong
**Fix**: Use semantic colors from Theme.Colors

### Issue: Layout feels cramped
**Fix**: Increase spacing using Theme.Spacing values

### Issue: Button too small on iPad
**Fix**: Add maxWidth with horizontal padding:
```swift
.frame(maxWidth: Theme.Layout.maxCardWidth)
.padding(.horizontal, Theme.Spacing.screenPadding)
```

### Issue: Animation feels janky
**Fix**: Use spring animations instead of linear

---

## 📖 Full Documentation

For complete design specs and guidelines:
- **PREMIUM_DESIGN_GUIDE.md** - Complete design system
- **REDESIGN_SUMMARY.md** - What changed
- **Theme.swift** - All design tokens
- **PremiumComponents.swift** - Component source
- **RestaurantViews.swift** - Example implementation

---

## 🎨 Design Philosophy

Remember these principles when building new screens:

1. **Mobile-First** - Optimize for phone, then scale up
2. **Generous Spacing** - Let content breathe
3. **Visual Hierarchy** - Size, weight, color for importance
4. **Consistent Patterns** - Reuse components and layouts
5. **Delightful Details** - Animations, haptics, micro-interactions
6. **Environmental Focus** - Green branding, impact metrics
7. **Accessibility** - High contrast, large tap targets

---

## ✅ Quick Checklist for New Screens

When creating a new screen:

- [ ] Use `Theme.Spacing` for all spacing
- [ ] Use `Theme.Typography` for all text
- [ ] Use `Theme.Colors` for all colors
- [ ] Use `Theme.CornerRadius` for all corners
- [ ] Add proper shadows (card/floating/elevated)
- [ ] Add spring animations for interactions
- [ ] Add haptic feedback for buttons
- [ ] Use premium components where possible
- [ ] Test in light AND dark mode
- [ ] Ensure 44pt minimum tap targets
- [ ] Add loading states (shimmer)
- [ ] Add empty states
- [ ] Respect safe area insets
- [ ] Add bottom padding for FABs/tabs

---

## 🚀 You're Ready!

Your premium design system is **fully implemented** and ready to use. Start with the high-priority screens, follow the patterns from the Restaurant Dashboard, and reference the examples in this guide.

**Happy building!** ✨🌱
