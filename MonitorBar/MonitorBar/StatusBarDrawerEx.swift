//
//  MonitorBar
//  StatusBarDrawerEx.swift
//
//  Created by wing on 2017/1/11.
//  Copyright © 2016 Magic Install. All rights reserved.
//

import Cocoa

/// 将StatusBarDrawer 中的绘图方法分离至此文件
extension StatusBarDrawer {
    
    
    /// 取得白底状态栏上默认的元件颜色
    static let lightThemeItemColor = NSColor(calibratedRed: 0.211, green: 0.211, blue: 0.211, alpha: 1)
    
  
// MARK: - 通用绘制方法

    /// 没有icon 有key 的元件通用绘制方法
    ///
    /// - Parameter sender: <#sender description#>
    static func noIconHasKeyItemDraw(_ item: statusBarItem, inColumnRect columnRect: CGRect) {
        // 测试用
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.right
//        style.lineSpacing = CGFloat(lineSpacing)
//        style.paragraphSpacing = CGFloat(lineSpacing)
        let fontAttr = [
            NSFontAttributeName: NSFont(name: "PingFangSC-Medium", size: 9)!,
            NSForegroundColorAttributeName: NSColor(calibratedRed: 0.211, green: 0.211, blue: 0.211, alpha: 1),
            NSParagraphStyleAttributeName: style
            ] as [String : Any]
        
        let str: String? = item.contents[StatusBarLayout.ITEM_CONTENTS_KEY_SENSOR_KEYS] as? String
        if str != nil {
            str!.draw(in: item.rect, withAttributes: fontAttr)
        }
    }
    
    /// 没有icon 也没有key 的元件通用绘制方法
    ///
    /// - Parameter sender: <#sender description#>
    static func noIconNoKeyItemDraw(_ item: statusBarItem, inColumnRect columnRect: CGRect) {
        // 测试用
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.right
        //        style.lineSpacing = CGFloat(lineSpacing)
        //        style.paragraphSpacing = CGFloat(lineSpacing)
        let fontAttr = [
            NSFontAttributeName: NSFont(name: "PingFangSC-Medium", size: 9)!,
            NSForegroundColorAttributeName: NSColor(calibratedRed: 0.211, green: 0.211, blue: 0.211, alpha: 1),
            NSParagraphStyleAttributeName: style
            ] as [String : Any]
        
        let str: String? = item.contents[StatusBarLayout.ITEM_CONTENTS_KEY_XML_TEXT] as? String
        if str != nil {
            str!.draw(in: item.rect, withAttributes: fontAttr)
        }
    }
    
    /// 使用静态图像的元件通用绘制方法
    ///
    /// - Parameter sender: <#sender description#>
    static func staticIconDraw(_ item: statusBarItem, inColumnRect columnRect: CGRect) {
        
        
    }
    
    
    
// MARK: -
    
