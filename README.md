# TMM-Mini
TrackMyMetric Demo Task

# TMM Mini - Health Tracking App 🏃‍♂️

A modern iOS health tracking application that provides users with clear, actionable insights about their daily activity through HealthKit integration.

## 📱 Overview

TMM Mini is a health tracking application that helps users monitor their daily steps and calorie burn through beautiful visualizations and meaningful insights. The app features fitness rings (inspired by Apple Watch), 7-day trend charts, and personalized weekly comparisons.

### Key Features

- 🎯 **Fitness Rings** - Visual progress tracking for steps and calories
- 📊 **7-Day Charts** - Track your activity trends with interactive bar charts
- 🎠 **Smart Insights** - Automated weekly comparisons and best day highlights
- 💾 **Offline Support** - 30-day data caching for instant loading
- 🔄 **Pull-to-Refresh** - Always get the latest data from HealthKit
- ✨ **Skeleton Loading** - Beautiful loading states for better UX
- 🎨 **Premium Animations** - Smooth transitions and delightful interactions

---

## 🏗️ Architecture Overview

### MVVM + Combine Architecture

The app follows a clean **MVVM (Model-View-ViewModel)** architecture with **Combine** for reactive programming.

```
┌─────────────────────────────────────────────────────┐
│                    Presentation Layer                │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐          │
│  │SplashVC  │  │OnBoardVC │  │ HomeVC   │          │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘          │
│       │             │              │                 │
│  ┌────▼─────┐  ┌───▼──────┐  ┌───▼──────┐         │
│  │SplashVM  │  │OnBoardVM │  │ HomeVM   │         │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘         │
└───────┼─────────────┼─────────────┼────────────────┘
        │             │              │
┌───────▼─────────────▼──────────────▼────────────────┐
│                  Business Layer                      │
│  ┌────────────────────────────────────────┐         │
│  │        HealthKitService                │         │
│  │  (Protocol-based abstraction)          │         │
│  └──────────────┬─────────────────────────┘         │
└─────────────────┼──────────────────────────────────┘
                  │
┌─────────────────▼──────────────────────────────────┐
│                   Data Layer                        │
│  ┌──────────────┐        ┌──────────────┐         │
│  │HealthKit     │        │ CoreData     │         │
│  │Repository    │        │Repository    │         │
│  └──────────────┘        └──────────────┘         │
└────────────────────────────────────────────────────┘
```

### Key Components

#### 1. **ViewModels**
- **SplashViewModel** - Handles initial navigation and permission checking
- **OnBoardViewModel** - Manages HealthKit authorization flow
- **HomeViewModel** - Core business logic, data fetching, and insights calculation

#### 2. **Services**
- **HealthKitService** - Abstraction layer over HealthKit
- **HealthKitRepository** - Direct HealthKit data access with error handling

#### 3. **Data Persistence**
- **HealthDataRepository** - CoreData operations for 30-day caching
- **CoreDataManager** - Persistent store management

#### 4. **UI Components**
- **Custom Table View Cells** - RingsTVCell, ChartTVCell, CarouselTVCell
- **SwiftUI Charts** - Modern bar charts with iOS 16+ support
- **Skeleton Views** - Loading state placeholders

---

## 🔧 Setup Instructions

### Prerequisites

