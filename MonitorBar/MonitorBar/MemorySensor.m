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
// MARK: -
// MARK: 类方法

/// 取得内核端口
+ (host_name_port_t)host {
    static host_name_port_t h = 0;
    if (h == 0) {
        h = mach_host_self();
    }
    
    return h;
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

@end
