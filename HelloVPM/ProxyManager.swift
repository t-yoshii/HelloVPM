//
//  ProxyManager.swift
//  HelloVPM
//
//  Created by Takamitsu Yoshii on 2019/01/24.
//  Copyright © 2019年 XevoKK. All rights reserved.
//

import Foundation
import SmartDeviceLink

class ProxyManager: NSObject {
    private let appName = "HelloVPM"
    private let appId = "com.xevo.testapp.0000.helloVPM"

    var captureVC: UIViewController?

    // Manager
    var sdlManager: SDLManager!

    // Singleton
    static let sharedManager = ProxyManager()

    private override init() {
        super.init()
    }

    func connect() {
        // Used for USB Connection
        //let lifecycleConfiguration = SDLLifecycleConfiguration(appName: appName, fullAppId: appId)
        //let lifecycleConfiguration = SDLLifecycleConfiguration(appName: appName, appId: appId)

        // Used for TCP/IP Connection
        let lifecycleConfiguration = SDLLifecycleConfiguration(appName: appName, fullAppId: appId, ipAddress: "10.10.120.47", port: 15324)

        // App icon image
        /*
         if let appImage = UIImage(named: "AppIcon Name") {
         let appIcon = SDLArtwork(image: appImage, name: "Name to Upload As", persistent: true, as: .JPG /* or .PNG */)
         lifecycleConfiguration.appIcon = appIcon
         }
         */

        lifecycleConfiguration.shortAppName = "HVPM"
        lifecycleConfiguration.appType = .navigation

        let streamingMediaConfig = SDLStreamingMediaConfiguration()
        streamingMediaConfig.rootViewController = captureVC


        let configuration = SDLConfiguration(lifecycle: lifecycleConfiguration, lockScreen: .disabled(), logging: .debug(), streamingMedia: streamingMediaConfig, fileManager: .default())

        sdlManager = SDLManager(configuration: configuration, delegate: self)

        // Start watching for a connection with a SDL Core
        sdlManager.start { (success, error) in
            if success {
                // Your app has successfully connected with the SDL Core
            }
        }
    }
}

//MARK: SDLManagerDelegate
extension ProxyManager: SDLManagerDelegate {
    func managerDidDisconnect() {
        print("Manager disconnected!")
    }

    func hmiLevel(_ oldLevel: SDLHMILevel, didChangeToLevel newLevel: SDLHMILevel) {
        print("Went from HMI level \(oldLevel) to HMI level \(newLevel)")
    }
}
