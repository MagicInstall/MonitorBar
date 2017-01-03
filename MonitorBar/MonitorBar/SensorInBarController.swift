//
//  SensorInBarController.swift
//  MonitorBar
//
//  Created by wing on 2016/12/19.
//  Copyright © 2016 Magic Install. All rights reserved.
//

import Cocoa

class SensorInBarController: NSViewController , NSTableViewDelegate, NSTableViewDataSource {
    
    /// 传感器数组
    public var sensorArray : [Sensor] = Array()
    
    
    /// 连接传感器列表在状态栏菜单中的占位模型
    @IBOutlet weak var sensorsRootItem: NSMenuItem!
    
    /// 连接用于替换占位模型的模型, 该模型不参与实际交互编程
    /// 可以将同一个模型同时连接到rootView 与tableView (如果rootView 就是tableView 的话)
    /// TODO: Found no sensor
    @IBOutlet weak var rootView: NSView!
    
    /// 连接传感器列表模型
    @IBOutlet weak var tableView: NSTableView!
    
    override func awakeFromNib() {
        print("awakeFromNib")
        /// TODO: 在新线程检测硬件
        showSensorsView()
        
        StorageSensor.buildSensors(fromKeys: StorageSensor.effectiveKeys())

    }
    
    /// 将占位模型替换为传感器列表模型
    func showSensorsView() {
        sensorsRootItem.view = tableView;
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
    // MARK: NSTableViewDataSource
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return sensorArray.count
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
//        return NSTextFieldCell(textCell: rowCellArray[row])
//        var _cell = tableView.make(withIdentifier: "SensorInBarCell", owner: self)
        return sensorArray[row]
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell : SensorInBarCell = tableView.make(withIdentifier: "SensorInBarCell", owner: self) as! SensorInBarCell
        cell.name.stringValue     = sensorArray[row].name
        cell.subTitle?.stringValue = sensorArray[row].description
// TODO: 改为格式化输出        cell.value.stringValue    = (sensorArray[row].stringValue)
        
        return cell
    }
}
