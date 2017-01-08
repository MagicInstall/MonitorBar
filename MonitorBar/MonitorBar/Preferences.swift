//
//  Preferences.swift
//  MonitorBar
//
//  Created by wing on 2016/12/29.
//  Copyright © 2016年 Magic Install. All rights reserved.
//

import Cocoa

class Preferences: NSWindowController {

    
    // MARK: -
    // MARK: 类常量
    
    /// 记住最后一次Toolbar 切换的view
    static let USER_DEFAULTS_KEY_LAST_VIEW = "User_Defaults_Key_Last_View"
    
    
    static let LAST_VIEW_NAME_GENARAL = "Last_View_Name_Genaral"
    static let LAST_VIEW_NAME_STATUSBAR = "Last_View_Name_Statusbar"
    static let LAST_VIEW_NAME_MENU = "Last_View_Name_menu"
    static let LAST_VIEW_NAME_GRAPHIC = "Last_View_Name_Gaphic"
    
    /// 更新的间隔(秒)
    static let UPDATE_INTERVAL = "UpdateInterval"
    
    /// 状态栏显示项设置
    static let IN_STATUS_BAR_ITEMS = "InStatusBarItems"
    
    /// 菜单显示项设置
    static let IN_MENU_ITEMS = "InMenuItems"
    
    /// 图表显示项设置
    static let IN_GRAPHIC_ITEMS = "InGraphicItems"

    
    // MARK: -
    // MARK: 类方法

    /// 为了确认是否已经载入默认设置, 用一个引用来保存
    static private var userDefaults : UserDefaults?
    
    /// 每处使用UserDefaults.standard 之前都必须要运行载入出厂设置,
    /// 实际上只会载入一次.
    static func initDefaults() {
        if Preferences.userDefaults == nil {
            Preferences.userDefaults = UserDefaults.standard
            let url = Bundle.main.url(forResource: "Defaults", withExtension: "plist")
            let dict = NSDictionary(contentsOf: url!)
            Preferences.userDefaults!.register(defaults: dict! as! [String : Any])
        }
    }
    
    
    // MARK: -
    // MARK: 实例方法
    
    /// 初始化时取得标准偏好设置对象
    private var userDefaults = UserDefaults.standard
    
    override func awakeFromNib() {
        Preferences.initDefaults()
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    override var windowNibName: String? {
        return "Preferences"
    }
    
    override func showWindow(_ sender: Any?) {
        // TODO: 载入内页
        let lastView = userDefaults.string(forKey: Preferences.USER_DEFAULTS_KEY_LAST_VIEW) ?? ""
        switch lastView {
        case Preferences.LAST_VIEW_NAME_STATUSBAR:
            showStatusbarView(self)
            break
        case Preferences.LAST_VIEW_NAME_MENU:
            showMenuView(self)
            break
        case Preferences.LAST_VIEW_NAME_GRAPHIC:
            showGenaralView(self)
            break
        default:
            showGenaralView(self)
        }
        
        super.showWindow(sender)
    }
    
// MARK: -
// MARK: Genaral
    
    /// 连接常规设置的view
    @IBOutlet var genaralView: NSView!
    @IBOutlet weak var genaralToolbarItem: NSToolbarItem!

    /// 连接更新间隔的文本Cell
    @IBOutlet weak var intervalCell: NSTextFieldCell!
    
    /// 连接更新间隔的拖动条cell
    @IBOutlet weak var intervalSliderCell: NSSliderCell!

    /// 连接更新间隔的拖动条的Action
    @IBAction func onIntervalSliderChanged(_ sender: NSSlider) {
        intervalCell.title = intervalSliderCell.stringValue
    }
   
    
    /// 替换常规设置view 到前面
    @IBAction func showGenaralView(_ sender: AnyObject) {
        self.window?.contentView?.addSubview(genaralView)
        
        statusbarView?.removeFromSuperview()
        menuView?.removeFromSuperview()
        graphicView?.removeFromSuperview()
        
        userDefaults.setValue(Preferences.LAST_VIEW_NAME_GENARAL, forKey: Preferences.USER_DEFAULTS_KEY_LAST_VIEW)
    }
    
    
// MARK: -
// MARK: 状态栏设置
    
    /// 连接状态栏设置的view
    @IBOutlet var statusbarView: NSView!
    
    @IBAction func showStatusbarView(_ sender: AnyObject) {
        self.window?.contentView?.addSubview(statusbarView)
        
        genaralView?.removeFromSuperview()
        menuView?.removeFromSuperview()
        graphicView?.removeFromSuperview()
        
        userDefaults.setValue(Preferences.LAST_VIEW_NAME_STATUSBAR, forKey: Preferences.USER_DEFAULTS_KEY_LAST_VIEW)
    }
    
// MARK: -
// MARK: 菜单栏设置
    
    /// 连接菜单栏设置的view
    @IBOutlet var menuView: NSView!
    
    @IBAction func showMenuView(_ sender: AnyObject) {
        self.window?.contentView?.addSubview(menuView)
        
        genaralView?.removeFromSuperview()
        statusbarView?.removeFromSuperview()
        graphicView?.removeFromSuperview()
        
        userDefaults.setValue(Preferences.LAST_VIEW_NAME_MENU, forKey: Preferences.USER_DEFAULTS_KEY_LAST_VIEW)
    }


// MARK: -
// MARK: 统计图设置
    
    /// 连接统计图设置的view
    @IBOutlet var graphicView: NSView!
    
    
    @IBAction func showGraphicView(_ sender: AnyObject) {
        self.window?.contentView?.addSubview(graphicView)
        
        genaralView?.removeFromSuperview()
        statusbarView?.removeFromSuperview()
        menuView?.removeFromSuperview()
        
        userDefaults.setValue(Preferences.LAST_VIEW_NAME_GRAPHIC, forKey: Preferences.USER_DEFAULTS_KEY_LAST_VIEW)
    }
    
// MARK: -
// MARK: Toolbar
    
    /// 连接常规设置工具
//    @IBAction func onClickGenaralItem(_ sender: AnyObject) {
//    }
    
    /// 连接状态栏设置工具
//    @IBAction func onClickStatusbarItem(_ sender: AnyObject) {
//        
//    }
    
    /// 连接菜单栏设置工具
//    @IBAction func onClickMenuItem(_ sender: AnyObject) {
//    }
    
    /// 连接统计图设置工具
//    @IBAction func onClickGraphicItem(_ sender: AnyObject) {
//    }
    
//// MARK: -
//// MARK: NSToolbarDelegate
//    func toolbarSelectableItemIdentifiers(_ toolbar: NSToolbar) -> [String] {
//        print("toolbarSelectableItemIdentifiers")
//        return [""]
//    }
//    
}
