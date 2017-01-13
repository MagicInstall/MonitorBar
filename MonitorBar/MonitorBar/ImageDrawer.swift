//
//  MonitorBar
//  ImageDrawer.swift
//
//  Created by wing on 2017/1/9.
//  Copyright © 2016 Magic Install. All rights reserved.
//

import Cocoa

/// 提供从外部修改NSImage 内容的方法协议
@objc protocol ImageDrawerDelegate {
    /// 该方法用于实现绘制NSImage 前后, 切换Context 等逻辑,
    /// 并不执行实际绘图过程,
    /// 绘图过程由drawingFunc 参数提供的方法实行.
    ///
    /// - Parameter drawingFunc: 在切换Context 等逻辑的过程中, 
    ///                          轮到需要实际绘图的时候调用该方法.
    @objc optional func draw(drawingFunc: (_ rect: CGRect)->())
    
    
    /// 该方法被draw(drawingFunc:)->() 方法调用,
    /// 实现具体的绘图过程;
    /// 在进入该方法的时候, Context 已经在相应的Image 内.
    ///
    /// - Parameter rect: 相应Image 的绘图区域.
    @objc optional func drawingFunc(inRect rect: CGRect)
}

