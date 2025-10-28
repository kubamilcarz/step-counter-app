//
//  AppDelegate.swift
//  Step Counter
//
//  Created by Kuba Milcarz on 28/10/2025.
//

import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {

    var config: BuildConfiguration!
    var dependencies: Dependencies!
    
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        #if MOCK
            config = .mock
        #elseif DEV
            config = .dev
        #else
            config = .prod
        #endif
        
        dependencies = Dependencies(config: config)
        
        return true
    }
}

enum BuildConfiguration: Equatable {
    case mock(isPremium: Bool, isConnected: Bool)
    case dev
    case prod
    
    var isProd: Bool { self == .prod }
}
