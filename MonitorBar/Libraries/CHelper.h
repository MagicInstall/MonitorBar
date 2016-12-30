//
//  MonitorBar
//  CHelper.h
//
//  Created by wing on 2016/12/23.
//  Copyright © 2016 Magic Install. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "smc.h"


/// 该类旨在简化一些Swift 的指针操作
@interface CHelper : NSObject
+ (NSString *) getStringFrom: (UInt8 *) buffer ;
+ (NSNumber *) getIntForm:(UInt8 *)buffer StartIndex:(int)start Length:(int)length;

@end
