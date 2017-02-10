//
//  MonitorBar
//  NetworkSensor.m
//
//  Created by wing on 2016/12/31.
//  Copyright © 2016 Magic Install. All rights reserved.
//

#import "NetworkSensor.h"

#import <ifaddrs.h>
#import <sys/socket.h>
#import <net/if.h>

@implementation NetworkSensor {
// MARK: - 实例私有常量
    
    /// 存放自开机以来, 上一次读数的CPU 时间
    double _oldAbsTime;
    
    /// 存放自开机以来, 上一次的读数
    uint32_t _oldValue;
    
    /// 存放自开机以来, 本次读数的CPU 时间
    double _newAbsTime;
    
    /// 存放自开机以来, 本次的读数
    uint32_t _newValue;
}


// MARK: - 类常量


+ (const NSString *)NETWORK_GLOBAL_DATA_IN_SPEED_KEY  { return @"NGDI"; }
+ (const NSString *)NETWORK_GLOBAL_DATA_OUT_SPEED_KEY { return @"NGDO"; }
//static const NSString *NETWORK_GLOBAL_DATA_IN_SPEED_KEY = @"NGDI";
//static const NSString *NETWORK_GLOBAL_DATA_OUT_SPEED_KEY = @"NGDO";



// MARK: - 类变量

static NSMutableDictionary /*NSMutableSet<StorageSensor *>*/ *__sensors = nil;



// MARK: - 类方法

+ (NSSet<NSString *> *)effectiveKeys {
    return [[NSSet alloc] initWithObjects:
            [NetworkSensor NETWORK_GLOBAL_DATA_IN_SPEED_KEY],
            [NetworkSensor NETWORK_GLOBAL_DATA_OUT_SPEED_KEY]
            , nil
            ];
}

+ (NSDictionary *)buildSensorsFromKeys:(NSSet<NSString*>*)keys {
    // 先取可用key ,用这个数量初始化 __sensors.
    NSSet<NSString *> *effectiveKeys = [NetworkSensor effectiveKeys];
    
    __sensors = [[NSMutableDictionary alloc] initWithCapacity:[effectiveKeys count]];
    
    for (NSString *key in keys) {
        if ([effectiveKeys containsObject:key]) {
            [__sensors setObject:[[NetworkSensor alloc] initWithKey:key] forKey:key];
        }
    }
 
    [NetworkSensor update];
    
    return (NSDictionary *)__sensors;
}

+ (NSDictionary *)activeSensors {
    return [__sensors copy]; // 返回浅副本
}

+ (id<Sensor>)activeSensorsWithKey:(NSString *)key {
    return [__sensors objectForKey:key];
}


+ (void)test {
    struct ifaddrs *ifa_list = 0, *ifa;
    if (getifaddrs(&ifa_list) == -1)
    {
        return;
    }
    
    uint32_t iBytes = 0;
    uint32_t oBytes = 0;
    
    for (ifa = ifa_list; ifa; ifa = ifa->ifa_next)
    {
//        if (AF_LINK != ifa->ifa_addr->sa_family)
//            continue;
        
//        if (!(ifa->ifa_flags & IFF_UP) && !(ifa->ifa_flags & IFF_RUNNING))
//            continue;
        
        if (ifa->ifa_data == 0) continue;
        
        struct if_data *if_data = (struct if_data *)ifa->ifa_data;
        
        iBytes += if_data->ifi_ibytes;
        oBytes += if_data->ifi_obytes;
        
        //            NSLog(@"%s :iBytes is %d, oBytes is %d",
        //                  ifa->ifa_name, iBytes, oBytes);
        
        printf("%s iBytes:%d oBytes:%d\n", ifa->ifa_name,if_data->ifi_ibytes, if_data->ifi_obytes);
        
    }  
    freeifaddrs(ifa_list); 
}

+ (void)update {
    struct ifaddrs *ifa_list = 0, *ifa;
    if (getifaddrs(&ifa_list) == -1) {
        printf("getifaddrs() 返回-1");
        return;
    }
    
    uint32_t totalDownloadBytes = 0;
    uint32_t totalUploadBytes   = 0;
    
    for (ifa = ifa_list; ifa; ifa = ifa->ifa_next)
    {
        //        if (AF_LINK != ifa->ifa_addr->sa_family)
        //            continue;
        
        //        if (!(ifa->ifa_flags & IFF_UP) && !(ifa->ifa_flags & IFF_RUNNING))
        //            continue;
        
        if (ifa->ifa_data == 0) {
//            printf("ifa->ifa_data == 0\n");
            continue;
        }
        
        struct if_data *if_data = (struct if_data *)ifa->ifa_data;
        
        totalDownloadBytes += if_data->ifi_ibytes;
        totalUploadBytes   += if_data->ifi_obytes;
        
        //            NSLog(@"%s :iBytes is %d, oBytes is %d",
        //                  ifa->ifa_name, iBytes, oBytes);
        
//        printf("%s iBytes:%d oBytes:%d\n", ifa->ifa_name,if_data->ifi_ibytes, if_data->ifi_obytes);
        
    }
    freeifaddrs(ifa_list);
    
    CFAbsoluteTime cpuTicks = CFAbsoluteTimeGetCurrent(); // 可按需调整该位置(时机)
    /* 事后处理 */
    
    NSString *key = nil;
    NetworkSensor * sensor = nil;
    
    // @"NGDI"
    key = (NSString *)[NetworkSensor NETWORK_GLOBAL_DATA_IN_SPEED_KEY];
    sensor = [__sensors objectForKey:key];
    if (sensor) {
        [sensor pushValue:[NSNumber numberWithUnsignedInteger:totalDownloadBytes] AtAbsoluteTime:cpuTicks];
    }
    
    // @"NGDO"
    key = (NSString *)[NetworkSensor NETWORK_GLOBAL_DATA_OUT_SPEED_KEY];
    sensor = [__sensors objectForKey:key];
    if (sensor) {
        [sensor pushValue:[NSNumber numberWithUnsignedInteger:totalUploadBytes] AtAbsoluteTime:cpuTicks];
    }
}



// MARK: - 属性

@synthesize name         = _name;
@synthesize key          = _key;
@synthesize description  = _description;
@synthesize numericValue = _numericValue;
@synthesize unit         = _unit;

@synthesize history; // TODO:


// MARK: - 实例方法

- (instancetype)initWithKey:(NSString *)key {
    self = [super init];
    if (self) {
        _key          = key;
        _name         = NSLocalizedString(key, key);
        _description  = NSLocalizedString([key stringByAppendingString:(NSString * _Nonnull)DESCRIPTION_LOCALIZED_KEY_APPENDING_STRING], key);
        _numericValue = [NSNumber numberWithUnsignedInteger:0];
        _unit         = NSLocalizedString(@"Unit_BPS", @"B/s");
    }
    return self;
}

- (void)pushValue:(NSNumber *)value AtAbsoluteTime:(double)time {
    _oldAbsTime = _newAbsTime;
    _oldValue   = _newValue;
    
    _newAbsTime = time;
    _newValue   = [value unsignedIntValue];
    
    _numericValue  = [NSNumber numberWithUnsignedInteger:
                      (NSUInteger)((double)(_newValue - _oldValue)) / (_newAbsTime - _oldAbsTime)
                      ];
    
}

- (NSUInteger)hash {
    return [_name hash];
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@(%@):%lu%@", _name, _key, [_numericValue unsignedIntegerValue], _unit];
}



@end
