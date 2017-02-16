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
    static func noIconHasKeyItemDraw(_ item: statusBarItem, inColumnRect columnRect: CGRect) {
        // 测试用
//        let style = NSMutableParagraphStyle()
//        style.alignment = NSTextAlignment.right
//        style.lineSpacing = CGFloat(lineSpacing)
//        style.paragraphSpacing = CGFloat(lineSpacing)
        
        
        var str: String? = nil
        var sensor: Sensor? = nil
        let key: String? = item.contents[StatusBarLayout.ITEM_CONTENTS_KEY_SENSOR_KEYS] as? String
//        let hasUnit:Bool = (item.contents[StatusBarLayout.ITEM_CONTENTS_KEY_APPED_UNIT] != nil) && (item.contents[StatusBarLayout.ITEM_CONTENTS_KEY_APPED_UNIT] as? String == "1")
        if key != nil {
            // 取值
            sensor  = item.contents[key!]  as? Sensor
            if sensor != nil {

                // TODO: 增加需要格式化输出的传感器...
                switch sensor {
                case is TemperatureSensor:
                    str = "\(sensor!.numericValue.uintValue)\(sensor!.unit)"
                    break
                    
                case is NetworkSensor, is StorageSensor, is MemorySensor:
                    str = // "\(sensor!.numericValue.uintValue)\(sensor!.unit)"
                        DigitFormatter.to4Digit(
                            fromDouble: sensor!.numericValue.doubleValue,
                            unit:       sensor!.unit
                    )
                    break

                // 通用格式
                default:
                    str = "\(sensor!.numericValue.uintValue)"
                }
                

            } else {
                str = key!
            }
        } else {
            str = "囧..."
        }
        
        // 取得整个元件的绝对座标
        let alignedRect = item.rect.convertToLayouted(inColumnRect: columnRect, withAlign: item.alignment)
        let fontAttr = StatusBarDrawer.fontAttribute()
        str!.draw(in: alignedRect, withAttributes: fontAttr)
//        str!.draw(in: CGRect(x: 0.0, y:0.0, width:50, height:50), withAttributes: fontAttr)
        
//        if true {
//            // 测试框
//            let rectanglePath = NSBezierPath(rect: alignedRect)
//            rectanglePath.lineWidth = 0.5
//            NSColor.red.setStroke()
//            rectanglePath.stroke()
//    
//            fontAttr[NSForegroundColorAttributeName] = NSColor.red
//            alignedRect.debugDescription.draw(in: NSMakeRect(alignedRect.origin.x - 210.0, alignedRect.origin.y - 4, 200, 22.0), withAttributes: fontAttr)
//        }
    }
    
    /// 没有icon 也没有key 的元件通用绘制方法
    static func noIconNoKeyItemDraw(_ item: statusBarItem, inColumnRect columnRect: CGRect) {

        var text = item.contents[StatusBarLayout.ITEM_CONTENTS_KEY_XML_TEXT] as? String
        // 睇下有冇对应本地化字符串
        text = NSLocalizedString((text != nil ? text! : "囧..."), comment: "xml text");
        
        let alignedRect = item.rect.convertToLayouted(inColumnRect: columnRect, withAlign: item.alignment)
        let fontAttr = StatusBarDrawer.fontAttribute()
        text!.draw(in: alignedRect, withAttributes: fontAttr)
    }
    
    /// 使用静态图像的元件通用绘制方法
    static func staticIconDraw(_ item: statusBarItem, inColumnRect columnRect: CGRect) {
        // 取得整个元件的绝对座标
        var alignedRect = item.rect.convertToLayouted(inColumnRect: columnRect, withAlign: item.alignment)
        
        let nsImage = item.contents[StatusBarLayout.ITEM_CONTENTS_KEY_ICON_INSTANCE] as? NSImage
        if nsImage == nil {
            assertionFailure("囧...")
            return
        }
        
        // 本绘制方法的基准值
        let originalWidth : CGFloat = nsImage!.size.width
        let originalHeight: CGFloat = nsImage!.size.height
        
        // 缩放比, 以高度为基准计算
        let scaling = alignedRect.height / originalHeight
        
        // 再将图标对齐一次
        alignedRect = CGRect(x: 0.0, y: 0.0, width: originalWidth * scaling, height: originalHeight * scaling).convertToLayouted(inColumnRect: alignedRect, withAlign: .alignToCenter)
        
        // 变换
        let context = NSGraphicsContext.current()!.cgContext
        NSGraphicsContext.saveGraphicsState()
        context.translateBy(x: alignedRect.x, y: alignedRect.y)
//        context.scaleBy(x: scaling, y: scaling)
        
        nsImage!.draw(in: alignedRect)
        
        // 还原变换
        NSGraphicsContext.restoreGraphicsState()
    }
    
    
    
