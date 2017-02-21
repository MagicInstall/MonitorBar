//
//  MonitorBar
//  HistoryValues.h
//
//  Created by wing on 2017/1/1.
//  Copyright © 2016 Magic Install. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 提供历史值的储存容器,
/// 非线程安全!
@interface HistoryValues : NSObject

/**
 历史最大步数, 
 当插入新的历史对象而令到总步数大于该值时,
 最旧的历史将被移除.
 */
@property (atomic) NSUInteger length;

@property (atomic, readonly, nonnull) NSArray *history;

/**
 初始化
 
 @param length 按节点的数量分配空间
 */
- (nullable instancetype)initWithLength:(NSInteger)length;


/**
 将一个对象插入到历史的顶端
 */
- (void)pushObject:(nonnull id)object;

/**
 按索引号获取历史值
 
 @param index 索引0 为最近的一个值;
 索引上限为maxLength - 1,
 试图获取超过历史上限的值并不会引发异常, 但只会返回nil;
 */
- (nullable id) objectWithIndex: (NSUInteger)index;


@end
