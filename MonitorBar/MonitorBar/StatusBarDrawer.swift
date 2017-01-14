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
        let context = NSGraphicsContext.current()!.cgContext
        NSGraphicsContext.saveGraphicsState()
        context.clear(rect)
        
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



