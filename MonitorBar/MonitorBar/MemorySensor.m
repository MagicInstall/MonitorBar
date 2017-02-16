//
//  MonitorBar
//  MemorySensor.m
//
//  Created by wing on 2017/1/1.
//  Copyright © 2016 Magic Install. All rights reserved.
//

#import "MemorySensor.h"
#import <mach/mach_host.h>
#include <sys/sysctl.h>

@implementation MemorySensor

// MARK: - 类常量

+ (const NSString *)MEMORY_FREE_KEY     { return @"UsMF"; }

+ (const NSString *)MEMORY_INACTIVE_KEY { return @"UsMI"; }

+ (const NSString *)MEMORY_ACTIVE_KEY   { return @"UsMA"; }

+ (const NSString *)MEMORY_WIRE_KEY     { return @"UsMW"; }


// MARK: - 类变量

static NSMutableDictionary /*NSMutableSet<StorageSensor *>*/ *__sensors = nil;


// MARK: - 类方法

/// 取得内核端口
+ (host_name_port_t)host {
    static host_name_port_t h = 0;
    if (h == 0) {
        h = mach_host_self();
    }
    
    return h;
}

+ (NSUInteger) getPageSize {
    NSUInteger result = 0;
    
    if (result == 0) {
        
        int vmmib[2] = { CTL_VM, VM_SWAPUSAGE };
        struct xsw_usage swapInfo;
        size_t swapLength = sizeof(swapInfo);
        if (sysctl(vmmib, 2, &swapInfo, &swapLength, NULL, 0) >= 0) {
            result = swapInfo.xsu_pagesize;
        } else {
            NSAssert(false, @"获取分页大小出错, 默认初始化为4096");
            result = 4096;
        }
    }
    
    return result;
}

+ (NSUInteger) getPhysicalTotal {
    static NSUInteger result = 0;
    
    if (result == 0) {
        result = [[NSProcessInfo processInfo] physicalMemory];
    }
    
    return result;
}

+ (void)test {
    kern_return_t kr;
    vm_statistics_data_t stats;
    unsigned int numBytes = HOST_VM_INFO_COUNT;
    
    kr = host_statistics([self host], HOST_VM_INFO, (host_info_t)&stats, &numBytes);
    if (kr != KERN_SUCCESS) {
        return;
    }
//    else {
//        vm_statistics_data_t		currentDiffs;
//        vm_statistics_data_t		lastStats;
//
//        currentDiffs.free_count      = (stats.free_count - lastStats.free_count);
//        currentDiffs.active_count    = (stats.active_count - lastStats.active_count);
//        currentDiffs.inactive_count  = (stats.inactive_count - lastStats.inactive_count);
//        currentDiffs.wire_count      = (stats.wire_count - lastStats.wire_count);
//        currentDiffs.faults          = (stats.faults - lastStats.faults);
//        currentDiffs.pageins         = (stats.pageins - lastStats.pageins);
//        currentDiffs.pageouts        = (stats.pageouts - lastStats.pageouts);
//        
//        lastStats.free_count         = stats.free_count;
//        lastStats.active_count       = stats.active_coun7t;
//        lastStats.inactive_count     = stats.inactive_count;
//        lastStats.wire_count         = stats.wire_count;
//        lastStats.faults             = stats.faults;
//        lastStats.pageins            = stats.pageins;
//        lastStats.pageouts           = stats.pageouts;
//        lastStats.lookups            = stats.lookups;
//        lastStats.hits               = stats.hits;
//    }
    
//    if (values1) [values1 setNextValue:currentDiffs.faults];
//    if (values2) [values2 setNextValue:currentDiffs.pageins];
//    if (values3) [values3 setNextValue:currentDiffs.pageouts];
    
    printf("%llu\n", [[NSProcessInfo processInfo] physicalMemory]);
    
    // Swap space monitoring.
    int vmmib[2] = { CTL_VM, VM_SWAPUSAGE };
    struct xsw_usage swapInfo;
    size_t swapLength = sizeof(swapInfo);
    if (sysctl(vmmib, 2, &swapInfo, &swapLength, NULL, 0) >= 0) {
//        self.usedSwap = swapInfo.xsu_used;
//        self.totalSwap = swapInfo.xsu_total;
        NSLog(@"Used: %llu (%3.2fM)    Total: %llu (%3.2fM)", swapInfo.xsu_used, (float)swapInfo.xsu_used / 1024. / 1024., swapInfo.xsu_total, (float)swapInfo.xsu_total / 1024. / 1024.);
    }
    
}

