//
//  MonitorBar
//  IBDrawingImageView.swift
//
//  Created by wing on 2017/1/9.
//  Copyright © 2016 Magic Install. All rights reserved.
//

import Cocoa

/// 该NSImageView 子类提供IB 上实时显示ImageDrawer 类的绘图结果.
/// 在IB 上拖出一个CustomView, 并将Class 指定为IBDrawingImageView 即可
@IBDesignable class IBDrawingImageView: NSView, ImageDrawerDelegate, StatusBarLayoutDelegate {


// MARK: - 属性
    var image: NSImage? = nil
    
    var _drawString: Bool = false
    @IBInspectable var drawString: Bool {
        set(value) {
            initShare()
            _drawString = value
        }
        get {
            return _drawString
        }
    }
    
    @IBInspectable var fontSize: Float  = 9.0 // Float(NSFont.systemFontSize(for: .mini))
    @IBInspectable var fontName: String = "PingFangSC-Medium" // NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .mini)).familyName!
    @IBInspectable var fontColor: NSColor = NSColor(calibratedRed: 0.211, green: 0.211, blue: 0.211, alpha: 1) // 官方颜色
    @IBInspectable var alignment: NSTextAlignment = NSTextAlignment.right
    @IBInspectable var fixStringY: Float = 4.0
    @IBInspectable var lineSpacing: Float = 0.0

//    @IBInspectable var font = [NSFontAttributeName: NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .mini))]
    
    
    var _drawLayout: Bool = false
    @IBInspectable var drawLayout: Bool {
        set(value) {
            initShare()
            _drawLayout = value
        }
        get {
            return _drawLayout
        }
    }
    
    var _drawDebugFrame: Bool = false
    @IBInspectable var drawDebugFrame: Bool {
        set(value) {
            initShare()
            _drawDebugFrame = value
        }
        get {
            return _drawDebugFrame
        }
    }
    
    var _drawDebugFrame2: Bool = false
    @IBInspectable var drawDebugFrame2: Bool {
        set(value) {
            initShare()
            _drawDebugFrame2 = value
        }
        get {
            return _drawDebugFrame2
        }
    }
    
    @IBInspectable var debugFrameColor : NSColor = NSColor.red
    
 
// MARK: - 实例方法
    
    /// 唔清楚IB 几时初始化, 每个setter 都要放一句...
    func initShare() {
        if image == nil {
            image = NSImage(size: NSMakeSize(100.0, 100.0))
        }
        
        if barLayout == nil {
            barLayout = StatusBarLayout()
            if barLayout == nil {
                assertionFailure("囧...")
            }
            barLayout!.loadLayout(withXmlString:
                "<layout>" +
                    "<column minLength=\"22\">" +
                        "<item keys=\"SGDR, SGDW\" icon=\"m2SSD\" align=\"center\" rect=\"0, 0, 8, 19\" />" +
                    "</column>" +
                    "<column minLength=\"24\">" +
                        "<item keys=\"TC0D\" align=\"topRight\" rect=\"0, -3, 24, 22\"></item>" +
                        "<item keys=\"TG0D\" align=\"topRight\" rect=\"0, 6, 24, 22\"></item>" +
                    "</column>" +
                    "<column minLength=\"26\">" +
                        "<item keys=\"F1Ac\" align=\"topRight\" rect=\"0, -3, 26, 22\" />" +
                        "<item keys=\"F2Ac\" align=\"topRight\" rect=\"0, 6, 26, 22\" />" +
                    "</column>" +
                    "<column minLength=\"48\">" +
                        "<item icon=\"upArrow\"  align=\"topLeft\" rect=\"2, 1, 10, 9\" />" +
                        "<item icon=\"downArrow\"  align=\"topLeft\" rect=\"2, 11, 10, 9\" />" +
                        "<item keys=\"NGDO\" align=\"topRight\" rect=\"0, -3, 40, 22\" />" +
                        "<item keys=\"NGDI\" align=\"topRight\" rect=\"0, 6, 40, 22\" />" +
                    "</column>" +
                    "<column minLength=\"26\">" +
                        "<item keys=\"UsMF, UsMI\" icon=\"pieCpuMem\" align=\"center\" rect=\"2, 0, 20, 20\" />" +
                    "</column>" +
                "</layout>",
                forDelegate: self)
        }
        
        if drawer == nil {
            drawer = StatusBarDrawer(withStatusImage: image)
            if drawer == nil {
                assertionFailure("囧...")
            }
            drawer?.setDrawingFunction(drawingFunc: drawingFunc)
        }
    }
    
    override func draw(_ dirtyRect: CGRect) {
        drawer?.draw(false)
        image?.draw(in: dirtyRect)
    }
    

    /// image 跟随View 的尺寸
    override var frame: CGRect {
        set(value){
            super.frame = value
        }
        get {
            // 貌似只有哩度系每次喺IB调大小都会经过的
            image?.size = super.frame.size
            return super.frame
        }
    }


// MARK: - StatusBarDrawer, ImageDrawer
    var drawer: StatusBarDrawer? = nil
    
