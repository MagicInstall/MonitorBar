//
//  MonitorBar
//  StatusBarLayout.swift
//
//  Created by wing on 2017/1/11.
//  Copyright © 2016 Magic Install. All rights reserved.
//

import Cocoa


protocol StatusBarLayoutDelegate {
    
    
// MARK: - statusBarItem 初始化接口

    
    /// StatusBarLayout 在载入预设布局后通知代理者
    ///
    /// - Parameter layout: 触发当前事件的StatusBarLayout 实例
    func onLoadedFromXml(withLayout layout: StatusBarLayout)
    
    
    /// 在StatusBarLayout 载入预设的XML布局时,
    /// 每遍历到一个<item> 标签, 就会调用本方法,
    /// 请求代理者提供一个由代理者自定义的状态栏元件,
    /// StatusBarLayout 将接收此元件用于以后的布局以及绘制等...
    ///
    /// - Parameter attributeDict: 当前<item> 标签中包含的全部属性.
    /// - Returns: 返回将要添加到StatusBarLayout 的元件;
    ///            若返回nil, StatusBarLayout 将自行创建一个默认的statusBarItem 实例.
    func onFindItemFromXml(attributes attributeDict: [String : String]) -> statusBarItem?
    
    
    /// 在StatusBarLayout 载入预设的XML布局时,
    ///
    /// 每遍历到一个</item> 标签, 就会调用本方法通知代理者.
    ///
    /// - Note:
    ///   statusBarItem 的draw 方法指针在默认的初始化过程中并不会对其进行设置,
    ///   而若该元件的draw方法为nil, 在绘制的时候只会被当作占位元件(其尺寸等属性可影响布局),
    ///   但并不会进行实际的绘制;
    ///   若要元件能够被显示, 就要在此事件中为元件指定其draw 方法.
    ///
    /// - Parameters:
    ///   - item: StatusBarLayout 在创建statusBarItem 实例时,
    ///           会将<item> 标签中除了align, rect 两个属性以外的其它标签属性全部以字典的方式
    ///           插入到statusBarItem 的contents 属性中,
    ///           代理者可以在此事件中进一步对元件进行各种设置.
    func onLoadedFromXml(withItem item:statusBarItem)
    /// - Returns: 返回一个Bool 值指示StatusBarLayout 是否需要为该元件指定一个默认的绘制方法.
    
    
    /// 在StatusBarLayout 重新布局之后通知代理者
    ///
    /// - Parameter sender: 触发当前事件的StatusBarLayout 实例
    func onLayouted(_ sender: StatusBarLayout)
}

// MARK: -  -

/// 提供状态栏专用的布局
///
/// - Note: 布局使用XML 格式:
/// - 最外层是plist 的STATUS_BAR_LAYOUT 键;
/// - column 布局排列是从右至左;
/// - item 无序排列, 布局是按对齐方式+绘图区域表示.
/// 
/// 参考:
///
///     <!-- column只有宽度(官方称为length )而没有高度, 高度永远是状态栏的高度. -->
///     <column minLength="50">
///         <item align="center" rect="0, 1, 100, 20" keys="SGDR, SGDW" icon="m2SSD" />
///     </column>
class StatusBarLayout: NSObject, XMLParserDelegate {
    
// MARK: - 类常量
    public static let ITEM_CONTENTS_KEY_ALIGN    = "align"
    public static let ITEM_CONTENTS_KEY_RECT     = "rect"
    public static let ITEM_CONTENTS_KEY_XML_TEXT = "xmlText"
    
    
// MARK: - 属性
    
    /// 列的闭包存放列宽及其中的元件,
    /// item 不能为nil, 没有item 可以用0个元素表示; 
    /// 空的列可以作为占位元件.
    public var columns: [(length: CGFloat, items: [statusBarItem])] = []
    
    
    /// 在调用layout() 后可从此属性读取当前整个布局的大小
    private var _layoutedSize: CGSize = CGSize.zero
    public var size: CGSize {
        get {
            return _layoutedSize
        }
    }

    
    /// StatusBarLayoutDelegate 接口的代理者
    var delegate: StatusBarLayoutDelegate? = nil


    
// MARK: - 实例方法
    
    /// 生成实例的同时载入用户设置的布局
//    override init() { // }(layoutForDelegate delegate: StatusBarLayoutDelegate? = nil) {
//        super.init()
//        
////        self.delegate = delegate
//        
//
//    }
    ///
    /// - Parameter delegate: StatusBarLayout 在载入元件的时候需要代理者提供一些自定义的设置
    ///                       (例如statusBarItem 的派生类).   
    
