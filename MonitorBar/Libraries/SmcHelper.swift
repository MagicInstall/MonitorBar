//
//  SmcHelper.swift
//  MonitorBar
//
//  Created by wing on 2016/12/21.
//  Copyright © 2016 Magic Install. All rights reserved.
//
//  此文件部分代码来自于https://github.com/kozlek/HWSensors 项目, 
//  再经过代码优化, 从而移植至Swift.

import Cocoa

class SmcHelper: NSObject {
    /// 避免打开过多的端口
    static private var isConnected = false
    
    /// 记住已经打开的端口
    static private var smcConnection : io_connect_t = 0
    
    
    // MARK: 底层连接
    
    /// 建立底层SMC 连接, 并返回传感器的Key.
    /// 由于用户设备可能同时存在多种SMC 类型,
    /// 因此需要分别连接, 并保存好各种SMC 的底层连接端口.
    /// - 一定要在适当的时候释放该连接
    ///
    /// - returns: connection: 内核设备连接端口号, 断开SMC 连接(或执行SMC 相关的底层函数)的时候需要这个值
    ///            keys:       字符串类型的传感器内核Key(s)
    static func connectionSmc() -> Bool {
//        var smcConnection : io_connect_t = 0
        if isConnected == false {
            // 打开端口
            if kIOReturnSuccess != SMCOpen("AppleSMC", &smcConnection) {
                print("SMCOpen 失败!")
                return false
            }
            isConnected = true
            print("SMC 内核端口已连接")
        }
//        
//        // 先取得传感器数量
//        var smcVal = read(key:"#KEY", connection: smcConnection)
//        let deviceKeys = NSMutableSet()
//        if smcVal == nil {
//            print("读取#KEY key 失败! 无法枚举传感器.");
//            return (smcConnection, deviceKeys)
//        }
//        print("\(smcVal!)")
//        
//        // 枚举全部传感器
//        var key: String
//        let deviceCount = smcVal!.getUInt32Value()
//        for index in (0...(deviceCount - 1)) {
//            var inputStructure  = SMCKeyData_t()
//            var outputStructure = SMCKeyData_t()
//            var val = SMCVal_t()
//            
//            memset(&inputStructure, 0, MemoryLayout<SMCKeyData_t>.size);
//            memset(&outputStructure, 0, MemoryLayout<SMCKeyData_t>.size);
//            memset(&val, 0, MemoryLayout<SMCVal_t>.size);
//            
//            inputStructure.data8 = UInt8(SMC_CMD_READ_INDEX);
//            inputStructure.data32 = UInt32(index);
//            
//            if (kIOReturnSuccess == SMCCall(smcConnection, KERNEL_INDEX_SMC, &inputStructure, &outputStructure)) {
//                key = String(format: "%c%c%c%c",
//                               UInt(outputStructure.key >> 24),
//                               UInt(outputStructure.key >> 16),
//                               UInt(outputStructure.key >> 8),
//                               UInt(outputStructure.key))
//                
//                deviceKeys.add(key)
//
//                smcVal = read(key:key, connection: smcConnection)
//                print("\(smcVal)")
////                if (!excluded || NSNotFound == [excluded indexOfObject:key]) {
////                    [array addObject:key];
////                }
//            }
//        }

        return true
    }
    
    
    /// 断开底层SMC 连接
    ///
    /// - parameter connection: 通过connectionSmc() 方法取得的内核设备连接端口号
    static func disconnetSmc() {
        if isConnected == false {
            return
        }
        
        if kIOReturnSuccess != SMCClose(smcConnection) {
            print("SMC 内核端口注销出错!")
        }
        
        isConnected = false
        smcConnection = 0
    }
    
