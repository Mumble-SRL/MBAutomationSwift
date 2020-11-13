//
//  MBAudienceManager.swift
//  MBAudience
//
//  Created by Lorenzo Oliveto on 09/04/2020.
//  Copyright © 2020 Mumble S.r.l (https://mumbleideas.it/). All rights reserved.
//

import UIKit
import MBurgerSwift
import UserNotifications
import CoreLocation

internal class MBAudienceManager: NSObject {
    internal static let shared = MBAudienceManager()
    
    private var locationManager: CLLocationManager?
    private var currentLocation: CLLocationCoordinate2D?
    
    weak var delegate: MBAudienceDelegate?
    
    var startSessionDate: Date?
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(endSession), name: UIApplication.willTerminateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(endSession), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterFroreground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
        
    // MARK: - Location

    func startLocationUpdates() {
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager?.requestAlwaysAuthorization()
            locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager?.delegate = self
            locationManager?.startMonitoringSignificantLocationChanges()
        } else {
            locationManager?.startMonitoringSignificantLocationChanges()
        }
    }
    
    func stopLocationUpdates() {
        if let locationManager = locationManager {
            locationManager.stopMonitoringSignificantLocationChanges()
        }
    }
    
    func setCurrentLocation(latitude: Double, longitude: Double) {
        currentLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        updateLocation()
    }
    
    // MARK: - Sessions
    
    func incrementSession() {
        let userDefaults = UserDefaults.standard
        let session = userDefaults.integer(forKey: "com.mumble.mburger.audience.session")
        let newSession = session + 1
        userDefaults.set(newSession, forKey: "com.mumble.mburger.audience.session")
        let key = sessionDateKey(forSession: newSession)
        userDefaults.set(Date(), forKey: key)
        userDefaults.synchronize()
        clearOldSessionValues()
        startSession()
    }
    
    var currentSession: Int {
        return UserDefaults.standard.integer(forKey: "com.mumble.mburger.audience.session")
    }
    
    private func clearOldSessionValues() {
        // Clear only the last 3 values, this should be enough because this function will be called at every start, ideally it will find only currentSession - 2
        let sessionsToClear = [currentSession - 2,
                               currentSession - 3,
                               currentSession - 4]
        for i in sessionsToClear where i >= 0 {
            UserDefaults.standard.removeObject(forKey: sessionDateKey(forSession: i))
        }
    }
    
    internal func startSessionDate(forSession session: Int) -> Date? {
        let key = sessionDateKey(forSession: session)
        let date = UserDefaults.standard.object(forKey: key) as? Date
        return date
    }
    
    private func sessionDateKey(forSession session: Int) -> String {
        let sessionString = NSNumber(value: session).stringValue
        return "com.mumble.mburger.audience.sessionTime.session" + sessionString
    }

    // MARK: - Api
    
    func updateMetadata() {
        DispatchQueue.global(qos: .utility).async {
            let locale = Locale.preferredLanguages.first
            let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
            
            UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { [weak self] settings in
                guard let strongSelf = self else {
                    return
                }
                let pushEnabled = settings.authorizationStatus == .authorized
                
                let locationAuthorizationStatus = CLLocationManager.authorizationStatus()
                let locationEnabled = locationAuthorizationStatus == .authorizedAlways || locationAuthorizationStatus == .authorizedWhenInUse
                
                var parameters = [String: AnyHashable]()
                parameters["push_enabled"] = pushEnabled ? "true" : "false"
                parameters["location_enabled"] = locationEnabled ? "true" : "false"
                parameters["locale"] = locale ?? "en_US"
                parameters["app_version"] = version
                parameters["sessions"] = NSNumber(value: strongSelf.currentSession).stringValue
                
                parameters["sessions_time"] = floor(strongSelf.totalSessionTime())
                let currentSession = strongSelf.currentSession
                if let currentSessionDate = strongSelf.startSessionDate(forSession: currentSession) {
                    parameters["last_session"] = floor(currentSessionDate.timeIntervalSince1970)
                } else {
                    parameters["last_session"] = 0
                }
                if let mobileUserId = strongSelf.getMobileUserId() {
                    parameters["mobile_user_id"] = mobileUserId
                }
                
                if let customId = strongSelf.getCustomId() {
                    parameters["custom_id"] = customId
                }
                
                if let currentLocation = strongSelf.currentLocation {
                    parameters["latitude"] = currentLocation.latitude.truncate(places: 8)
                    parameters["longitude"] = currentLocation.longitude.truncate(places: 8)
                }
                
                if let tags = strongSelf.getTagsAsDictionaries() {
                    parameters["tags"] = tags
                }
                
                parameters["platform"] = "ios"
                
                MBApiManager.request(withToken: MBManager.shared.apiToken,
                                     locale: MBManager.shared.localeString,
                                     apiName: "devices",
                                     method: .post,
                                     parameters: parameters,
                                     development: MBManager.shared.development,
                                     success: { _ in
                                        strongSelf.delegate?.audienceDataSent()
                }, failure: { error in
                    strongSelf.delegate?.audienceDataFailed(error: error)
                })
            })
        }
    }
    
    func updateLocation() {
        guard let currentLocation = currentLocation else {
            return
        }
        
        MBPluginsManager.locationDataUpdated(latitude: currentLocation.latitude,
                                             longitude: currentLocation.longitude)
        var parameters = [String: AnyHashable]()
        parameters["latitude"] = currentLocation.latitude.truncate(places: 8)
        parameters["longitude"] = currentLocation.longitude.truncate(places: 8)
        DispatchQueue.global(qos: .utility).async {
            MBApiManager.request(withToken: MBManager.shared.apiToken,
                                 locale: MBManager.shared.localeString,
                                 apiName: "locations",
                                 method: .post,
                                 parameters: parameters,
                                 development: MBManager.shared.development,
                                 success: { _ in
                                    self.delegate?.audienceDataSent()
            }, failure: { error in
                self.delegate?.audienceDataFailed(error: error)
            })
        }
    }
    
    // MARK: - Sessions
    
    @objc private func startSession() {
        if startSessionDate != nil {
            endSession()
        }
        startSessionDate = Date()
    }
    
    @objc private func endSession() {
        let sessionTime = self.totalSessionTime()
        UserDefaults.standard.set(sessionTime, forKey: "com.mumble.mburger.audience.sessionTime")
        startSessionDate = nil
    }
    
    private func totalSessionTime() -> TimeInterval {
        var time = UserDefaults.standard.double(forKey: "com.mumble.mburger.audience.sessionTime")
        if let startSessionDate = startSessionDate {
            time += -startSessionDate.timeIntervalSinceNow
        }
        return time
    }
    
    @objc func applicationWillEnterFroreground() {
        startSession()
        updateMetadata()
    }
}

