//
//  BarController.swift
//  MonitorBar
//
//  Created by wing on 2016/12/19.
//  Copyright © 2016 Magic Install. All rights reserved.
//

import Cocoa

class BarController: NSViewController {
    
    /// 连接最上层的菜单模型
    @IBOutlet weak var rootMenu : NSMenu!
    
    /// 系统分配的状态栏对象
    let rootStatusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    
    override func awakeFromNib() {
        let icon = NSImage(named: "multipliers")
        icon?.isTemplate = true // best for dark mode
        rootStatusItem.image = icon
        rootStatusItem.menu  = rootMenu
        
    }
    
    var preferencesWindow : Preferences?
    
    @IBAction func onClickPreferences(_ sender: AnyObject) {
        if preferencesWindow == nil {
            preferencesWindow = Preferences()
        }
        preferencesWindow!.showWindow(nil)
    }
    
}
