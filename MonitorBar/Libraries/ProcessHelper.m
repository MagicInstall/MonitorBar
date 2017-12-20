//
//  MonitorBar
//  ProccessHelper.m
//
//  Created by wing on 2017/6/8.
//  Copyright © 2017 Magic Install. All rights reserved.
//

#import "ProcessHelper.h"

#include <sys/sysctl.h>
#include <libproc.h>

@implementation ProcessHelper

/// 返回所有正在运行的进程的 id，name，占用cpu，运行时间
+ (NSArray *)CpuUsage
{
    NSMutableArray * result = [[NSMutableArray alloc] init];
    
                uint64_t afterTimeTotal = 0;
                uint64_t afterTimeUsage = 0;
    for (int t = 0; t < 100; t++) {
        
 
    
        int psize = proc_listpids(PROC_ALL_PIDS, 0, NULL, 0);
        NSAssert((psize > 0), @"囧...");
        int pcount = psize / sizeof(pid_t);
        pid_t allPid[pcount];
        psize = proc_listpids(PROC_ALL_PIDS, 0, allPid, psize);
        if ((psize / sizeof(struct kinfo_proc)) < pcount) pcount = psize / sizeof(pid_t);
        for (int i = 0 ; i < pcount; i ++) {
            if (allPid[i] != 37475/*492*/) continue;
            
            
            struct proc_taskallinfo proc;
            if (proc_pidinfo(allPid[i], PROC_PIDTASKALLINFO, 0, &proc, PROC_PIDTASKALLINFO_SIZE)) {
                uint64_t nowTimeTotal = proc.ptinfo.pti_total_user   + proc.ptinfo.pti_total_system;
                uint64_t nowTimeUsage = proc.ptinfo.pti_threads_user /*+ proc.ptinfo.pti_threads_system*/;
                printf("%s[%d] %.2fMB %llu%%\n", proc.pbsd.pbi_name, allPid[i], (proc.ptinfo.pti_resident_size / 1000000.0f),
                       ((nowTimeUsage - afterTimeUsage) * 100 / (nowTimeTotal - afterTimeTotal) / 4)
                       );
                afterTimeTotal = nowTimeTotal;
                afterTimeUsage = nowTimeUsage;
            }

        }
        
        usleep(1000000);
    }
    
    //指定名字参数，按照顺序第一个元素指定本请求定向到内核的哪个子系统，第二个及其后元素依次细化指定该系统的某个部分。
    //CTL_KERN，KERN_PROC,KERN_PROC_ALL 正在运行的所有进程
    int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL ,0};
    //size_t miblen = 4;
    //值-结果参数：函数被调用时，size指向的值指定该缓冲区的大小；函数返回时，该值给出内核存放在该缓冲区中的数据量
    //如果这个缓冲不够大，函数就返回ENOMEM错误
    size_t size = 0;
    
    
    
    NSUInteger count = size / sizeof(struct kinfo_proc);
    
    for (int t = 0; t < 100; t++) {
    //返回0，成功；返回-1，失败
    /* int status  = */sysctl(mib, 4U, NULL, &size, NULL, 0);
        count = size / sizeof(struct kinfo_proc);
        
        
        NSAssert((count > 0), @"囧...");

        struct kinfo_proc process[count];
        
        

    
    
//    struct kinfo_proc * process = NULL;
//    struct kinfo_proc * newprocess = NULL;
    
//    do {
//        size += size / 10;
//        newprocess = realloc(process, size);
//        if (!newprocess)
//        {
//            if (process)
//            {
//                free(process);
//                process = NULL;
//            }
//            return result;
//        }
//        process = newprocess;
//        status = sysctl(mib, 4U, process, &size, NULL, 0);
//    } while (status == -1 && errno == ENOMEM);
    
    
        int status = sysctl(mib, 4U, process, &size, NULL, 0);
        if (status) {
            printf("[ProccessHelper CpuUsage] 取得进程占用率出错, status:%d\n", status);
            return result;
        }
        
    
//        if (size % sizeof(struct kinfo_proc) == 0)
//        {
            //int count = (int) size / sizeof(struct kinfo_proc);
//            if (count)
//            {
        if ((size / sizeof(struct kinfo_proc)) < count) count = size / sizeof(struct kinfo_proc);
            
        NSLog(@"---------- %6d-----------", t);
        for (NSInteger i = 0; i < count; i++) {
            if (process[i].kp_proc.p_pid != /*453*/37475) continue;

            
            //if (process[i].kp_proc.p_estcpu || process[i].kp_proc.p_pctcpu)
                printf("[%d] %f\n", process[i].kp_proc.p_pid, [[NSDate date] timeIntervalSince1970] - process[i].kp_proc.p_un.__p_starttime.tv_sec);
            
            continue;
            
            NSString *name    = [NSString stringWithUTF8String:process[i].kp_proc.p_comm];
                        //NSString * pid       = [NSString stringWithFormat:@"%d",  process[i].kp_proc.p_pid];
            NSNumber *pid     = [NSNumber numberWithUnsignedInteger:process[i].kp_proc.p_pid];
                        //NSString * percent   = [NSString stringWithFormat:@"%d",  process[i].kp_proc.p_estcpu];
            NSNumber *percent = [NSNumber numberWithUnsignedInteger:process[i].kp_proc.p_un.__p_starttime.tv_sec];
                        //NSString * startTime = [NSString stringWithFormat:@"%ld", process[i].kp_proc.p_un.__p_starttime.tv_sec];
                        //double t = [[NSDate date] timeIntervalSince1970] - process[i].kp_proc.p_un.__p_starttime.tv_sec;
                        //NSString * useTiem   = [NSString stringWithFormat:@"%f",t];
                        //NSString * status = [[NSString alloc] initWithFormat:@"%d",process[i].kp_proc.p_flag];
            
            // 更多的进程信息可参照 struct extern_proc 的声明.
            
            /*if (process[i].kp_proc.p_swtime)  */printf("%s\n", process[i].kp_proc.p_comm);
                        
                        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            
                        [dic setValue:pid     forKey:@"PID"];
                        [dic setValue:name    forKey:@"Name"];
                        [dic setValue:percent forKey:@"%CPU"];
                        //[dic setValue:useTiem forKey:@"UseTime"];
                        //[dic setValue:startTime    forKey:@"StartTime"];
                        // 18432 is the currently running application
                        // 16384 is background
                        //[dic setValue:status forKey:@"status"];

                        [result addObject:dic];

        }
//                free(process);
//                process = NULL;
                //NSLog(@"array = %@",array);
    
        // 将占用率最高的排在前面
        [result sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            if ([[obj1 objectForKey:@"%CPU"] unsignedIntegerValue] > [[obj1 objectForKey:@"%CPU"] unsignedIntegerValue]) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            if ([[obj1 objectForKey:@"%CPU"] unsignedIntegerValue] < [[obj1 objectForKey:@"%CPU"] unsignedIntegerValue]) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            return (NSComparisonResult)NSOrderedSame;
        }];
    
        
//            }
//        }
//    }
//    return nil;
        usleep(1000000);
    }
    
    return result;
}
@end
