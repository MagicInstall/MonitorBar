//
//  MonitorBar
//  CPUSensor.m
//
//  Created by wing on 2016/12/31.
//  Copyright © 2016 Magic Install. All rights reserved.
//

#import "CPUSensor.h"

#import <mach/mach_host.h>
#import <mach/vm_map.h>

#include <sys/sysctl.h>

@implementation CPUSensor

// MARK: - 类常量

+ (const NSString *)CORE_USER_PERCENT_KEY_FORMAT   { return @"UC%XU"; }
+ (const NSString *)CORE_NICE_PERCENT_KEY_FORMAT   { return @"UC%XN"; }
+ (const NSString *)CORE_SYSTEM_PERCENT_KEY_FORMAT { return @"UC%XS"; }
+ (const NSString *)CORE_IDLE_PERCENT_KEY_FORMAT   { return @"UC%XI"; }


// MARK: - 类变量

static NSMutableDictionary *__sensors = nil;


// MARK: - 类方法

/// 取得内核端口
+ (host_name_port_t)host {
    static host_name_port_t h = 0;
    if (h == 0) {
        h = mach_host_self();
    }
    
    return h;
}

+ (NSUInteger) coreAmount{
    static NSUInteger count = 0;
    
    if (count == 0) {
        int mib[2U] = { CTL_HW, HW_NCPU };
        size_t sizeOfNumCPUs = sizeof(count);
        int status = sysctl(mib, 2U, &count, &sizeOfNumCPUs, NULL, 0U);
        if(status)
            count = 1;
        
        
        //        processor_cpu_load_info_t newCPUInfo;
        //        kern_return_t			  kr;
        //        mach_msg_type_number_t    load_count;
        //
        //        kr = host_processor_info([CPUSensor host],
        //                                 PROCESSOR_CPU_LOAD_INFO,
        //                                 &count,
        //                                 (processor_info_array_t *)&newCPUInfo,
        //                                 &load_count);
        //        if(kr == KERN_SUCCESS) {
        //            vm_deallocate(mach_task_self(),
        //                          (vm_address_t)newCPUInfo,
        //                          (vm_size_t)(load_count * sizeof(*newCPUInfo)));
        //
        //        }
        //        else count = 1;
    }
    
    return count;
}


//+ (processor_cpu_load_info_t)coreUsage:(processor_cpu_load_info_t *)lastCPUInfo {
//    processor_cpu_load_info_t		newCPUInfo;
//    kern_return_t					kr;
//    unsigned int					coreCount;
//    mach_msg_type_number_t			load_count;
//    NSInteger						totalCPUTicks;
//
//    kr = host_processor_info([CPUSensor host],
//                             PROCESSOR_CPU_LOAD_INFO,
//                             &coreCount,
//                             (processor_info_array_t *)&newCPUInfo,
//                             &load_count);
//    if(kr != KERN_SUCCESS) return 0;
//
//    for (NSInteger c = 0; c < coreCount; c++) {
//
//    }
//
//
//    for (NSInteger i = 0; i < coreCount; i++) {
//        if (i >= [CPUSensor coreAmount]) break;
//
//        totalCPUTicks = 0;
//
//        for (NSInteger t = 0; t < CPU_STATE_MAX; t++) {
//            totalCPUTicks += newCPUInfo[i].cpu_ticks[t] - (*lastCPUInfo)[i].cpu_ticks[t];
//        }
//
//        immediateUser[i]   = (totalCPUTicks == 0) ? 0 : (CGFloat)(newCPUInfo[i].cpu_ticks[CPU_STATE_USER] - (*lastCPUInfo)[i].cpu_ticks[CPU_STATE_USER]) / (CGFloat)totalCPUTicks * 100.;
//        immediateSystem[i] = (totalCPUTicks == 0) ? 0 : (CGFloat)(newCPUInfo[i].cpu_ticks[CPU_STATE_SYSTEM] - (*lastCPUInfo)[i].cpu_ticks[CPU_STATE_SYSTEM]) / (CGFloat)totalCPUTicks * 100.;
//        immediateNice[i]   = (totalCPUTicks == 0) ? 0 : (CGFloat)(newCPUInfo[i].cpu_ticks[CPU_STATE_NICE] - (*lastCPUInfo)[i].cpu_ticks[CPU_STATE_NICE]) / (CGFloat)totalCPUTicks * 100.;
//
//        immediateTotal[i] = immediateUser[i] + immediateSystem[i] + immediateNice[i];
//
//        for(NSInteger t = 0; t < CPU_STATE_MAX; t++)
//            (*lastCPUInfo)[i].cpu_ticks[t] = newCPUInfo[i].cpu_ticks[t];
//    }
//
//    vm_deallocate(mach_task_self(),
//                  (vm_address_t)newCPUInfo,
//                  (vm_size_t)(load_count * sizeof(*newCPUInfo)));
//
//    return (NSInteger)coreCount;
//
//}

