//
//  MonitorBar
//  FanSensor.swift
//
//  Created by wing on 2017/1/14.
//  Copyright © 2016 Magic Install. All rights reserved.
//

import Cocoa

/// 提供风扇相关读数
class FanSensor: NSObject , Sensor {
    static let KEY_FAN_NUMBER        = "FNum"
    static let KEY_FAN_MANUAL        = "FS! "
    static let KEY_FORMAT_FAN_ID     = "F%XID"
    static let KEY_FORMAT_FAN_SPEED  = "F%XAc"
    static let KEY_FORMAT_FAN_MIN    = "F%XMn"
    static let KEY_FORMAT_FAN_MAX    = "F%XMx"
    static let KEY_FORMAT_FAN_TARGET = "F%XTg"
    
    
// MARK: - 类变量
    private static var __sensors: [String: FanSensor] = [:]
    
    
// MARK: - 类方法
    
    static func effectiveKeys() -> Set<String> {
        var resultKeys = Set<String>() // SmcHelper.listSMCKeys()
        let fanCount: UInt = UInt(SmcHelper.read(key: "FNum")?.getUInt32Value() ?? 0)
        for i in 0 ..< fanCount {
            resultKeys.insert(String(format: KEY_FORMAT_FAN_SPEED, i))
        }
        return resultKeys
    }
    
    static func buildSensors(fromKeys keys: Set<String>) -> [AnyHashable : Any]? {
        // 求交集
        let interKeys = keys.intersection(effectiveKeys())
        
        var result: [String: FanSensor] = [:]
        for key in interKeys {
            
            if __sensors[key] == nil {
                // 创建一个新实例
                __sensors[key] = FanSensor(withKey: key)
            }
            
            result[key] = __sensors[key]
        }
        if result.count < 1 {
            return nil
        }
        
        FanSensor.update()
        
        return result
    }
    
    static func activeSensors() -> [AnyHashable : Any]? {
        return __sensors
    }
    
    static func activeSensors(withKey key: String) -> Sensor? {
        return __sensors[key]
    }
    
    static func update() {
        for sensorKVC in __sensors {
            let smcValue = SmcHelper.read(key: sensorKVC.value.key)
            if (smcValue == nil) {
                assertionFailure("囧...")
            }
            switch smcValue!.dataType {
            case "fpe2" /* TODO: 添加其它类型 */:
                sensorKVC.value.pushValue(NSNumber(value: smcValue!.getFloat()))
                break
                
            default:
                assertionFailure("未支持该类型的值...")
            }
        }
    }
    
    
// MARK: - 属性
    
    private var _name: String
    var name: String {
        get {
            return _name
        }
    }
    
    private var _key: String
    var key: String {
        get {
            return _key
        }
    }
    
    private var _description: String
    override var description: String {
        get {
            return _description
        }
    }
    
    private var _unit: String
    var unit: String {
        get {
            return _unit
        }
    }
    
    private var _numericValue: NSNumber
    var numericValue: NSNumber {
        get {
            return _numericValue
        }
    }
    
    private var _history: HistoryValues // TODO: history
    var history: HistoryValues {
        get {
            return _history
        }
    }
    
    
// MARK: - 实例方法
    
    
    init?(withKey key: String) {
        let fanIndex = key[1].smcHexToInt().int
        let nameKey = String("F\(fanIndex)ID") // KEY_FORMAT_FAN_ID
        if nameKey == nil {
            assertionFailure("囧...")
        }
//        let nameKeyResult = SmcHelper.read(key: nameKey!)?.getStringValue()
        
        
        print(SmcHelper.read(key: nameKey!)?.getStringValue() ?? "\(nameKey) 读取出错")
        let format = "Fan%d"
        
        _name         = String(format: NSLocalizedString(format, comment: "Fan%d"), fanIndex)
        
        _description  = String(format: NSLocalizedString(format + DESCRIPTION_LOCALIZED_KEY_APPENDING_STRING, comment: "Fan%d_Description"), fanIndex)
        
        
        _key          = key
        _numericValue = NSNumber(value: 0.0);
        _unit         = NSLocalizedString("Unit_RPM", comment: "RPM");
        
        // TODO:
        _history = HistoryValues()
    }
    
    func pushValue(_ value: NSNumber, atAbsoluteTime time: Double = CFAbsoluteTimeGetCurrent()) {
        _numericValue = value
        
    }
    
    override var hash: Int {
        get {
            return _key.hash
        }
    }
    
    override var debugDescription: String {
        get {
            return String(format: "%@(%@):%10.3f%@", _name, _key, _numericValue.floatValue, _unit);
        }
    }
    
}