    /// 取得已经连接的内核端口
    ///
    /// - Returns: smc内核端口号
//    static func getConnected() -> io_connect_t {
//        return smcConnection
//    }
    
    
    /// 检测出SMC 中全部Key
    ///
    /// - parameter connection:   内核设备连接端口号
    /// - parameter minuendKeys:  该集合用于在返回结果之前, 将结果中与集合相同的key 去掉
    ///
    /// - returns: 即使方法调用失败, 仍然会返回一个空的集合对象
    static func listSMCKeys(connection: io_connect_t = smcConnection, minuendKeys: NSMutableSet? = nil) -> NSMutableSet {
        let keysSet = NSMutableSet()
        
        
        // 先取得传感器数量
        var smcVal = read(key:"#KEY", connection: connection)
        let deviceKeys = NSMutableSet()
        if smcVal == nil {
            print("读取#KEY key 失败! 无法枚举传感器.");
            return keysSet/* Empty */
        }
        print("\(smcVal!)")
        
        // 枚举全部传感器
        var key: String
        let deviceCount = smcVal!.getUInt32Value()
        for index in (0...(deviceCount - 1)) {
            var inputStructure  = SMCKeyData_t()
            var outputStructure = SMCKeyData_t()
            var val = SMCVal_t()
            
            memset(&inputStructure, 0, MemoryLayout<SMCKeyData_t>.size);
            memset(&outputStructure, 0, MemoryLayout<SMCKeyData_t>.size);
            memset(&val, 0, MemoryLayout<SMCVal_t>.size);
            
            inputStructure.data8 = UInt8(SMC_CMD_READ_INDEX);
            inputStructure.data32 = UInt32(index);
            
            if (kIOReturnSuccess == SMCCall(connection, KERNEL_INDEX_SMC, &inputStructure, &outputStructure)) {
                key = String(format: "%c%c%c%c",
                             UInt(outputStructure.key >> 24),
                             UInt(outputStructure.key >> 16),
                             UInt(outputStructure.key >> 8),
                             UInt(outputStructure.key))
                
                deviceKeys.add(key)
                
                smcVal = read(key:key, connection: connection)
                print("\(smcVal!)")
            }
        }
        
        return keysSet
    }
    
    // MARK: -
    // MARK: 底层通信
    
    
    /// 读取底层SMC 信息
    ///
    /// - parameter key:        传感器的内核Key
    /// - parameter connection: 内核设备连接端口号
    ///
    /// - returns: 返回SMC 信息对象
    static func read(key: String, connection: io_connect_t = smcConnection) -> SMCValue? {
        let smcValue = SMCValue()
        if kIOReturnSuccess != SMCReadKey(connection, key, smcValue.getReference()) {
            print("SMCReadKey(\(key)) 失败!")
            return nil
        }
        
        return smcValue
        
        // 提取有用的SMC 信息
        // 以下代码源自 HWSensors/Shared/SmcHelper.m
        // 由于原方法涉及太多C 类型转换, 
        // 因此合并到此处, 并优化代码
        
//        
//        // value = [SmcHelper decodeNumericValueFromBuffer:info.bytes length:info.dataSize type:info.dataType];
//        
//        // (NSNumber*)decodeNumericValueFromBuffer:(void *)data length:(NSUInteger)length type:(const char *)type
//        
////        let type = NSString(utf8String:&(smcValue.dataType.0))
//        let type = String(utf8String: &(smcValue.dataType.0))
//        if (type == nil) || (type!.characters.count < 3) {
//            print("SMCVal_t.dataType 错误!")
//            return 0
//        }
//        
//        let length = Int(smcValue.dataSize)
//        switch type! {
//        case "ui8 ", "si8 ":
//            if length != 1 {
//                print("\nSMCVal_t.dataSize 错误!")
//                return 0
//            }
//            var result: UInt8 = 0
//            bcopy(&(smcValue.bytes.0), &result, 1);
//            
//            // 处理符号位
//            if (type! == "si8") && ((result & 0x80) == 1) {
//                result &= ~0x80
//                return NSNumber(value: -(Int8(result)))
//            }
//            return NSNumber(value: result)
//            
//        case "ui16", "si16":
//            if length != 2 {
//                print("\nSMCVal_t.dataSize 错误!")
//                return 0
//            }
//            
//            var result: UInt16 = 0
//            bcopy(&(smcValue.bytes.0), &result, 2);
//            result = CFSwapInt16(result)
//
//            if (type! == "si16") && ((result & 0x8000) == 1) {
//                result &= ~0x8000
//                return NSNumber(value: -(Int16(result)))
//            }
//            return NSNumber(value: result)
//            
//        case "ui32", "si32":
//            if length != 4 {
//                print("\nSMCVal_t.dataSize 错误!")
//                return 0
//            }
//            
//            var result: UInt32 = 0
//            bcopy(&(smcValue.bytes.0), &result, 4);
//            result = CFSwapInt32(result)
//            
//            if (type! == "si32") && ((result & 0x80000000) == 1) {
//                result &= ~0x80000000
//                return NSNumber(value: -(Int32(result)))
//            }
//            return NSNumber(value: result)
//            
//        case "sp78", "fp88", "fpe2", "fp2e", "fp4c":
//            if length != 2 {
//                print("\nSMCVal_t.dataSize 错误!")
//                return 0
//            }
//            
//            var result: UInt16 = 0
//            bcopy(&(smcValue.bytes.0), &result, 2)
//            
//            var swapped: UInt16 = CFSwapInt16(result)
//            let minus = (swapped & 0x8000) == 0x8000
//            var signd = false
//            if (type! == "sp78") {
//                signd = true
//            }
//            if signd && minus {
//                swapped &= ~0x8000
//            }
//            let f = getIndexFrom(hexChar: smcValue.dataType.3)/* 8 */
//            return NSNumber(value: (Float(swapped) / Float(0x01 << f)) * (signd && minus ? -1 : 1))
//            
//        case "ch8*":
//            print(CHelper.getStringFrom(&(smcValue.bytes.0)), terminator: "\n  --")
//            return 0
//           
//        case "{fds":
//            print(CHelper.getStringFrom(&(smcValue.bytes.4)), terminator: "\n  --")
//            return CHelper.getIntForm(&(smcValue.bytes.0), start: 0, length: 4)
//            
//        
//        default:
//            if ((smcValue.dataType.0 == 102/* f */) || (smcValue.dataType.0 == 115/* s */)) && (smcValue.dataType.1 == 112/* p */) {
//                if length != 2 {
//                    print("\nSMCVal_t.dataSize 错误!")
//                    return 0
//                }
//                
//                var result: UInt16 = 0
//                bcopy(&(smcValue.bytes.0), &result, 2)
//                
//                let i = getIndexFrom(hexChar: smcValue.dataType.2)
//                let f = getIndexFrom(hexChar: smcValue.dataType.3)
//                if (i + f != (smcValue.dataType.0 == 115/* s */ ? 15 : 16) ) {
//                    return 0;
//                }
//                
//                var swapped: UInt16 = CFSwapInt16(result)
//                let signd = smcValue.dataType.0 == 115/* s */
//                let minus = (swapped & 0x8000) == 0x8000
//
//                if signd && minus {
//                    swapped &= ~0x8000
//                }
//                
//                return NSNumber(value: (Float(swapped) / Float(0x01 << f)) * (signd && minus ? -1 : 1))
//            }
//        
//            
//            print("未知的SMCVal_t.dataType (\(type))")
//        }
//        return 0
    }
    