+ (NSSet<NSString *> *)effectiveKeys {
    return [[NSSet alloc] initWithObjects:
            [MemorySensor MEMORY_FREE_KEY],
            [MemorySensor MEMORY_INACTIVE_KEY],
            [MemorySensor MEMORY_ACTIVE_KEY],
            [MemorySensor MEMORY_WIRE_KEY],
            nil
            ];
}

+ (NSDictionary *)buildSensorsFromKeys:(NSSet<NSString*>*)keys {
    
    //    @synchronized (__sensors) {
    // 先取可用key ,用这个数量初始化 __sensors.
    NSSet<NSString *> *effectiveKeys = [MemorySensor effectiveKeys];
    
    __sensors = [[NSMutableDictionary alloc] initWithCapacity:[effectiveKeys count]];
    
    
    for (NSString *key in keys) {
        if ([effectiveKeys containsObject:key]) {
            [__sensors setObject:[[MemorySensor alloc] initWithKey:key] forKey:key];
        }
    }
    
    [MemorySensor update];
    
    return (NSDictionary *)__sensors;
}

+ (NSDictionary *)activeSensors {
    return [__sensors copy]; // 返回浅副本
}

+ (id<Sensor>)activeSensorsWithKey:(NSString *)key {
    return [__sensors objectForKey:key];
}

+ (void)update {
    kern_return_t kr;
    vm_statistics_data_t stats;
    unsigned int numBytes = HOST_VM_INFO_COUNT;
    
    kr = host_statistics([self host], HOST_VM_INFO, (host_info_t)&stats, &numBytes);
    if (kr != KERN_SUCCESS) {
        NSAssert(false, @"获取内存信息出错!");
        return;
    }
    
    CFAbsoluteTime cpuTicks = CFAbsoluteTimeGetCurrent(); // 可按需调整该位置(时机)
    /* 事后处理 */
    
    NSString *key = nil;
    MemorySensor * sensor = nil;
    NSUInteger pgSize = [MemorySensor getPageSize];
    
    // @"UsMF"
    key = (NSString *)[MemorySensor MEMORY_FREE_KEY];
    sensor = [__sensors objectForKey:key];
    if (sensor) {
        [sensor pushValue:[NSNumber numberWithUnsignedLong:stats.free_count * pgSize] AtAbsoluteTime:cpuTicks];
    }
    
    // @"UsMI"
    key = (NSString *)[MemorySensor MEMORY_INACTIVE_KEY];
    sensor = [__sensors objectForKey:key];
    if (sensor) {
        [sensor pushValue:[NSNumber numberWithUnsignedLong:stats.inactive_count * pgSize] AtAbsoluteTime:cpuTicks];
    }
    
    // @"UsMA"
    key = (NSString *)[MemorySensor MEMORY_ACTIVE_KEY];
    sensor = [__sensors objectForKey:key];
    if (sensor) {
        [sensor pushValue:[NSNumber numberWithUnsignedLong:stats.active_count * pgSize] AtAbsoluteTime:cpuTicks];
    }
    
    // @"UsMW"
    key = (NSString *)[MemorySensor MEMORY_WIRE_KEY];
    sensor = [__sensors objectForKey:key];
    if (sensor) {
        [sensor pushValue:[NSNumber numberWithUnsignedLong:stats.wire_count * pgSize] AtAbsoluteTime:cpuTicks];
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
        _numericValue = [NSNumber numberWithUnsignedLong:0];
        _unit         = NSLocalizedString(@"Unit_Bytes", @"B");
    }
    return self;
}

- (void)pushValue:(NSNumber *)value AtAbsoluteTime:(double)time {
    _numericValue  = value;
}

- (NSUInteger)hash {
    return [_key hash];
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@(%@):%lu%@", _name, _key, [_numericValue unsignedLongValue], _unit];
}



@end