    /// 取得可用的动态Icon 名, 以及对应的绘制方法指针.
    static let effectiveImage: [String : Any] = [
        "m2SSD" : StatusBarDrawer.drawM2SSD
    ]
    
    
    
// MARK: - 对应effectiveImage 的绘制方法
// TODO: 需要将下面的方法对应的key手动添加至effectiveImage...
    
    
    /// 画动态SSD 图标
    static func drawM2SSD(_ item: statusBarItem, inColumnRect columnRect: CGRect) {
        // 取得整个元件的绝对座标
        var alignedRect = item.rect.convertToLayouted(inColumnRect: columnRect, withAlign: item.alignment)
        
        // 本绘制方法的基准值
        let originalWidth : CGFloat = 8.0
        let originalHeight: CGFloat = 20.0
        
        // 再将图标对齐一次
        alignedRect = CGRect(x: 0.0, y: 0.0, width: originalWidth, height: originalHeight).convertToLayouted(inColumnRect: alignedRect, withAlign: item.alignment)
        
        // 缩放比, 以高度为基准计算
        let scaling = alignedRect.height / originalHeight
        
        // 修正宽高比
        let fixedWidth  = originalWidth * scaling // rect.width  - fmod(rect.width,  originalWidth)
        let fixedHeight = alignedRect.height // - fmod(rect.height, originalHeight)
        

        let fixedRect = CGRect(x: alignedRect.left, y: alignedRect.top, width: fixedWidth, height: fixedHeight)
        
        // 取值
        let readSensor  = item.contents[StorageSensor.storage_GLOBAL_DATA_READ_SPEED_KEY()]  as? StorageSensor
        let writeSensor = item.contents[StorageSensor.storage_GLOBAL_DATA_WRITE_SPEED_KEY()] as? StorageSensor
        
        // 颜色
        let ssdColor   = NSColor.statusBarEnable
        let readColor  = NSColor.m2SSDRead.withAlphaComponent(CGFloat(readSensor?.numericValue ?? 50_000_000.0) / 100_000_000.0)
        let writeColor = NSColor.m2SSDwrite.withAlphaComponent(CGFloat(writeSensor?.numericValue ?? 50_000_000.0) / 100_000_000.0)

        // 缩放
        let context = NSGraphicsContext.current()!.cgContext
        NSGraphicsContext.saveGraphicsState()
        context.translateBy(x: alignedRect.x, y: alignedRect.y)
        context.scaleBy(x: scaling, y: scaling)
        
        //// pcb Drawing
        let pcbPath = NSBezierPath()
        pcbPath.move(to: NSPoint(x: 8, y: 1))
        pcbPath.line(to: NSPoint(x: 8, y: 17))
        pcbPath.curve(to: NSPoint(x: 7, y: 18), controlPoint1: NSPoint(x: 8, y: 17.55), controlPoint2: NSPoint(x: 7.55, y: 18))
        pcbPath.curve(to: NSPoint(x: 7, y: 19.5), controlPoint1: NSPoint(x: 7, y: 18.81), controlPoint2: NSPoint(x: 7, y: 19.5))
        pcbPath.line(to: NSPoint(x: 3, y: 19.5))
        pcbPath.curve(to: NSPoint(x: 3, y: 18), controlPoint1: NSPoint(x: 3, y: 19.5), controlPoint2: NSPoint(x: 3, y: 18.81))
        pcbPath.curve(to: NSPoint(x: 2.5, y: 18), controlPoint1: NSPoint(x: 3, y: 18), controlPoint2: NSPoint(x: 2.79, y: 18))
        pcbPath.curve(to: NSPoint(x: 2.5, y: 19.5), controlPoint1: NSPoint(x: 2.5, y: 18.81), controlPoint2: NSPoint(x: 2.5, y: 19.5))
        pcbPath.line(to: NSPoint(x: 1, y: 19.5))
        pcbPath.curve(to: NSPoint(x: 1, y: 18), controlPoint1: NSPoint(x: 1, y: 19.5), controlPoint2: NSPoint(x: 1, y: 18.81))
        pcbPath.curve(to: NSPoint(x: 0, y: 17), controlPoint1: NSPoint(x: 0.45, y: 18), controlPoint2: NSPoint(x: -0, y: 17.55))
        pcbPath.line(to: NSPoint(x: 0, y: 1))
        pcbPath.curve(to: NSPoint(x: 0.45, y: 0.16), controlPoint1: NSPoint(x: 0.01, y: 0.64), controlPoint2: NSPoint(x: 0.19, y: 0.34))
        pcbPath.curve(to: NSPoint(x: 0.57, y: 0.1), controlPoint1: NSPoint(x: 0.49, y: 0.14), controlPoint2: NSPoint(x: 0.53, y: 0.12))
        pcbPath.curve(to: NSPoint(x: 1, y: 0), controlPoint1: NSPoint(x: 0.7, y: 0.04), controlPoint2: NSPoint(x: 0.84, y: 0))
        pcbPath.line(to: NSPoint(x: 3, y: 0))
        pcbPath.curve(to: NSPoint(x: 4, y: 1), controlPoint1: NSPoint(x: 3, y: 0.55), controlPoint2: NSPoint(x: 3.45, y: 1))
        pcbPath.curve(to: NSPoint(x: 5, y: 0), controlPoint1: NSPoint(x: 4.55, y: 1), controlPoint2: NSPoint(x: 5, y: 0.55))
        pcbPath.line(to: NSPoint(x: 7, y: 0))
        pcbPath.curve(to: NSPoint(x: 8, y: 1), controlPoint1: NSPoint(x: 7.55, y: 0), controlPoint2: NSPoint(x: 8, y: 0.45))
        pcbPath.close()
        pcbPath.move(to: NSPoint(x: 6, y: 4))
        pcbPath.line(to: NSPoint(x: 2, y: 4))
        pcbPath.curve(to: NSPoint(x: 1, y: 5), controlPoint1: NSPoint(x: 1.45, y: 4), controlPoint2: NSPoint(x: 1, y: 4.45))
        pcbPath.line(to: NSPoint(x: 1, y: 7))
        pcbPath.curve(to: NSPoint(x: 2, y: 8), controlPoint1: NSPoint(x: 1, y: 7.55), controlPoint2: NSPoint(x: 1.45, y: 8))
        pcbPath.line(to: NSPoint(x: 6, y: 8))
        pcbPath.curve(to: NSPoint(x: 7, y: 7), controlPoint1: NSPoint(x: 6.55, y: 8), controlPoint2: NSPoint(x: 7, y: 7.55))
        pcbPath.line(to: NSPoint(x: 7, y: 5))
        pcbPath.curve(to: NSPoint(x: 6, y: 4), controlPoint1: NSPoint(x: 7, y: 4.45), controlPoint2: NSPoint(x: 6.55, y: 4))
        pcbPath.close()
        pcbPath.move(to: NSPoint(x: 6, y: 10))
        pcbPath.line(to: NSPoint(x: 2, y: 10))
        pcbPath.curve(to: NSPoint(x: 1, y: 11), controlPoint1: NSPoint(x: 1.45, y: 10), controlPoint2: NSPoint(x: 1, y: 10.45))
        pcbPath.line(to: NSPoint(x: 1, y: 13))
        pcbPath.curve(to: NSPoint(x: 2, y: 14), controlPoint1: NSPoint(x: 1, y: 13.55), controlPoint2: NSPoint(x: 1.45, y: 14))
        pcbPath.line(to: NSPoint(x: 6, y: 14))
        pcbPath.curve(to: NSPoint(x: 7, y: 13), controlPoint1: NSPoint(x: 6.55, y: 14), controlPoint2: NSPoint(x: 7, y: 13.55))
        pcbPath.line(to: NSPoint(x: 7, y: 11))
        pcbPath.curve(to: NSPoint(x: 6, y: 10), controlPoint1: NSPoint(x: 7, y: 10.45), controlPoint2: NSPoint(x: 6.55, y: 10))
        pcbPath.close()
        ssdColor.setFill()
        pcbPath.fill()
        
        //// read Drawing
        let readPath = NSBezierPath(roundedRect: NSRect(x: 1, y: 4, width: 6, height: 4), xRadius: 1, yRadius: 1)
        readColor.setFill()
        readPath.fill()
        
        //// write Drawing
        let writePath = NSBezierPath(roundedRect: NSRect(x: 1, y: 10, width: 6, height: 4), xRadius: 1, yRadius: 1)
        writeColor.setFill()
        writePath.fill()
        
        
        if false {
            // 测试框
            let rectanglePath = NSBezierPath(rect: fixedRect)
            rectanglePath.lineWidth = 0.5
            NSColor.red.setStroke()
            rectanglePath.stroke()
            
            let style = NSMutableParagraphStyle()
            style.alignment = NSTextAlignment.right
            //        style.lineSpacing = CGFloat(lineSpacing)
            //        style.paragraphSpacing = CGFloat(lineSpacing)
            var fontAttr = [
                NSFontAttributeName: NSFont(name: "PingFangSC-Medium", size: 9)!,
                NSForegroundColorAttributeName: NSColor(calibratedRed: 0.211, green: 0.211, blue: 0.211, alpha: 1),
                NSParagraphStyleAttributeName: style
                ] as [String : Any]
            
            fontAttr[NSForegroundColorAttributeName] = NSColor.red
            fixedRect.debugDescription.draw(in: NSMakeRect(fixedRect.origin.x - 210.0, -4, 200, 22.0), withAttributes: fontAttr)
        }
        
        NSGraphicsContext.restoreGraphicsState()
    }
}



