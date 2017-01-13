//
//  MonitorBar
//  StatusBarDrawer.swift
//
//  Created by wing on 2017/1/9.
//  Copyright © 2016 Magic Install. All rights reserved.
//

import Cocoa
import CoreGraphics

/// 系统状态栏的高度
/// - 一般不要修改此值, 
/// 定义为变量是为了StatusBarDrawer.createStatusBarDrawer(toStatusItem:) 类方法可以修改此值
var SystemStatusBarHeight: CGFloat = 22

/// 目前只知道唯一能实时修改状态栏显示内容的方法就只有重绘NSStatusItem 中的Button 中的NSImage ,
/// 该类提供在NSImage 上绘图的基本方法.
class StatusBarDrawer: NSObject, ImageDrawerDelegate {
    
// MARK: - 属性
    
    /// 用于绘制的图像实例
    public var image: NSImage
    
    /// 绘图区域的大小
//    public var size: NSSize {
//        set(size) {
//            image.size = size
//        }
//        get {
//            return image.size
//        }
//    }
    
    public var length: CGFloat {
        set(value) {
            if value > 0.0 {
                image.size.width = value
            }
            else {
                image.size.width = SystemStatusBarHeight
                print("宽度设置为\(value) 会导致lockFocus() 异常!")
            }
        }
        get {
            return image.size.width
        }
    }
    
    
// MARK: - 实例方法

    
    init?(withStatusImage image: NSImage?) {
        if (image == nil) {
            return nil
        }
        self.image = image!
        
        super.init()
    }
    
    
    func draw(drawingFunc: (_ rect: CGRect) -> ()) {
        image.lockFocusFlipped(true)
        let size = image.size
        let rect = CGRect.init(x: 0.0, y: 0.0, width: size.width, height: size.width)
        
        // TODO: 清空image
        
        drawingFunc(rect)
        image.unlockFocus()
    }
    
    /// 本方法内部调用draw(drawingFunc:) 方法(是它的简化版),
    /// 在调用本方法前, 必须保证已使用setDrawingFunction(drawingFunc:) 方法指定了绘图函数!
    func draw() {
        draw(drawingFunc: _drawingFunction!)
    }
    
    /// 保存使用draw() 方法所必须的绘图方法
    private var _drawingFunction: ((CGRect)->())? = nil

    /// 为draw() 方法指定绘图函数
    ///
    /// - Parameter drawingFunc: 传入ImageDrawer 协议的drawingFunc(inRect rect:) 函数.
    func setDrawingFunction(drawingFunc: @escaping (_ rect: CGRect)->()) {
        _drawingFunction = drawingFunc
    }
    
    
// MARK: - 类方法

    /// 从系统提供的状态栏Item 生成一个StatusBarDrawer 实例,
    /// 并将该实例与状态栏Item 的image 关联.
    ///
    ///
    /// - Parameter item: <#item description#>
    /// - Returns: <#return value description#>
    static func createStatusBarDrawer(toStatusItem item: NSStatusItem) -> StatusBarDrawer? {
        var image = item.image
        if image == nil {
            let size = item.button!.frame.size
            
            // 顺便检测一下状态栏高度
            if size.height != SystemStatusBarHeight {
                SystemStatusBarHeight = size.height
                print("系统状态栏的高度变为:%.1f", SystemStatusBarHeight)
            }
            
            image = NSImage(size: size)
            item.image = image
            if item.image == nil {
                print("囧...")
                return nil
            }
//            image?.isTemplate = true
        }
        return StatusBarDrawer(withStatusImage: image!)
    }
    
// MARK: - 模块化绘图方法

    
    
    /// 画一个帮助定位的框架
    static func drawDebugFrame(inRect rect: CGRect, withColor color:NSColor) {
        color.setStroke()
        
        // 外框
        let rectanglePath = NSBezierPath(rect: rect)
        rectanglePath.lineWidth = 1
        rectanglePath.stroke()
        
        // 水平中线
        let bezierPath = NSBezierPath()
        bezierPath.move(to: NSPoint(x: rect.origin.x,              y: rect.origin.y + rect.height / 2))
        bezierPath.line(to: NSPoint(x: rect.origin.x + rect.width, y: rect.origin.y + rect.height / 2))
        bezierPath.lineWidth = 0.5
        bezierPath.stroke()
    }

}


// MARK: - 状态栏绘制的0座标是在右上角!
    
    /// 画SSD 图标
    ///
    ///
    /// - Parameters:
    ///   - rect:
    ///   - ssdColor: <#ssdColor description#>
    ///   - readColor: <#readColor description#>
    /// - Returns:     返回最终绘画的区域; 其中宽度是以高度为基准作调整.
