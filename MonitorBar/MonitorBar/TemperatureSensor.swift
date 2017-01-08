//
//  TemperatureSensor.swift
//  MonitorBar
//
//  Created by wing on 2016/12/31.
//  Copyright © 2016 Magic Install. All rights reserved.
//

import Cocoa

class TemperatureSensor: NSTableCellView, Sensor {
//    init(key:String) {
////        self.key = key
//    }
    @IBOutlet weak var nameField: NSTextField!
    
    @IBOutlet weak var subTitleField: NSTextField?
    
    @IBOutlet weak var valueField: NSTextField!

   
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func effectiveKeys() -> Set<String> {
        return Set<String>()
    }
    
    static func buildSensors(fromKeys keys: Set<String>) -> [AnyHashable : Any]? {
        return nil
    }
    
    static func activeSensors() -> [AnyHashable : Any]? {
        return nil
    }
    
    static func activeSensors(withKey key: String) -> Sensor? {
        return nil
    }
    
    static func update() {
        
    }
    
    var name: String {
        get {
            return ""
        }
    }
    var key: String {
        get {
            return ""
        }
    }
    override var hash: Int {
        get {
            return 0
        }
    }
    override var description: String {
        get {
            return ""
        }
    }
    var unit: String = ""
    var numericValue: NSNumber = 0.0
    var history: HistoryValues
    
    func pushValue(_ value: NSNumber, atAbsoluteTime time: Double) {
    
    }
 
}
