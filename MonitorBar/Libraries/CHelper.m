//
//  MonitorBar
//  CHelper.m
//
//  Created by wing on 2016/12/23.
//  Copyright © 2016 Magic Install. All rights reserved.
//

#import "CHelper.h"

@implementation CHelper


/**
 将char[] 类型转换成NSString 类型

 @param buffer C 的字符串指针

 @return return 返回NSString 类型的结果
 */
+ (NSString *) getStringFrom: (UInt8 *) buffer {
    NSString * result = [NSString stringWithCString:(const char*)buffer encoding:NSUTF8StringEncoding];
    return result;
}


/**
 <#Description#>

 @param buffer <#buffer description#>
 @param start  <#start description#>
 @param length <#length description#>

 @return <#return value description#>
 */
+ (NSNumber *) getIntForm:(UInt8 *)buffer StartIndex:(int)start Length:(int)length {
    int result = 0;
    for (int i = start; i < length; i++) {
        result += *(buffer + length - i - 1) << (i * 8);
    }
    return [NSNumber numberWithInt:result];
}

@end
