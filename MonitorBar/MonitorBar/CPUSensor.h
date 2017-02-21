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


// MARK: - 类常量

/** 用户进程在核心%d的占用率KEY 的格式: "UC%dU" */
+ (const NSString * _Nonnull)CORE_USER_PERCENT_KEY_FORMAT;

/** 优先级被改变的进程在核心%d的占用率KEY 的格式: "UC%dN" */
+ (const NSString * _Nonnull)CORE_NICE_PERCENT_KEY_FORMAT;

/** 内核进程在核心%d的占用率KEY 的格式: "UC%dS" */
+ (const NSString * _Nonnull)CORE_SYSTEM_PERCENT_KEY_FORMAT;

/** 空闲进程在核心%d的占用率KEY 的格式: "UC%dI" */
+ (const NSString * _Nonnull)CORE_IDLE_PERCENT_KEY_FORMAT;



// MARK: - 类方法

/// 取得CPU 核心总数
+ (NSUInteger) coreAmount;

+ (void)test;


@end

/// 为保存内核对象processor_cpu_load_info_t 中的数据提供ARC 对象
@interface usageInfo : NSObject
//@property NSArray<NSArray *> *core;

@end


@interface NSString (NSStringTransform)
- (NSUInteger) hexToInt;
@end



