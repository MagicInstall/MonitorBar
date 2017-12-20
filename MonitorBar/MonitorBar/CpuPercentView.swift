//
//  CpuPercentView.swift
//  MonitorBar
//
//  Created by wing on 2017/6/25.
//  Copyright © 2017 Magic Install. All rights reserved.
//

import Cocoa

class CpuPercentView: NSView {
    
// MARK: - 控件连接
    
    /// 内核占用率容器控件
    @IBOutlet weak var CoresCollectionView: NSCollectionView!
    
    /// 进程占用率容器控件
    @IBOutlet weak var ProcessesTableView: NSTableView!
    
// MARK: - 实例方法
    
    /// 刷新CPU 占用率
    func Updata() {
        
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
