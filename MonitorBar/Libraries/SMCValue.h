//
//  MonitorBar
//  SMCValue.h
//
//  Created by wing on 2016/12/23.
//  Copyright © 2016 Magic Install. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "smc.h"

/// 该类为Swift 提供SMCVal_t 类型的转换
@interface SMCValue : NSObject

/**
 从内核设备读取一个SMC Key 的信息.

 @param key  key
 @param conn 内核设备连接端口号

 @return 返回一个便于Swift 使用的对象
 */
//+ (SMCValue *) readKey: (NSString*)key FromConnection: (io_connect_t)conn;


//- (instancetype)initWithCStruct:(SMCVal_t *)value;

//UInt32Char_t            key;
//UInt32                  dataSize;
//UInt32Char_t            dataType;
//SMCBytes_t              bytes;


/**
 为C 库提供读写内部值的指针, 
 该方法主要供readKey:FromConnection: 方法使用;
 为避免线程问题, 一般不要使用该指针.
 */
- (SMCVal_t *) getReference;


/**
 Key 名称
 */
@property NSString *key;


/**
 取得内部数据的类型名
 */
@property (readonly) NSString *dataType;


/**
 取得便于Swift 使用的值类型
 */
//@property (readonly) Class valueType;


/**
 取得内部数据的字节大小
 */
@property (readonly) NSInteger dataSize;


/**
 取得内部数据
 */
- (NSData *) getData;

// MARK: -
// MARK: 以下代码改写自 HWSensors/Shared/SmcHelper.m

/**
 以数字形式取得内部数据, 便于Swift 使用.
 在不确定内部数据是数字还是字符或者其它.. 的时候, 
 可以先判断一下dataType 属性.
 */
- (UInt32) getUInt32Value;

/**
 以数字形式取得内部数据, 便于Swift 使用.
 在不确定内部数据是数字还是字符或者其它.. 的时候,
 可以先判断一下dataType 属性.
 */
- (SInt32) getSInt32Value;

/**
 以数字形式取得内部数据, 便于Swift 使用.
 在不确定内部数据是数字还是字符或者其它.. 的时候,
 可以先判断一下dataType 属性.
 */
- (float) getFloatValue;

// MARK: -


/**
 以字符串形式取得内部数据, 便于Swift 使用.
 在不确定内部数据是数字还是字符或者其它.. 的时候,
 可以先判断一下dataType 属性.
 */
- (NSString *) getStringValue;


@property (readonly, copy) NSString *description;
@end
