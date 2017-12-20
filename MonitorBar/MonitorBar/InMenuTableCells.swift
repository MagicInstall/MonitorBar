//
//  MonitorBar
//  InMenuTableCells.swift
//
//  Created by wing on 2017/1/7.
//  Copyright © 2016 Magic Install. All rights reserved.
//

import Cocoa

class SensorInMenuCellView: NSTableCellView {
    
    @IBOutlet weak var nameField:  NSTextField!
    @IBOutlet weak var valueField: NSTextField!
    
//    override func draw(_ dirtyRect: CGRect) {
//        super.draw(dirtyRect)
//
//        // Drawing code here.
//    }

}

class GroudInMenuCellView: NSTableCellView {

    @IBOutlet weak var image:  NSImageView?
    
    @IBOutlet weak var titleField: NSTextField!

    
    var _gradient : NSGradient?
    
    override func draw(_ dirtyRect: CGRect) {
        super.draw(dirtyRect)

        if _gradient == nil {
            _gradient = NSGradient.init(starting: NSColor.clear, ending: NSColor.clear)
        }
        
        let contentRect = self.bounds;
        
        _gradient?.draw(in: NSMakeRect(contentRect.origin.x + 1.0, contentRect.origin.y, contentRect.size.width - 2.0, contentRect.size.height), angle: 0)
    }
}

//class EmptyInMenuCellView: NSTableCellView {
//    <#code#>
//}