    /// 貌似系将一个十六进制字符转为十进制数字的算法...的一部分...
    /// 唔知点描述哩个方法...
    /// 此方法源自 HWSensors/Shared/SmcHelper.m
    ///
    /// - parameter hexChar: 一个字符
    ///
    /// - returns: 返回一个整数索引
    @objc(getIndexFromUInt8Char:) static func getIndexFrom(hexChar: UInt8) -> Int {
        if (hexChar > 47) && (hexChar < 58) /* 1 - 9 */{
            return Int(hexChar) - 48
        }
        
        if (hexChar > 96) && (hexChar < 103) { /* a - f */
            return Int(hexChar) - 87
        }
        
        if (hexChar > 64) && (hexChar < 71) { /* A - F */
            return Int(hexChar) - 55
        }
       
        return -1
    }
    
    @objc(getIndexFromInt8Char:) static func getIndexFrom(hexChar: Int8) -> Int {
        let result = getIndexFrom(hexChar: UInt8(hexChar))
        if result == -1 {
            return 0x80
        }
        return result
    }
    
    

}

// MARK: -  -

extension String {
    /// 返回指定索引位置的单个字符
    subscript(index: UInt) -> String {
        return String(self[self.index(self.startIndex, offsetBy: Int(index))])
    }
    
    
    /// 返回指定范围的子字符串
    subscript (range: Range<Int>) -> String {
        get {
            let startIndex = self.index(self.startIndex, offsetBy: range.lowerBound)
            let endIndex = self.index(self.startIndex, offsetBy: range.upperBound)
            return self[Range(startIndex..<endIndex)]
        }
    }
    
    /// 十六进制字符串转成Swift 的Int
    ///
    /// - Parameter regular: TODO: 可选使用正则匹配出十六进制部分, 只返回第一个匹配的转换值.
    /// - Returns: 返回正则匹配的部分, 以及转换后的Int 值.
    func smcHexToInt(withRegular regular: String? = nil) -> (int: Int, subString: String) {
        var subStr: String = self
        if regular != nil {
            // TODO: 正则匹配
            subStr = self
        }
        
        var count: UInt = 0
        var resultInt: Int = 0
        charFor: for char in subStr.unicodeScalars {
            switch char {
            case "0"..."9":
                resultInt += Int(UInt(char.value - 48) << (count * 4))
                break
            case "A"..."F":
                resultInt += Int(UInt(char.value - 55) << (count * 4))
                break
            case "a"..."f":
                resultInt += Int(UInt(char.value - 87) << (count * 4))
                break
            default:
                break charFor
            }
            count += 1
        }
        return (resultInt, subStr)
    }
    
    
}
