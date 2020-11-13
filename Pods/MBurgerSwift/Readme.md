<p align="center" >
<img src="https://raw.githubusercontent.com/Mumble-SRL/MBurgerSwift/master/Images/mburger-icon.png" alt="MBurger Logo" title="MBurger Logo">
</p>

[![Documentation](https://img.shields.io/badge/documentation-100%25-brightgreen.svg)](https://github.com/Mumble-SRL/MBurgerSwift/tree/master/docs)
[![](https://img.shields.io/badge/SPM-supported-DE5C43.svg?style=flat)](https://swift.org/package-manager/)
![CocoaPods](https://img.shields.io/badge/pod-v1.0.8-blue.svg)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/badge/License-Apache%202.0-yellow.svg)](https://github.com/Mumble-SRL/MBurgerSwift/blob/mastetr/LICENSE)

# MBurgerSwift

MBurgerSwift is a client libary, written in Swift, that can be used to interact with the [MBurger](https://mburger.cloud/login) API. The minimum deployment target for the library is iOS 10.0.

# Installation

## Swift Package Manager

With Xcode 11 you can start using [Swift Package Manager](https://swift.org/package-manager/) to add **MBurgerSwift** to your project. Follow those simple steps:

* In Xcode go to File > Swift Packages > Add Package Dependency.
* Enter `https://github.com/Mumble-SRL/MBurgerSwift.git` in the "Choose Package Repository" dialog and press Next.
* Specify the version using rule "Up to Next Major" with "1.0.7" as its earliest version and press Next.
* Xcode will try to resolving the version, after this, you can choose the `MBurgerSwift` library and add it to your app target.

## CocoaPods

CocoaPods is a dependency manager for iOS, which automates and simplifies the process of using 3rd-party libraries in your projects. You can install CocoaPods with the following command:

```ruby
$ gem install cocoapods
```

To integrate the MBurgerSwift into your Xcode project using CocoaPods, specify it in your Podfile:

```ruby
platform :ios, '10.0'

target 'TargetName' do
    pod 'MBurgerSwift'
end
```

If you use Swift rememember to add `use_frameworks!` before the pod declaration.


Then, run the following command:

```
$ pod install
```

CocoaPods is the preferred methot to install the library.

## Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks. To integrate MBurgerSwift into your Xcode project using Carthage, specify it in your Cartfile:

```
github "Mumble-SRL/MBurgerSwift"
```


## Manual installation

To install the library manually drag and drop the folder `MBurgerSwift` to your project structure in XCode. 

Note that `MBurgerSwift` has `MBNetworkingSwift (1.0.4)` as dependency, so you have to install also this library.

# Initialization

To initialize the SDK you have to create a token through the [dashboard](https://mburger.cloud/). Click on the settings icon on the top-right and create a API Key specifiyng the permissions.

![Dashboard image](https://raw.githubusercontent.com/Mumble-SRL/MBurgerSwift/master/Images/api_token.jpg)

Then in your `AppDelegate` `application:didFinishLaunchingWithOptions:` initialize the `MBManager` of the SDK setting a token like this:

```swift
import MBurgerSwift

...

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        MBManager.shared.apiToken = "YOUR_API_TOKEN"
    return true
}
```

You will not be able to interact with the SDK if you don't initialize it with a correct token/key.

# Usage

Use the `MBClient` class to make all the request to the api to retrieve data from MBurger. All the api calls have a plural version and its singular counterpart. For example you can retrieve the list of blocks of the project or you can retrieve a single block giving its id.

# Project

You can retrieve the informations of the project like this:

```swift
MBClient.getProject(success: { project in

}, failure: { error in

})
```

# Blocks

You can retrieve the blocks of the project with the function `getBlocks(Success:Failure)` like this:

```swift
MBClient.getBlocks(success: { (blocks, paginationInfos) in

}, failure: { (error) in

})
```

The parameter `parameters` is an optional array of objects that conforms to the `MBParameter` protocol passed to the MBurger api as parameter. The majorityof the parameters that can be passed to the apis are already defined in the SDK and can be used after the initialization:

* `MBSortParameter`
* `MBPaginationParameter`
* `MBFilterParameter`
* `MBGeofenceParameter`

If you want to pass another type of parameter you can use the `MBGeneralParameter` class that can be initialized with a key and a value that will be passed to the apis.

So if you want to include a pagination parameter you can do like this:

```swift
let paginationParam = MBPaginationParameter(skip: 0, take: 10)
MBClient.getBlocks(withParameters: [paginationParam], success: { (blocks, paginationInfos) in

}, failure: { (error) in

})
```

There is another version of the `getBlocks(withParameters:success:failure:)`,  that takes two aditional parameter `includingSections` (a boolean that indicate whether or not include, for each block, the sections), and `includeElements` (a boolean value that do the same thing but for the elements of the sections).

So you could retrieve the informations of all the blocks, all the sections of the blocks and all the elements of the sections with this call:

```swift
MBClient.getBlocks(withParameters: [paginationParam], includingSections: true, includeElements: true, success: { (blocks, paginationInfos) in

}, failure: { (error) in

})
```

# Sections

You can retrieve all the sections with a block with the given id with the function `getSections(ofBlock:parameters:success:failure:)` like this:

```swift
MBClient.getSections(ofBlock: THE_BLOCK_ID, parameters: nil, success: { (sections, paginationInfos) in

}, failure: { (error) in

})
```

Like for the blocks there's a version of this function that takes a bool `elements` that indicate to include or not the elements of the section se if you want to retrieve all the sections of a block and their elements you can call:

```swift
MBClient.getSections(ofBlock: THE_BLOCK_ID, parameters: nil, elements: true, success: { (sections, paginationInfos) in

}, failure: { (error) in

})
```

# Type Decoding

`MBurgerSwift` has a built in system that can be used to init your custom constructs. You have only to make your construct conform to `MBDecodable` protocol.

For example a `News` that's reflecting a newsfeed block in MBurger: 

```swift
class News: MBDecodable {
    let text: String
    let images: [MBImage]
    let link: String
    let date: Date
    
    enum DecoderCodingKeys: String, CodingKey {
        case text
        case images
        case link
        case date
    }
    
    required init(from decoder: MBDecoder) throws {
        let container = try decoder.container(keyedBy: DecoderCodingKeys.self)
        
        text = try container.decode(String.self, forKey: .text)
        images = try container.decode([MBImage].self, forKey: .images)
        link = try container.decode(String.self, forKey: .link)
        date = try container.decode(Date.self, forKey: . date)
    }
}

```

And call the `decode` function of `MBDecoder` to create and populate an array of news like this:

```swift
MBClient.getSections(ofBlock: THE_BLOCK_ID, parameters: nil, elements: true, success: { (sections, _) in
    sections.forEach { section in
         do {
             if let elements = section.elements {
                 let news = try MBDecoder.decode(News.self, elements: elements)
                 newsArray.append(news)
             }
         } catch let error {
              self.showError(error)
         }
     }
}, failure: { error in
      self.showError(error)
})       
```

**Note** that the DecoderCodingKey needs to match to the *name* of the element in the MBurger block(e.g. if the element on the dashboard is called *Title* the decoder key needs to be *Title*):

```swift
enum DecoderCodingKeys: String, CodingKey {
        case text = "Title"
        case images
        case link
        case date
 }
```

You can find a complete example in the Example project.

# Serialization

All the object models implement the `Codable` protocol so you can serialize and deserialize them without having to implement it. Below the list of objects that implement this protocol.

* `MBProject`
* `MBBlock`
* `MBSection`
* `MBElement`
* `MBFile`
* `MBAddressElement`
* `MBCheckboxElement`
* `MBDateElement`
* `MBDropdownElement`
* `MBGeneralElement`
* `MBImagesElement`
* `MBMarkdownElement`
* `MBMediaElement`
* `MBRelationElement`
* `MBPollElement`
* `MBTextElement`
* `MBColorElement`
* `MBMultipleElement`
* `MBUser`

# Equality

All the model objects are conform to the `Equatable` protcol based on the corresponding id (e.g. an MBSection will result equal to another MBSection object if they have the same `sectionId`)

# Authentication

Read the full documentation for authentication apis [here](https://github.com/Mumble-SRL/MBurgerSwift/tree/master/MBurgerSwift/MBAuth).

# Admin

If you need to create blocks and sections in your MBurger project you can use the [MBAdmin SDK](https://github.com/Mumble-SRL/MBAdmin)

# Plugins
You can add more to MBurger with plugins, classes that conforms to the `MBPluginProtocol` that can extend the functionalities of MBurger. An example of a plugin is [MPPayments](https://github.com/Mumble-SRL/MBPayments-iOS.git) a plugin that you to charge the users with single payments or sbscription.

# Documentation

For further information, you can check out the full SDK Reference in the [docs](docs) folder.


# Contacts

You can contuct us at [info@mumbleideas.it](mailto:info@mumbleideas.it).

# License

MBurger is released under the Apache 2.0 license. See [LICENSE](LICENSE) for details.
