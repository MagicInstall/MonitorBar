//
//  MonitorBar
//  StorageSensor.m
//
//  Created by wing on 2016/12/31.
//  Copyright © 2016 Magic Install. All rights reserved.
//

#import "StorageSensor.h"

#include <sys/mount.h>

#import <IOKit/IOKitLib.h>
#import <IOKit/storage/IOBlockStorageDriver.h>

const NSString * _Nonnull DESCRIPTION_LOCALIZED_KEY_APPENDING_STRING = @"_Description";

@implementation StorageSensor {
    // MARK: -
    // MARK: 实例私有常量
    
    /// 存放自开机以来, 上一次读数的CPU 时间
    double _oldAbsTime;
    
    /// 存放自开机以来, 上一次的读数
    UInt64 _oldValue;
    
    /// 存放自开机以来, 本次读数的CPU 时间
    double _newAbsTime;
    
    /// 存放自开机以来, 本次的读数
    UInt64 _newValue;
}

//static const NSString *NETWORK_GLOBAL_DATA_IN_SPEED_KEY = @"NGDI";


// MARK: -
// MARK: 类常量

+ (const NSString *)STORAGE_GLOBAL_DATA_WRITE_SPEED_KEY { return @"SGDW"; }
+ (const NSString *)STORAGE_GLOBAL_DATA_READ_SPEED_KEY  { return @"SGDR"; }



// MARK: -
// MARK: 类变量

static NSMutableDictionary /*NSMutableSet<StorageSensor *>*/ *__sensors = nil;



// MARK: -
// MARK: 类方法

+ (NSSet<NSString *> *)effectiveKeys {
    return [[NSSet alloc] initWithObjects:
            [StorageSensor STORAGE_GLOBAL_DATA_READ_SPEED_KEY],
            [StorageSensor STORAGE_GLOBAL_DATA_WRITE_SPEED_KEY]
            , nil
            ];
}

//+ (NSSet<Sensor> *)buildSensorsFromKeys:(nonnull NSSet<NSString*>*)keys {
+ (NSDictionary *)buildSensorsFromKeys:(NSSet<NSString*>*)keys {
    
    @synchronized (__sensors) {
        // 先取可用key ,用这个数量初始化 __sensors.
        NSSet<NSString *> *effectiveKeys = [StorageSensor effectiveKeys];
        
//        if (__sensors == nil) {
//            __sensors = [[NSMutableSet alloc] initWithCapacity:[effectiveKeys count]];
        __sensors = [[NSMutableDictionary alloc] initWithCapacity:[effectiveKeys count]];
//        }
        
//        NSMutableDictionary *ddd = [[NSMutableDictionary alloc] init];
        
        for (NSString *key in keys) {
            if ([effectiveKeys containsObject:key]) {
//                [__sensors addObject:[[StorageSensor alloc] initWithKey:key]];
                [__sensors setObject:[[StorageSensor alloc] initWithKey:key] forKey:key];
            }
        }
        
        // @"SGDW"
//        key = (NSString *)[StorageSensor STORAGE_GLOBAL_DATA_WRITE_SPEED_KEY];
//        if ([keys containsObject:key]) {
//            [__sensors addObject:[[StorageSensor alloc] initWithKey:key]];
//        }
//        
//        // @"SGDR"
//        key = (NSString *)[StorageSensor STORAGE_GLOBAL_DATA_READ_SPEED_KEY];
//        if ([keys containsObject:key]) {
//            [__sensors addObject:[[StorageSensor alloc] initWithKey:key]];
//        }
        
        
        [StorageSensor update];
    }
//    return (NSSet<Sensor> *)__sensors;
    return (NSDictionary *)__sensors;
}

//+ (NSSet<Sensor> *)activeSensors {
//    return (NSSet<Sensor> *)__sensors;
//}

+ (NSDictionary *)activeSensors {
    return __sensors;
}

// TODO: 合并到[StorageSensor update] 方法.
+ (io_iterator_t)IOService {
    static io_iterator_t drivelist = IO_OBJECT_NULL;
    
    if (drivelist == IO_OBJECT_NULL) {
//        io_iterator_t drivelist = IO_OBJECT_NULL;
        mach_port_t masterPort = IO_OBJECT_NULL;
        
        /* get ports and services for drive stats */
        /* Obtain the I/O Kit communication handle */
        IOMasterPort(bootstrap_port, &masterPort);
        
        /* Obtain the list of all drive objects */
        IOServiceGetMatchingServices(masterPort,
                                     IOServiceMatching("IOBlockStorageDriver"),
                                     &drivelist);
    }
    
    return drivelist;
}

