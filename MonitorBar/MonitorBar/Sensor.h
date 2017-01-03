//
//  MonitorBar
//  Sensor.h
//
//  Created by wing on 2016/12/31.
//  Copyright © 2016 Magic Install. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <mach/mach_time.h>
#import "HistoryValues.h"

extern const NSString * _Nonnull DESCRIPTION_LOCALIZED_KEY_APPENDING_STRING;

/// 该协议为所有传感器(其它读数的设备等)的基类
@protocol Sensor

// MARK: -
// MARK: 类方法

/**
 取得该类传感器可用的全部Key(s)
 */
+ (NSSet<NSString *>* _Nonnull)effectiveKeys;


/**
 通过传入需要读数的传感器Key 取得传感器实例, 同时对类的内部初始化.
 
 @param keys 可用的传感器可以通过[Sensor effectiveKeys] 取得.
 @return     使用者只需持有该引用就能在[Sensor update] 后取得传感器的读数.
 */
+ (NSDictionary * _Nullable)buildSensorsFromKeys:(nonnull NSSet<NSString*>*)keys;
//+ (NSSet<Sensor> * _Nullable)buildSensorsFromKeys:(nonnull NSSet<NSString *>*)keys;

/**
 取得正在运作的传感器
 (通过[Sensor buildSensorsFromKeys:] 方法启用相应的传感器).
 */
+ (NSDictionary * _Nullable)activeSensors;
//+ (NSSet<Sensor> * _Nullable)activeSensors;

/**
 取得正在运作的传感器
 (通过[Sensor buildSensorsFromKeys:] 方法启用相应的传感器).

 @param key 可用的传感器可以通过[Sensor effectiveKeys] 取得.
*/
+ (NSSet<Sensor> * _Nullable)activeSensorsWithKey:(NSString * _Nonnull)key;


/** 使用都调用该方法更新所有传感器;
 内核提供的数据大部分都是调用一次就取得全部的数值, 如果每个传感器都单独获取读数, 将会造成巨大资源浪费, 故使用此方式一次更新全部传感器;
 */
+ (void)update;



// MARK: -
// MARK: 属性

/// 传感器显示的名称
@property (readonly) NSString * _Nonnull name;

/// 传感器内核key
@property (readonly) NSString * _Nonnull key;

/// 传感器内核key 的hash值
@property (readonly) NSUInteger hash;

/// 传感器显示的描述
@property (readonly) NSString * _Nonnull description;

/// 传感器值的基本单位
@property (readonly) NSString * _Nonnull unit;

/// 传感器显示的数值
//@property (readonly) NSString * _Nonnull stringValue;

/// 传感器读数
@property (readonly) NSNumber * _Nonnull numericValue;

/// 用于绘图的传感器历史读数数组, 只储存数字对象
@property (readonly) HistoryValues * _Nonnull history;



// MARK: -
// MARK: 实例方法

/** 更新时将一个新的读数压入, 方法内部会转换成便于使用的储存形式.

 @param time 从 CFAbsoluteTimeGetCurrent() 方法取得的时间.
 */
- (void)pushValue:(nonnull NSNumber *)value AtAbsoluteTime:(double)time ;




// MARK: -
// MARK: 作废(基类)方法




@end

//@interface Sensor : NSObject
//
//@end
