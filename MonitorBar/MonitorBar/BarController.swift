//
//  BarController.swift
//  MonitorBar
//
//  Created by wing on 2016/12/19.
//  Copyright © 2016 Magic Install. All rights reserved.
//

import Cocoa


extension StatusBarLayout {
    public static let ITEM_CONTENTS_KEY_SENSOR_KEYS   = "keys"
    public static let ITEM_CONTENTS_KEY_APPED_UNIT    = "appedUnit"
    public static let ITEM_CONTENTS_KEY_ICON_NAME     = "icon"
    public static let ITEM_CONTENTS_KEY_ICON_INSTANCE = "NSImage"
}

// MARK: -  -

/// 状态栏绘制的流程是这样的:
/// StatusBarLayout 负责元件的布局;
/// StatusBarDrawer 负责具体绘制过程;
/// 本BarController 负责将元件(statusBarItem) 的draw() 方法关联至对应的StatusBarDrawer 方法,
/// 当接收到Updater 的更新通知时, 
/// BarController 在StatusBarDrawer 的代理方法中遍历StatusBarLayout 中的全部元件并调用其draw() 方法进行绘制.
class BarController: NSViewController, NSMenuDelegate, StatusBarLayoutDelegate {
    
    /// 连接最上层的菜单模型
    @IBOutlet weak var rootMenu : NSMenu!
    
