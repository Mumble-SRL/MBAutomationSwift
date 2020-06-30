//
//  MBAutomationViewTracking.swift
//  MBAutomation
//
//  Created by Lorenzo Oliveto on 30/06/2020.
//  Copyright © 2020 Lorenzo Oliveto. All rights reserved.
//

import UIKit

class MBAutomationViewTracking: NSObject {
    internal static func swizzleViewControllerDidAppear() {
        let instance: UIViewController = UIViewController()
        let aClass: AnyClass! = object_getClass(instance)

        let originalSelector = #selector(UIViewController.viewDidAppear(_:))
        let swizzledSelector = #selector(UIViewController.mbautomation_viewDidAppear(_:))

        guard let originalMethod = class_getInstanceMethod(aClass, originalSelector),
            let swizzledMethod = class_getInstanceMethod(aClass, swizzledSelector) else {
                return
        }

        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
    
    static func trackViewForViewController(viewController: UIViewController) {
        if let viewName = viewController.mbTrackingName {
            print(viewName)
        } else {
            print(String(describing: viewController.self))
        }
    }
}