    /// 为IB 而做的初始化方法
//    init(withXmlString xmlString: String) {
//        super.init()
//        loadLayout(withXmlString: xmlString)
//    }
    
    
    /// 从偏好设置载入布局
    ///
    /// 在载入布局之后会自动调用layout() 刷新一次.
    ///
    /// - Parameter delegate: 载入XML 的时候会调用相应的代理方法,
    ///                       若已经设置过代理者引用, 可以使用默认nil,
    ///                       传入nil 时并不会将原有的代理者清除.
    func loadLayout(forDelegate delegate: StatusBarLayoutDelegate? = nil) {
        if delegate != nil {
            self.delegate = delegate

        }
        
        // 载入布局配置
        Preferences.initDefaults()
        var xmlString = UserDefaults.standard.string(forKey: Preferences.STATUS_BAR_LAYOUT)
        if xmlString == nil {
            // 默认的布局只显示一个App Icon
            xmlString =
                "<column minLength=\"\(SystemStatusBarHeight)\">" +
                    "<item align=\"center\" rect=\"0, 0, \(SystemStatusBarHeight), \(SystemStatusBarHeight)\" icon=\"AppIcon\" />" +
                "</column>"
        }
        
        loadLayout(withXmlString: xmlString, forDelegate: delegate)
    }
    
    /// 为IB 而做的载入布局方法
    ///
    /// 在载入布局之后会自动调用layout() 刷新一次.
    ///
    /// - Parameters: xmlString: XML格式的字符串
    func loadLayout(withXmlString xmlString: String?, forDelegate delegate: StatusBarLayoutDelegate? = nil) {
//        // 载入布局配置
//        Preferences.initDefaults()
//        let xmlString = UserDefaults.standard.string(forKey: Preferences.STATUS_BAR_LAYOUT)
        if xmlString == nil {
            assertionFailure("囧...")
            return
        }
        
        self.columns.removeAll()
        
        let parser = XMLParser.init(data: xmlString!.data(using: .utf8)!)
        parser.delegate = self
        parser.parse()
        
        _ = layout()
        delegate?.onLoadedFromXml(withLayout: self)
    }
    
    /// 重新布局
    ///
    /// 遍历所有元件,
    /// 根据元件的内容与属性重算各个元件之间的空间关系.
    /// 一般在通过外部对columns 或其内部的元件进行修改之后调用此方法.
    /// 如果布局内包含可变宽度的元件, 亦要适时重新布局
    ///
    /// - Note:  目前只是做成根据列宽求出系统状态栏元件的宽度...
    /// 
    /// - TODO: column 的最终宽度会可能会被其中的item 撑大;
    /// - TODO: item   的实际绘制不一定会跟随rect 缩放, 具体取决于绘制方法,
    ///                但rect, align 或者其它绘图属性(例如字体样式)有可能影响父级column 的最终宽度.
    ///
    /// - Returns: 返回整个布局最后所需的总尺寸
    public func layout() -> CGSize {
        var totalWidth:CGFloat = 0.0
        for cloumn in columns {
            totalWidth += cloumn.length
        }
        
        _layoutedSize = CGSize(width: totalWidth, height: SystemStatusBarHeight)
        delegate?.onLayouted(self)
        return _layoutedSize
    }
    
    /// 计算完整绘制一个String所需要的尺寸.
    ///
    /// - TODO: 该方法包装了String.boundingRect方法, 简化其使用.
    public func boundingString(_ string: String) -> CGSize {
//        let strRect:CGRect = "987654321234℃56↑71.9MB/s\n↓1.27KB/s".boundingRect(with: rect.size, options: option, attributes: fontAttr, context: nil)
        return CGSize(width: 100.0, height: 22.0) // TODO: 测试用
    }
    
    /// 绘制该布局对象内的所有元件
    ///
    /// - Parameter rect: 绘图区域
    public func draw(inRect rect: CGRect) {
        var currentRight: CGFloat = rect.rigth
        
        for column in columns {
            for item in column.items {
                item.draw?(item, CGRect(left: (currentRight - column.length), right: currentRight))
            }
            
            currentRight += column.length
        }
    }
    
    
// MARK: - XMLParserDelegate
    
    /// XMLParser 读到标签开始.
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        print("<\(elementName) \(attributeDict)>")
        