    /// 系统分配的状态栏对象
    let rootStatusItem = NSStatusBar.system().statusItem(withLength: 100.0)
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        print("BarController init?(coder: NSCoder)")

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onSensorsUpdate(notification:)),
            name: NSNotification.Name(Updater.NOTIFICATION_UPDATER_SENSOERS_UPDATED),
            object: nil
        )
        
        // 载入Assets.xcassets 的图标
        for name in NSImage.assetsImageNames() {
            if iconResouces[name] == nil {
                iconResouces[name] = NSImage(named: name)
            }
        }
    }
    
    override func awakeFromNib() {
        print("BarController awakeFromNib")

        
        // 创建状态栏绘图器
        if drawer == nil {
            drawer = StatusBarDrawer.createStatusBarDrawer(toStatusItem: rootStatusItem)
//            drawer!.setDrawingFunction(drawingFunc: drawingFunc)
            drawer!.setDrawingFunction(drawingFunc: barLayout.draw)
        }
        
        // FIXME: 会由于早过Updater 加载而导致无法显示任何传感器
//        if didLoadDefault == false {
//            loadDataSourceFromDefault()
//            barLayout.loadLayout(forDelegate: self)
//        }        
        
        rootStatusItem.menu  = rootMenu
        
//        rootStatusItem.target = self
//        rootStatusItem.action = #selector(onStatusItemClick(sender:))
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
    
    
    func onStatusItemClick(sender: AnyObject?) {
        print("onStatusItemClick")
    }
    
    @objc func onSensorsUpdate(notification:Notification) -> Void {
//        print("onFoundedSensors")
        
        if didLoadDefault == false {
            loadDataSourceFromDefault()
            barLayout.loadLayout(forDelegate: self)
        }        

        drawer?.draw()
        rootStatusItem.button?.setNeedsDisplay()
    }
    
    
    
// MARK: - StatusBarDrawer, ImageDrawer
    
    
    /// 状态栏绘画对象
    var drawer : StatusBarDrawer?
    
    
//    func drawingFunc(inRect rect: CGRect) {
//        // 测试用的定位框架
////        StatusBarDrawer.drawDebugFrame(inRect: rect, withColor: NSColor.red)
//        
//        
//        
//        
//        var currentRight: CGFloat = 0.0
//        
//        for column in barLayout.columns {
//            for item in column.items {
//                item.draw?(item, currentRight)
//            }
//            
//            currentRight += column.length
//        }
//    }
    
 
// MARK: - StatusBarLayout
    
    /// 状态栏布局器
    var barLayout = StatusBarLayout() // 在init?(coder:)  设置delegate
    
    
    /// 图标资源的实例用字典保存,
    /// 用资源名作为key, 便于查找.
    ///
    /// 不要用Assets 中的资源名覆盖掉effectiveImage 中的方法指针,
    /// 否则只能输出静态图像.
    var iconResouces: [String : Any] = StatusBarDrawer.effectiveImage
    
    
    
    /// StatusBarDrawer 内部的image 的宽度必须与状态栏的宽度对应,
    /// 只用本方法设置宽度避免出错!
    func setLength(_ width: CGFloat) {
        rootStatusItem.length = width
        drawer?.length        = width
    }
    
    
    /// 将元件(statusBarItem) 的draw() 方法关联至对应的StatusBarDrawer 方法
    /// 取icon
    ///    └	有icon
    ///             └	动态icon
    ///                   └	动态icon	查 [icon name: func]
    ///                 静态icon
    ///                   └	直接image.draw
    ///         冇icon
    ///             └	有key
    ///                   └	[key : sensor] 读NSNumber 值
    ///                             └	格式化后draw
    ///                 冇key
    ///                   └	读comment	直接draw
    public func setupItems() {
        for column in barLayout.columns {
            for var item in column.items {
                
                let imageName:String? = item.contents[StatusBarLayout.ITEM_CONTENTS_KEY_ICON_NAME] as! String?
                var hasIcon = (imageName != nil) // 先用是否设置了ITEM_CONTENTS_KEY_ICON_NAME 属性判断
                
                // 进一步判断该imageName 是否可用
                if hasIcon {
                    let resource = onItemFindIconObject(withName: imageName!)
                    switch resource {
                    // 静态icon
                    case is NSImage:
                        item.contents[StatusBarLayout.ITEM_CONTENTS_KEY_ICON_INSTANCE] = resource
                        item.draw = StatusBarDrawer.staticIconDraw
                        hasIcon = true
                        break // 暂不要写直接 continue
                        
                    // 动态icon
                    case is ((_ item: statusBarItem, _ columnRect: CGRect) -> ()):
                        let namedRes = NSImage(named: imageName!)
                        if namedRes != nil {
                            // 可以使用静态icon + 动态draw 的方式呈现!
                            item.contents[StatusBarLayout.ITEM_CONTENTS_KEY_ICON_INSTANCE] = namedRes!
                        }
                        // 指定相应的绘制方法
                        item.draw = iconResouces[imageName!] as? ((statusBarItem, CGRect) -> ())
                        hasIcon   = true
                        break // 暂不要写直接 continue
                        
                    default:
                        hasIcon = false
                    }
                    
                    
//                    var icon  = onItemIconSetup(item)
//                    let dFunc = onItemDrawFunctionSetup(item)
//                    
//                    // 动态icon
//                    if (dFunc != nil){
//                        if (icon == nil) {
//                            // 可以使用静态icon + 动态draw 的方式呈现!
//                            icon = NSImage(named: imageName!)
//                        }
//                        if icon != nil {
//                            item.contents[StatusBarLayout.ITEM_CONTENTS_KEY_ICON_INSTANCE] = icon!
//                        }
//                        item.draw = dFunc
//                        hasIcon   = true
//                    }
//                    // 静态icon
//                    else if icon != nil {
//                        item.contents[StatusBarLayout.ITEM_CONTENTS_KEY_ICON_INSTANCE] = icon!
//                        item.draw = StatusBarDrawer.staticIconDraw
//                        hasIcon   = true
//                   }
                }
                
                // 冇icon
                if hasIcon == false {
                    // 注: 如果元件的imageName 在iconResouces 中没有对应, 亦会进这里!
                    
                    // 有key
                    if item.contents[StatusBarLayout.ITEM_CONTENTS_KEY_SENSOR_KEYS] != nil {
                        item.draw = StatusBarDrawer.noIconHasKeyItemDraw
                    }
                        // 冇key
                    else {
                        item.draw = StatusBarDrawer.noIconNoKeyItemDraw
                    }
                }
                
                // 添加附加内容
                
                let keys = item.contents[StatusBarLayout.ITEM_CONTENTS_KEY_SENSOR_KEYS] as? String
                if keys != nil {
                    let sensors = onItemConnectSensors(keys!.components(separatedBy: ", "))
                    if sensors != nil {
                        for sensor in sensors! {
                            item.contents[sensor.key] = sensor
                        }
                    }
                }
            } // for item
        } // for column
    }

    func onLayouted(_ sender: StatusBarLayout) {
        setLength(sender.size.width)
    }
    
    func onLoadedFromXml(withLayout layout: StatusBarLayout) {
        setupItems()
    }
    
    func onLoadedFromXml(withItem item: statusBarItem) {
        // 协议方法, 冇用到...
    }
    
    func onFindItemFromXml(attributes attributeDict: [String : String]) -> statusBarItem? {
        // 协议方法, 冇用到...
        return nil
    }
    
    /// setupItems() 方法将要取得显示图标所需的资源
    ///
    /// - Returns: 返回值目前只有NSImage 以及绘制方法指针可用,
    ///            setupItems() 会将此实例或方法设置到item 的本体.
    func onItemFindIconObject(withName name: String) -> Any? {
        return self.iconResouces[name]
    }
    
    /// setupItems() 将要关联传感器到显示元件
    ///
    /// - Returns: 返回将要关联到item 的传感器,
    ///            setupItems() 会将传感器实例添加到item 的contents属性.
    func onItemConnectSensors(_ sensorKeys:[String]) -> [Sensor]? {
        var sensors: [Sensor] = []
        for key in sensorKeys {
            if sensorSource[key] != nil {
                sensors.append(sensorSource[key]!)
            }
        }
        if sensors.count < 1 {
            return nil
        }
        return sensors
    }
    
        
//    /// setupItems() 方法将要设置图像实例
//    ///
//    /// - Returns: 返回将要设置到item 的context 属性的图像实例,
//    ///            setupItems() 会将此实例设置到item 的本体.
//    func onItemIconSetup(_ item: statusBarItem) -> NSImage? {
//        let iconName: String? = item.contents[StatusBarLayout.ITEM_CONTENTS_KEY_ICON_NAME] as! String?
//        if (iconName == nil) || !(self.iconResouces[iconName!] is NSImage?) { return nil }
//        return self.iconResouces[iconName!] as! NSImage?
//    }
//    
//    /// setupItems() 将要设置绘图方法
//    ///
//    /// - Returns: 返回将要设置到item 的drawFunc 属性的方法,
//    ///            setupItems() 会将此方法设置到item 的本体.
//    func onItemDrawFunctionSetup(_ item:statusBarItem) -> ((_ item: statusBarItem, _ columnRect: CGRect) -> ())? {
//        let iconName: String? = item.contents[StatusBarLayout.ITEM_CONTENTS_KEY_ICON_NAME] as! String?
//        if iconName == nil {
//            return nil
//        }
//        return self.iconResouces[iconName!] as? ((statusBarItem, CGRect) -> ())
//    }

    
// MARK: - 管理传感器
    
    /// 传感器数组
    var sensorSource : [String : Sensor] = [:]
    
    /// 用于判断何时载入配置
    var didLoadDefault = false
    
    /// 从用户配置载入要显示的传感器
    func loadDataSourceFromDefault() {
        // 一. 载入出厂设置
        Preferences.initDefaults()
        let dictionary = UserDefaults.standard.dictionary(forKey: Preferences.IN_STATUS_BAR_ITEMS) as? Dictionary<String, Array<String>>
        
        // 二. 遍历用户设置的传感器
        sensorSource.removeAll()
        let groudArray = dictionary?["Groud"]
        if (dictionary != nil) || (groudArray != nil) {
            for groud in groudArray! {
                let keyArray = dictionary?[groud]
                if (keyArray != nil) {
                    if keyArray!.count > 0 {
                        print(groud)
                    }
                    // 枚举Key
                    keyEnum : for key in keyArray! {
                        let sensor:Sensor?
                        // 根据组名载入传感器
                        switch groud {
                            
                        // TODO: 加入其它传感器...
                            
                        case "Temperatures":
                            sensor = TemperatureSensor.activeSensors(withKey: key)
                            break
                            
                        case "Network":
                            sensor = NetworkSensor.activeSensors(withKey: key)
                            break
                            
                        case "Storage":
                            sensor = StorageSensor.activeSensors(withKey: key)
                            break
                            
                        case "Fans":
                            sensor = FanSensor.activeSensors(withKey: key)
                            break
                            
                        default:
                            break keyEnum;
                            
                        } // switch groud
                        
                        if (sensor == nil) { continue }
                        print("|- ", sensor!.name)
//                            sensorSource.append((sensor!, nil))
                        sensorSource[key] = sensor!
                        
                    } // for key in keyArray
                }
            }
        }
        
        didLoadDefault = true
        print("BarController loaded sensors")
    }
  

    
// MARK: - 偏好设置
    
    var preferencesWindow : Preferences?
    
    /// 连接菜单的偏好设置的行为
    @IBAction func onClickPreferences(_ sender: AnyObject) {
        if preferencesWindow == nil {
            preferencesWindow = Preferences()
        }
        preferencesWindow!.showWindow(nil)
    }
    
}
