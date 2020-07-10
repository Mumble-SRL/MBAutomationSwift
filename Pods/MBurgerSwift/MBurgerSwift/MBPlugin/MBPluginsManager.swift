//
//  MBPluginsManager.swift
//  MBurgerSwift
//
//  Created by Lorenzo Oliveto on 30/06/2020.
//  Copyright © 2020 Mumble S.r.l (https://mumbleideas.it/). All rights reserved.
//

import UIKit

/// The main class that manages and synchronize MBurger plugins
public class MBPluginsManager {
    
    /// Function called at startup by MBurger to do startup jobs
    static func handlePluginStartup(plugins: [MBPlugin],
                                    launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        guard plugins.count != 0 else {
            return
        }
        let sortedPlugins = plugins.sorted(by: { (p1, p2) -> Bool in
            return p1.applicationStartupOrder > p2.applicationStartupOrder
        })
        var startupBlocks = [ApplicationStartupBlock]()
        for plugin in sortedPlugins {
            if let startupBlock = plugin.applicationStartupBlock() {
                startupBlocks.append(startupBlock)
            }
        }
        
        guard startupBlocks.count != 0 else {
            return
        }
        
        executeStartupBlock(index: 0,
                            startupBlocks: startupBlocks,
                            launchOptions: launchOptions)
    }
    
    private static func executeStartupBlock(index: Int,
                                            startupBlocks: [ApplicationStartupBlock],
                                            launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        guard index < startupBlocks.count else {
            return
        }
        let startupBlock = startupBlocks[index]
        startupBlock(launchOptions, {
            if index + 1 < startupBlocks.count {
                self.executeStartupBlock(index: index + 1,
                                         startupBlocks: startupBlocks,
                                         launchOptions: launchOptions)
            }
        })
    }

    /// Syncronize location data coming from the plugins, this function is used by audience plugin to tell other plugins that new data is available.
    /// - Parameters:
    ///   - latitude: The new latitude.
    ///   - longitude: The new longitude.
    public static func locationDataUpdated(latitude: Double, longitude: Double) {
        for plugin in MBManager.shared.plugins {
            plugin.locationDataUpdated(latitude: latitude, longitude: longitude)
        }
    }
    
    /// Used to pass campaigns from MBMessages & MBAutomation in order to display automation campaigns based on the triggers
    /// - Parameters:
    ///   - campaigns: The campaigns fetched, tipically `MBCampaign` objects
    public static func campaignsReceived(campaigns: [Any]) {
        for plugin in MBManager.shared.plugins {
            plugin.campaignsReceived(campaings: campaigns)
        }
    }
}
