//
//  MonitorBar
//  MemorySensor.h
//
//  Created by wing on 2017/1/1.
//  Copyright © 2016 Magic Install. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Sensor.h"

/// 提供内存相关读数
@interface MemorySensor : NSObject <Sensor>

+ (void)test;

@end
