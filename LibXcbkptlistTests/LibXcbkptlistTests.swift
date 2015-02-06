//
//  LibXcbkptlistTests.swift
//  LibXcbkptlistTests
//
//  Created by Tino Heth on 04.01.15.
//  Copyright (c) 2015 Tino Heth. All rights reserved.
//

import Cocoa
import XCTest

class LibXcbkptlistTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testXMLCreation() {
        // This is an example of a functional test case.
		var test = FileBreakpoint(path: "Path", lineNumber: 22)
		println(test.toXML().XMLString)
        XCTAssert(true, "Pass")
    }
}
