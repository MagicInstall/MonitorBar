//
//  MonitorBar
//  MemorySensor.h
//
//  Created by wing on 2017/1/1.
//  Copyright © 2016 Magic Install. All rights reserved.
//
//
//  free是空闲内存；
//  active是已使用，但可被分页的（在iOS中，只有在磁盘上静态存在的才能被分页，例如文件的内存映射，而动态分配的内存是不能被分页的；
//  inactive是不活跃的，也就是程序退出后却没释放的内存，以便加快再次启动，而当内存不足时，就会被回收，因此也可看作空闲内存；
//  wire就是已使用，且不可被分页的。
//  最后你会发现，即使把这些全加起来，也比设备内存少很多，那么剩下的只好当成已被占用的神秘内存了。不过在模拟器上，这4个加起来基本上就是Mac的物理内存量了，相差不到2MB。

#import <Cocoa/Cocoa.h>

#import "Sensor.h"

/// 提供内存相关读数
@interface MemorySensor : NSObject <Sensor>

// MARK: - 类常量

/** 空闲内存 */
+ (const NSString * _Nonnull)MEMORY_FREE_KEY;

/** 程序退出后还没释放的内存 */
+ (const NSString * _Nonnull)MEMORY_INACTIVE_KEY;

/** 已使用且可被分页的内存 */
+ (const NSString * _Nonnull)MEMORY_ACTIVE_KEY;

/** 已使用但不可被分页的内存 */
+ (const NSString * _Nonnull)MEMORY_WIRE_KEY;

// MARK: - 类方法

/// 获取分页大小
+ (NSUInteger) getPageSize;

/// 获取物理内存总大小
+ (NSUInteger) getPhysicalTotal;

+ (void)test;

@end
