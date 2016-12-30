//
//  Sensor.swift
//  MonitorBar
//
//  Created by wing on 2016/12/20.
//  Copyright © 2016 Magic Install. All rights reserved.
//

import Cocoa

class Sensor: NSObject {
    // MARK: -
    // MARK: 属性
    
    /// 传感器显示的名称
    public var name : String?
    
    /// 传感器显示的描述
    override public var description: String {
        get {
            if (_description != nil) {
                return _description!
            }
            return ""
        }
        set(text) {
            _description = text
        }
    }
    private var _description : String?

    /// 传感器显示的数值
    public var value : String?
    
}
