//
//  MonitorBarTests.swift
//  MonitorBarTests
//
//  Created by wing on 2016/12/21.
//  Copyright © 2016 Magic Install. All rights reserved.
//

import XCTest
@testable import MonitorBar

class MonitorBarTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
//        let fanCount = SmcHelper.read(key: "FNum")?.getUInt32Value() ?? 0
//        for i in 0...fanCount-1 {
//            let key = String(format: "F%XID", i)
//            let fanID = SmcHelper.read(key: key)
//            print("\(fanID)")
//        }
        
        _ = CPUSensor.buildSensors(fromKeys: CPUSensor.effectiveKeys())
        for sensorKVC in CPUSensor.activeSensors()! {
            print(sensorKVC)
        }
        
        NSLog("%@", ProcessHelper.cpuUsage());
//        ProcessHelper.cpuUsage()
        
//        MemorySensor.test()
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