+ (void)test {
    printf("%ld Core\n", [CPUSensor coreAmount]);
    
    struct kinfo_proc *mylist = NULL;
    struct kinfo_proc **procList = &mylist;
    
    size_t mycount = 0;
    size_t *procCount = &mycount;
    // Returns a list of all BSD processes on the system.  This routine
    // allocates the list and puts it in *procList and a count of the
    // number of entries in *procCount.  You are responsible for freeing
    // this list (use "free" from System framework).
    // On success, the function returns 0.
    // On error, the function returns a BSD errno value.
    
    int                 err;
    struct kinfo_proc *        result;
    bool                done;
    static const int    name[] = { CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0 };
    // Declaring name as const requires us to cast it when passing it to
    // sysctl because the prototype doesn't include the const modifier.
    size_t              length;
    
    //    assert( procList != NULL);
    //    assert(*procList == NULL);
    //    assert(procCount != NULL);
    
    *procCount = 0;
    
    // We start by calling sysctl with result == NULL and length == 0.
    // That will succeed, and set length to the appropriate length.
    // We then allocate a buffer of that size and call sysctl again
    // with that buffer.  If that succeeds, we're done.  If that fails
    // with ENOMEM, we have to throw away our buffer and loop.  Note
    // that the loop causes use to call sysctl with NULL again; this
    // is necessary because the ENOMEM failure case sets length to
    // the amount of data returned, not the amount of data that
    // could have been returned.
    
    result = NULL;
    done = false;
    do {
        assert(result == NULL);
        
        // Call sysctl with a NULL buffer.
        
        length = 0;
        err = sysctl( (int *) name, (sizeof(name) / sizeof(*name)) - 1,
                     NULL, &length,
                     NULL, 0);
        if (err == -1) {
            err = errno;
        }
        
        // Allocate an appropriately sized buffer based on the results
        // from the previous call.
        
        if (err == 0) {
            result = malloc(length);
            if (result == NULL) {
                err = ENOMEM;
            }
        }
        
        // Call sysctl again with the new buffer.  If we get an ENOMEM
        // error, toss away our buffer and start again.
        
        if (err == 0) {
            err = sysctl( (int *) name, (sizeof(name) / sizeof(*name)) - 1,
                         result, &length,
                         NULL, 0);
            if (err == -1) {
                err = errno;
            }
            if (err == 0) {
                done = true;
            } else if (err == ENOMEM) {
                assert(result != NULL);
                free(result);
                result = NULL;
                err = 0;
            }
        }
    } while (err == 0 && ! done);
    
    // Clean up and establish post conditions.
    
    if (err != 0 && result != NULL) {
        free(result);
        result = NULL;
    }
    *procList = result;
    if (err == 0) {
        *procCount = length / sizeof(struct kinfo_proc);
    }
    
    assert( (err == 0) == (*procList != NULL) );
    
    
    
}