// MARK: -
    
    /// 取得可用的动态Icon 名, 以及对应的绘制方法指针.
    static let effectiveImage: [String : Any] = [
        "m2SSD"     : StatusBarDrawer.drawM2SSD,
        "upArrow"   : StatusBarDrawer.drawUpArrow,
        "downArrow" : StatusBarDrawer.drawDownArrow,
        "pieCpuMem" : StatusBarDrawer.drawCPUMemoryPie,
    ]
    
    
    
// MARK: - 对应effectiveImage 的绘制方法
// TODO: 需要将下面的方法对应的key手动添加至effectiveImage...
    
    
    /// 画动态SSD 图标
    static func drawM2SSD(_ item: statusBarItem, inColumnRect columnRect: CGRect) {
        // 取得整个元件的绝对座标
        var alignedRect = item.rect.convertToLayouted(inColumnRect: columnRect, withAlign: item.alignment)
        
        // 本绘制方法的基准值
        let originalWidth : CGFloat = 8.0
        let originalHeight: CGFloat = 19.0
        
        // 缩放比, 以高度为基准计算
        let scaling = alignedRect.height / originalHeight
        
        // 再将图标对齐一次
        alignedRect = CGRect(x: 0.0, y: 0.0, width: originalWidth * scaling, height: originalHeight * scaling).convertToLayouted(inColumnRect: alignedRect, withAlign: .alignToCenter)
        
//        // 修正宽高比
//        let fixedWidth  = originalWidth * scaling // rect.width  - fmod(rect.width,  originalWidth)
//        let fixedHeight = alignedRect.height // - fmod(rect.height, originalHeight)
//        
//
//        let fixedRect = CGRect(x: alignedRect.left, y: alignedRect.top, width: fixedWidth, height: fixedHeight)
        
        // 取值
        let readSensor  = item.contents[StorageSensor.storage_GLOBAL_DATA_READ_SPEED_KEY()]  as? StorageSensor
        let writeSensor = item.contents[StorageSensor.storage_GLOBAL_DATA_WRITE_SPEED_KEY()] as? StorageSensor
        
        // 颜色
        let pcbColor   = NSColor.statusBarTextEnable
        let readColor  = NSColor.m2SSDRead.withAlphaComponent(CGFloat(readSensor?.numericValue ?? 50_000_000.0) / 100_000_000.0)
        let writeColor = NSColor.m2SSDwrite.withAlphaComponent(CGFloat(writeSensor?.numericValue ?? 50_000_000.0) / 100_000_000.0)

        // 变换
        let context = NSGraphicsContext.current()!.cgContext
        NSGraphicsContext.saveGraphicsState()
        context.translateBy(x: alignedRect.x, y: alignedRect.y)
        context.scaleBy(x: scaling, y: scaling)
        
        //// pcb Drawing
        let pcbPath = NSBezierPath()
        pcbPath.move(to: NSPoint(x: 8, y: 1))
        pcbPath.line(to: NSPoint(x: 8, y: 16))
        pcbPath.curve(to: NSPoint(x: 7, y: 17), controlPoint1: NSPoint(x: 8, y: 16.55), controlPoint2: NSPoint(x: 7.55, y: 17))
        pcbPath.curve(to: NSPoint(x: 7, y: 18.5), controlPoint1: NSPoint(x: 7, y: 17.81), controlPoint2: NSPoint(x: 7, y: 18.5))
        pcbPath.line(to: NSPoint(x: 3, y: 18.5))
        pcbPath.curve(to: NSPoint(x: 3, y: 17), controlPoint1: NSPoint(x: 3, y: 18.5), controlPoint2: NSPoint(x: 3, y: 17.81))
        pcbPath.curve(to: NSPoint(x: 2.5, y: 17), controlPoint1: NSPoint(x: 3, y: 17), controlPoint2: NSPoint(x: 2.79, y: 17))
        pcbPath.curve(to: NSPoint(x: 2.5, y: 18.5), controlPoint1: NSPoint(x: 2.5, y: 17.81), controlPoint2: NSPoint(x: 2.5, y: 18.5))
        pcbPath.line(to: NSPoint(x: 1, y: 18.5))
        pcbPath.curve(to: NSPoint(x: 1, y: 17), controlPoint1: NSPoint(x: 1, y: 18.5), controlPoint2: NSPoint(x: 1, y: 17.81))
        pcbPath.curve(to: NSPoint(x: 0, y: 16), controlPoint1: NSPoint(x: 0.45, y: 17), controlPoint2: NSPoint(x: -0, y: 16.55))
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
        pcbColor.setFill()
        pcbPath.fill()
        
        //// read Drawing
        let readPath = NSBezierPath(roundedRect: NSRect(x: 1, y: 4, width: 6, height: 4), xRadius: 1, yRadius: 1)
        readColor.setFill()
        readPath.fill()
        
        //// write Drawing
        let writePath = NSBezierPath(roundedRect: NSRect(x: 1, y: 10, width: 6, height: 4), xRadius: 1, yRadius: 1)
        writeColor.setFill()
        writePath.fill()
        
        
//        if false {
//            // 测试框
//            let rectanglePath = NSBezierPath(rect: fixedRect)
//            rectanglePath.lineWidth = 0.5
//            NSColor.red.setStroke()
//            rectanglePath.stroke()
//            
//            let style = NSMutableParagraphStyle()
//            style.alignment = NSTextAlignment.right
//            //        style.lineSpacing = CGFloat(lineSpacing)
//            //        style.paragraphSpacing = CGFloat(lineSpacing)
//            var fontAttr = [
//                NSFontAttributeName: NSFont(name: "PingFangSC-Medium", size: 9)!,
//                NSForegroundColorAttributeName: NSColor(calibratedRed: 0.211, green: 0.211, blue: 0.211, alpha: 1),
//                NSParagraphStyleAttributeName: style
//                ] as [String : Any]
//            
//            fontAttr[NSForegroundColorAttributeName] = NSColor.red
//            fixedRect.debugDescription.draw(in: NSMakeRect(fixedRect.origin.x - 210.0, -4, 200, 22.0), withAttributes: fontAttr)
//        }
        
        // 还原变换
        NSGraphicsContext.restoreGraphicsState()
    }
    
    
    
    /// 画向上箭头
    static func drawUpArrow(_ item: statusBarItem, inColumnRect columnRect: CGRect) {
        // 取得整个元件的绝对座标
        var alignedRect = item.rect.convertToLayouted(inColumnRect: columnRect, withAlign: item.alignment)
        
        // 本绘制方法的基准值
        let originalWidth : CGFloat = 10
        let originalHeight: CGFloat = 10
        
        // 缩放比, 以高度为基准计算
        let scaling = alignedRect.height / originalHeight
        
        // 再将图标对齐一次
        alignedRect = CGRect(x: 0.0, y: 0.0, width: originalWidth * scaling, height: originalHeight * scaling).convertToLayouted(inColumnRect: alignedRect, withAlign: .alignToCenter)
        
        // 变换
        let context = NSGraphicsContext.current()!.cgContext
        NSGraphicsContext.saveGraphicsState()
        context.translateBy(x: alignedRect.x, y: alignedRect.y)
        context.scaleBy(x: scaling, y: scaling)
        
        NSColor.statusBarTextEnable.setStroke()
        
        //// Bezier Drawing
        let bezierPath = NSBezierPath()
        bezierPath.move(to: NSPoint(x: 5, y: 2))
        bezierPath.line(to: NSPoint(x: 5, y: 9.5))
        bezierPath.line(to: NSPoint(x: 5, y: 2))
        bezierPath.close()
        bezierPath.lineWidth = 1
        bezierPath.lineCapStyle = .roundLineCapStyle
        bezierPath.stroke()
        
        
        //// Bezier 2 Drawing
        let bezier2Path = NSBezierPath()
        bezier2Path.move(to: NSPoint(x: 2.5, y: 3.5))
        bezier2Path.line(to: NSPoint(x: 5, y: 1))
        bezier2Path.line(to: NSPoint(x: 7.5, y: 3.5))
        bezier2Path.lineWidth = 1
        bezier2Path.lineCapStyle = .roundLineCapStyle
        bezier2Path.stroke()
        
        // 还原变换
        NSGraphicsContext.restoreGraphicsState()
    }

    
    // 画向下箭头
    static func drawDownArrow(_ item: statusBarItem, inColumnRect columnRect: CGRect) {
        // 取得整个元件的绝对座标
        var alignedRect = item.rect.convertToLayouted(inColumnRect: columnRect, withAlign: item.alignment)
        
        // 本绘制方法的基准值
        let originalWidth : CGFloat = 10
        let originalHeight: CGFloat = 10
        
        // 缩放比, 以高度为基准计算
        let scaling = alignedRect.height / originalHeight
        
        // 再将图标对齐一次
        alignedRect = CGRect(x: 0.0, y: 0.0, width: originalWidth * scaling, height: originalHeight * scaling).convertToLayouted(inColumnRect: alignedRect, withAlign: .alignToCenter)
        
        // 变换
        let context = NSGraphicsContext.current()!.cgContext
        NSGraphicsContext.saveGraphicsState()
        context.translateBy(x: alignedRect.x, y: alignedRect.y)
        context.scaleBy(x: scaling, y: scaling)
     
        NSColor.statusBarTextEnable.setStroke()
        
        //// Bezier Drawing
        let bezierPath = NSBezierPath()
        bezierPath.move(to: NSPoint(x: 5, y: 8))
        bezierPath.line(to: NSPoint(x: 5, y: 0.5))
        bezierPath.line(to: NSPoint(x: 5, y: 8))
        bezierPath.close()
        bezierPath.lineWidth = 1
        bezierPath.lineCapStyle = .roundLineCapStyle
        bezierPath.stroke()
        
        
        //// Bezier 2 Drawing
        let bezier2Path = NSBezierPath()
        bezier2Path.move(to: NSPoint(x: 2.5, y: 6.5))
        bezier2Path.line(to: NSPoint(x: 5, y: 9))
        bezier2Path.line(to: NSPoint(x: 7.5, y: 6.5))
        bezier2Path.lineWidth = 1
        bezier2Path.lineCapStyle = .roundLineCapStyle
        bezier2Path.stroke()
        
        // 还原变换
        NSGraphicsContext.restoreGraphicsState()
    }
    
    
    
    // 画CPU + 内存一体的饼图
    static func drawCPUMemoryPie(_ item: statusBarItem, inColumnRect columnRect: CGRect) {
        // 取得整个元件的绝对座标
        var alignedRect = item.rect.convertToLayouted(inColumnRect: columnRect, withAlign: item.alignment)
        
        // 本绘制方法的基准值
        let originalWidth : CGFloat = 20.0
        let originalHeight: CGFloat = 20.0
        
        // 缩放比, 以高度为基准计算
        let scaling = alignedRect.height / originalHeight
        
        // 再将图标对齐一次
        alignedRect = CGRect(x: 0.0, y: 0.0, width: originalWidth * scaling, height: originalHeight * scaling).convertToLayouted(inColumnRect: alignedRect, withAlign: .alignToCenter)
        
        // 取值
        let freeSensor     = item.contents[MemorySensor.memory_FREE_KEY()] as? MemorySensor
        let inactiveSensor = item.contents[MemorySensor.memory_INACTIVE_KEY()] as? MemorySensor
        
        var freePercent: CGFloat = 0.6 // 0.6 是为IB 而设, 逻辑上应该是0
        if (freeSensor != nil) && (inactiveSensor != nil) {
            freePercent = 1.0 -/*画图需要反方向取值*/ CGFloat(freeSensor!.numericValue.floatValue + inactiveSensor!.numericValue.floatValue) / CGFloat(MemorySensor.getPhysicalTotal())
        }

        // 变换
        let context = NSGraphicsContext.current()!.cgContext
        NSGraphicsContext.saveGraphicsState()
        context.translateBy(x: alignedRect.x, y: alignedRect.y)
        context.scaleBy(x: scaling, y: scaling)
        
        // 画遮罩
        let clipPath = NSBezierPath(roundedRect: NSRect(x: 0, y: 0, width: 20, height: 20), xRadius: 3, yRadius: 3)
//        memoryPath.lineWidth = 0.5
//        NSColor.CPUMemoryBG.setStroke()
//        memoryPath.stroke() // 先画一次外框
        
        // 在遮罩中混合CPU 使用率
        clipPath.windingRule = .evenOddWindingRule
        
        // 添加留白路径...
        
        // TODO: 取当前CPU 使用率
        if true {
            
            var val: CGFloat
            for x in (0...13).reversed(){
                // TODO: 取值
                val = CGFloat(x)
                clipPath.appendRect(CGRect(x: 16.0 - CGFloat(x), y: 2.0 + val, width: 0.7, height: 16.0 - val))
            }
        }
        
        clipPath.addClip()
        
        
        // 填充空闲部分
        let freeRect = CGRect(x: -5, y: -5, width: 30, height: 30)
        let memFreePath = NSBezierPath()
        memFreePath.appendArc(
            withCenter: CGPoint(x: freeRect.midX, y: freeRect.midY),
            radius: freeRect.width / 2,
            startAngle: (360 * freePercent - 90),
            endAngle: -90,
            clockwise: false)
        memFreePath.line(to: CGPoint(x: freeRect.midX, y: freeRect.midY))
        memFreePath.close()
        
        NSColor.CPUMemory1.setFill()
        memFreePath.fill()
        
        // 填充使用部分
        let usageRect = CGRect(x: -5, y: -5, width: 30, height: 30)
        let memUsagePath = NSBezierPath()
        memUsagePath.appendArc(
            withCenter: CGPoint(x: usageRect.midX, y: usageRect.midY),
            radius: usageRect.width / 2,
            startAngle: -90,
            endAngle: (360 * freePercent - 90),
            clockwise: false)
        memUsagePath.line(to: CGPoint(x: usageRect.midX, y: usageRect.midY))
        memUsagePath.close()

        NSColor.statusBarTextEnable.setFill()
        memUsagePath.fill()
        
        // 还原变换
        NSGraphicsContext.restoreGraphicsState()
    }
}



