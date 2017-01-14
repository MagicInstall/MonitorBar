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
        <#code#>
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
        
    }
    
    func pushValue(_ value: NSNumber, atAbsoluteTime time: Double) {
        <#code#>
    }
    
}
