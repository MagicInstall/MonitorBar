//
//  MonitorBar
//  Launch.swift
//
//  Created by wing on 2017/2/18.
//  Copyright © 2016 Magic Install. All rights reserved.
//

import Cocoa
import ServiceManagement


/// 提供App 运行相关方法
class Launch:NSObject {
    static func makeAppLoginStartup(startup: Bool) {
        // 这里请填写你自己的Heler BundleID        
        let launcherAppIdentifier = Bundle.main.bundleIdentifier! as CFString
        // 开始注册/取消启动项        
        
        SMLoginItemSetEnabled(launcherAppIdentifier, startup)
//        var startedAtLogin = false
//        for app in NSWorkspace.shared().runningApplications {
//            if app.bundleIdentifier == launcherAppIdentifier as String {
//                startedAtLogin = true
//            }
//        } ?? "\\(- -)/" + ".Helper")
//        if startedAtLogin {
//            DistributedNotificationCenter.defaultCenter().postNotificationName("killhelper", object: Bundle.main.bundleIdentifier!)
//        }
    }
    
    
    
    
//    
//    
//    func applicationIsInStartUpItems() -> Bool {
//        return (itemReferencesInLoginItems().existingReference != nil)
//    }
//    
//    func itemReferencesInLoginItems() -> (existingReference: LSSharedFileListItem?, lastReference: LSSharedFileListItem?) {
//        var itemUrl : UnsafeMutablePointer<Unmanaged<CFURL>?> = UnsafeMutablePointer<Unmanaged<CFURL>?>.allocate(capacity: 1)
//        if let appUrl : NSURL? = NSURL.fileURL(withPath: Bundle.main.bundlePath) {
//            let loginItemsRef = LSSharedFileListCreate(
//                nil,
//                kLSSharedFileListSessionLoginItems.takeRetainedValue(),
//                nil
//                ).takeRetainedValue() as LSSharedFileList?
//            if loginItemsRef != nil {
//                let loginItems: NSArray = LSSharedFileListCopySnapshot(loginItemsRef, nil).takeRetainedValue() as NSArray
//                println("There are \(loginItems.count) login items")
//                let lastItemRef: LSSharedFileListItemRef = loginItems.lastObject as LSSharedFileListItemRef
//                for var i = 0; i < loginItems.count; ++i {
//                    let currentItemRef: LSSharedFileListItemRef = loginItems.objectAtIndex(i) as LSSharedFileListItemRef
//                    if LSSharedFileListItemResolve(currentItemRef, 0, itemUrl, nil) == noErr {
//                        if let urlRef: NSURL =  itemUrl.memory?.takeRetainedValue() {
//                            println("URL Ref: \(urlRef.lastPathComponent)")
//                            if urlRef.isEqual(appUrl) {
//                                return (currentItemRef, lastItemRef)
//                            }
//                        }
//                    } else {
//                        println("Unknown login application")
//                    }
//                }
//                //The application was not found in the startup list
//                return (nil, lastItemRef)
//            }
//        }
//        return (nil, nil)
//    }
//    
//    func toggleLaunchAtStartup(sure: Bool) {
//        let itemReferences = itemReferencesInLoginItems()
//        let shouldBeToggled = (itemReferences.existingReference == nil)
//        let loginItemsRef = LSSharedFileListCreate(
//            nil,
//            kLSSharedFileListSessionLoginItems.takeRetainedValue(),
//            nil
//            ).takeRetainedValue() as LSSharedFileListRef?
//        if loginItemsRef != nil {
//            if shouldBeToggled {
//                if let appUrl : CFURLRef = NSURL.fileURLWithPath(NSBundle.mainBundle().bundlePath) {
//                    LSSharedFileListInsertItemURL(
//                        loginItemsRef,
//                        itemReferences.lastReference,
//                        nil,
//                        nil,
//                        appUrl,
//                        nil,
//                        nil
//                    )
//                    println("Application was added to login items")
//                }
//            } else {
//                if let itemRef = itemReferences.existingReference {
//                    LSSharedFileListItemRemove(loginItemsRef,itemRef);
//                    println("Application was removed from login items")
//                }
//            }
//        }
//    }
}
