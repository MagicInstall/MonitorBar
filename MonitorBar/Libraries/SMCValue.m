//
//  MonitorBar
//  SMCValue.m
//
//  Created by wing on 2016/12/23.
//  Copyright © 2016 Magic Install. All rights reserved.
//

#import "SMCValue.h"
#import "CHelper.h"

@implementation SMCValue {
// MARK: 私有变量
    
    SMCVal_t _cSmcVal;
}

// MARK: -
// MARK: 类方法
//+ (SMCValue *) readKey: (NSString*)key FromConnection: (io_connect_t)conn {
//    SMCValue *value = [[SMCValue alloc] init];
//    if (kIOReturnSuccess != SMCReadKey(conn, [key UTF8String], [value getReference])) {
//        NSLog(@"SMCReadKey(\(key)) 失败!");
//        return nil;
//    }
//    
//    
//    return value;
//}


//- (instancetype)initWithCStruct:(SMCVal_t *)value {
//    self = [super init];
//    bcopy(value, &_cSmcVal, sizeof(SMCVal_t));
//    return self;
//}

// MARK: -
// MARK: 实例属性
- (SMCVal_t *) getReference {
    return &_cSmcVal;
}

- (NSString *) key {
    return [NSString stringWithUTF8String:_cSmcVal.key];
}
- (void) setKey:(NSString *)key {
    int length = (int)[key length];
    if (length > sizeof(_cSmcVal.key)) {
        length = sizeof(_cSmcVal.key);
    }
    bcopy([key UTF8String], &(_cSmcVal.key), length);
}

- (NSString *) dataType {
    return [NSString stringWithUTF8String:_cSmcVal.dataType];
}

//- (Class) valueType {
//    NSString *type = self.dataOriginalType;
//    if ([type isEqual: @"ui8 "] || [type isEqual: @"ui16"] || [type isEqual: @"ui32"] ||
//        [type isEqual: @"si8 "] || [type isEqual: @"si16"] || [type isEqual: @"si32"] ||
//        [type isEqual: @"sp78"] ||
//        [type isEqual: @"fp88"] || [type isEqual: @"fpe2"] || [type isEqual: @"fp2e"] || [type isEqual: @"fp4c"]) {
//            
//           return [NSNumber class];
//    }
//    
//    if ([type isEqual: @"ch8*"] || [type isEqual: @"{fds"]) {
//        return [NSString class];
//    }
//    
//    return nil;
//}

- (NSInteger) dataSize {
    return _cSmcVal.dataSize;
}

- (NSData *) getData {
    return [NSData dataWithBytes:_cSmcVal.bytes length:_cSmcVal.dataSize];
}

- (UInt32) getUInt32Value {
    int length = (int)[self dataSize];
    if (length < 1) return 0;
    
    if (length > 4) length = 4;
    
    UInt32 uint32Value;
    bcopy(_cSmcVal.bytes, &uint32Value, length);
    switch (length) {
        case 2:
            return CFSwapInt16(uint32Value);
        case 4:
            return CFSwapInt32(uint32Value);;
    }
    
    return uint32Value;
}

- (SInt32) getSInt32Value {
    SInt32 sint32Value;
    UInt32 uint32Value = [self getUInt32Value];
    bcopy(&uint32Value, &sint32Value, 4);
    return sint32Value;
}

- (float)getFloatValue {
    if ([self dataSize] != 2) {
        printf("\nSMCVal_t.dataSize 错误!");
        return 0.0;
    }
    
    UInt16 uint16Value = [self getUInt32Value];
    BOOL minus = (uint16Value & 0x8000) == 0x8000;
    BOOL signd = [[self dataType] isEqual: @"sp78"];

    if (signd && minus) uint16Value &= ~0x8000; // 清零符号位
    
    UInt8 f = [self getIndexFromHexChar: _cSmcVal.dataType[3]];
    return (float)uint16Value / (float)(0x01 << f) * (signd && minus ? -1 : 1);

    
    return 0.0;
}


/**
 貌似系将一个十六进制字符转为十进制数字的算法...的一部分...
 唔知点描述哩个方法...
 此方法源自 HWSensors/Shared/SmcHelper.m

 @param hexChar 一个字符

 @return 返回0 ~ 15 十进制整数
 */
- (UInt8) getIndexFromHexChar: (UInt8)hexChar {
    if ((hexChar > 47) && (hexChar < 58)) { /* 1 - 9 */
        return hexChar - 48;
    }
    
    if ((hexChar > 96) && (hexChar < 103)) { /* a - f */
        return hexChar - 87;
    }
    
    return 0;
}

- (NSString *) getStringValue {
    if ([[self dataType]  isEqual: @"{fds"]) {
        // 风扇的data 是一个结构体, 这里直接跳到风扇名称
        return [NSString stringWithCString:(const char*)(_cSmcVal.bytes + 4) encoding:NSUTF8StringEncoding];
    }
    
    return [NSString stringWithCString:(const char*)_cSmcVal.bytes encoding:NSUTF8StringEncoding];;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ %@(Type:%@ Size:%ld)", self.key, [self getData], self.dataType, self.dataSize];
}

- (NSUInteger)hash {
    return self.key.hash;
}

@end