//    static func drawSSD(inRect rect: CGRect,
//                        ssdColor: NSColor = lightThemeItemColor,
//                        readColor: NSColor = NSColor.clear,
//                        writeColor: NSColor = NSColor.clear) -> CGRect {
//        // 定义常量
////        let x                       = rect.origin.x
////        let y                       = rect.origin.y
//        let originalWidth : CGFloat = 8.0
//        let originalHeight: CGFloat = 20.0
//        
//        // 缩放比, 以高度为基准计算
//        let scaling = rect.height / originalHeight
//        
//        // 修正宽高比
//        let fixedWidth  = originalWidth * scaling // rect.width  - fmod(rect.width,  originalWidth)
//        let fixedHeight = rect.height // - fmod(rect.height, originalHeight)
//        let fixedRect = NSMakeRect(rect.left, rect.top, fixedWidth, fixedHeight)
//
//        
//        //// pin1 Drawing
//        let pin1Path = NSBezierPath(rect: CGRect(
//            x:      fixedRect.left + 1,
//            y:      fixedRect.top + 15.5,
//            width:  1.5 * scaling,
//            height: 4   * scaling))
//        ssdColor.setFill()
//        pin1Path.fill()
//        
//        //// pin2 Drawing
//        let pin2Path = NSBezierPath(rect: CGRect(x: 3, y: 15.5, width: 4, height: 4))
//        ssdColor.setFill()
//        pin2Path.fill()
//         
//        //// pcb Drawing
//        let pcbPath = NSBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 8, height: 18), xRadius: 1, yRadius: 1)
//        ssdColor.setFill()
//        pcbPath.fill()
//       
//        //// Oval Drawing
//        let ovalPath = NSBezierPath(ovalIn: CGRect(x: 2.5, y: -1.5, width: 3, height: 3))
//        NSColor.clear.setFill()
//        ovalPath.fill()
//        
//        //// read Drawing
//        let readPath = NSBezierPath(roundedRect: NSRect(x: 1, y: 4, width: 6, height: 4), xRadius: 1, yRadius: 1)
//        readColor.setFill()
//        readPath.fill()
//        
//        //// write Drawing
//        let writePath = NSBezierPath(roundedRect: NSRect(x: 1, y: 10, width: 6, height: 4), xRadius: 1, yRadius: 1)
//        writeColor.setFill()
//        writePath.fill()
//
//        
//        return fixedRect
//    }
//}


/// 提供状态栏布局与绘制所需的绘图区域结构体;
/// 此区域座标以右上角为0点
//struct StatusRect {
//    
//    /// 位置属性以右上角为原点
//    public var position: CGPoint = CGPoint(x: 0.0, y: 0.0)
//    
//    public var size: CGSize = CGSize(width: 0.0, height: 0.0)
//    
//    public init() {}
//    
//    public init(position: CGPoint, size: CGSize) {
//        self.position = position
//        self.size     = size
//    }
//    
//    public var x: CGFloat {
//        get {
//            return position.x
//        }
//        set(newValue) {
//            position.x = newValue
//        }
//    }
//    
//    public var y: CGFloat {
//        get {
//            return position.y
//        }
//        set(newValue) {
//            position.y = newValue
//        }
//    }
//    
//    public var width: CGFloat {
//        get {
//            return size.width
//        }
//        set(newValue) {
//            size.width = CGFloat(fabs(Double(newValue)))
//        }
//    }
//    
//    public var height: CGFloat {
//        get {
//            return size.height
//        }
//        set(newValue) {
//            size.height = CGFloat(fabs(Double(newValue)))
//        }
//    }}

//extension StatusRect {
////    init(top: CGFloat, left: CGFloat, bottom: CGFloat, rigth : CGFloat) {
////        <#statements#>
////    }
//    
//    public var top : CGFloat {
//        get {
//            if size.height < 0 {
//                return position.y + size.height
//            }
//            return position.y
//        }
//    }
//    
//    public var left : CGFloat {
//        get {
//            if size.width < 0 {
//                return position.x
//            }
//            return position.x - size.width
//        }
//    }
//    
//    public var bottom : CGFloat {
//        get {
//            if size.height < 0 {
//                return position.y
//            }
//            return position.y + size.height
//        }
//    }
//    
//    public var rigth : CGFloat {
//        get {
//            if size.width < 0 {
//                return position.x - size.width
//            }
//            return position.x
//        }
//    }
//}


//extension CGRect {
//    init(statusRect: StatusRect) {
//        self.size   = statusRect.size
//        self.origin = CGPoint(
//            x: statusRect.x - CGFloat(fabs(Double(statusRect.width))),
//            y: statusRect.y)
//    }
//}



