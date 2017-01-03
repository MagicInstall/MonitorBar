//
//  MonitorBar
//  NetworkSensor.h
//
//  Created by wing on 2016/12/31.
//  Copyright © 2016 Magic Install. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sensor.h"

/// 提供网络相关读数
@interface NetworkSensor : NSObject <Sensor>

//static const NSString *NETWORK_SENSOR_DATA_IN_KEY = @"NWDI";
+ (void)test;

@end
