[![Swift Version][swift-image]][swift-url]
[![License][license-image]][license-url]
[![Platform](https://img.shields.io/cocoapods/p/LFAlertController.svg?style=flat)](http://cocoapods.org/pods/LFAlertController)


# Drinkr!
<br />
<p align="center">
    <img src="logo.jpeg" alt="Logo" width="80" height="80">
      <p>
      No ideas for the night out plan?
      Drinkr! is anyone who loves night life, cocktail tasting, exploring bars & bistros. 
      Our goal is to maximize the joy for Drinkers in the night, give them inspirations for where to go tonight and what drinks to get tonight.
      </p>
</p>

<p align="row">
<img src= "" width="400" >
<img src= "" width="400" >
</p>

## Features & Technologies

1. **Bar Map**

CoreLocation, Apple MapKit, Google Places API

2. **Cocktail Recipe Wiki**

Gesture Recognizer, Cocktail DB API

3. **Bottle Scanner**

AVFoundation Camera, Vision Image Classifier, CoreML

4. **Posts & News**

Comply to Apple UGC Guideline, Animation, AVFoundation Audio

5. **User Profile**

Google Sign In, Apple Sign In, Firebase Firestore, Storage


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

## Meta

Ruby Chu – [@yoon_tech](https://twitter.com/yoon_tech) – dev.rubyc@gmail.com

Distributed under the MIT license. See ``LICENSE`` for more information.

[https://github.com/yoonzy-tech/Drinkr](https://github.com/yoonzy-tech/Drinkr)

[swift-image]:https://img.shields.io/badge/swift-5.0-orange.svg
[swift-url]: https://swift.org/
[license-image]: https://img.shields.io/badge/License-MIT-blue.svg
[license-url]: LICENSE
