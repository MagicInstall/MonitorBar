//
//  MonitorBar
//  HistoryValues.m
//
//  Created by wing on 2017/1/1.
//  Copyright © 2016 Magic Install. All rights reserved.
//

#import "HistoryValues.h"

@implementation HistoryValues {
    NSUInteger _maxLength;
    NSMutableArray* _array;
}

// MARK: -
// MARK: 类常量
static const NSUInteger HISTORY_LENGTH_MAX_DEFAULTE = 10;


// MARK: -
// MARK: 属性

- (void)setMaxLength:(NSUInteger)length {
    _maxLength = length;
    while (_array.count > _maxLength) {
        [_array removeLastObject];
    }
}
- (NSUInteger)maxLength {
    return _maxLength;
}

@synthesize history = _array;

// MARK: -
// MARK: 初始化

- (instancetype)init {
    self = [super init];
    if (self) {
        _maxLength = HISTORY_LENGTH_MAX_DEFAULTE;
        _array = [[NSMutableArray alloc] initWithCapacity:HISTORY_LENGTH_MAX_DEFAULTE];
    }
    return self;
}

- (instancetype)initWithMaxLength:(NSInteger)length {
    self = [super init];
    if (self) {
        _maxLength = length;
        _array = [[NSMutableArray alloc] initWithCapacity:length];
    }
    return self;
}



// MARK: -
// MARK: 实例方法

- (void)pushObject:(nonnull id)object {
    [_array insertObject:object atIndex:0];
    
    if (_array.count > _maxLength) {
        [_array removeLastObject];
    }
}



@end