/// 该方法的实现源自网络
+ (void)update {
    io_registry_entry_t drive  = 0; /* needs release */
    UInt64   totalReadBytes = 0;
    UInt64   totalWriteBytes = 0;
    
    io_iterator_t drivelist = [StorageSensor IOService];
    
    while ((drive = IOIteratorNext(drivelist))) {
        CFNumberRef  number  = 0; /* don't release */
        CFDictionaryRef properties = 0; /* needs release */
        CFDictionaryRef statistics = 0; /* don't release */
        UInt64  value  = 0;
        
        /* Obtain the properties for this drive object */
        IORegistryEntryCreateCFProperties(drive, (CFMutableDictionaryRef *) &properties, kCFAllocatorDefault, kNilOptions);
        
        
        /* Obtain the statistics from the drive properties */
        statistics = (CFDictionaryRef) CFDictionaryGetValue(properties, CFSTR(kIOBlockStorageDriverStatisticsKey));
        if (statistics) {
            /* Obtain the number of bytes read from the drive statistics */
            number = (CFNumberRef) CFDictionaryGetValue(statistics, CFSTR(kIOBlockStorageDriverStatisticsBytesReadKey));
            if (number) {
                CFNumberGetValue(number, kCFNumberSInt64Type, &value);
                totalReadBytes += value;
            }
            /* Obtain the number of bytes written from the drive statistics */
            number = (CFNumberRef) CFDictionaryGetValue (statistics, CFSTR(kIOBlockStorageDriverStatisticsBytesWrittenKey));
            if (number) {
                CFNumberGetValue(number, kCFNumberSInt64Type, &value);
                totalWriteBytes += value;
            }
        }
        /* Release resources */
        CFRelease(properties); properties = 0;
        IOObjectRelease(drive); drive = 0;
    }
    IOIteratorReset(drivelist);
    
//    UInt64 cpuTicks = mach_absolute_time(); // 可按需调整该位置(时机)
    CFAbsoluteTime cpuTicks = CFAbsoluteTimeGetCurrent(); // 可按需调整该位置(时机)
    /* 事后处理 */
    
    NSString *key = nil;
    StorageSensor * sensor = nil;
    
    // @"SGDR"
    key = (NSString *)[StorageSensor STORAGE_GLOBAL_DATA_READ_SPEED_KEY];
    sensor = [__sensors objectForKey:key];
    if (sensor) {
        [sensor pushValue:[NSNumber numberWithUnsignedLongLong:totalReadBytes] AtAbsoluteTime:cpuTicks];
    }
    
    // @"SGDW"
    key = (NSString *)[StorageSensor STORAGE_GLOBAL_DATA_WRITE_SPEED_KEY];
    sensor = [__sensors objectForKey:key];
    if (sensor) {
        [sensor pushValue:[NSNumber numberWithUnsignedLongLong:totalWriteBytes] AtAbsoluteTime:cpuTicks];
    }
}

//+(void) getDISKcountersWithDriveList:(io_iterator_t)drivelist i_dsk:(UInt64 *)i_dsk o_dsk:(UInt64 *)o_dsk {
//    io_registry_entry_t drive  = 0; /* needs release */
//    UInt64   totalReadBytes = 0;
//    UInt64   totalWriteBytes = 0;
//    
//    while ((drive = IOIteratorNext(drivelist))) {
//        CFNumberRef  number  = 0; /* don't release */
//        CFDictionaryRef properties = 0; /* needs release */
//        CFDictionaryRef statistics = 0; /* don't release */
//        UInt64  value  = 0;
//        
//        /* Obtain the properties for this drive object */
//        IORegistryEntryCreateCFProperties(drive, (CFMutableDictionaryRef *) &properties, kCFAllocatorDefault, kNilOptions);
//        
//        /* Obtain the statistics from the drive properties */
//        statistics = (CFDictionaryRef) CFDictionaryGetValue(properties, CFSTR(kIOBlockStorageDriverStatisticsKey));
//        if (statistics) {
//            /* Obtain the number of bytes read from the drive statistics */
//            number = (CFNumberRef) CFDictionaryGetValue(statistics, CFSTR(kIOBlockStorageDriverStatisticsBytesReadKey));
//            if (number) {
//                CFNumberGetValue(number, kCFNumberSInt64Type, &value);
//                totalReadBytes += value;
//            }
//            /* Obtain the number of bytes written from the drive statistics */
//            number = (CFNumberRef) CFDictionaryGetValue (statistics, CFSTR(kIOBlockStorageDriverStatisticsBytesWrittenKey));
//            if (number) {
//                CFNumberGetValue(number, kCFNumberSInt64Type, &value);
//                totalWriteBytes += value;
//            }
//        }
//        /* Release resources */
//        CFRelease(properties); properties = 0;
//        IOObjectRelease(drive); drive = 0;
//    }
//    IOIteratorReset(drivelist);
//    *i_dsk = totalReadBytes;
//    *o_dsk = totalWriteBytes;
//}

+ (void)test {
//    UInt64 i_dsk, o_dsk;
//    [StorageSensor getDISKcountersWithDriveList:[StorageSensor IOService] i_dsk:&i_dsk o_dsk:&o_dsk];
}



// MARK: -
// MARK: 属性

@synthesize name = _name;
@synthesize key  = _key;
@synthesize description = _description;
@synthesize numericValue = _numericValue;
@synthesize unit = _unit;

// MARK: -
// MARK: 实例方法

- (instancetype)initWithKey:(NSString *)key {
    self = [super init];
    if (self) {
        _key          = key;
        _name         = NSLocalizedString(key, key);
        _description  = NSLocalizedString([key stringByAppendingString:(NSString * _Nonnull)DESCRIPTION_LOCALIZED_KEY_APPENDING_STRING], key);
        _numericValue = [NSNumber numberWithDouble:0.0];
        _unit         = @"B/s";
    }
    return self;
}

- (void)pushValue:(NSNumber *)value AtAbsoluteTime:(double)time {
    _oldAbsTime = _newAbsTime;
    _oldValue = _newValue;
    
    _newAbsTime = time;
    _newValue = [value unsignedLongLongValue];
    
    _numericValue = [NSNumber numberWithDouble:(double)(_newValue - _oldValue) / (_newAbsTime - _oldAbsTime)];
}

- (NSUInteger)hash {
    return [_name hash];
}

- (NSString *)debugDescription {
    
//    return [NSString stringWithFormat:@"%@(%@):%f%@", _name, _key, [_numericValue doubleValue], _unit];
    return [NSString stringWithFormat:@"%@(%@):%f%@", _name, _key, [_numericValue doubleValue], _unit];
}

@end
