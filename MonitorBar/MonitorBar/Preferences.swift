//
//  Preferences.swift
//  MonitorBar
//
//  Created by wing on 2016/12/29.
//  Copyright © 2016年 Magic Install. All rights reserved.
//

import Cocoa
import ServiceManagement


class Preferences: NSWindowController {

    
    // MARK: -
    // MARK: 类常量
    
    /// 记住最后一次Toolbar 切换的view
    static let TOOLBAR_LAST_VIEW = "PreferencesWindowToolbarLastView"
    
    
    static let LAST_VIEW_NAME_GENARAL = "Genaral"
    static let LAST_VIEW_NAME_STATUSBAR = "Statusbar"
    static let LAST_VIEW_NAME_MENU = "Menu"
    static let LAST_VIEW_NAME_GRAPHIC = "Graphic"
    
    /// 更新的间隔(秒)
    static let UPDATE_INTERVAL = "UpdateInterval"
    
    /// 更新的间隔(秒)
    static let Launch_At_Login = "LoginLaunch"
    
    /// 状态栏显示项设置
    static let IN_STATUS_BAR_ITEMS = "InStatusBarItems"
    
    /// 状态栏布局设置
    static let STATUS_BAR_LAYOUT = "StatusBarLayout"

    
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
        let lastView = userDefaults.string(forKey: Preferences.TOOLBAR_LAST_VIEW) ?? ""
        switch lastView {
        case Preferences.LAST_VIEW_NAME_STATUSBAR:
            showStatusbarView(self)
            break
        case Preferences.LAST_VIEW_NAME_MENU:
            showMenuView(self)
            break
        case Preferences.LAST_VIEW_NAME_GRAPHIC:
            showGraphicView(self)
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
    
    /// 连接自动启动开关
    @IBOutlet weak var loginLaunchSwitch: NSButton!
    
    /// 连接自动启动开关的Action
    @IBAction func onLoginLaunchClick(_ sender: NSButton) {
        let enable = (sender.state == 0) ? false : true
        userDefaults.setValue(enable, forKey: Preferences.Launch_At_Login)
        
//        Launch.makeAppLoginStartup(startup: enable)
        
        // 开始注册/取消启动项
        let launcherAppIdentifier = "MagicInstall.MonitorBarHelper" as CFString

        SMLoginItemSetEnabled(launcherAppIdentifier, enable)

    }
    
   
    
    /// 替换常规设置view 到前面
    @IBAction func showGenaralView(_ sender: AnyObject) {
//        genaralToolbarItem.En
        
        self.window?.contentView?.addSubview(genaralView)
        
        statusbarView?.removeFromSuperview()
        menuView?.removeFromSuperview()
        graphicView?.removeFromSuperview()
        
        userDefaults.setValue(Preferences.LAST_VIEW_NAME_GENARAL, forKey: Preferences.TOOLBAR_LAST_VIEW)
        
        loginLaunchSwitch.state = (userDefaults.bool(forKey: Preferences.Launch_At_Login)) ? 1 : 0
    }
    
//    override func validateToolbarItem(_ item: NSToolbarItem) -> Bool {
//        if item == genaralToolbarItem {
//            return true
//        }
//        return false
//    }

    
    
// MARK: -
// MARK: 状态栏设置
    
    /// 连接状态栏设置的view
    @IBOutlet var statusbarView: NSView!
    
    @IBAction func showStatusbarView(_ sender: AnyObject) {
        self.window?.contentView?.addSubview(statusbarView)
        
        genaralView?.removeFromSuperview()
        menuView?.removeFromSuperview()
        graphicView?.removeFromSuperview()
        
        userDefaults.setValue(Preferences.LAST_VIEW_NAME_STATUSBAR, forKey: Preferences.TOOLBAR_LAST_VIEW)
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
        
        userDefaults.setValue(Preferences.LAST_VIEW_NAME_MENU, forKey: Preferences.TOOLBAR_LAST_VIEW)
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
        
        userDefaults.setValue(Preferences.LAST_VIEW_NAME_GRAPHIC, forKey: Preferences.TOOLBAR_LAST_VIEW)
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
