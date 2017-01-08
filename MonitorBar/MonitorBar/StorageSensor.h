//
//  MonitorBar
//  StorageSensor.h
//
//  Created by wing on 2016/12/31.
//  Copyright © 2016 Magic Install. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Sensor.h"

/// 提供磁盘相关读数
@interface StorageSensor : NSObject <Sensor>

// MARK: -
// MARK: 类常量

/**
 全部硬盘的写速度
 */
+ (const NSString * _Nonnull)STORAGE_GLOBAL_DATA_WRITE_SPEED_KEY;

/** 
 全部硬盘的读速度
 */
+ (const NSString * _Nonnull)STORAGE_GLOBAL_DATA_READ_SPEED_KEY;



/// 取得磁盘内核服务端口
//+ (io_iterator_t)IOService;

/// Test
+ (void)test;


// MARK: -
// MARK: 属性

// MARK: -
// MARK: 实例方法

/// 用指定key 初始化磁盘传感器
- (_Nullable instancetype)initWithKey:(nonnull NSString *)key;

@end
