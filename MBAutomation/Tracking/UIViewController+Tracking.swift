//
//  MBTrackedViewController.swift
//  MBAutomation
//
//  Created by Lorenzo Oliveto on 30/06/2020.
//  Copyright © 2020 Lorenzo Oliveto. All rights reserved.
//

import Foundation
import UIKit

private var _trackingNameKey: UInt8 = 181
private var _trackingMetadataKey: UInt8 = 182

extension UIViewController {
    // MARK: - Method Swizzling
    @objc func mbautomation_viewDidAppear(_ animated: Bool) {
        self.mbautomation_viewDidAppear(animated)

        MBAutomationViewTracking.trackViewForViewController(viewController: self)
    }
    
    /// Name that will be sent to MBurger automation instead of the class name
    public var mbaTrackingName: String? {
        get {
            return objc_getAssociatedObject(self, &_trackingNameKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &_trackingNameKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    /// Metdata that will be sent to MBurger automation for this viewController, you need to set this before `viewDidAppear` is called
    public var mbaTrackingMetadata: [String: Any]? {
        get {
            return objc_getAssociatedObject(self, &_trackingMetadataKey) as? [String: Any]
        }
        set {
            objc_setAssociatedObject(self, &_trackingMetadataKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

 }
