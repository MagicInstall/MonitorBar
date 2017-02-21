//
//  MonitorBar
//  Sensor.m
//
//  Created by wing on 2016/12/31.
//  Copyright © 2016 Magic Install. All rights reserved.
//

#import "Sensor.h"

const NSString * _Nonnull DESCRIPTION_LOCALIZED_KEY_APPENDING_STRING = @"_Description";


// MARK: -  -

@implementation HistoryValues (SensorHistoryValues)

- (void)pushNumeric:(nonnull NSNumber *)value CpuTick: (CFAbsoluteTime)tick {
    [self pushObject:[[ValueAndCpuTick alloc] initWithValue:value CpuTick:tick]];
}

//- (void)pushFloat: (float) value CpuTick: (CFAbsoluteTime)tick {
//    [self pushObject:[[ValueAndCpuTick alloc] initWithValue:[NSNumber numberWithFloat:value] CpuTick:tick]];
//}

- (nonnull NSNumber *) valueWithIndex: (NSUInteger)index {
    id object = [self valueAndCpuTickWithIndex:index];
    if ((object != nil) && ([object isKindOfClass: [ValueAndCpuTick class]])) {
        return object;
    }
    return [NSNumber numberWithUnsignedInteger:0];
}

- (nonnull ValueAndCpuTick *) valueAndCpuTickWithIndex: (NSUInteger)index {
    id object = [self objectWithIndex:index];
    if ((object != nil) && ([object isKindOfClass: [ValueAndCpuTick class]])) {
        return object;
    }
    return [[ValueAndCpuTick alloc] initWithValue:[NSNumber numberWithUnsignedInteger:0] CpuTick:0];
}

@end


// MARK: -  -

@implementation ValueAndCpuTick

- (instancetype)initWithValue: (NSNumber *)value CpuTick: (CFAbsoluteTime)tick {
    self = [super init];
    if (self) {
        [self setValue: value];
        [self setCpuTick: tick];
    }
    return self;
}

@end
