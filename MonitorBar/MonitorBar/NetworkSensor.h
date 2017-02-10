//
//  MonitorBar
//  NetworkSensor.h
//
//  Created by wing on 2016/12/31.
//  Copyright © 2016 Magic Install. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Sensor.h"

/// 提供网络相关读数
@interface NetworkSensor : NSTableCellView /* OC 不能多继承只能这样了... */ <Sensor>

// MARK: - 类常量

/**
 全部硬盘的写速度
 */
+ (const NSString * _Nonnull)NETWORK_GLOBAL_DATA_IN_SPEED_KEY;

/**
 全部硬盘的读速度
 */
+ (const NSString * _Nonnull)NETWORK_GLOBAL_DATA_OUT_SPEED_KEY;



//static const NSString *NETWORK_SENSOR_DATA_IN_KEY = @"NWDI";
+ (void)test;
// MARK: - 实例方法

/// 用指定key 初始化磁盘传感器
- (_Nullable instancetype)initWithKey:(nonnull NSString *)key;


@end
