//
//  MonitorBar
//  MenuController.swift
//
//  Created by wing on 2016/12/19.
//  Copyright © 2016 Magic Install. All rights reserved.
//

import Cocoa

class MenuController: NSViewController , NSTableViewDelegate, NSTableViewDataSource {
    
// MARK: - 属性


    
// MARK: - 实例方法
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        print("MenuController init?(coder: NSCoder)")
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onSensorsUpdate(notification:)),
            name: NSNotification.Name(Updater.NOTIFICATION_UPDATER_SENSOERS_UPDATED),
            object: nil
        )
        
    }

    
    override func awakeFromNib() {
        print("MenuController awakeFromNib")

        // FIXME: 会由于早过Updater 加载而导致无法显示任何传感器
//        if didLoadDefault == false {
//            loadDataSourceFromDefault()
//            tableView.reloadData()
//        }
    }
    
    override func loadView() {
        print("MenuController loadView")
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        print("MenuController viewWillAppear")
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        print("MenuController viewWillDisappear")
    }
    
    deinit {
        print("MenuController deinit")
    }
    
    
    /// 刷新通知回调
    @objc func onSensorsUpdate(notification:Notification) -> Void {
//        if didLoadDefault == false { return }
        if didLoadDefault == false {
            loadDataSourceFromDefault()
            tableView.reloadData()
        }

        
        if (sensorSource.count > 0) && (sensorsRootItem.view != tableView) {
            showSensorsView()
        }
        else if (sensorSource.count == 0) {
            if sensorsRootItem.view == tableView {
                sensorsRootItem.view = nil
            }
            // TODO: 改为刷新
            sensorsRootItem.title = NSLocalizedString("Empty…", comment: "Empty…")
            return
        }

        refreshCells()
    }
    
    
    
// MARK: -
// MARK: 传感器视图
    
    /// 连接传感器列表在状态栏菜单中的占位模型
    @IBOutlet weak var sensorsRootItem: NSMenuItem!
    
    /// 连接用于替换占位模型的模型, 该模型不参与实际交互编程
    /// 可以将同一个模型同时连接到rootView 与tableView (如果rootView 就是tableView 的话)
    /// TODO: Found no sensor
    @IBOutlet weak var rootView: NSView!
    
    /// 连接传感器列表模型
    @IBOutlet weak var tableView: NSTableView!
    
    
    
    /// 将菜单项替换为传感器视图
    ///
    /// - Parameters:
    ///   - ready: YES: 显示传感器视图; NO: 显示菜单项.
