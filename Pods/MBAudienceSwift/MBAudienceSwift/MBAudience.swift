//
//  MBAudience.swift
//  MBAudience
//
//  Created by Lorenzo Oliveto on 22/04/2020.
//  Copyright © 2020 Lorenzo Oliveto. All rights reserved.
//

import UIKit
import MBurgerSwift

/// Delegate for the audience plugin, implement this method and set it to receive calls when audience data are sent successfully or if they fail to sync with the server.
public protocol MBAudienceDelegate: class {
    /// This function is called when audience data are sent successfully.
    func audienceDataSent()
    /// This function is called when an error is encountered sending audience data to the server.
    /// - Parameters:
    ///   - error: The error that caused the failure.
    func audienceDataFailed(error: Error)
}

/// This is the plugin class for MBurger that implements the audience functionality, you can use this to target content to specific users or groups of users, based on their in app behavior. Audience data are updated at every startup, and when the app enters foreground, using the `applicationWillEnterFroreground` notification
public class MBAudience: NSObject, MBPlugin {
    
    /// Initializes the plugin and do the startup work, increment the session and update the metadata. You can optionally pass a delegate that will be informed when the data are sent successfully or if the data sync fails.
    /// - Parameters:
    ///   - delegate: An optional delegate that will be informed when the data are sent successfully or if the data sync fails.
    public init(delegate: MBAudienceDelegate? = nil) {
        super.init()
        MBAudience.delegate = delegate
        MBAudienceManager.shared.incrementSession()
        MBAudienceManager.shared.updateMetadata()
    }

    // MARK: - Tags
    
    /// Set the tag with a key and a value, if a tag with that key already exists its value is replaced by the new value. After setting the new tag the new audience data are sent to the server.
    /// - Parameters:
    ///   - tag: The tag.
    ///   - value: The value of the tag.
    public static func setTag(_ tag: String, value: String) {
        MBAudienceManager.shared.setTag(tag, value: value)
    }
    
    /// Removes the tag with the specified key and syncs audience data with the server.
    /// - Parameters:
    ///   - key: The key of the tag that needs to be removed.
    public static func removeTag(_ tag: String) {
        MBAudienceManager.shared.removeTag(tag)
    }
    
    // MARK: - Custom id
    
    /// Set a custom id that will be sent with the audience data, this can be used if  you want to target users coming from different platforms from `MBurger`. After setting this id the new audience data are sent to the server.
    /// - Parameters:
    ///   - customId: The custom id, this value is saved and will be sent until `removeCustomId` is called.
    public static func setCustomId(_ customId: String) {
        MBAudienceManager.shared.setCustomId(customId)
    }
    
    /// Removes the custom id saved and sync audience data to the server.
    public static func removeCustomId() {
        MBAudienceManager.shared.setCustomId(nil)
    }
    
    /// Retrieves the current saved custom id.
    /// - Returns: The current saved custom id.
    public static func getCustomId() -> String? {
        return MBAudienceManager.shared.getCustomId()
    }

    // MARK: - Mobile user id
    
    /// Set the mobile user id of the user currently logged in MBurger. After setting this id the new audience data are sent to the server.
    ///
    /// NOTE: The mobile user id is not sent automatically when a user log in/log out with MBAuth. It will be implemented in the future but at the moment you have to set and remove it manually.
    /// - Parameters:
    ///   - mobileUserId: The mobile user id, this value is saved and will be sent until `removeMobileUserId` is called.
    public static func setMobileUserId(_ mobileUserId: Int) {
        MBAudienceManager.shared.setMobileUserId(mobileUserId)
    }
    
    /// Removes the mobile user id and sync audience data to the server.
    public static func removeMobileUserId() {
        MBAudienceManager.shared.setMobileUserId(nil)
    }
    
    /// Retrieves the current saved mobile user id.
    /// - Returns: The current saved mobile user id.
    public static func getMobileUserId() -> Int? {
        return MBAudienceManager.shared.getMobileUserId()
    }

    // MARK: - Location
    
    /// Start collecting location data and to send it to the server. MBAudience uses `startMonitoringSignificantLocationChanges` of CoreLocation with an accuracy of `kCLLocationAccuracyHundredMeters`. To stop collecting location data call `stopLocationUpdates`.
    public static func startLocationUpdates() {
        MBAudienceManager.shared.startLocationUpdates()
    }
    
    /// Stop collecting location data.
    public static func stopLocationUpdates() {
        MBAudienceManager.shared.stopLocationUpdates()
    }
    
    /// Updates current user location with the parameters passed and calls the api to update the device data.
    /// - Parameters:
    ///   - latitude: Current latitude
    ///   - longitude: Current longitude
    public static func setCurrentLocation(latitude: Double, longitude: Double) {
        MBAudienceManager.shared.setCurrentLocation(latitude: latitude, longitude: longitude)
    }

    // MARK: - Notifications
    
    /// Calling this function when your app delegate receives `didRegisterForRemoteNotifications` will trigger an update of the metadata, so the value of the field `push_enabled` will be always fresh.
    /// - Parameters:
    ///   - deviceToken: The device token returned by `didRegisterForRemoteNotifications` (Not used at the moment).
    public static func didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data) {
        MBAudienceManager.shared.updateMetadata()
    }

    /// Calling this function when your app delegate receives `didFailToRegisterForRemoteNotifications` will trigger an update of the metadata, so the value of the field `push_enabled` will be always fresh.
    /// - Parameters:
    ///   - error: The error returned by `didFailToRegisterForRemoteNotifications` (Not used at the moment).
    public static func didFailToRegisterForRemoteNotifications(withError error: Error) {
        MBAudienceManager.shared.updateMetadata()
    }

    /// Returns the current session tracked by `MBAudience`
    public static func currentSession() -> Int {
        return MBAudienceManager.shared.currentSession
    }
    
    /// The date of the last session
    public static func startSessionDate(forSession session: Int) -> Date? {
        return MBAudienceManager.shared.startSessionDate(forSession: session)
    }

    // MARK: - Delegate
    
    /// The delegate of the `MBAudience` plugin, it will receive function calls when audience data are sent successfully or if they fail to sync with the server.
    public static var delegate: MBAudienceDelegate? {
        get {
            return MBAudienceManager.shared.delegate
        }
        set {
            MBAudienceManager.shared.delegate = newValue
        }
    }

}
