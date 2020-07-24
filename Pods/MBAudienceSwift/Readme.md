![Test Status](https://img.shields.io/badge/documentation-100%25-brightgreen.svg)
![License: MIT](https://img.shields.io/badge/pod-v1.0.2-blue.svg)
[![CocoaPods](https://img.shields.io/badge/License-Apache%202.0-yellow.svg)](LICENSE)

# MBAudienceSwift

MBAudienceSwift is a plugin libary for [MBurger](https://mburger.cloud), that lets you track user data and behavior inside your and to target messages only to specific users or groups of users. This plugin is often used with the [MBMessagesSwift](https://github.com/Mumble-SRL/MBMessagesSwift) plugin to being able to send push and messages only to targeted users.

# Installation

## Swift Package Manager

With Xcode 11 you can start using [Swift Package Manager](https://swift.org/package-manager/) to add **MBAudienceSwift** to your project. Follow those simple steps:

* In Xcode go to File > Swift Packages > Add Package Dependency.
* Enter `https://github.com/Mumble-SRL/MBAudienceSwift.git` in the "Choose Package Repository" dialog and press Next.
* Specify the version using rule "Up to Next Major" with "1.0.1" as its earliest version and press Next.
* Xcode will try to resolving the version, after this, you can choose the `MBAudienceSwift` library and add it to your app target.

# CocoaPods

CocoaPods is a dependency manager for iOS, which automates and simplifies the process of using 3rd-party libraries in your projects. You can install CocoaPods with the following command:

```ruby
$ gem install cocoapods
```

To integrate the MBurgerSwift into your Xcode project using CocoaPods, specify it in your Podfile:

```ruby
platform :ios, '12.0'

target 'TargetName' do
    pod 'MBAudienceSwift'
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
github "Mumble-SRL/MBudienceSwift"
```

# Manual installation

To install the library manually drag and drop the folder `MBAudience` to your project structure in XCode. 

Note that `MBAudienceSwift` has `MBurgerSwift (1.0.5)` and `MPushSwift (0.2.12)` as dependencies, so you have to install also those libraries.

# Initialization

To initialize the SDK you have to add `MBAudience` to the array of plugins of `MBurger`.

```swift
import MBurgerSwift
import MBMessagesSwift

...

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    MBManager.shared.apiToken = "YOUR_API_TOKEN"
    MBManager.shared.plugins = [MBAudience()]
        
    return true
}
```

You can set a delegate when initializing the `MBAudience` plugin, the delegate will be called when audience data are sent successfully to the sever or if the sync fails

```swift
let audiencePlugin = MBAudience(delegate: [the delegate])
```

# Tracked data

Below are described all the data that are tracked by the MBAudience SDK and that you will be able to use from the [MBurger](https://mburger.cloud) dashboard. Most of the data are tracked automatically, for a couples a little setup by the app is neccessary.

- **app_version**: The current version of the app.
- **locale**: The locale of the phone, the value returned by `Locale.preferredLanguages.first`.
- **sessions**: An incremental number indicating the number of time the user opens the app, this number is incremented at each startup.
- **sessions_time**: The total time the user has been on the app, this time is paused when the app goes in background (using `didEnterBackgroundNotification`) .and it's resumed when the app re-become active (using `willEnterForegroundNotification`).
- **last_session**: The start date of the last session.
- **push_enabled**: If push notifications are enabled or not; to determine this value the framework uses this function: `UNUserNotificationCenter.current().getNotificationSettings`.
- **location_enabled**: If user has given permissions to use location data or not; this is true if `CLLocationManager.authorizationStatus()` is `authorizedAlways` or `authorizedWhenInUse`.
- **mobile_user_id**: The user id of the user curently logged in MBurger
- **custom_id**: A custom id that can be used to filter further.
- **tags**: An array of tags
- **latitude, longitude**: The latitude and longitude of the last place visited by this device

## Tags

You can set tags to assign to a user/device (e.g. if user has done an action set a tag), so you can target those users later:


To set a tag:

```swift
MBAudience.setTag("TAG", value: "VALUE")
```

To remove it:

```swift
MBAudience.removeTag("TAG")
```

## Custom Id

You can set a custom id in order to track/target users with id coming from different platforms. 

To set a custom id:

```swift
MBAudience.setCustomId("CUSTOM_ID")
```
To remove it:

```swift
MBAudience.removeCustomId()
```

To retrieve the current saved id:

```swift
MBAudience.getCustomId()
```

## Mobile User Id

This is the id of the user currently logged in MBurger using MBAuth. At the moment the mobile user id is not sent automatically when a user log in/log out with MBAuth. It will be implemented in the future but at the moment you have to set and remove it manually when the user completes the login flow and when he logs out.

To set the mobile user id:

```swift
MBAudience.setMobileUserId(MOBILE_USER_ID)
```

To remove it, if the user logs out:

```swift
MBAudience.removeMobileUserId()
```

To get the currently saved mobile user id: 

```swift
MBAudience.getMobileUserId()
```

## Location Data

MBAudience let you track and target user based on their location, the framework uses the method [startMonitoringSignificantLocationChanges](https://developer.apple.com/documentation/corelocation/cllocationmanager/1423531-startmonitoringsignificantlocati) of the CoreLocation manager with an accuracy of `kCLLocationAccuracyHundredMeters`. To start monitoring for location changes call, it will continue monitoring until the stop method is called:

```swift
MBAudience.startLocationUpdates()
```

To stop monitoring location changes you have to call:

```swift
MBAudience.stopLocationUpdates()
```