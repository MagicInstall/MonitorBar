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
        let str: NSString = "北京, 上海, 深圳, 香港"
        let splitedArray = str.components(separatedBy: ", ")
        StatusBarLayout()
        
//        let linker = UroborosLink(length: 3)
//        linker?.update(NSNumber(value: 1))
//        linker?.update(NSNumber(value: 2))
//        linker?.update(NSNumber(value: 3))
//        linker?.moveToHead()

//        print(DigitFormatter.to6Digit(fromDouble: 0.0, unit:"|"))
//        print(DigitFormatter.to6Digit(fromDouble: 1_000_000_000_000_000_000_000_000.0, unit:"|"))
//        
//        print(DigitFormatter.to6Digit(fromDouble: -9_999.99999, unit:"|"))
//        print(DigitFormatter.to6Digit(fromDouble: 9_999.99999, unit:"|"))
//        print(DigitFormatter.to6Digit(fromDouble: -999.999, unit:"|"))
//        print(DigitFormatter.to6Digit(fromDouble: -9.99999, unit:"|"))
//        print(DigitFormatter.to6Digit(fromDouble: 9.99999, unit:"|"))
//        
//        print(DigitFormatter.to6Digit(fromDouble: -1, unit:"|"))
//        print(DigitFormatter.to6Digit(fromDouble: 1, unit:"|"))
//        print(DigitFormatter.to6Digit(fromDouble: -1000.0, unit:"|"))
//        print(DigitFormatter.to6Digit(fromDouble: 1000.0, unit:"|"))
//        
//        print(DigitFormatter.to5Digit(fromDouble: 0.0, unit:"|"))
//        print(DigitFormatter.to5Digit(fromDouble: 1_000_000_000_000_000_000_000_000.0, unit:"|"))
//        
//        print(DigitFormatter.to5Digit(fromDouble: -9_999.99999, unit:"|"))
//        print(DigitFormatter.to5Digit(fromDouble: 9_999.99999, unit:"|"))
//        print(DigitFormatter.to5Digit(fromDouble: -999.999, unit:"|"))
//        print(DigitFormatter.to5Digit(fromDouble: -9.99999, unit:"|"))
//        print(DigitFormatter.to5Digit(fromDouble: 9.99999, unit:"|"))
//        
//        print(DigitFormatter.to5Digit(fromDouble: -1, unit:"|"))
//        print(DigitFormatter.to5Digit(fromDouble: 1, unit:"|"))
//        print(DigitFormatter.to5Digit(fromDouble: -1000.0, unit:"|"))
//        print(DigitFormatter.to5Digit(fromDouble: 1000.0, unit:"|"))
//        
//        
//        print(DigitFormatter.to4Digit(fromDouble: 0.0, unit:"|"))
//        print(DigitFormatter.to4Digit(fromDouble: 1_000_000_000_000_000_000_000_000.0, unit:"|"))
//
//        print(DigitFormatter.to4Digit(fromDouble: -999.999, unit:"|"))
//        print(DigitFormatter.to4Digit(fromDouble: -9.99999, unit:"|"))
//        print(DigitFormatter.to4Digit(fromDouble: 9.99999, unit:"|"))
//        print(DigitFormatter.to4Digit(fromDouble: -9_999.99999, unit:"|"))
//        print(DigitFormatter.to4Digit(fromDouble: 9_999.99999, unit:"|"))
//        print(DigitFormatter.to4Digit(fromDouble: 1000.0, unit:"|"))
//        print(DigitFormatter.to4Digit(fromDouble: -1000.0, unit:"|"))
//        
//        print(DigitFormatter.to4Digit(fromDouble: -1, unit:"|"))
//        print(DigitFormatter.to4Digit(fromDouble: 1, unit:"|"))
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