        switch elementName {
        case "column":
            let strValue = attributeDict["minLength"]
            var width = SystemStatusBarHeight
            if strValue != nil {
                width = CGFloat((strValue! as NSString).floatValue)
            }
            
            columns.append((length: width, items: [/* 先插个空的 */]))
            break
            
        case "item":
            // 向代理请求其定制的元件实例
            var item: statusBarItem? = delegate?.onFindItemFromXml(attributes: attributeDict)
            if item == nil {
                item = statusBarLayoutItem(attributes: attributeDict)
            }
            
            // Swift 哩度唔可以用Last(), 貌似因为Last 返回的是copy, 
            // 只能用下标
            assert((columns.count > 0) && (item != nil ) , "囧...")
            columns[columns.count - 1].items.append(item!)
            break
            
        default:
            assertionFailure("遇到不明标签:\(elementName)")
        }
    }
    
    /// XMLParser 读到文本内容.
    ///
    /// 目前只有纯文本的元件使用.
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        print(string)
        
        // Swift 哩度唔可以用Last(), 貌似因为Last 返回的是copy,
        // 只能用下标
        assert(columns.count > 0, "囧...")
        var items = columns[columns.count - 1].items
        assert(items.count > 0, "囧...")
        items[items.count - 1].contents[StatusBarLayout.ITEM_CONTENTS_KEY_XML_TEXT] = string
    }

    /// XMLParser 读到标签结束
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        print("</\(elementName)>")
        
        switch elementName {
        case "item":
            // Swift 哩度唔可以用Last(), 貌似因为Last 返回的是copy,
            // 只能用下标
            assert(columns.count > 0, "囧...")
            let items = columns[columns.count - 1].items
            assert(items.count > 0, "囧...")
            delegate?.onLoadedFromXml(withItem: items[items.count - 1])
            break
            
        default: break
        }
    }

}


// MARK: -  -

protocol statusBarItem {
    /// 相对于列区域的对齐方式
    var alignment : StatusBarItemAlignmentType {get set}
    
    /// 自身的绘制区域
    var rect:CGRect {get set}
    
    /// 绘制到当前Context
    /// - Note: 重中之重!!
    ///         元件的绘制由StatusBarLayout 进行分配,
    ///         StatusBarLayout 会在适当时候调用此方法,
    ///         使用者只需要调用StatusBarLayout.draw() 方法即可,
    ///         一般不要直接调用此方法.
    var draw: ((_ item: statusBarItem, _ columnRect: CGRect) -> ())? {get set}
    
    /// 以字典的形式保存有用的内容
    var contents: [String : Any] {get set}
    
    /// 使用XMLParser 读取的属性字典初始化
    ///
    /// 子类重写该方法时, alignment 以及rect 属性无需特意设置,
    /// 只需要调用父类的本初始化方法.
    init(attributes attributeDict: [String : String])
    
    func copy() -> statusBarItem
}

// MARK: -  -

class statusBarLayoutItem: NSObject, statusBarItem {
    
    // MARK: - 属性
    
    /// 相对于列区域的对齐方式
    public final var alignment : StatusBarItemAlignmentType = .alignToTopRight
    
    /// 自身的绘制区域
    public final var rect:CGRect = CGRect(x: 0.0, y: 0.0, width: SystemStatusBarHeight, height: SystemStatusBarHeight)
    
    /// 绘制到当前Context
    /// - Note: 重中之重!!
    ///         元件的绘制由StatusBarLayout 进行分配,
    ///         StatusBarLayout 会在适当时候调用此方法,
    ///         使用者只需要调用StatusBarLayout.draw() 方法即可,
    ///         一般不要直接调用此方法.
    open var draw: ((_ item: statusBarItem, _ columnRect: CGRect) -> ())? = nil
    
    /// 以字典的形式保存有用的内容.
    open var contents: [String : Any] = [:] // = NSString(string: "???")
    
    
    
    // MARK: - 实例方法
    
    /// 使用XMLParser 读取的属性字典初始化
    ///
    /// 子类重写该方法时, alignment 以及rect 属性无需特意设置,
    /// 只需要调用父类的本初始化方法.
    required init(attributes attributeDict: [String : String] = [:]) {

        for attr in attributeDict {
            switch attr.key {
            case StatusBarLayout.ITEM_CONTENTS_KEY_ALIGN:
                self.alignment = StatusBarItemAlignmentType(rawValue: attr.value) ?? .alignToTopRight
                break
                
            case StatusBarLayout.ITEM_CONTENTS_KEY_RECT:
                var strRect = NSString(string: attr.value).components(separatedBy: ", ") // 逗号后面有个空格!
                if strRect.count == 4 {
                    self.rect.x      = CGFloat((strRect[0] as NSString).floatValue)
                    self.rect.y      = CGFloat((strRect[1] as NSString).floatValue)
                    self.rect.width  = CGFloat((strRect[2] as NSString).floatValue)
                    self.rect.height = CGFloat((strRect[3] as NSString).floatValue)
                }
                break
                
            // 其它属性全部插入到contents
            default:
                self.contents[attr.key] = attr.value
                break
            }
        }
    }
    