- Xcode 15.0+
- iOS 16.0+ deployment target
- CocoaPods 1.12.0+

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/tmm-mini.git
   cd tmm-mini
   ```

2. **Install dependencies**
   ```bash
   pod install
   ```

3. **Open workspace**
   ```bash
   open TMM\ Mini.xcworkspace
   ```

4. **Configure HealthKit**
   - Ensure HealthKit capability is enabled in project settings
   - Add HealthKit usage descriptions to `Info.plist`:
     ```xml
     <key>NSHealthShareUsageDescription</key>
     <string>We need access to read your step count and calories to show your health statistics</string>
     ```

5. **Setup CoreData**
   - Create `TMMModel.xcdatamodeld` file
   - Add `HealthDataEntity` with attributes:
     - `id` (UUID)
     - `date` (Date)
     - `stepCount` (Double)
     - `activeEnergy` (Double)
     - `createdAt` (Date)
     - `updatedAt` (Date)

6. **Build and Run**
   - Select a physical device (HealthKit doesn't work well in Simulator)
   - Build and run (⌘R)

### Required Pods

```ruby
pod 'SkeletonView'        # Skeleton loading animations
pod 'lottie-ios'          # Confetti animations
pod 'MKRingProgressView'  # Fitness rings (if not custom)
```

---

## 📐 Key Design Decisions

### 1. **MVVM with Combine**

**Decision**: Use MVVM architecture with Combine for reactive data flow

**Rationale**:
- Clear separation of concerns
- Testable business logic
- Reactive UI updates
- Type-safe data binding

**Tradeoffs**:
- ✅ Pros: Clean architecture, easy to test, scalable
- ❌ Cons: More boilerplate, steeper learning curve for Combine

### 2. **CoreData for Caching**

**Decision**: Cache 30 days of health data in CoreData

**Rationale**:
- Instant app launch with cached data
- Reduced HealthKit queries (battery friendly)
- Offline capability for historical data
- Fast calculations for weekly insights

**Tradeoffs**:
- ✅ Pros: Fast load times, works offline, better UX
- ❌ Cons: Extra storage, sync complexity, potential stale data

### 3. **Protocol-Oriented Service Layer**

**Decision**: Use protocols for all services (HealthKitService, Repository)

**Rationale**:
- Dependency injection ready
- Easy to mock for testing
- Flexible implementation swapping
- Follows SOLID principles

**Tradeoffs**:
- ✅ Pros: Testable, flexible, maintainable
- ❌ Cons: More interfaces to maintain

### 4. **Skeleton Views Instead of Spinners**

**Decision**: Use SkeletonView library for loading states

**Rationale**:
- Modern UX pattern (used by Facebook, LinkedIn)
- Shows layout structure early
- Reduces perceived load time
- More engaging than spinners

**Tradeoffs**:
- ✅ Pros: Better UX, modern feel, reduces perceived wait
- ❌ Cons: External dependency, more implementation work

### 5. **SwiftUI Charts with UIKit**

**Decision**: Embed SwiftUI charts in UIKit table view cells

**Rationale**:
- Leverage iOS 16+ native Charts framework
- Beautiful, animated charts out of the box
- Easier than custom drawing code
- Smooth integration with UIHostingController

**Tradeoffs**:
- ✅ Pros: Native, maintained by Apple, beautiful
- ❌ Cons: iOS 16+ only, mixing SwiftUI/UIKit

### 6. **Date-Based Data Verification**

**Decision**: Explicitly match dates instead of using array `.last`

**Rationale**:
- HealthKit queries complete in random order
- `.last` doesn't guarantee "today's" data
- Explicit matching prevents display bugs
- More reliable than sorting alone

**Tradeoffs**:
- ✅ Pros: Reliable, correct data displayed
- ❌ Cons: More code, slight performance overhead

### 7. **Programmatic Splash Animations**

**Decision**: Animate splash screen programmatically (not AutoLayout)

**Rationale**:
- More control over animation timing
- No Interface Builder setup required
- Easier to customize and tune
- Smoother interpolation

**Tradeoffs**:
- ✅ Pros: Full control, easy to adjust, smooth
- ❌ Cons: Doesn't respect AutoLayout as naturally

---

## 🎯 Data Flow

### App Launch Flow

```
1. SplashVC
   ├─ Check if first launch
   │  ├─ YES → Navigate to OnBoardVC
   │  └─ NO → Check HealthKit status
   │     ├─ Authorized → Navigate to HomeVC
   │     └─ Denied → Show Limited Mode Alert
   │
2. OnBoardVC (if first launch)
   ├─ Request HealthKit permission
   ├─ User grants/denies
   │  ├─ Granted → Navigate to HomeVC
   │  └─ Denied → Show Limited Mode Alert → Navigate to HomeVC
   │
3. HomeVC
   ├─ Show skeleton loading
   ├─ Load cached data (instant)
   ├─ Fetch fresh data from HealthKit (background)
   ├─ Update UI
   └─ Calculate insights
```

### Data Fetching Strategy

```
HomeViewModel.loadInitialData()
   │
   ├─ Check HealthKit authorization
   │  │
   │  ├─ Authorized
   │  │  ├─ 1. Load cached data (instant)
   │  │  │  └─ Display immediately (great UX)
   │  │  │
   │  │  └─ 2. Fetch fresh data (background)
   │  │     ├─ Query last 7 days from HealthKit
   │  │     ├─ Sort by date
   │  │     ├─ Match today's data explicitly
   │  │     ├─ Save to CoreData
   │  │     ├─ Calculate insights
   │  │     └─ Update UI
   │  │
   │  └─ Not Authorized
   │     └─ Show cached data only (if available)
```

### Pull-to-Refresh Flow

```
User pulls down
   │
   ├─ Show refresh control
   ├─ Force fetch from HealthKit
   ├─ Update cache
   ├─ Recalculate insights
   ├─ Update UI
   └─ Hide refresh control
