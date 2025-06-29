<div align="center">

  # Drinkr! - iOS Social Drinking Discovery App
  <img src="/Screenshots/Logo.png" alt="Logo" width="150" height="150"> <br />

  [![Swift Version](https://img.shields.io/badge/swift-5.0-orange.svg)](https://swift.org/) [![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE) [![Platform](https://img.shields.io/cocoapods/p/LFAlertController.svg?style=flat)](http://cocoapods.org/pods/LFAlertController)

</div>

Drinkr! is a comprehensive iOS social discovery app that combines drink identification, bar discovery, cocktail recipes, and social networking. Built with native iOS technologies and powered by Firebase, Core ML, and multiple APIs, it provides a complete social platform for drink enthusiasts to discover, share, and explore the world of beverages.

## 📷 Screenshots

<p align="row">
  <img src= "/Screenshots/AppStoreScreenshot.png">
</p>

## ✨ Key Features

### 🔍 Machine Learning Drink Scanner

- **AI Recognition**: Custom-trained Core ML models for beer and whiskey identification
- **Multi-Input Support**: Camera capture and photo library selection
- **Scan History**: Track and revisit all scanned drinks
- **Rich Information**: Detailed drink data including origin, alcohol volume, and type

### 🗺 Bar Discovery & Maps

- **Location Services**: Find nearby bars and pubs using Google Places API
- **Interactive Maps**: Apple MapKit integration with dynamic pins and navigation
- **Smart Search**: Customizable radius and filtering options
- **Favorites**: Save and manage preferred locations

### 🍸 Cocktail Recipe Database

- **Comprehensive Database**: Access thousands of cocktail recipes via TheCocktailDB API
- **Smart Search**: Find recipes by ingredients, name, or alcohol type
- **Recipe Categories**: Organized by spirit base (Gin, Whiskey, Vodka, etc.)
- **Shake to Discover**: Motion-based random cocktail suggestions

### 📱 Social Media Features

- **Content Creation**: Photo posts with captions and camera integration
- **Social Engagement**: Like and comment system with real-time updates
- **Personalized Feed**: Content based on following relationships
- **Content Moderation**: User reporting and blocking capabilities

### 👤 User Management

- **Multi-Provider Auth**: Firebase, Google Sign-In, and Apple Sign-In support
- **Activity Tracking**: History of scans, favorites, and social interactions
- **Profile Customization**: User photos and preferences

## 🛠 Tech Stack

### Core Technologies

- **Language**: Swift 5.0
- **Framework**: UIKit with MVC architecture
- **Minimum iOS Version**: iOS 13.0+
- **Development Tool**: Xcode 14.0+
- **Backend**: Firebase (Firestore, Authentication, Storage)

### Third-Party Libraries & Dependencies

```ruby
# Key Dependencies (estimated from codebase analysis)
# UI & Animation
pod 'Lottie'              # Rich animations and micro-interactions
pod 'MJRefresh'           # Pull-to-refresh functionality
pod 'ProgressHUD'         # Loading indicators and progress displays
pod 'IQKeyboardManager'   # Intelligent keyboard management

# Networking & Images
pod 'Alamofire'           # HTTP networking and API requests
pod 'Kingfisher'          # Async image loading and caching

# Firebase Services
pod 'Firebase/Firestore'  # NoSQL database
pod 'Firebase/Auth'       # User authentication
pod 'Firebase/Storage'    # File and image storage
pod 'FirebaseFirestoreSwift' # Swift-friendly Firestore bindings

# Google Services
pod 'GooglePlaces'        # Places API integration
pod 'GoogleSignIn'        # OAuth authentication

# Authentication
pod 'AuthenticationServices' # Apple Sign-In support
```

### 📍 Location & Maps

- **CoreLocation**: User location tracking for the Bar Map feature
- **Apple MapKit**: Interactive display of bar locations with dynamic pins
- **Google Places API**: Rich data about nearby bars and nightlife venues
- **Location Services**: Background location updates and geofencing capabilities

### 📷 Camera & Image Processing

- **AVFoundation Camera**: Real-time camera input for bottle scanning
- **Vision Image Classifier**: ML-powered drink identification and preprocessing
- **CoreML**: On-device machine learning for fast bottle recognition
- **Photos Framework**: Photo library access and efficient image management
- **Custom ML Models**: `DemoBeerWhiskyModel.mlmodel` and `BarHeinModel.mlmodel`

### 🔒 Authentication & User Data

- **Google Sign In / Apple Sign In**: Secure, convenient authentication options
- **Firebase Firestore**: Robust user profile and preference storage
- **Firebase Storage**: Efficient management of user-uploaded content
- **Firebase Authentication**: Multi-provider authentication system
- **KeychainManager**: Secure credential storage and management

### 📡 APIs & Data Integration

- **Cocktail DB API**: Comprehensive cocktail recipe database via RapidAPI
- **Google Places API**: Detailed venue information and ratings
- **Alamofire**: HTTP networking for robust API communication
- **Real-time Sync**: Firebase listeners for live data updates

### 🎛 User Interaction & Experience

- **Gesture Recognizer**: Intuitive navigation throughout the app
- **Custom Animations**: Lottie animations for enhanced visual feedback and engagement
- **MJRefresh**: Pull-to-refresh functionality for data updates
- **ProgressHUD**: Loading indicators and progress displays
- **IQKeyboardManager**: Intelligent keyboard management

### 🎵 Media & Content

- **AVFoundation Audio**: Rich audio features for social posts
- **Apple UGC Guidelines Compliance**: Safe, appropriate user-generated content
- **Kingfisher**: Advanced image loading and caching system
- **Image Compression**: Optimized media storage and transmission

### Architecture Patterns

- **MVC (Model-View-Controller)**: Clean separation of concerns
- **Singleton Pattern**: Shared services (FirebaseManager, CocktailManager, GooglePlacesManager)
- **Delegation Pattern**: Protocol-based communication between components
- **Observer Pattern**: Real-time data updates with Firebase listeners
- **Factory Pattern**: Reusable UI components and table view cells

## 🏗 Project Structure

```
Drinkr!/
├── Controllers/               # View controllers for each feature
│   ├── BarMap/               # Bar discovery and map functionality
│   │   ├── BarMapViewController.swift
│   │   ├── BarResultsViewController.swift
│   │   └── FavoriteBarsViewController.swift
│   ├── Cocktails/            # Cocktail recipes and discovery
│   │   ├── CocktailResultsViewController.swift
│   │   ├── DrinkDetailsViewController.swift
│   │   ├── FavoriteCocktailsViewController.swift
│   │   └── RecipesViewController.swift
│   ├── Posts/                # Social media functionality
│   │   ├── PostsViewController.swift
│   │   ├── CameraViewController.swift
│   │   ├── CommentsViewController.swift
│   │   └── EditCaptionViewController.swift
│   ├── Profile/              # User profile management
│   │   ├── ProfileViewController.swift
│   │   ├── SignInViewController.swift
│   │   └── PanelTabsViewController.swift
│   └── Scanner/              # AI-powered drink scanning
│       ├── ScannerViewController.swift
│       └── ScanHistoryViewController.swift
├── Models/                   # Data models and structures
│   ├── DrinksInfo.swift     # Drink information and service
│   ├── DrinksResponse.swift # Cocktail API response models
│   ├── PlacesResponse.swift # Google Places API models
│   ├── Post.swift           # Social media post model
│   ├── ScanHistory.swift    # Scan history tracking
│   ├── User.swift           # User profile model
│   └── *.mlmodel            # Core ML models
├── Views/                    # Custom UI components
│   ├── Cocktails/           # Cocktail-specific UI components
│   ├── Posts/               # Social media UI components
│   └── Custom Cells/        # Reusable table and collection view cells
├── Resource/                 # Core services and managers
│   ├── FirebaseManager.swift    # Firebase integration
│   ├── CocktailManager.swift    # Cocktail API management
│   ├── GooglePlacesManager.swift # Google Places integration
│   ├── AuthManager.swift        # Authentication handling
│   └── AppDelegate.swift        # App lifecycle management
├── Extensions/               # Swift extensions and utilities
│   ├── UIColor+Extension.swift
│   ├── UIImage+Extension.swift
│   ├── Date+Extension.swift
│   └── Utils.swift
├── Storyboards/             # Interface Builder files
│   └── Base.lproj/
└── Assets.xcassets/         # App icons, images, and resources
```
## 📱 User Interface & Experience

### Design Principles

- **Native iOS Design**: Follows Apple's Human Interface Guidelines
- **Accessibility First**: VoiceOver support and accessibility features
- **Responsive Layout**: Adaptive layouts for all iOS device sizes
- **Intuitive Navigation**: Tab-based navigation with contextual actions
- **Visual Feedback**: Loading states, animations, and success indicators
- **Haptic Feedback**: Tactile responses for user interactions

### Key UI Components

- **Custom XIB Files**: Reusable interface components with clean separation
- **Interactive Maps**: Touch-responsive Apple MapKit integration
- **Camera Interface**: Native camera controls with custom overlays
- **Collection Views**: Efficient scrolling layouts for posts and cocktails
- **Tab Navigation**: Intuitive app structure with contextual actions

## 🚀 Getting Started

### Prerequisites

- **Development Environment**: Xcode 14.0 or later
- **iOS Target**: iOS 13.0+ deployment target
- **Dependency Manager**: CocoaPods for library management
- **API Credentials**: Google Places API, RapidAPI, Firebase configuration

### Installation & Setup

1. **Clone the repository**

   ```bash
   git clone https://github.com/yoonzy-tech/drinkr-app.git
   cd drinkr-app
   ```

2. **Install dependencies**

   ```bash
   pod install
   ```

3. **Open workspace**

   ```bash
   open "Drinkr!.xcworkspace"
   ```

4. **Configure Firebase**

   - Download `GoogleService-Info.plist` from Firebase Console
   - Add the file to your Xcode project
   - Configure Firebase Authentication providers

5. **Set up API credentials**

   - Create `Keys.swift` file in Resources directory:

   ```swift
   // API Keys Configuration
   let cocktailDBApiKey = "YOUR_RAPIDAPI_KEY"
   let GMSPlacesAPIKey = "YOUR_GOOGLE_PLACES_API_KEY"
   ```

6. **Configure Google Services**

   ```swift
   // In AppDelegate.swift
   GMSPlacesClient.provideAPIKey(GMSPlacesAPIKey)
   ```

7. **Build and run**
   - Select target device or simulator
   - Build and run the project (⌘+R)

### Firebase Configuration

Set up the following Firebase services:

1. **Firestore Database**

   ```javascript
   // Collection structure
   /posts          // User posts and social content
   /users          // User profiles and authentication data
   /scanHistories  // Drink scanning history
   /cocktailDB     // Cached cocktail recipes
   /googlePlaces   // Cached location data
   ```

2. **Authentication Providers**

   - Email/Password authentication
   - Google Sign-In
   - Apple Sign-In
  
## 📊 Performance & Technical Implementation

### Real-time Data & Social Features

- **Firebase Listeners**: Live comments and likes with minimal data transfer
- **Optimistic UI Updates**: Instant feedback for user interactions
- **Background Processing**: GCD for API calls and heavy operations
- **Query Optimization**: Indexed Firestore queries for fast data retrieval
- **Offline Support**: Local data caching for seamless offline functionality

### Image & Media Management

- **Kingfisher Integration**: Advanced image loading with memory and disk caching
- **Lazy Loading**: On-demand content loading for smooth scrolling performance
- **Image Compression**: Optimized Firebase Storage integration
- **Camera Pipeline**: Efficient PHPickerViewController and AVFoundation implementation

### Machine Learning Pipeline

- **Core ML Processing**: On-device drink recognition (299x299 pixel preprocessing)
- **Model Optimization**: Compressed models for sub-second inference
- **Vision Framework**: Advanced image analysis and preprocessing
- **Prediction Pipeline**: Image capture → preprocessing → ML inference → data lookup → history storage

### Location & Maps

- **Google Places API**: Real-time bar discovery with location-based search
- **Apple MapKit**: Dynamic map pins with efficient clustering
- **Location Services**: Background location updates and geofencing
- **Caching Strategy**: Persistent location data for improved performance

### User Experience Optimizations

- **Lottie Animations**: Smooth, scalable vector animations
- **Audio Integration**: AVAudioPlayer for immersive posting experience
- **Pull-to-Refresh**: MJRefresh for intuitive data updates
- **Progress Indicators**: ProgressHUD for all loading states

## 📈 Future Enhancements

- [ ] **Advanced ML Models**: Wine and spirit recognition
- [ ] **AR Integration**: Augmented reality drink information overlay
- [ ] **Social Features**: Friend recommendations and social graphs
- [ ] **Personalization**: AI-powered cocktail recommendations
- [ ] **Offline Mode**: Complete offline functionality
- [ ] **Apple Watch**: Companion app for quick bar discovery
- [ ] **Analytics Dashboard**: Personal drinking statistics and insights
- [ ] **Multi-language**: Localization for global markets
- [ ] **Voice Control**: Siri integration for hands-free operation
- [ ] **Advanced Search**: Cocktail ingredient-based filtering

## 🔧 Debugging & Analytics

- **Firebase Analytics**: User behavior tracking and insights
- **Crashlytics**: Real-time crash reporting and analysis
- **Performance Monitoring**: App performance metrics

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Ruby Chew**

- GitHub: [@rubychew](https://github.com/rubychew)
- LinkedIn: [Ruby Chew](https://linkedin.com/in/rubychew)
- Email: rubychew.dev@gmail.com

---

_This project demonstrates advanced iOS development skills including Core ML integration, Firebase backend services, third-party API integration, and complex social media functionality. Built as a comprehensive portfolio piece showcasing modern iOS app development practices._


This project was designed and developed by Ruby Chu as a portfolio piece.