    func drawingFunc(inRect rect: CGRect) {
        // 测试用的定位框架
        if _drawDebugFrame {
            StatusBarDrawer.drawDebugFrame(inRect: rect, withColor: debugFrameColor)
        }

        // 定义字体
        let style = NSMutableParagraphStyle()
        style.alignment = alignment
        style.lineSpacing = CGFloat(lineSpacing)
        style.paragraphSpacing = CGFloat(lineSpacing)
        var fontAttr = [
            NSFontAttributeName: NSFont(name: fontName, size: CGFloat(fontSize))!,
            NSForegroundColorAttributeName: fontColor,
            NSParagraphStyleAttributeName: style
            ] as [String : Any]
        
        // 画布局
        if _drawLayout {
            barLayout!.draw(inRect: self.frame)
        }
        
        
        // 字符串
        if _drawString {
           
//            "987654321234℃56↑71.9MB/s\n↓1.27KB/s".draw(in: rect.offsetBy(dx: 0.0, dy: rect.origin.y - CGFloat(fixStringY)), withAttributes: fontAttr)
            var stringRect = rect.offsetBy(dx: 0.0, dy: rect.origin.y - CGFloat(fixStringY))
            stringRect.size.height = 34
            
            "987654321234℃56↑71.9MB/s\n↓1.27KB/s".draw(in: stringRect, withAttributes: fontAttr)
            
            style.alignment = .left
            "987654321234℉56↓1.27KB/s".draw(in: rect.offsetBy(dx: 0.0, dy: rect.origin.y + (rect.height / 2) - CGFloat(fixStringY)), withAttributes: fontAttr)
            
            let option = NSStringDrawingOptions.usesLineFragmentOrigin
            let strRect:CGRect = "987654321234℃56↑71.9MB/s\n↓1.27KB/s".boundingRect(with: rect.size, options: option, attributes: fontAttr, context: nil)
            fontAttr[NSForegroundColorAttributeName] = NSColor.red
            //        CGRect(dictionaryRepresentation: strRect)
            strRect.debugDescription.draw(in: rect.offsetBy(dx: 0.0, dy: rect.origin.y - CGFloat(fixStringY)), withAttributes: fontAttr)
        }
        
        // SSD
//        if _drawSsdIcon {
//            let icoRect = StatusBarDrawer.drawSSD(inRect: NSMakeRect(150.0, 1.0, 10, 20))
//            
//            if _drawDebugFrame2 {
//                // 测试框
//                let rectanglePath = NSBezierPath(rect: icoRect)
//                rectanglePath.lineWidth = 0.5
//                NSColor.red.setStroke()
//                rectanglePath.stroke()
//                
//                fontAttr[NSForegroundColorAttributeName] = NSColor.red
//                icoRect.debugDescription.draw(in: NSMakeRect(icoRect.origin.x - 210.0, -CGFloat(fixStringY), 200, 22.0), withAttributes: fontAttr)
//            }
//        }
    }
    
// MARK: - StatusBarLayout
    
    
    /// 状态栏布局器
    var barLayout: StatusBarLayout? = nil
    
    /// 图标资源的实例用字典保存,
    /// 用资源名作为key, 便于查找.
    ///
    /// 不要用Assets 中的资源名覆盖掉effectiveImage 中的方法指针,
    /// 否则只能输出静态图像.
    var iconResouces: [String : Any] = StatusBarDrawer.effectiveImage
    
    
    /// 将元件(statusBarItem) 的draw() 方法关联至对应的StatusBarDrawer 方法
    /// 取icon
    ///    └	有icon
    ///             └	动态icon
    ///                   └	动态icon	查 [icon name: func]
    ///                 静态icon
    ///                   └	直接image.draw
    ///         冇icon
    ///             └	有key
    ///                   └	[key : sensor] 读NSNumber 值
    ///                             └	格式化后draw
    ///                 冇key
    ///                   └	读comment	直接draw
    func setupItemsDrawFunc() {
        for column in barLayout!.columns {
            for var item in column.items {
                // 载入图像资源
                let imageName:String? = item.contents[StatusBarLayout.ITEM_CONTENTS_KEY_ICON_NAME] as! String?
                var hasIcon = (imageName != nil) // 先用是否设置了iconName 属性判断
                
                // 进一步判断该iconName 是否可用
                if hasIcon {
                    let icon = self.iconResouces[imageName!]
                    
                    // 有icon:
                    if (icon != nil) {
                        switch icon {
                        // 静态icon
                        case is NSImage:
                            item.contents[StatusBarLayout.ITEM_CONTENTS_KEY_ICON_INSTANCE] = icon!
                            item.draw = StatusBarDrawer.staticIconDraw
                            hasIcon = true
                            break // 暂不要写直接 continue
                            
                        // 动态icon
                        case is ((_ item: statusBarItem, _ columnRect: CGRect) -> ()):
                            let namedRes = NSImage(named: imageName!)
                            if namedRes != nil {
                                // 可以使用静态icon + 动态draw 的方式呈现!
                                // - 貌似IB 系取唔到Assets 的...
                                item.contents[StatusBarLayout.ITEM_CONTENTS_KEY_ICON_INSTANCE] = namedRes!
                            }
                            // 指定相应的绘制方法
                            item.draw = iconResouces[imageName!] as? ((statusBarItem, CGRect) -> ())
                            hasIcon   = true
                            break // 暂不要写直接 continue
                            
                        default:
                            hasIcon = false
                        }
                    }
                }
                
                // 冇icon
                if hasIcon != true {
                    // 注: 如果元件的imageName 在iconResouces 中没有对应, 亦会进这里!
                    
                    // 有key
                    if item.contents[StatusBarLayout.ITEM_CONTENTS_KEY_SENSOR_KEYS]  != nil {
                        item.draw = StatusBarDrawer.noIconHasKeyItemDraw
                    }
                        // 冇key
                    else {
                        item.draw = StatusBarDrawer.noIconNoKeyItemDraw
                    }
                }
            } // for item
        } // for column
    }
    
    
// MARK: - StatusBarLayoutDelegate
    
    func onFindItemFromXml(attributes attributeDict: [String : String]) -> statusBarItem? {
        return nil
    }
    func onLoadedFromXml(withItem item: statusBarItem) {
    }
    func onLoadedFromXml(withLayout layout: StatusBarLayout) {
        setupItemsDrawFunc()
    }
    func onLayouted(_ sender: StatusBarLayout) {
    }

}