```

---

### Integration Tests

- HealthKit authorization flow
- CoreData persistence
- Data fetching and caching

### UI Tests

- Onboarding flow
- Permission handling
- Pull-to-refresh
- Empty states

---

## 📊 Performance Optimizations

### 1. **Lazy Data Fetching**
- Show cached data immediately (< 100ms)
- Fetch fresh data in background
- Progressive UI updates

### 2. **Efficient HealthKit Queries**
- Query only necessary data types
- Use date predicates to limit results
- Batch queries for 7 days at once

### 3. **CoreData Optimizations**
- Indexed date field for fast lookups
- Batch saves (one per day, not per query)
- Automatic cleanup (delete > 30 days)

### 4. **UI Optimizations**
- Skeleton views reduce perceived wait time
- Reusable table view cells
- SwiftUI chart rendering on background thread
- Smooth animations with spring physics

---

## 🚀 What I Would Improve in 1 Week

### High Priority (Days 1-3)

#### 1. **Comprehensive Testing** ⚡️
**Current State**: Minimal test coverage
**Goal**: 80%+ coverage

**Implementation**:
```swift
// Add Unit Tests
- HomeViewModelTests
- SplashViewModelTests
- OnBoardViewModelTests
- HealthKitRepositoryTests (mocked)

// Add Integration Tests
- End-to-end onboarding flow
- Data persistence lifecycle
- Permission handling edge cases

// Add UI Tests
- Complete user journeys
- Error state handling
- Accessibility tests
```

**Benefit**: Catch bugs early, confident refactoring, better code quality

---

#### 2. **Error Handling & Recovery** 🛡️
**Current State**: Basic error handling
**Goal**: Robust error recovery with user feedback

**Implementation**:
```swift
// Enhanced Error Types
enum HealthKitError: Error {
    case authorizationDenied
    case unavailable
    case queryFailed(reason: String)
    case networkError
    case rateLimitExceeded
}

// User-Friendly Error Messages
extension HealthKitError {
    var userMessage: String {
        switch self {
        case .authorizationDenied:
            return "Please enable HealthKit access in Settings"
        case .queryFailed(let reason):
            return "Unable to load data: \(reason)"
        // ...
        }
    }
    
    var recoverySuggestion: String {
        // Actionable steps for user
    }
}

// Retry Logic
class RetryHandler {
    func retry<T>(
        maxAttempts: Int = 3,
        operation: @escaping () -> AnyPublisher<T, Error>
    ) -> AnyPublisher<T, Error> {
        // Exponential backoff retry
    }
}
```

**Benefit**: Better user experience, fewer support tickets, clearer debugging

---

#### 3. **Analytics & Logging** 📈
**Current State**: Print statements
**Goal**: Structured logging and analytics

**Implementation**:
```swift
// Logging Framework
enum LogLevel {
    case debug, info, warning, error, critical
}

protocol Logger {
    func log(_ message: String, level: LogLevel, file: String, function: String)
}

// Analytics Events
enum AnalyticsEvent {
    case appLaunched
    case onboardingStarted
    case onboardingCompleted
    case healthKitAuthorized
    case healthKitDenied
    case dataRefreshed
    case insightViewed(type: String)
    case errorOccurred(error: Error)
}

// Usage
Analytics.shared.track(.healthKitAuthorized)
Logger.shared.log("Data fetched successfully", level: .info)
```

**Benefit**: Understand user behavior, track bugs, optimize features

---

### Medium Priority (Days 4-5)

#### 4. **Advanced Features** ✨

**A. Customizable Goals**
```swift
// User settings
struct HealthGoals: Codable {
    var dailySteps: Int = 10_000
    var dailyCalories: Int = 500
    var weeklyActive: Int = 5 // days
}

// Settings screen
class SettingsViewController {
    // Allow users to customize their goals
    // Update ring progress calculations dynamically
}
```

**B. Notifications**
```swift
// Daily reminders
- "You're 2,000 steps away from your goal!"
- "Great job! You've hit your goal 5 days this week"
- "Your best week yet! Keep it up!"

// Implementation
class NotificationManager {
    func scheduleGoalReminder(at time: Date)
    func scheduleAchievementNotification()
}
```

**C. Widgets**
```swift
// Home Screen Widget
- Show today's rings
- Display step count
- Quick glance at progress

