//
//  MonitorBar
//  ProccessHelper.h
//
//  Created by wing on 2017/6/8.
//  Copyright © 2017 Magic Install. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProcessHelper : NSObject

/// 取得全部进程的cpu 占用率
+ (NSArray *)CpuUsage;
@end
