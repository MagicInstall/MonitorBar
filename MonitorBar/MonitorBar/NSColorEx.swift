//
//  MonitorBar
//  NSColorEx.swift
//
//  Created by wing on 2017/1/12.
//  Copyright © 2016 Magic Install. All rights reserved.
//

import Cocoa

/// 提供预设颜色
extension NSColor {
    
    
    /// 取得本app 全部预设颜色
    public static let defaults: [String : NSColor] = [
    
        "statusBarTextEnable" : statusBarTextEnable,
        
        
        "m2SSDRead"  : m2SSDRead,
        "m2SSDwrite" : m2SSDwrite,
        "cpuMen1"    : CPUMemory1,
    
    ]
    
    
    // TODO: 需要将下面的方法对应的key手动添加至defaults...
    
    /// 状态栏的深灰色
    public static let statusBarTextEnable: NSColor = NSColor(white: 0, alpha: 0.75)
    
    /// SSD 图标读取状态
    public static let m2SSDRead:  NSColor = NSColor(calibratedRed: 0.38, green: 0.88, blue: 1.0, alpha: 1)

    /// SSD 图标写入状态
    public static let m2SSDwrite: NSColor = NSColor(calibratedRed: 1.0, green: 0.58, blue: 0.99, alpha: 1)

    /// CPU+内存图标中最浅的灰色
    public static let CPUMemory1: NSColor = NSColor(white: 0, alpha: 0.30)
   
    
}
