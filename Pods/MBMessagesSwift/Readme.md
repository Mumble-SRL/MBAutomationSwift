[![Documentation](https://img.shields.io/badge/documentation-100%25-brightgreen.svg)](https://github.com/Mumble-SRL/MBMessagesSwift/tree/master/docs)
[![](https://img.shields.io/badge/SPM-supported-DE5C43.svg?style=flat)](https://swift.org/package-manager/)
[![CocoaPods](https://img.shields.io/badge/pod-v0.2.1-blue.svg)](https://cocoapods.org)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/badge/License-Apache%202.0-yellow.svg)](LICENSE)

# MBMessagesSwift

MBMessagesSwift is a plugin libary for [MBurger](https://mburger.cloud), that lets you display in app messages and manage push notifications in your app. The minimum deployment target for the library is iOS 11.0. 

Using this library you can display the messages that you set up in the MBurger dashboard in your app. You can also setup and manage push notifications connected to your MBurger project.

[//]: # (TODO: aggiungere immagine)

# Installation

## Swift Package Manager

With Xcode 11 you can start using [Swift Package Manager](https://swift.org/package-manager/) to add **MBMessagesSwift** to your project. Follow those simple steps:

* In Xcode go to File > Swift Packages > Add Package Dependency.
* Enter `https://github.com/Mumble-SRL/MBMessagesSwift.git` in the "Choose Package Repository" dialog and press Next.
* Specify the version using rule "Up to Next Major" with "0.1.1" as its earliest version and press Next.
* Xcode will try to resolving the version, after this, you can choose the `MBMessagesSwift` library and add it to your app target.

## CocoaPods

CocoaPods is a dependency manager for iOS, which automates and simplifies the process of using 3rd-party libraries in your projects. You can install CocoaPods with the following command:

```ruby
$ gem install cocoapods
```

To integrate the MBMessagesSwift into your Xcode project using CocoaPods, specify it in your Podfile:

```ruby
platform :ios, '12.0'

target 'TargetName' do
    pod 'MBMessagesSwift'
end
```

If you use Swift rememember to add `use_frameworks!` before the pod declaration.


Then, run the following command:

```
$ pod install
```

CocoaPods is the preferred methot to install the library.

## Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks. To integrate MBMessagesSwift into your Xcode project using Carthage, specify it in your Cartfile:

```
github "Mumble-SRL/MBMessagesSwift"
```

## Manual installation

To install the library manually drag and drop the folder `MBMessages` to your project structure in XCode. 

Note that `MBMessagesSwift` has `MBurgerSwift (1.0.8)` and `MPushSwift (0.2.13)` as dependencies, so you have to install also those libraries.

# Initialization

To initialize the SDK you have to add `MBMessagesSwift` to the array of plugins of `MBurger`.

```swift
import MBurgerSwift
import MBMessagesSwift

...

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    MBManager.shared.apiToken = "YOUR_API_TOKEN"
    MBManager.shared.plugins = [MBMessages()]
        
    return true
}
```

Then you have to tell MBManager.shared that the app has been opened with `MBManager.shared.applicationDidFinishLaunchingWithOptions(launchOptions: launchOptions)`, this will trigger all the startup actions of the MBurger plugins. Once you've done this in app messages will be fetched automatically at the startup of the application and showed, if they need to be showed.


```swift
...

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    MBManager.shared.apiToken = "YOUR_API_TOKEN"
    MBManager.shared.plugins = [MBMessages()]
        
    MBManager.shared.applicationDidFinishLaunchingWithOptions(launchOptions: launchOptions)

    return true
}
```

## Initialize MBMessages with parameters

You can set a couples of parameters when initializing the `MBMessages` plugin:

```swift
let messagesPlugin = MBMessages(delegate: [the delegate],
                                viewDelegate: [view delegate],
                                styleDelegate: [style delegate],
                                messagesDelay: 1
                                debug: true)

```

- **messagesDelay**: it's the time after which the messages will be displayed once fetched
- **debug**: if this is set to `true`, all the message returned by the server will be displayed, if this is set to `false` a message will appear only once for app installation. This is `false` by default
- **delegate**: the delegate will receive a call if the fetch of the messages fails, with the error that caused the fail, see [MBMessagesDelegate](#MBMessagesDelegate) for more details.
- **viewDelegate**: the view delegates will receive calls when views of messages are showed or hidden, it will also receives a call when the button of the views will be touched, so you need to implement this protocol if you want to open an in-app link from an in app message. See [MBInAppMessageViewDelegate](#MBInAppMessageViewDelegate) for a detailed description of the protocol.
- **styleDelegate**: you can use this protocol to specify colors and fonts of the in app messages. See [Stylize in app messages](#Stylizeinappmessages) for more details

# Stylize in app messages

If you want to specify fonts and colors of the messages displayed you can use the `MBInAppMessageViewStyleDelegate` protocol. All the functions of the protocol are optional, if a function is not implemented the framework will use a default value. The elements that can be stylized are the following:

- **backgroundStyle**: can be a solid color or a translucent color
- **backgroundColor**: the color of the background
- **titleColor**: the text color for the title of the message
- **bodyColor**: the text color for the body
- **closeButtonColor**: the color of the close button
- **button1BackgroundColor**: the background color of the first action button
- **button1TitleColor**: the text color of the first action button
- **button2BackgroundColor**: the background color of the second action button
- **button2TitleColor**: the text color of the second action button
- **button2BorderColor**: the border color of the second action button
- **titleFont**: the font of the title
- **bodyFont**: the font of the body
- **buttonsTextFont**: the font of the buttons titles

Example:

```swift
func backgroundStyle(forMessage message: MBInAppMessage) -> MBInAppMessageViewBackgroundStyle {
    return .solid
}
    
func backgroundColor(forMessage message: MBInAppMessage) -> UIColor {
    return .green
}
    
func titleColor(forMessage message: MBInAppMessage) -> UIColor {
    return .blue
}
    
func bodyColor(forMessage message: MBInAppMessage) -> UIColor {
    return .darkText
}
    
func button1TitleColor(forMessage message: MBInAppMessage) -> UIColor {
    return .white
}
    
func button1BackgroundColor(forMessage message: MBInAppMessage) -> UIColor {
    return .cyan
}
```

### MBMessagesDelegate

Implement this protocol if you want to receive a function call when in app messages view are showed or hidden. You will need to use this protocol also if you want to responsd to a user tapping on buttons on in app messages view.

`viewWillAppear` and `viewDidAppear` are called when the view is showed, `viewWillDisappear` and `viewDidDisappear` when it's hidden.

```swift
func viewWillAppear(view: MBInAppMessageView)
func viewDidAppear(view: MBInAppMessageView)
func viewWillDisappear(view: MBInAppMessageView)
func viewDidDisappear(view: MBInAppMessageView)
```

To respond to a user tapping on a button you have to implement `func buttonPressed(view: MBInAppMessageView, button: MBInAppMessageButton)`, here's an example:

```swift
func buttonPressed(view: MBInAppMessageView, button: MBInAppMessageButton) {
    let linkType = button.linkType
    if linkType == .link && button.link.hasPrefix("http") {
        if let url = URL(string: button.link) {
            //Open url
        }
    } else {
        // Open in app link (button.link)
    }
}
```


### MBMessagesDelegate

Implement this protocol if you want to receives a call when the fetches of the message fails from the server:

```swift
func inAppMessageCheckFailed(sender: MBMessages, error: Error?)
```

# Push notifications

With this plugin you can also manage the push notification section of MBurger, this is a wrapper around MPush, the underlying platform, so you should refer to the [MPush documentation 
](https://github.com/Mumble-SRL/MPush-Swift) to understand the concepts and to start the push integration. In order to use `MBMessagesSwift` instead of `MPushSwift` you have to do the following changes:

Set the push token like this:

```swift
MBMessages.pushToken = "YOUR_PUSH_TOKEN"
```

And then register your device to topics (all the other function have a similar syntax change):

```swift
MBMessages.registerDeviceToPush(deviceToken: deviceToken, success: {
    MBMessages.registerPushMessages(toTopic: MBPTopic("YOUR_TOPIC"))
})
```

MBurger has 2 default topics that you should use in order to guarantee the correct functionality of the engagement platform:

* `MBMessages.projectPushTopic`: this topic represents all devices registred to push notifications for this project
* `MBMessages.devicePushTopic`: this topic represents the current device

```swift
MBMessages.registerPushMessages(toTopics:[MBMessages.projectPushTopic,
                                          MBMessages.devicePushTopic,
                                          MBPTopic("OTHER_TOPIC")])
```

### MBPTopic additional parameters

When creating topic you can specify additional parameters:

* `title`: a title fot that topic that will be displayed in the dashboard, if not specified it has the same value as the topic id
* `single`: If the topic identify a single user or a group of users, defaults to `false`


# User interaction with a push

With `MBMessagesSwift` you can setup a callback that will be called when the user interacts with a push notification or opens the app from a push. You can setup the code like this, the payload variable will be the payload of the push:

```swift
MBMessages.userDidInteractWithNotificationBlock = { payload in
    // Do actions in response
    print("Notification arrived:\n\(payload)")
}
```
In order to this to function you will have to tell `MBMessagesSwift` that a notification has arrived so you need to add this in those lines in your `UNUserNotificationCenterDelegate` class, often the `AppDelegate`.

```swift
func userNotificationCenter(_ center: UNUserNotificationCenter,
                            willPresent notification: UNNotification,
                            withCompletionHandler
    completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    // Add this line
    MBMessages.userNotificationCenter(willPresent: notification)
    completionHandler(UNNotificationPresentationOptions.alert)
}
    
func userNotificationCenter(_ center: UNUserNotificationCenter,
                            didReceive response: UNNotificationResponse,
                            withCompletionHandler
    completionHandler: @escaping () -> Void) {
    // Add this line
    MBMessages.userNotificationCenter(didReceive: response)
    completionHandler()
}
```

# Message Metrics

Using `MBMessagesSwift` gives you also the chanche to collect informations about your user and the push, those will be displyed on the [MBurger](https://mburger.cloud) dashboard. As described in the prervious paragraph, in order for this to function, you have to tell `MBMessagesSwift` that a push has arrived, if you've already done it in the step above you're fine, otherwise you need to add `MBMessages.userNotificationCenter(willPresent: notification)` and `MBMessages.userNotificationCenter(didReceive: response)` to your `UNUserNotificationCenterDelegate` class.

# Automation

If messages have automation enabled they will be ignored and managed by the [MBAutomationSwift SDK](https://github.com/Mumble-SRL/MBAutomationSwift.git) so make sure to include and configure the automation SDK correctly.