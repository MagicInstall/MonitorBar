//
//  MonitorBar
//  HistoryValues.swift
//
//  Created by wing on 2017/2/17.
//  Copyright © 2016 Magic Install. All rights reserved.
//

import Cocoa

extension HistoryValues  {
    /// 返回指定索引位置的值
    subscript(index: Int) -> (value: NSNumber, tick: CFAbsoluteTime) {
        let valAndTick = self.valueAndCpuTick(with: UInt(index))
        return (valAndTick.value!, valAndTick.cpuTick)
    }

}