+ (NSSet<NSString *> *)effectiveKeys {
    static NSMutableSet<NSString *> *keys = nil;
    
    if (keys == nil) {
        keys = [[NSMutableSet alloc] initWithCapacity:16];
        
        for (uint c = 0; c < [CPUSensor coreAmount]; c++) {
            [keys addObject:[NSString stringWithFormat:(NSString *)[CPUSensor CORE_USER_PERCENT_KEY_FORMAT], c]];
            [keys addObject:[NSString stringWithFormat:(NSString *)[CPUSensor CORE_NICE_PERCENT_KEY_FORMAT], c]];
            [keys addObject:[NSString stringWithFormat:(NSString *)[CPUSensor CORE_SYSTEM_PERCENT_KEY_FORMAT], c]];
            [keys addObject:[NSString stringWithFormat:(NSString *)[CPUSensor CORE_IDLE_PERCENT_KEY_FORMAT], c]];
        }
    }
    
    return keys;
}

+ (NSDictionary *)buildSensorsFromKeys:(NSSet<NSString*>*)keys {
    
    //    @synchronized (__sensors) {
    // 先取可用key ,用这个数量初始化 __sensors.
    NSSet<NSString *> *effectiveKeys = [CPUSensor effectiveKeys];
    
    __sensors = [[NSMutableDictionary alloc] initWithCapacity:[effectiveKeys count]];
    
    
    for (NSString *key in keys) {
        if ([effectiveKeys containsObject:key]) {
            [__sensors setObject:[[CPUSensor alloc] initWithKey:key] forKey:key];
        }
    }
    
    [CPUSensor update];
    
    return (NSDictionary *)__sensors;
}

+ (NSDictionary *)activeSensors {
    return [__sensors copy]; // 返回浅副本
}

+ (id<Sensor>)activeSensorsWithKey:(NSString *)key {
    return [__sensors objectForKey:key];
}

//  在Linux 上, 获取CPU 时间的单位是jiffies, 1 jiffies = 0.01 秒;
//  一般而言，idle + user + nice + system 约等于100%;
+ (void)update {
    static processor_info_array_t cpuInfo, prevCpuInfo;
    static mach_msg_type_number_t numCpuInfo, numPrevCpuInfo;
    
    natural_t numCPUs = 0;
    kern_return_t err = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &numCPUs, &cpuInfo, &numCpuInfo);
    if(err == KERN_SUCCESS) {
        @synchronized (__sensors) {

            for(uint i = 0; i < numCPUs/*[CPUSensor coreAmount]*/; ++i) {
                integer_t inUser, inNice, inSystem, inIdel, total;
                
                inUser   = cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER];
                inNice   = cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE];
                inSystem = cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM];
                inIdel   = cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE];
                          
                if(prevCpuInfo) {
                    inUser   -= prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER];
                    inNice   -= prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE];
                    inSystem -= prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM];
                    inIdel   -= prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE];
                    
    //            } else {
    //                inUser = cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER] + cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM] + cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE];
    //                total = inUser + cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE];
                }
                
                total = inUser + inNice + inSystem + inIdel;
                // 防止除0
                if (total == 0) total = 1;
                
                CFAbsoluteTime cpuTicks = CFAbsoluteTimeGetCurrent(); // 可按需调整该位置(时机)
                /* 事后处理 */
                
                NSString *key = nil;
                CPUSensor * sensor = nil;
                
                // @"UC%XU"
                key = [NSString stringWithFormat:(NSString *)[CPUSensor CORE_USER_PERCENT_KEY_FORMAT], i];
                sensor = [__sensors objectForKey:key];
                if (sensor) {
                    [sensor pushValue:[NSNumber numberWithFloat:((CGFloat)inUser / (CGFloat)total)] AtAbsoluteTime:cpuTicks];
                }
                
                // @"UC%XN"
                key = [NSString stringWithFormat:(NSString *)[CPUSensor CORE_NICE_PERCENT_KEY_FORMAT], i];
                sensor = [__sensors objectForKey:key];
                if (sensor) {
                    [sensor pushValue:[NSNumber numberWithFloat:((CGFloat)inNice / (CGFloat)total)] AtAbsoluteTime:cpuTicks];
                }
                
                // @"UC%XS"
                key = [NSString stringWithFormat:(NSString *)[CPUSensor CORE_SYSTEM_PERCENT_KEY_FORMAT], i];
                sensor = [__sensors objectForKey:key];
                if (sensor) {
                    [sensor pushValue:[NSNumber numberWithFloat:((CGFloat)inSystem / (CGFloat)total)] AtAbsoluteTime:cpuTicks];
                }
                
                // @"UC%XI"
                key = [NSString stringWithFormat:(NSString *)[CPUSensor CORE_IDLE_PERCENT_KEY_FORMAT], i];
                sensor = [__sensors objectForKey:key];
                if (sensor) {
                    [sensor pushValue:[NSNumber numberWithFloat:((CGFloat)inIdel / (CGFloat)total)] AtAbsoluteTime:cpuTicks];
                }
                
                
    //            NSLog(@"Core: %u Usage: %f",i,inUse / total);
            }
        } // @synchronized (__sensors)
        
        if(prevCpuInfo) {
            size_t prevCpuInfoSize = sizeof(integer_t) * numPrevCpuInfo;
            vm_deallocate(mach_task_self(), (vm_address_t)prevCpuInfo, prevCpuInfoSize);
        }
        
        prevCpuInfo = cpuInfo;
        numPrevCpuInfo = numCpuInfo;
        
        cpuInfo = NULL;
        numCpuInfo = 0;
    } else {
        NSAssert(false, @"获取CPU 占用率出错!");
    }
}


