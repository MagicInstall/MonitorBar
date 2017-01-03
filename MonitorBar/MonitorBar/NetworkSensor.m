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

@implementation NetworkSensor


// MARK: -
// MARK: 类常量
static const NSString *NETWORK_GLOBAL_DATA_IN_SPEED_KEY = @"NGDI";
static const NSString *NETWORK_GLOBAL_DATA_OUT_SPEED_KEY = @"NGDO";

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

@end