//    func showSensorsView(ready: Bool, localizedStringKey: String?) {
//        // 显示传感器视图
//        if ready {
//            sensorsRootItem.view = tableView;
//        }
//        // 显示为普通Item
//        else {
//            sensorsRootItem.view = nil;
//            if localizedStringKey {
//                sensorsRootItem.title = NSLocalizedString("Unit_BPS", "B/s")
//            }
//        }
//    }
    
    /// 将占位模型替换为传感器列表模型
    func showSensorsView() {
        sensorsRootItem.view = tableView;
        tableView.reloadData()
    }
    
    
    /// 用于判断何时载入配置
    var didLoadDefault = false
    
    /// 从用户配置载入要显示的传感器
    func loadDataSourceFromDefault() {
        // 一. 载入出厂设置
        Preferences.initDefaults()
        let dictionary = UserDefaults.standard.dictionary(forKey: Preferences.IN_MENU_ITEMS) as? Dictionary<String, Array<String>>
        
        // 二. 遍历用户设置的传感器
        sensorSource.removeAll()
        let groudArray = dictionary?["Groud"]
        if (dictionary != nil) || (groudArray != nil) {
             for groud in groudArray! {
                let keyArray = dictionary?[groud]
                if (keyArray != nil) {
                    // 插入Groud cell
                    if keyArray!.count > 0 {
                        sensorSource.append((SensorGroud(withTitle: groud), nil))
                        print(groud)
                    }
                    // 枚举Key
                    keyEnum : for key in keyArray! {
                        var sensors: Sensor? = nil
                        switch groud {
                            
                        case "Temperatures":
                            sensors = TemperatureSensor.activeSensors(withKey: key)
                            break
                            
                        // TODO: 加入其它传感器...
                            
                        case "Network":
                            sensors = NetworkSensor.activeSensors(withKey: key)
//                            if (sensors == nil) { continue }
//                            print("|- ", sensors!.name)
//                            sensorSource.append((sensors!, nil))
                            break
                            
                        case "Storage":
                            sensors = StorageSensor.activeSensors(withKey: key)
//                            if (sensors == nil) { continue }
//                            print("|- ", sensors!.name)
//                            sensorSource.append((sensors!, nil))
                            break
                            
                        case "Fans":
                            sensors = FanSensor.activeSensors(withKey: key)
                            break
                            
                        case "CPU":
                            sensors = CPUSensor.activeSensors(withKey: key)
                            break
                            
                        case "Memory":
                            sensors = MemorySensor.activeSensors(withKey: key)
                            break
                            
                        default:
                            break keyEnum;
                        } // switch groud
                        
                        if (sensors == nil) { continue }
                        print("|- ", sensors!.name)
                        sensorSource.append((sensors!, nil))
                    
                    } // keyEnum : for key in keyArray!
                }
            }
        }
        
        didLoadDefault = true
        print("MenuController 偏好设置加载完毕")
    }
    
    
    // MARK: -
    // MARK: NSViewController
    
//    override func viewDidLoad() {
//        print("viewDidLoad", terminator: " J\n")
//    }
    
    /// 测试用
    @IBAction func test1(_ sender: AnyObject) {
//        loadDataSourceFromDefault()
//        tableView.reloadData()
        
        
        

    }
    
    @IBAction func test2(_ sender: AnyObject) {
//        let appleSMC = SmcHelper.connectionSmc()
//        
//        
////        print("Opened\(result?.connection), \(result?.keys.count) Keys")
//        
//        SmcHelper.disconnetSmc()
//        
//        NetworkSensor.test()
//        CPUSensor.test()
//        MemorySensor.test()
        
//        StorageSensor.update()
//        print(StorageSensor.activeSensors()!)
        
        
//        let serviceName = "fuck".cString(using: String.Encoding.utf8)
//        String.withCString("")
        
        
//        var fakeSmcConnection : io_connect_t = 0
//        let result = SMCOpen("FakeSMCKeyStore", &fakeSmcConnection)
//        if result != kIOReturnSuccess {
//            print("Fuck")
//        }
//        print("Opened\(fakeSmcConnection)")
//        SMCClose(fakeSmcConnection)
//        print("Closed")

    }
    
    /// 连接 打开活动监视器菜单 点击事件
    @IBAction func onActMonitorMenuClick(_ sender: NSMenuItem) {
        let runningApps = NSWorkspace.shared().runningApplications
        var isRunning   = false
        
        let appPath = "/Applications/Utilities/Activity Monitor.app"
        let bundle = Bundle(path: appPath)
        
        if bundle != nil {
            for app in runningApps {
                if app.bundleIdentifier == bundle!.bundleIdentifier {
                    isRunning = true
                    // 如果已经正在运行, 就将窗口前置
                    app.activate(options: NSApplicationActivationOptions.activateAllWindows)
                    break
                }
            }
            
            if !isRunning {
                let path   = bundle!.executablePath
                
                let task = Process()
                task.launchPath = path
                task.launch()
                
                print("\(appPath) Launched")
            }
        } else {
            assert(false, "\(appPath) 不存在!")
        }
    }
