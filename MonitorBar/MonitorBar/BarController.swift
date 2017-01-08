//
//  BarController.swift
//  MonitorBar
//
//  Created by wing on 2016/12/19.
//  Copyright © 2016 Magic Install. All rights reserved.
//

import Cocoa

class BarController: NSViewController, NSMenuDelegate {
    
// MARK: -
// MARK: 状态栏
    
    /// 连接最上层的菜单模型
    @IBOutlet weak var rootMenu : NSMenu!
    
    /// 系统分配的状态栏对象
    let rootStatusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    
    override func awakeFromNib() {
        print("BarController awakeFromNib")
        let icon = NSImage(named: "multipliers")
        icon?.isTemplate = true // best for dark mode
        rootStatusItem.image = icon
        rootStatusItem.menu  = rootMenu
        
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onSensorsUpdate(notification:)),
            name: NSNotification.Name(Updater.NOTIFICATION_UPDATER_SENSOERS_UPDATED),
            object: nil
        )
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        print("BarController viewWillAppear")
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        print("BarController viewWillDisappear")
    }
    
    deinit {
        print("BarController deinit")
    }
    
    
    @objc func onSensorsUpdate(notification:Notification) -> Void {
//        print("onFoundedSensors")
    }
    
// MARK: -
// MARK: 偏好设置
    
    var preferencesWindow : Preferences?
    
    /// 连接菜单的偏好设置的行为
    @IBAction func onClickPreferences(_ sender: AnyObject) {
        if preferencesWindow == nil {
            preferencesWindow = Preferences()
        }
        preferencesWindow!.showWindow(nil)
    }
    
}
