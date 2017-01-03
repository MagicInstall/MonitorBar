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

+ (NSInteger) coreAmount{
    static unsigned int count = 0;
    
    if (count == 0) {
        processor_cpu_load_info_t newCPUInfo;
        kern_return_t			  kr;
        mach_msg_type_number_t    load_count;
        
        kr = host_processor_info([CPUSensor host],
                                 PROCESSOR_CPU_LOAD_INFO,
                                 &count,
                                 (processor_info_array_t *)&newCPUInfo,
                                 &load_count);
        if(kr == KERN_SUCCESS) {
            vm_deallocate(mach_task_self(),
                          (vm_address_t)newCPUInfo,
                          (vm_size_t)(load_count * sizeof(*newCPUInfo)));
            
        }
        else count = 0;
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

@end
