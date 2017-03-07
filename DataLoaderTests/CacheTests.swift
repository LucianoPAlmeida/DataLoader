//
//  CacheTests.swift
//  DataLoader
//
//  Created by Luciano Almeida on 18/02/17.
//  Copyright © 2017 Luciano Almeida. All rights reserved.
//

import XCTest
@testable import DataLoader
class CacheTests: XCTestCase {
    
    var cache: Cache<String, Int> = Cache<String, Int>()
    
    override func setUp() {
        super.setUp()
        cache.allowsExpiration = true
        cache.maxAge = 2
        cache.set(value: 3, for: "low")
        cache.set(value: 5, for: "medium")
        cache.set(value: 7, for: "high")
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        cache.clear()
        super.tearDown()
        
    }
    
    func testCache() {
        XCTAssertTrue(cache.contains(key: "low"))
        XCTAssertTrue(cache.contains(key: "medium"))
        XCTAssertTrue(cache.get(for: "medium") == 5)

        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testCacheLimit() {
        self.cache = Cache<String, Int>(maxCacheItems: 2)
        cache.set(value: 3, for: "low")
        cache.set(value: 5, for: "medium")
        cache.set(value: 7, for: "high")
        XCTAssertTrue(cache.count == 2)
        XCTAssertNil(cache.get(for: "low"))
        XCTAssertNotNil(cache.get(for: "medium"))
        XCTAssertNotNil(cache.get(for: "high"))


    }
    
    func testExpiration() {
        XCTAssertTrue(cache.get(for: "medium") == 5)
        let exp = expectation(description: "expiration")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            exp.fulfill()
            XCTAssertTrue(self.cache.get(for: "medium") == nil)
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
