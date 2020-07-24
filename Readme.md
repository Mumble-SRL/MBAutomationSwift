[![Documentation](https://img.shields.io/badge/documentation-100%25-brightgreen.svg)](https://github.com/Mumble-SRL/MBAutomationSwift/tree/master/docs)
[![](https://img.shields.io/badge/SPM-supported-DE5C43.svg?style=flat)](https://swift.org/package-manager/)
[![CocoaPods](https://img.shields.io/badge/pod-v0.1.3-blue.svg)](https://cocoapods.org)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/badge/License-Apache%202.0-yellow.svg)](LICENSE)

# MBAutomationSwift

`MBAutomationSwift` is a plugin libary for [MBurger](https://mburger.cloud), that lets you send automatic push notifications and in-app messages crated from the MBurger platform. It has as dependencies [MBMessagesSwift](https://github.com/Mumble-SRL/MBMessagesSwift) and [MBAudienceSwift](https://github.com/Mumble-SRL/MBAudienceSwift). With this library you can also track user events and views.

Using `MBAutomationSwift` you can setup triggers for in-app messages and push notifications, in the MBurger dashboard and the SDK will show the coontent automatically when triggers are satisfied. 

It depends on `MBAudienceSwift` because messages can be triggered by location changes or tag changes, coming from this SDK.

It depends on `MBMessagesSwift` because it contains all the views for the in-app messages and the checks if a message has been already displayed or not.

The data fflow from all the SDKs is manage entirely by MBurger, yuo don't have to worry about it.

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

# Initialization

To initialize automation you need to insert `MBAutomation` as a `MBurger` plugins, tipically automation is used in conjunction with the `MBMessagesSwift` and `MBAudienceSwift` plugins.

``` swift
MBManager.shared.plugins = [MBAutomation(), ... other plugins]
```

MBAutomation can bbe initialized with 3 optional parameters:

* `trackingEnabled`: If the tracking is enabled or not, setting this to false all the tracking will be disabled
* `trackViewsAutomatically`: If the automatic track of views is enabled or not
* `eventsTimerTime`: The frequency used to send events and view to MBurger

# Triggers

Every in-appmessage or push notification coming from MBurger can have an array of triggers, those are managed entirely by the MBAutomation SDK that evaluates them and show the mssage only when the conditioon defined by the triggers are matched. 

If thre are more than one trigger, they can be evaluated with 2 methods:

* `any`: once one of triggers becomes true the message is displayed to the user
* `all`: all triggers needs to be true in order to show the message.

Here's the list of triggers managed by automation SDK:


#### App opening

`MBAppOpeningTrigger`: Becoomes true when the app has been opened n times (`times` property), it's checked at the app startup.


#### Event

`MBEventTrigger`: Becomes true when an event happens n times (`times` property)

#### Inactive user

`MBInactiveUserTrigger`: Becomes true if a user has not opened the app for n days (`days` parameter)

#### Location

`MBLocationTrigger`: If a user enters a location, specified by `latitude`, `longitude` and `radius`. This trigger can be activated with a ttime delay defined as the `after` property. The location data comes from the [MBAudienceSwift](https://github.com/Mumble-SRL/MBAudienceSwift) SDK.

#### Tag change

`MBTagChangeTrigger`: If a tag of the [MBAudienceSwift](https://github.com/Mumble-SRL/MBAudienceSwift) SDK changes and become equals or not to a value. It has a `tag` property (the tag that needs to be checked) and a `value` property (the value that needs to be equal or different in order to activate the trigger)

#### View

`MBViewTrigger`: it's activated when a user enters a view n times (`times` property). If the `secondsOnView` the user needs to stay the seconds defined in order to activate the trigger.

# Send events

You can send events with the `MBAutomationSwift` liike this:

``` swift
MBAutomation.sendEvent("event")
```

You can specify 2 more parameters, both optional: `name` a name that will be displayed in the MBurger dashboard and a dictionary of additional `metadata` to specifymore fields of the event

``` swift
MBAutomation.sendEvent("purchase",
                       name: "Purchase",
                       metadata: ["quantity": 1])
```

Events are saved in a local database and sent to the server every 10 seconds, you can change the frequency setting the `eventsTimerTime` property.

# View Tracking

In MBAutomation the tracking of the views is automatic, you can disable it initializing `MBAutomation` with `trackViewsAutomatically` to `false`. `MBAutomation` uses [method swizzling](https://nshipster.com/method-swizzling/) to track view automatically on `viewDidAppear`. 

The default name for all the ViewControllers is the class name (e.g. if your ViewController is called HomeViewController you will see HomeViewController as the view). If you want to change the name for a ViewController you can setup the `mbaTrackingName` of the ViewController.

``` swift
import MBAutomationSwift

override func viewDidLoad() {
    super.viewDidLoad()
	 ...
	         
    mbaTrackingName = "Home"
    ...
}

```

You can send additional data with the view event setting the `mbaTrackingMetadata` property of the ViewController, those will be displayed in the metadata field of the dashboard.

If you have diisabled the automatic tracking and you still want to track the views you can use this function, passing a `UIViewController`.


``` swift
override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    MBAutomation.trackScreenView(self)
}
```

As the events, views are saved in a local database and sent to the server every 10 seconds and you can change the frequency setting the `eventsTimerTime` property.