extension MBAudienceManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            currentLocation = lastLocation.coordinate
            updateLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    }
}

// MARK: - Data manager

extension MBAudienceManager {
    // MARK: - Tags
    
    func setTag(_ tag: String, value: String) {
        var newTags = getTags() ?? []
        var tagChanged = false
        if let indexFound = newTags.firstIndex(where: {$0.tag == tag}) {
            let tag = newTags[indexFound]
            if tag.value != value {
                tagChanged = true
                tag.value = value
                newTags[indexFound] = tag
            }
        } else {
            tagChanged = true
            newTags.append(MBAudienceTag(tag: tag, value: value))
        }
        if tagChanged {
            saveNewTags(tags: newTags)
            updateMetadata()
            MBPluginsManager.tagChanged(tag: tag, value: value)
        }
    }
    
    func removeTag(_ tag: String) {
        var newTags = getTags() ?? []
        if let indexFound = newTags.firstIndex(where: {$0.tag == tag}) {
            newTags.remove(at: indexFound)
        }
        saveNewTags(tags: newTags)
        updateMetadata()
        MBPluginsManager.tagChanged(tag: tag, value: nil)
    }
    
    private func saveNewTags(tags: [MBAudienceTag]) {
        let userDefaults = UserDefaults.standard
        let mappedTags = tags.map({ $0.toDictionary() })
        userDefaults.set(mappedTags, forKey: "com.mumble.mburger.audience.tags")
    }
    
    func getTags() -> [MBAudienceTag]? {
        let userDefaults = UserDefaults.standard
        guard let tags = userDefaults.object(forKey: "com.mumble.mburger.audience.tags") as? [[String: String]] else {
            return nil
        }
        return tags.map({MBAudienceTag(dictionary: $0)})
    }
    
    func getTagsAsDictionaries() -> [[String: String]]? {
        let userDefaults = UserDefaults.standard
        guard let tags = userDefaults.object(forKey: "com.mumble.mburger.audience.tags") as? [[String: String]] else {
            return nil
        }
        return tags
    }
    
    // MARK: - Custom Id

    func setCustomId(_ customId: String?) {
        let userDefaults = UserDefaults.standard
        if let customId = customId {
            userDefaults.set(customId, forKey: "com.mumble.mburger.audience.customId")
        } else {
            userDefaults.removeObject(forKey: "com.mumble.mburger.audience.customId")
        }
        updateMetadata()
    }
    
    func getCustomId() -> String? {
        let userDefaults = UserDefaults.standard
        return userDefaults.object(forKey: "com.mumble.mburger.audience.customId") as? String
    }

    // MARK: - Mobile User Id

    func setMobileUserId(_ mobileUserId: Int?) {
        let userDefaults = UserDefaults.standard
        if let mobileUserId = mobileUserId {
            let stringValue = NSNumber(value: mobileUserId).stringValue
            userDefaults.set(stringValue, forKey: "com.mumble.mburger.audience.mobileUserId")
        } else {
            userDefaults.removeObject(forKey: "com.mumble.mburger.audience.mobileUserId")
        }
        updateMetadata()
    }
    
    func getMobileUserId() -> Int? {
        let userDefaults = UserDefaults.standard
        if let stringValue = userDefaults.object(forKey: "com.mumble.mburger.audience.mobileUserId") as? String {
            return Int(stringValue)
        }
        return nil
    }

}

// MARK: -

extension Double {
    func truncate(places: Int) -> Double {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}
