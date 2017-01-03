//
//  MonitorBar
//  UroborosLink.h
//
//  Created by wing on 2016/12/31.
//  Copyright © 2016 Magic Install. All rights reserved.
//

#import <Foundation/Foundation.h>


// MARK: -
// MARK: UroborosNode

/// 双向链表节点,
/// 一般不要改变prev 及next 指针, 以免破坏链表结构造成内存泄漏!
@interface UroborosNode : NSObject
/// 所指对象的指针
@property id object;

/// 上一个节点的指针
@property UroborosNode *prev;

/// 下一个节点的指针
@property UroborosNode *next;
@end


// MARK: -
// MARK: UroborosLink

/// 咬尾蛇双向链表
@interface UroborosLink : NSObject

/// 取得当前节点
@property (readonly) UroborosNode *current;

/// 链表的长度;
/// 内部允许长度为0, 但此时操作节点将引发异常!
@property NSUInteger length;

/**
 初始化

 @param length 按节点的数量分配空间
 */
- (instancetype)initWithLength:(NSInteger)length;

/**
 使用任意对象新建一个节点并插入到链表尾
 */
//- (void)insertObject:(id)object;

/**
 将一个节点插入到链表尾
 */
//- (void)insertNode:(UroborosNode *)node;

/**
 移除一个节点
 */
//- (void)removeNode:(UroborosNode *)node;

/// 私有方法
//- (void)removeTailNode;

/**
 移除所有包含指定对象的节点
 */
//- (void)removeObject:(id)object;

/**
 移除所有节点
 */
//- (void)removeAllNode;

/**
 将当前指针移动到链表头
 */
- (UroborosNode *)moveToHead;

/**
 将当前指针移动到上一个节点并返回
 */
- (UroborosNode *)moveToPrev;

/**
 将当前指针移动到下一个节点并返回
 */
- (UroborosNode *)moveToNext;

/**
 判断是否到达结尾
 */
- (BOOL)isEnd;

/**
 将链表展开成一个数组并返回
 */
//-(NSArray *)toArray;

/**
 取得当前节点中的对象

 @return 由于链表内部允许长度为0, 若此时读取节点将引发异常!
 */
- (id)currentObject;

/**
 更新尾节点的对象, 链表头上移一个节点(尾节点成为头节点);
 由于链表内部允许长度为0, 若此时更新对象将引发异常!
 */
- (void)updateObject:(id)object;

/**
 更新尾节点的对象, 链表头上移一个节点(尾节点成为头节点);
 
 @param array 数组的上标对象将放在链表头, 然后降序(从大到小)填充节点.
              当该数组大于链表的长度时, 靠近下标端的数据将被忽略!
 */
// Swift 无法作用该重载 - (void)updateArray:(nonnull NSArray<id> *)array;


@end


