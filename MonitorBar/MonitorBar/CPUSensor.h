//
//  MonitorBar
//  CPUSensor.h
//
//  Created by wing on 2016/12/31.
//  Copyright © 2016 Magic Install. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Sensor.h"


/// 提供CPU相关读数
@interface CPUSensor : NSTableCellView /* OC 不能多继承只能这样了... */ <Sensor>

/// 取得CPU 核心总数
+ (NSInteger) coreAmount;

+ (void)test;


@end

/// 为保存内核对象processor_cpu_load_info_t 中的数据提供ARC 对象
@interface usageInfo : NSObject
@property NSArray<NSArray *> *core;

@end