// MARK: - 属性

@synthesize name         = _name;
@synthesize key          = _key;
@synthesize description  = _description;
@synthesize numericValue = _numericValue;
@synthesize unit         = _unit;

@synthesize history      = _history;


// MARK: - 实例方法

- (instancetype)initWithKey:(NSString *)key {
    self = [super init];
    if (self) {
//        NSAssert([key length] >= 4, @"未知的key");

        NSString *sub = [key substringToIndex:2];
        NSAssert([sub isEqualToString:@"UC"], @"未知的key");

        NSString *format = @"UC%d?";
        
        // 取得序号
        NSUInteger index = 0;
        if ([key length] >= 4) {
            // 取得中间十六进制的序号
            sub = [key substringFromIndex:2];
            sub = [sub substringToIndex:[sub length] - 1];
            index = [sub hexToInt];
            
            // 顺便合成格式
            format = [NSString stringWithFormat:@"UC%@%c", @"%d", [key characterAtIndex:[key length] - 1]];
        }
        
   
        _key          = key;
        _name         = [NSString stringWithFormat:NSLocalizedString(format, key), index];
        _description  = [NSString stringWithFormat:
                            NSLocalizedString([format stringByAppendingString:(NSString * _Nonnull)DESCRIPTION_LOCALIZED_KEY_APPENDING_STRING], key),
                         index];
        _numericValue = [NSNumber numberWithUnsignedInteger:0];
        _unit         = NSLocalizedString(@"Unit_Percent", @"%");
        
        _history      = [[HistoryValues alloc] initWithLength:14/*drawCPUMemoryPie 绘图方法需要14个*//* TODO: 改为读取宏 / 在Sensor 类加一个历史步数属性*/];
    }
    return self;
}

- (void)pushValue:(NSNumber *)value AtAbsoluteTime:(double)time {
    _numericValue = value;
    [_history pushNumeric:value CpuTick:time];
//    [_history pushFloat:value.floatValue CpuTick:time];
}

- (NSUInteger)hash {
    return [_key hash];
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@(%@):%.1f%@", _name, _key, [_numericValue floatValue] * 100.0, _unit];
}
@end

// MARK: -  -

@implementation NSString (NSStringTransform)
- (NSUInteger) hexToInt {
    NSUInteger result = 0;
    
    NSUInteger len = [self length];
    const char *chars = [self UTF8String];
    
    for (int i = 0; i < len; i++) {
        if ((chars[i] >= '0') && (chars[i] <= '9')) {
            result += (chars[i] - '0') << i;
        }
        else if ((chars[i] >= 'a') && (chars[i] <= 'z')) {
            result += (chars[i] - 'z') << i;
        }
        else if ((chars[i] >= 'A') && (chars[i] <= 'Z')) {
            result += (chars[i] - 'A') << i;
        }
    }
    
    return result;
}
@end

