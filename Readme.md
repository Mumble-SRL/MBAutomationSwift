![Test Status](https://img.shields.io/badge/documentation-100%25-brightgreen.svg)
![License: MIT](https://img.shields.io/badge/pod-v1.0.2-blue.svg)
[![CocoaPods](https://img.shields.io/badge/License-Apache%202.0-yellow.svg)](LICENSE)

# MBAutomationSwift

MBAutomationSwift is a plugin libary for [MBurger](https://mburger.cloud), that lets you send automatic push notifications and in-app messages crated from the MBurger platform. It has as dependencies [MBMessagesSwift](https://github.com/Mumble-SRL/MBMessagesSwift) and [MBAudienceSwift](https://github.com/Mumble-SRL/MBAudienceSwift). With this library you can also track user events and views.

# Installation

## Swift Package Manager

With Xcode 11 you can start using [Swift Package Manager](https://swift.org/package-manager/) to add **MBAutomationSwift** to your project. Follow those simple steps:

* In Xcode go to File > Swift Packages > Add Package Dependency.
* Enter `https://github.com/Mumble-SRL/MBAutomationSwift.git` in the "Choose Package Repository" dialog and press Next.
* Specify the version using rule "Up to Next Major" with "1.0.1" as its earliest version and press Next.
* Xcode will try to resolving the version, after this, you can choose the `MBAutomationSwift` library and add it to your app target.

# CocoaPods

CocoaPods is a dependency manager for iOS, which automates and simplifies the process of using 3rd-party libraries in your projects. You can install CocoaPods with the following command:

```ruby
$ gem install cocoapods
```

To integrate the MBurgerSwift into your Xcode project using CocoaPods, specify it in your Podfile:

```ruby
platform :ios, '12.0'

target 'TargetName' do
    pod 'MBAutomationSwift'
end
```

If you use Swift rememember to add `use_frameworks!` before the pod declaration.


Then, run the following command:

```
$ pod install
```

CocoaPods is the preferred methot to install the library.

## Chartage
[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks. To integrate MBudienceSwift into your Xcode project using Carthage, specify it in your Cartfile:

```
github "Mumble-SRL/MBAutomationSwift"
```

# Manual installation

To install the library manually drag and drop the folder `MBAutomationSwift` to your project structure in XCode. 

Note that `MBAutomationSwift` has `MBurgerSwift`, `MBMessagesSwift` and `MBAudienceSwift` as dependencies, so you have to install also those libraries manually.
