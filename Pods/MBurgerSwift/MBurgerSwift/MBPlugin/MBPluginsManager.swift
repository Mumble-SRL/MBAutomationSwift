//
//  MBPluginsManager.swift
//  MBurgerSwift
//
//  Created by Lorenzo Oliveto on 30/06/2020.
//  Copyright © 2020 Mumble S.r.l (https://mumbleideas.it/). All rights reserved.
//

import UIKit

/// The main class that manages the plugins
class MBPluginsManager {
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

}
