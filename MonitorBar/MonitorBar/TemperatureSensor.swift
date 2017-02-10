//
//  TemperatureSensor.swift
//  MonitorBar
//
//  Created by wing on 2016/12/31.
//  Copyright © 2016 Magic Install. All rights reserved.
//

import Cocoa

/// 提供温度相关读数
class TemperatureSensor: NSObject, Sensor {
    // CPU
    static let KEY_CPU_PACKAGE_TEMPERATURE           = "TCAD"
    
    // PECI
    static let KEY_PECI_GFX_TEMPERATURE              = "TCGc"  // SNB HD2/3000
    static let KEY_PECI_SA_TEMPERATURE               = "TCSc"  // SNB
    static let KEY_PECI_PACKAGE_TEMPERATURE          = "TCXc"  // SNB
    
    // HDD
    static let KEY_OPTICAL_DRIVE_TEMPERATURE         = "TO0P"
    
    // NorthBridge, MCH, MCP, PCH
    static let KEY_MCH_DIODE_TEMPERATURE             = "TN0C"
    static let KEY_MCH_HEATSINK_TEMPERATURE          = "TN0H"
    
    static let KEY_MCP_INTERNAL_DIE_TEMPERATURE      = "TN1D"
    static let KEY_MCP_PROXIMITY_TEMPERATURE         = "TM0P"
    
    static let KEY_PCH_DIE_TEMPERATURE               = "TP0D" // SNB PCH Die Digital
    static let KEY_PCH_PROXIMITY_TEMPERATURE         = "TP0P" // SNB
    
    static let KEY_MAINBOARD_TEMPERATURE             = "Tm0P" // MLB Proximity/DC In Proximity Airflow
    
    
// MARK: - 类变量
    private static var __sensors: [String: TemperatureSensor] = [:]
    
    
// MARK: - 类方法
    
    static func effectiveKeys() -> Set<String> {
        let keys = SmcHelper.listSMCKeys(prefix: UnicodeScalar("T"))
        return keys
    }
    
    static func buildSensors(fromKeys keys: Set<String>) -> [AnyHashable : Any]? {
        // 求交集
        let interKeys = keys.intersection(effectiveKeys())
        
        var result: [String: TemperatureSensor] = [:]
        for key in interKeys {
            
            if __sensors[key] == nil {
                // 创建一个新实例
                __sensors[key] = TemperatureSensor(withKey: key)
            }
            
            result[key] = __sensors[key]
        }
        if result.count < 1 {
            return nil
        }
        
        TemperatureSensor.update()
        
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
            case "sp78" /* TODO: 添加其它类型 */:
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
        // 温度传感器名比较麻烦
        switch key {
        // 固定字符的key
        case TemperatureSensor.KEY_CPU_PACKAGE_TEMPERATURE,
             TemperatureSensor.KEY_PECI_GFX_TEMPERATURE,
             TemperatureSensor.KEY_PECI_SA_TEMPERATURE,
             TemperatureSensor.KEY_PECI_PACKAGE_TEMPERATURE,
             TemperatureSensor.KEY_OPTICAL_DRIVE_TEMPERATURE,
             TemperatureSensor.KEY_MCH_DIODE_TEMPERATURE,
             TemperatureSensor.KEY_MCH_HEATSINK_TEMPERATURE,
             TemperatureSensor.KEY_MCP_INTERNAL_DIE_TEMPERATURE,
             TemperatureSensor.KEY_MCP_PROXIMITY_TEMPERATURE,
             TemperatureSensor.KEY_PCH_DIE_TEMPERATURE,
             TemperatureSensor.KEY_PCH_PROXIMITY_TEMPERATURE,
             TemperatureSensor.KEY_MAINBOARD_TEMPERATURE:
            
            _name = NSLocalizedString(key, comment: key)
            break
            
        // 有序号的key
        default:
            if key.characters.count != 4 {
                assertionFailure("囧...")
            }
            
            let index  = key[2].smcHexToInt().int
            let format = key[0] + key[1] + "%d" + key[3]
            _name      = String(format: NSLocalizedString(format, comment: format), index)
        }
        
        _description  = _name + NSLocalizedString("Temperatures", comment: "Temperatures")
        
        _key          = key
        _numericValue = NSNumber(value: 0.0);
        _unit         = NSLocalizedString("Unit_Temp", comment: "℃");
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
            return String(format: "%@(%@):%5.1f%@", _name, _key, _numericValue.floatValue, _unit);
        }
    }
    
}
