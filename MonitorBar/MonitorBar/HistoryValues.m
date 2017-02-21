//
//  MonitorBar
//  HistoryValues.m
//
//  Created by wing on 2017/1/1.
//  Copyright © 2016 Magic Install. All rights reserved.
//

#import "HistoryValues.h"

@implementation HistoryValues {
    NSUInteger _length;
    NSMutableArray<HistoryValues *>* _array;
}

// MARK: - 类常量
static const NSUInteger HISTORY_LENGTH_MAX_DEFAULTE = 10;


// MARK: - 属性

- (void)setLength:(NSUInteger)length {
    _length = length;
    while (_array.count > _length) {
        [_array removeLastObject];
    }
}
- (NSUInteger)length {
    return _length;
}

@synthesize history = _array;

// MARK: - 初始化

- (instancetype)init {
    self = [super init];
    if (self) {
        _length = HISTORY_LENGTH_MAX_DEFAULTE;
        _array = [[NSMutableArray alloc] initWithCapacity:HISTORY_LENGTH_MAX_DEFAULTE];
    }
    return self;
}

- (instancetype)initWithLength:(NSInteger)length {
    self = [super init];
    if (self) {
        _length = length;
        _array = [[NSMutableArray alloc] initWithCapacity:length];
    }
    return self;
}



// MARK: - 实例方法

- (void)pushObject:(nonnull id)object {
    if (_array.count >= _length) {
        [_array removeLastObject];
    }
    
    [_array insertObject:object atIndex:0];
}

- (id)objectWithIndex:(NSUInteger)index {
    if (index >= [_array count]) {
        return nil;
    }
    return _array[index];
}


@end

// MARK: -  -

@implementation HistoryValues (HistoryValuesPusher)

- (void)pushNumeric:(nonnull NSNumber *)value {
    [self pushObject:value];
}

@end



