//
//  MonitorBar
//  Updater.swift
//
//  Created by wing on 2017/1/7.
//  Copyright © 2016 Magic Install. All rights reserved.
//

import Cocoa

/// 提供整个更新流程架构
class Updater: NSObject {
    
    
// MARK: -
// MARK: 通知
    
    //    static let NOTIFICATION_UPDATER_CALLBACK_BUILD   = "Notification_Updater_Callback_Build"
    //    static let NOTIFICATION_UPDATER_FOUNDED_SENSOERS = "Notification_Updater_Founded_Sensoers"
    static let NOTIFICATION_UPDATER_SENSOERS_UPDATED = "Notification_Updater_Sensoers_Updated"

    
    
    
// MARK: -
// MARK: 类静态属性
    
    /// 串行线程
    static var updataQueue = DispatchQueue(label: "MonitorBar.updata.queue")
    
    /// GCD Timer
    static let timer = DispatchSource.makeTimerSource(queue: updataQueue)
    
    /// 更新间隔
//    static private var interval : Int = 2
    
    
    
    // MARK: -
    // MARK: 类方法
    
    override class func initialize() {
       superclass()?.initialize()
        
//        build(notification: Notification(name: Notification.Name(rawValue: NOTIFICATION_UPDATER_CALLBACK_BUILD)))
////        NotificationCenter.default.addObserver(
////            self,
////            selector: #selector(build(notification:)),
////            name: NSNotification.Name(Updater.NOTIFICATION_UPDATER_CALLBACK_BUILD),
////            object: nil
////        )
//    }
//    
//    @objc class func build(notification:Notification) {
        
        // 在专用线程进行
        updataQueue.async {
            // 一. 载入出厂设置
            Preferences.initDefaults()

            // 二. 载入配置
            // -- 载入间隔
            var interval = UserDefaults.standard.integer(forKey: Preferences.UPDATE_INTERVAL)
            if interval <= 0 {
                interval = 2
            }
//            Updater.interval = interval;
            
            // -- 载入将要显示的Key
            var activeKeys = Set<String>()
            activeKeys.formUnion(Updater.getKeys(withItemType: Preferences.IN_STATUS_BAR_ITEMS))
            activeKeys.formUnion(Updater.getKeys(withItemType: Preferences.IN_MENU_ITEMS))
            activeKeys.formUnion(Updater.getKeys(withItemType: Preferences.IN_GRAPHIC_ITEMS))
            
            // 三. 根据Key集合载入传感器
            // TODO: 加入其它buildSensors...
            StorageSensor.buildSensors(fromKeys: activeKeys)
            
            
            print("Updater loaded \(activeKeys)")
//            sleep(5)
            
            // 通知控件载入传感器...
//            DispatchQueue.main.async {
//                NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATION_UPDATER_FOUNDED_SENSOERS), object: nil)
//            }
            
//             -- StorageSensor
//            StorageSensor.buildSensors(fromKeys: StorageSensor.effectiveKeys().intersection(activeKeys))
//            let storageSensorsDict = StorageSensor.buildSensors(fromKeys: activeKeys)
//            
//            
//            var sensorForCell = [Sensor]()
//            sensorForCell.append(StorageSensor.activeSensors())
            
            // 四. 启动
            timer.setEventHandler(handler: {
                Updater.onTick()
            })
            Updater.start(withInterval: Double(interval))
        }
    }
    
    
//    static var lastTime = CFAbsoluteTimeGetCurrent();
    
    static private func onTick() {
//        let now = CFAbsoluteTimeGetCurrent();
//        print("tick", now - lastTime)
//        lastTime = now

            
        // TODO: 加入其它update...
        StorageSensor.update()
        
        // 通知控件刷新...
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name(NOTIFICATION_UPDATER_SENSOERS_UPDATED), object: nil)
        }
    }
    
    static func start(withInterval interval: Double) {
        timer.scheduleRepeating(deadline: DispatchTime.now(), interval: interval)
        timer.resume()
    }

    static func stop() {
        timer.suspend()
    }
    
    /// 枚举用户设置中指定控件类型的传感器
    ///
    /// - Parameters:
    ///   - forItemType: Preferences.IN_STATUS_BAR_ITEMS, Preferences.IN_MENU_ITEMS, Preferences.IN_GRAPHIC_ITEMS
    /// - Returns: 传感器的Key
    static func getKeys(withItemType type: String) -> Set<String> {
//    static func getKeys(withKeyType : String, forItemType: String) -> NSSet {
        let dictionary = UserDefaults.standard.dictionary(forKey: type) as? Dictionary<String, Array<String>>
        let groudArray = dictionary?["Groud"]
        var keys = Set<String>()
        if (dictionary != nil) || (groudArray != nil) {
            for groud in groudArray! {
                let keyArray = dictionary?[groud]
                if (keyArray != nil) {
                    for key in keyArray! {
                        keys.insert(key)
                    }
                }
            }
        }
        return keys
    }
    
//    static func getSensors(withGroud groud:String, inItemType type:String) -> [Sensor] {
//        let dictionary = UserDefaults.standard.dictionary(forKey: type) as? Dictionary<String, Array<String>>
//        let groudArray = dictionary?[groud]
//        
//    }
    
    
    
// MARK: -
// MARK: 实例方法
    
//    override init() {
//        Updater.initialize()
//        Updater.start()
//    }
    
    deinit {
        Updater.stop()
        print("Updater deinited")
    }
    

    
    
}