// MARK: - 管理传感器
    
    /// 传感器数组
    public var sensorSource = Array<(sensor:AnyObject, control:NSView?)>()
    
    func refreshCells() {
        for item in sensorSource {
            switch item.sensor {
            case is SensorGroud:
                break
            
            // TODO: 特殊Cell 直接case 传感器类类型...
                
            // 通用Cell
            case is Sensor:
                let sensor = item.sensor as! Sensor
                if item.control != nil {
                    if item.control is NSTextField {
                        // 根据不同的传感器设置显示的格式
                        switch sensor {
                            
                        // TODO: 加入其它传感器...
                            
                        case is StorageSensor, is NetworkSensor, is MemorySensor:
                            (item.control as! NSTextField).stringValue = DigitFormatter.to6Digit(
                                fromDouble: sensor.numericValue.doubleValue,
                                unit:       sensor.unit
                            )
                            break
                            
//                        case is NetworkSensor:
//                            (item.control as! NSTextField).stringValue = DigitFormatter.to6Digit(
//                                fromDouble: sensor.numericValue.doubleValue,
//                                unit:       sensor.unit
//                            )
//                            break
                            
                        default:
                           (item.control as! NSTextField).stringValue = "\(sensor.numericValue.intValue)\(sensor.unit)"
                        } // switch sensor
                    }
                    else {
                        assertionFailure(NSString(utf8String:object_getClassName(item.control)) as! String)
                    }
                    
//                } else {
//                    print("MenuController 未加载\(sensor.key) Cell")
                }
                break
                
            default:
                assertionFailure(NSString(utf8String:object_getClassName(item.sensor)) as! String)
                break
            } // switch item.sensor
        } // for item in sensorSource
    }
    
    /// 跟据sensorArray 的sensor 类类型创建TableCellView
    func makeCell(withIndex index: Int) -> NSView? {
        let item = sensorSource[index]
        
        switch item.sensor {
        case is SensorGroud:
            let groud = item.sensor as! SensorGroud
            
            let cell = tableView.make(withIdentifier: "GroudInMenuCell", owner: self) as! GroudInMenuCellView
            cell.titleField.stringValue = groud.title
            cell.imageView?.image       = groud.icon
            return cell
            
        // TODO: 特殊Cell 直接case 传感器类类型...
            
        // 通用Cell
        case is Sensor:
            let sensor = item.sensor as! Sensor
            
            let cell = tableView.make(withIdentifier: "SensorInMenuCell", owner: self) as! SensorInMenuCellView
            cell.nameField.stringValue     = sensor.name
            // 根据不同的传感器设置显示的格式
            switch sensor {
                
            // TODO: 加入其它传感器...
                
            case is NetworkSensor, is StorageSensor, is MemorySensor:
                cell.valueField.stringValue = DigitFormatter.to6Digit(
                    fromDouble: sensor.numericValue.doubleValue,
                    unit:       sensor.unit
                )
                break
                
//            case is StorageSensor:
//                cell.valueField.stringValue = DigitFormatter.to6Digit(
//                    fromDouble: sensor.numericValue.doubleValue,
//                    unit:       sensor.unit
//                )
//                break
                
            default:
                cell.valueField.stringValue = "\(sensor.numericValue.intValue)\(sensor.unit)"
            } // switch sensor
            
            sensorSource[index].control = cell.valueField
            return cell
            
        default:
            assertionFailure(NSString(utf8String:object_getClassName(item.sensor)) as! String)
            break
        } // switch item.sensor
        
        return nil
    }

    
    
// MARK: - NSTableViewDataSource
    
    func numberOfRows(in tableView: NSTableView) -> Int {
//        if sensorSource.count < 1 {
//            return 1 // 要插入一个提示Cell
//        }
        return sensorSource.count
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
//        return NSTextFieldCell(textCell: rowCellArray[row])
//        var _cell = tableView.make(withIdentifier: "SensorInBarCell", owner: self)
        return sensorSource[row]
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
//        if sensorSource.count < 1 {
//            let cell = tableView.make(withIdentifier: "EmptyInMenuCell", owner: self)
//            return cell
//        }
    
        return makeCell(withIndex: row)
    }
}