// Lock Screen Widget (iOS 16+)
- Circular progress indicator
- Step count
```

**Benefit**: Increased engagement, better retention, more value

---

#### 5. **UI/UX Polish** 🎨

**A. Haptic Feedback**
```swift
// Add haptics for:
- Ring completion (heavy impact)
- Goal achieved (success notification)
- Button taps (light impact)
- Pull-to-refresh completion (selection feedback)

let impact = UIImpactFeedbackGenerator(style: .medium)
impact.impactOccurred()
```

**B. Advanced Animations**
```swift
// Enhance:
- Ring fill animations (more organic)
- Chart bar entrance (staggered timing)
- Skeleton shimmer (custom gradient)
- Confetti burst (particle system)

// Micro-interactions:
- Button press states
- Cell selection feedback
- Swipe gestures
```

**C. Dark Mode Optimization**
```swift
// Ensure all colors adapt properly
- Test rings in dark mode
- Verify chart readability
- Adjust skeleton colors
- Update icon colors
```

**Benefit**: More polished feel, better engagement, premium perception

---

### Nice-to-Have (Days 6-7)

#### 6. **Data Export** 📤
```swift
// Export options
- PDF Report (weekly/monthly summaries)
- CSV Export (raw data)
- Share to Health app
- Email report

class ExportManager {
    func generatePDFReport(for dateRange: DateRange) -> Data
    func generateCSV(for dateRange: DateRange) -> String
}
```

#### 7. **Social Features** 👥
```swift
// Friendly competition
- Share achievements
- Weekly challenges with friends
- Leaderboards (optional, privacy-first)
- Encouragement messages

class SocialManager {
    func shareAchievement(_ achievement: Achievement)
    func inviteFriend()
}
```

#### 8. **Advanced Insights** 🧠
```swift
// Smart analysis
- Identify patterns (e.g., "Most active on Wednesdays")
- Predict goal achievement
- Suggest optimal activity times
- Detect unusual activity

class InsightsEngine {
    func analyzePatterns(data: [HealthData]) -> [Insight]
    func generatePersonalizedTips() -> [String]
}
```

---

## 🏛️ Architecture Improvements (Future)

### 1. **Modularization**
```
TMM Mini
├── Core (Framework)
│   ├── Networking
│   ├── Persistence
│   └── Analytics
├── HealthKit (Framework)
│   ├── Services
│   └── Models
├── UI (Framework)
│   ├── Components
│   └── Styles
└── App (Main Target)
```

### 2. **Coordinator Pattern**
```swift
protocol Coordinator {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    func start()
}

class AppCoordinator: Coordinator {
    func start() {
        showSplash()
    }
    
    func showOnboarding() { /* ... */ }
    func showHome() { /* ... */ }
}
```

### 3. **Dependency Injection Container**
```swift
protocol DependencyContainer {
    func makeHealthKitService() -> HealthKitServiceProtocol
    func makeDataRepository() -> HealthDataRepositoryProtocol
    // ... all dependencies
}

// Benefit: Better testability, clearer dependencies
```

---

## 📝 Known Issues & Limitations

### Current Limitations

1. **HealthKit Simulator Support**
   - Limited/no data in iOS Simulator
   - Testing requires a physical device

2. **iOS 16+ Requirement**
   - Charts framework requires iOS 16+
   - Fallback view for older versions is basic

3. **Real-time Sync**
   - Data updates on app launch and pull-to-refresh
   - No background updates (would require background modes)

4. **Single User**
   - No multi-user support
   - No data sync across devices

5. **Limited Data Types**
   - Only tracks steps and calories
   - Could expand to heart rate, distance, workouts

### Known Bugs

- None currently identified (pending comprehensive testing)

---

## 🤝 Contributing

### Code Style

- Follow Swift API Design Guidelines
- Use SwiftLint for consistency
- Write self-documenting code
- Add comments for complex logic

### Commit Message Format

```
type(scope): subject

body

footer
```

**Types**: feat, fix, docs, style, refactor, test, chore

**Example**:
```
feat(home): add weekly comparison insight

- Calculate the current week vs the previous week average
- Display percentage change in carousel
- Add unit tests for comparison logic

Closes #123
```

---

## 🗺️ Roadmap

### Q1 2026
- [ ] Comprehensive test suite
- [ ] Enhanced error handling
- [ ] Analytics integration
- [ ] Widget support

### Q2 2026
- [ ] Customizable goals
- [ ] Dark mode optimization
- [ ] Export functionality
- [ ] Notifications

### Q3 2026
- [ ] Apple Watch app
- [ ] Advanced insights
- [ ] Social features
- [ ] Cloud sync

---

**Built with ❤️ for health-conscious users**

*Version 1.0.0 - January 2026*
