//
//  AppDelegate.swift
//  MonitorBar
//
//  Created by wing on 2016/12/21.
//  Copyright © 2016年 Magic Install. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var preferencesWindow: NSWindow!
    
    

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        print("applicationDidFinishLaunching")
        // Insert code here to initialize your application
        
        
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(onFoundedSensors(notification:)),
//            name: NSNotification.Name(Updater.NOTIFICATION_UPDATER_FOUNDED_SENSOERS),
//            object: nil
//        )
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        print("applicationWillTerminate")
        // Insert code here to tear down your application
    }
    
    
//    @objc func onFoundedSensors(notification:Notification) -> Void {
//        print("onFoundedSensors")
//    }
    
    
}