    //    /// 元件只有宽度(官方称为length )而没有高度,
    //    /// 高度永远是状态栏的高度.
    //    var length: CGFloat = SystemStatusBarHeight
    
    
    // TODO: 导出到XML     将此方法加入到协议
    func toXML /* 改返个名 */ (withItem item: statusBarItem) {
        // 将align, rect 插入<item>
        
//        var ggg = NSObject().copy()

        
        for attribute in item.contents {
            switch attribute.key {
            // 将文本插入文本 = =..
            case StatusBarLayout.ITEM_CONTENTS_KEY_XML_TEXT:
                break
            default:
                // 将属性插入<item>
                break
            }
        }
    }
    
    func copy() -> statusBarItem {
        return super.copy() as! statusBarItem
    }
}


// MARK: -  -


/// 状态栏元件的对齐方式
public enum StatusBarItemAlignmentType: String {
    /// 正中
    case alignToCenter = "center"
    
    /// 右上
    case alignToTopRight = "topRight"
    
    /// 左上
    case alignToTopLeft = "topLeft"
    
    //    /// 右下
    //    case alignToBottomRight = "bottomRight"
    //
    //    /// 左下
    //    case AlignToBottomLeft = "bottomLeft"
}

//public enum statusBarItemContent {
//    case NSString
//    case NSImage
//}

// MARK: -  -

extension CGRect {
    
    /// StatusBarLayout 布局元件时生成column 区域所用的初始化方法,
    /// column 的y 座标永远是0 .
    /// - Parameter height: 除特殊情况, 否则使用默认值.
    init(left: CGFloat, right: CGFloat, height: CGFloat = SystemStatusBarHeight) {
        self = CGRect(x: left, y: 0.0, width: right - left, height: height)
    }
    
    /// StatusBarLayout 布局元件时所用的座标变换方法,
    /// 该方法将元件自身绘图区域平移至当前布局中的绝对座标
    ///
    /// - Parameters:
    ///   -  rect: 元件绘制的0座标是在右上角, 此区域的右边界(.right)作为起始座标.
    ///   - align: 相对于Column 区域的对齐方式
    /// - Returns: <#return value description#>
    func convertToLayouted(inColumnRect rect: CGRect,
                           withAlign align:StatusBarItemAlignmentType = .alignToTopRight) -> CGRect {
        
        var result = self
        
        switch align {
        // 右上角
        case .alignToTopRight:
            result.x = rect.rigth - self.width + self.x
            result.y = rect.y + self.y
            break
            
        // 左上角
        case .alignToTopLeft:
            result.x = rect.x + self.x
            result.y = rect.y + self.y
            break
            
        // 正中心
        case .alignToCenter:
            result.x = rect.x + ((rect.width  - self.width)  / 2.0) + self.x
            result.y = rect.y + ((rect.height - self.height) / 2.0) + self.y
            break
        
//        default:
//            break
        }
        return result
    }
}

extension CGRect {
    var x: CGFloat {
        get {
            return self.origin.x
        }
        set(newValue) {
            self.origin.x = newValue
        }
    }
    
    var y: CGFloat {
        get {
            return self.origin.y
        }
        set(newValue) {
            self.origin.y = newValue
        }
    }
    
    var width: CGFloat {
        get {
            return self.size.width
        }
        set(newValue) {
            self.size.width = newValue
        }
    }
    
    var height: CGFloat {
        get {
            return self.size.height
        }
        set(newValue) {
            self.size.height = newValue
        }
    }
}

extension CGRect {
    public var top : CGFloat {
        get {
            if size.height < 0 {
                return origin.y + size.height
            }
            return origin.y
        }
    }
    
    public var left : CGFloat {
        get {
            if size.width < 0 {
                return origin.x + size.width
            }
            return origin.x
        }
    }
    
    
    public var bottom : CGFloat {
        get {
            if size.height < 0 {
                return origin.y
            }
            return origin.y + size.height
        }
    }
    
    public var rigth : CGFloat {
        get {
            if size.width < 0 {
                return origin.x
            }
            return origin.x + size.width
        }
    }
}

