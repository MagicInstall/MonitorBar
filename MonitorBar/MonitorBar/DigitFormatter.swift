//
//  MonitorBar
//  DigitFormatter.swift
//
//  Created by wing on 2017/1/8.
//  Copyright © 2016 Magic Install. All rights reserved.
//

import Cocoa

/// 提供显示格式转换
class DigitFormatter: Formatter {
    
    
    /// 格式化成数字部分固定占用4个字符位置的样式
    static func to4Digit(fromDouble value: Double, unit:String! = "") -> String {
        // 特殊值处理
        if value == 0 {
            return "   0" + unit
        }
        if fabs(value) >= 1_000_000_000_000_000_000_000_000.0 {
            return "????" + unit
        }
        
        return to654Digit(fromDouble: value, digit: 4) + unit
    }
    
    /// 格式化成数字部分固定占用6个字符位置的样式
    static func to5Digit(fromDouble value: Double, unit:String! = "") -> String {
        // 特殊值处理
        if value == 0 {
            return "    0" + unit
        }
        if fabs(value) >= 1_000_000_000_000_000_000_000_000.0 {
            return "?????" + unit
        }
        
        return to654Digit(fromDouble: value, digit: 5) + unit
    }
    
    /// 格式化成数字部分固定占用6个字符位置的样式
    static func to6Digit(fromDouble value: Double, unit:String! = "") -> String {
        // 特殊值处理
        if value == 0 {
            return "     0" + unit
        }
        if fabs(value) >= 1_000_000_000_000_000_000_000_000.0 {
            return "??????" + unit
        }
        
        return to654Digit(fromDouble: value) + unit
    }
    
    
    /// 格式化成数字部分固定占用6个/ 5个/ 4个 字符位置的样式
    ///
    /// - Parameters:
    ///   - digit: 数字部分占用的位数, 只能是6 或5 或 4 !
    fileprivate static func to654Digit(fromDouble value: Double, digit:Int = 6) -> String {
        // 千进处理
        let carrying = thousandsCarrying(value)

        
        // 整个数字占位数
        let digitCount : Int = digit - carrying.subUnit.characters.count
        // 小数部分位数
        var decCount   : Int = 0
        
        // 有后缀, 就会有小数点
        if digitCount < digit {
//            digitCount -= carrying.subUnit.characters.count
            
            // 整数部分最多只有3位
            var intCount :Int = 3
            let fabs_value = fabs(carrying.value)
            if fabs_value < 100.0 {
                intCount -= 1
            }
            if fabs_value < 10.0 {
                intCount -= 1
            }
            
            decCount = digitCount - intCount - 1/* 小数点*/
            // 有负号
            if value < 0 {
                decCount -= 1
            }
        }
        
        var result : Double
        
        // 按输出位数截断余下精度
        // 小数最多只有4位
        if decCount == 4 {
            result = Double(Int(carrying.value * 10000.0)) / 10000.0
        }
        else if decCount == 3 {
            result = Double(Int(carrying.value * 1000.0)) / 1000.0
        }
        else if decCount == 2 {
            result = Double(Int(carrying.value * 100.0)) / 100.0
        }
        else if decCount == 1 {
            result = Double(Int(carrying.value * 10.0) ) / 10.0
        }
        else /*if decCount == 0*/ {
            result = Double(Int(carrying.value))
        }
        
        let format = "%" + String(digitCount) + "." + String(decCount) + "f" + "%@"
        return String(format: format, result, carrying.subUnit)
    }
    
    /// 千进处理
    static func thousandsCarrying(_ value:Double) -> (value:Double, subUnit:String) {
        let fabs_value = fabs(value)
        
        if fabs_value >= 1_000_000_000_000_000_000_000_000.0 {
            return (value, "?")
        }
        
        if fabs_value >= 1_000_000_000_000_000_000_000.0 {
            return (value / 1_000_000_000_000_000_000_000.0, "B")
        }
        else if fabs_value >= 1_000_000_000_000_000_000.0 {
            return (value / 1_000_000_000_000_000_000.0, "E")
        }
        else if fabs_value >= 1_000_000_000_000_000.0 {
            return (value / 1_000_000_000_000_000.0, "P")
        }
        else if fabs_value >= 1_000_000_000_000.0 {
            return (value / 1_000_000_000_000.0, "T")
        }
        else if fabs_value >= 1_000_000_000.0 {
            return (value / 1_000_000_000.0, "G")
        }
        else if fabs_value >= 1_000_000.0 {
            return (value / 1_000_000.0, "M")
        }
        else if fabs_value >= 1_000.0 {
            return (value / 1_000.0, "K")
        }
        return (value, "")
    }
    
    
// MARK: - Formatter
  
    
    
    /// 格式化后连接在后面的字符串
    public var unit: String = ""
    
    private var _digit : Int = 6
    /// 格式化后数字部分所占的字数,
    /// 只能是4 或5 或 6 !
    public var digit: UInt {
        set(value) {
            if value == 4 { _digit = 4 }
            else if value == 5 { _digit = 5 }
            else { _digit = 6 }
        }
        get { return UInt(_digit) }
    }
    
    
    override func string(for obj: Any?) -> String? {
        if obj == nil {
            return "nil"
        }
        
        switch obj {
        case is NSNumber:
            return DigitFormatter.to654Digit(
                    fromDouble: (obj as! NSNumber).doubleValue,
                    digit: _digit
                    ) + unit
            
        default:
            print(NSString(utf8String:object_getClassName(obj!)) ?? "??")
            return ""
        }
    }
    
    override func editingString(for obj: Any) -> String? {
        switch obj {
        case is NSNumber:
            return (obj as! NSNumber).stringValue
            
        default:
            print(NSString(utf8String:object_getClassName(obj)) ?? "??")
            return ""
        }
    }
    
    override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        
        var floatResult:Float = 0.0
        var scanner:Scanner
        var returnValue:Bool = false
        
        scanner = Scanner.init(string: string)
        scanner.scanString("$", into: nil) // ignore  return value
        if (scanner.scanFloat(&floatResult) && scanner.isAtEnd) {
            returnValue = true;
            if ((obj) != nil) {
                obj!.pointee = NSNumber(value: floatResult)
            }
        }
        else if ((error) != nil) {
            error!.pointee = NSLocalizedString("Couldn’t convert to float", comment: "Error converting") as NSString?
        }
        return returnValue;
    }
    
    override func attributedString(for obj: Any, withDefaultAttributes attrs: [String : Any]? = nil) -> NSAttributedString? {
        return super.attributedString(for: obj, withDefaultAttributes: attrs)
    }
    
    override func isPartialStringValid(_ partialString: String, newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>?, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        
        print(partialString)
        return super.isPartialStringValid(partialString, newEditingString: newString, errorDescription: error)
    }
    
    override func isPartialStringValid(_ partialStringPtr: AutoreleasingUnsafeMutablePointer<NSString>, proposedSelectedRange proposedSelRangePtr: NSRangePointer?, originalString origString: String, originalSelectedRange origSelRange: NSRange, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        
        print(origString + " [" +  NSString(string: origString).substring(with: origSelRange) + "]")
        return super.isPartialStringValid(partialStringPtr, proposedSelectedRange: proposedSelRangePtr, originalString: origString, originalSelectedRange: origSelRange, errorDescription: error)
    }
}
