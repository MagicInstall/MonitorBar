//
//  MonitorBar
//  SensorGroud.swift
//
//  Created by wing on 2017/1/8.
//  Copyright © 2016 Magic Install. All rights reserved.
//

import Cocoa

/// 简单存放分组名, 图标等属性的类
class SensorGroud: NSObject {
    init(withTitle title:String, icon:NSImage? = nil) {
        self.title = NSLocalizedString(title, comment: title)
        self.icon  = icon
    }
    
    public var title : String = NSLocalizedString("GRUOD", comment: "GRUOD")
    public var icon  : NSImage?
}
