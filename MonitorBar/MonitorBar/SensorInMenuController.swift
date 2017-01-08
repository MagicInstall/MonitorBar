//
//  MonitorBar
//  SensorInBarController.swift
//
//  Created by wing on 2016/12/19.
//  Copyright © 2016 Magic Install. All rights reserved.
//

import Cocoa

class SensorInMenuController: NSViewController , NSTableViewDelegate, NSTableViewDataSource {
    
// MARK: -
// MARK: 属性


    
// MARK: -
// MARK: 实例方法
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        print("init?(coder: NSCoder)")
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onSensorsUpdate(notification:)),
            name: NSNotification.Name(Updater.NOTIFICATION_UPDATER_SENSOERS_UPDATED),
            object: nil
        )
    }
    
    override func awakeFromNib() {
        print("SensorInMenuController awakeFromNib")
        showSensorsView()
    }
    
    override func loadView() {
        print("SensorInMenuController loadView")
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        print("SensorInMenuController viewWillAppear")
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        print("SensorInMenuController viewWillDisappear")
    }
    
    deinit {
        print("SensorInMenuController deinit")
    }
    
    
    /// 刷新通知回调
    @objc func onSensorsUpdate(notification:Notification) -> Void {
//        print("onSensorsUpdate")
//        showSensorsView()
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
//                sensorsRootItem.title = NSLocalizedString("Unit_Bytes_per_second", "B/s")
//            }
//        }
//    }
    
    /// 将占位模型替换为传感器列表模型
    func showSensorsView() {
        // 一. 载入出厂设置
        Preferences.initDefaults()
        let dictionary = UserDefaults.standard.dictionary(forKey: Preferences.IN_MENU_ITEMS) as? Dictionary<String, Array<String>>
        
        // 二. 枚举用户设置的传感器
        sensorArray.removeAll()
        let groudArray = dictionary?["Groud"]
        if (dictionary != nil) || (groudArray != nil) {
             for groud in groudArray! {
                let keyArray = dictionary?[groud]
                if (keyArray != nil) {
                    // 插入Groud cell
                    sensorArray.append((SensorGroud(withTitle: groud), nil))
                    print(groud)
                    keyEnum : for key in keyArray! {
                        switch groud {
                        // TODO: 加入其它传感器...
                        case "Storage":
                            let sensor = StorageSensor.activeSensors(withKey: key)
                            if (sensor == nil) { continue }
                            print("|- ", sensor!.name)
                            sensorArray.append((sensor!, nil))
                            break
                            
                        default:
                            break keyEnum;
                        }
                    }
                }
            }
        }
        
        sensorsRootItem.view = tableView;
        tableView.reloadData()
    }
    
    
    // MARK: -
    // MARK: NSViewController
    
//    override func viewDidLoad() {
//        print("viewDidLoad", terminator: " J\n")
//    }
    
    /// 测试用
    @IBAction func test1(_ sender: AnyObject) {
       
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
        
        StorageSensor.update()
        print(StorageSensor.activeSensors()!)
        
        
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
    
    
// MARK: -
// MARK: 管理传感器
    
    /// 传感器数组
    public var sensorArray = Array<(sensor:Any, control:Any?)>()
    
    /// 跟据sensorArray 的sensor 类类型创建TableCellView
    func makeCell(withIndex index: Int) -> NSView? {
        let item = sensorArray[index]
        
        switch item.sensor {
        case is SensorGroud:
            let groud = item.sensor as! SensorGroud
            
            let cell = tableView.make(withIdentifier: "GroudInMenuCell", owner: self) as! GroudInMenuCellView
            cell.titleField.stringValue = groud.title
            cell.imageView?.image       = groud.icon
            return cell
            
            
        // TODO: 加入其它传感器...
            
        case is StorageSensor:
            let sensor = item.sensor as! StorageSensor
            
            let cell = tableView.make(withIdentifier: "SensorInMenuCell", owner: self) as! SensorInMenuCellView
            cell.nameField.stringValue     = sensor.name
//            cell.valueField?.formatter   = DigitFormatter()
            cell.valueField.stringValue = DigitFormatter.to6Digit(
                fromDouble: sensor.numericValue.doubleValue,
                unit:       sensor.unit
            )
            
            sensorArray[index].control = cell.valueField
            return cell
            
        default:
            print(NSString(utf8String:object_getClassName(item.sensor)) ?? "??")
            break
        }
        
        return nil
    }
    
    func refreshCells() {
        for item in sensorArray {
            switch item.sensor {
            case is SensorGroud:
                break
                
            // TODO: 加入其它传感器...
                
            case is StorageSensor:
                let sensor = item.sensor as! Sensor
                print(sensor.name + String(sensor.numericValue.intValue))
                if item.control is NSTextField {
                    (item.control as! NSTextField).stringValue = DigitFormatter.to6Digit(
                        fromDouble: sensor.numericValue.doubleValue,
                        unit:       sensor.unit
                    )
                }
                else {
                    print(NSString(utf8String:object_getClassName(item.control ?? "")) ?? "??")
                }
                break
                
            default:
                print(NSString(utf8String:object_getClassName(item.sensor)) ?? "??")
                break
            }
        }
    }
    
    
// MARK: -
// MARK: NSTableViewDataSource
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if sensorArray.count < 1 {
            return 1 // 要插入一个提示Cell
        }
        return sensorArray.count
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
//        return NSTextFieldCell(textCell: rowCellArray[row])
//        var _cell = tableView.make(withIdentifier: "SensorInBarCell", owner: self)
        return sensorArray[row]
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if sensorArray.count < 1 {
            let cell = tableView.make(withIdentifier: "EmptyInMenuCell", owner: self)
            return cell
        }
        
        return makeCell(withIndex: row)
    }
}
