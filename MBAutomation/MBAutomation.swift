//
//  MBAutomation.swift
//  MBAutomation
//
//  Created by Lorenzo Oliveto on 30/06/2020.
//  Copyright © 2020 Lorenzo Oliveto. All rights reserved.
//

import UIKit
import MBurgerSwift

public class MBAutomation: NSObject, MBPlugin {
    
    /// Initializes the plugin, if trackViewsAutomatically if yes the views are tracked automatically. It uses method swizzling to track automatically screen view once view did appear happens.
    public init(trackViewsAutomatically: Bool = true) {
        super.init()
        if (trackViewsAutomatically) {
            MBAutomationViewTracking.swizzleViewControllerDidAppear()
        }
    }
    
    /// Sets the current view controller, this can be used if automatic view tracking is disabled or to force a particular screen
    public func trackScreenView(_ viewController: UIViewController) {
        MBAutomationViewTracking.trackViewForViewController(viewController: viewController)
    }
}
