//
//  MonitorBar
//  UroborosLink.m
//
//  Created by wing on 2016/12/31.
//  Copyright © 2016 Magic Install. All rights reserved.
//

#import "UroborosLink.h"

@implementation UroborosLink {
    UroborosNode *_current;
    UroborosNode *_head;
    
    NSUInteger _length;
//    NSMutableArray<id> *_nodeArray;
}


/**
 共用的初始化过程
 */
- (void) sharedInit {
    _head = nil;
    _current = nil;
    _length = 0;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self sharedInit];
//        _nodeArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (instancetype)initWithLength:(NSInteger)length {
    self = [super init];
    if (self) {
        [self sharedInit];
        
        [self setLength:length];
//        _nodeArray = [[NSMutableArray alloc] initWithCapacity:length];
    }
    return self;
}

- (void)dealloc
{
    [self setLength:0];
}

// MARK: -
// MARK: 插入/移除

- (void)setLength:(NSUInteger)length {
    NSInteger addCount = length - _length;
    if (addCount == 0) return;
    
    // 需要增加节点
    if (addCount > 0) {
        for (NSInteger i = 0; i < addCount; i++) {
            UroborosNode *newNode = [[UroborosNode alloc] init];
            
            [self insertNode:newNode];
        }
    }
    // 需要减少节点
    else {
        for (NSInteger i = addCount; i < 0; i++) {
            [self removeTailNode];
        }
    }
    
    _length = length;
}
- (NSUInteger)length{
//    if (_head == nil) return 0;
//    
//    uroborosNode *p = _head;
//    NSInteger len = 0;
//    
//    @synchronized (_head) {
//        do {
//            len ++;
//            p = [p next];
//        } while (p != _head);
//        
//    } // @synchronized
    
    return _length;
}

//- (void)insertObject:(id)object {
//    uroborosNode *newNode = [[uroborosNode alloc] init];
//    newNode.object = object;
//    [self insertNode:newNode];
//}

- (void)insertNode:(UroborosNode *)node {
    if (node == nil) return;
    
    @synchronized (_head) {
        // 当新链表未有节点时初始化链表头:
        if (_head == nil) {
            _head = node;
            [_head setPrev:_head];
            [_head setNext:_head];
            _current = _head;
        }
        // 插入节点到链表尾:
        else {
            // 必须先设置新节点
            node.prev = _head.prev;
            node.next = _head;
            
            _head.prev.next = node;
            _head.prev = node;
        }
        
//        [_nodeArray addObject:node];
    } // @synchronized
    
    _length ++;
}

//- (void)removeNode:(UroborosNode *)node {
//    
//}

/**
 移除最尾(头节点的上一个)节点
 */
- (void)removeTailNode {
    if (_head == nil) return;
    
    @synchronized (_head) {
        // 删除唯一一个节点
        if (_head.prev == _head) {
            
            _head.prev = nil;
            _head.next = nil;
            
            _head      = nil;
            _current   = nil;
        }
        // 删除链表尾部的节点
        else {
            UroborosNode *newTail = _current.prev.prev;
            
            _head.prev   = newTail;
            newTail.next = _head;
        }
        
//        [_nodeArray removeLastObject];
    } // @synchronized
    
    _length --;
}

//- (void)removeAllNode {
//    [self setLength:0];
//}

// MARK: -
// MARK: 取得节点

- (UroborosNode *)moveToHead {
    _current = _head;
    return _current;
}

- (UroborosNode *)moveToPrev {
    @synchronized (_head) {
        if (_current) _current = [_current prev];
    }
    return _current;
}

- (UroborosNode *)moveToNext {
    @synchronized (_head) {
        if (_current) _current = [_current next];
    }
    return _current;
}

//- (NSArray *)toArray {
//    return _nodeArray;
//}

///**
// 私有方法, 预生成节点数组
// */
//- (void)rebuiltArray {
//    [_nodeArray removeAllObjects];
//    if (_head == nil) return;
//    
//    UroborosNode *p = _head;
//    do {
//        [_nodeArray addObject:];
//        p = p.next;
//    } while (p != _head);
//}


// MARK: -
// MARK: 读写

- (id)currentObject {
    // 假设节点数量不为0 !
    return _current.object;
}


- (void)updateObject:(id)object {
    // 假设节点数量不为0 !
    @synchronized (_head) {
        _head = _head.prev;
        _head.object = object;
    }
}

//- (void)updateArray:(nonnull NSArray<id> *)array {
//    // 假设节点数量不为0 !
//    @synchronized (_head) {
//        UroborosNode *p = _head;
//        NSUInteger count = array.count;
//        if (count > _length) count = _length;
//        
//        NSUInteger upper = array.count - 1;
//        while (count > 0) {
//            
//            [self updateObject: array[upper]];
//            upper --;
//            count --;
//        }
//    } // @synchronized
//}

@end

// MARK: -
// MARK: UroborosNode
@implementation UroborosNode
@end
