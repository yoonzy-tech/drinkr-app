<div align="center">

  # Drinkr!
  <img src="/Screenshots/Logo.png" alt="Logo" width="150" height="150"> <br />

  [![Swift Version](https://img.shields.io/badge/swift-5.0-orange.svg)](https://swift.org/) [![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE) [![Platform](https://img.shields.io/cocoapods/p/LFAlertController.svg?style=flat)](http://cocoapods.org/pods/LFAlertController)

</div>

**Drinkr!** is for anyone who loves night life, cocktail tasting, and exploring bars & bistros. Our goal is to maximize your joy and provide inspiration for where to go and what drinks to try. We're here to make your night out truly unforgettable! Discover nearby hotspots, identify drinks with a snap, share highlights with friends, and find endless cocktail inspiration. Get ready to create lasting memories!

## 🌟 Key Features

### 🗺️ Bar Map: Find the Hottest Drinking Spots
Discover nearby bars and lounges to create the ultimate night out experience. Explore new venues and find hidden gems to make your evening unforgettable.

### 📸 Drink Scanner: Identify Your Favorite Drinks
Snap a photo of any drink and instantly identify the brand. Impress your friends and expand your knowledge of beverages while enjoying your night out.

### 📱 Social Posts: Share Your Night with Friends
Capture and share your night out moments with friends and the wider community. Let others join in on the fun and get recommendations for their own nights out.

### 🍹 Cocktail Wiki: Get Inspired for the Perfect Drink
Find the ideal cocktail inspiration for your night out. Discover exciting recipes, learn about different mixers, and impress everyone with your mixology skills.

## 📷 Screenshots

<p align="row">
  <img src= "/Screenshots/AppStoreScreenshot.png">
</p>

## 🛠️ Technologies & Applied Features

### 📍 Location & Maps
- **CoreLocation**: User location tracking for the Bar Map feature
- **Apple MapKit**: Interactive display of bar locations
- **Google Places API**: Rich data about nearby bars and nightlife venues

### 📷 Camera & Image Processing
- **AVFoundation Camera**: Real-time camera input for bottle scanning
- **Vision Image Classifier**: ML-powered drink identification
- **CoreML**: On-device machine learning for fast bottle recognition

### 🔒 Authentication & User Data
- **Google Sign In / Apple Sign In**: Secure, convenient authentication options
- **Firebase Firestore**: Robust user profile and preference storage
- **Firebase Storage**: Efficient management of user-uploaded content

### 📡 APIs & Data Integration
- **Cocktail DB API**: Comprehensive cocktail recipe database
- **Google Places API**: Detailed venue information and ratings

### 🎛 User Interaction & Experience
- **Gesture Recognizer**: Intuitive navigation throughout the app
- **Custom Animations**: Enhanced visual feedback and engagement

### 🎵 Media & Content
- **AVFoundation Audio**: Rich audio features for social posts
- **Apple UGC Guidelines Compliance**: Safe, appropriate user-generated content


## Requirements

- iOS 15.0+
- Xcode 14.3+

## Installation

#### CocoaPods
You can use [CocoaPods](http://cocoapods.org/) to install all the required pods for this project.

- Run `pod install` in your terminal console, if the project is not able to run successfully.

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '15.0'

target 'Drinkr!' do
  use_frameworks!

  # Pods for Drinkr!
  pod 'GooglePlaces'
  pod 'SwiftLint'
  pod 'IQKeyboardManagerSwift'
  pod 'Kingfisher'
  pod 'MJRefresh'
  pod 'Alamofire' 
  pod 'ProgressHUD'
```

## Credits

© 2025 Ruby Chu - [@yoon_tech](https://twitter.com/yoon_tech) - dev.rubyc@gmail.com

This project was designed and developed by Ruby Chu as a portfolio piece.