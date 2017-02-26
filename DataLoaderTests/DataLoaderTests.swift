//
//  DataLoaderTests.swift
//  DataLoaderTests
//
//  Created by Luciano Almeida on 01/02/17.
//  Copyright © 2017 Luciano Almeida. All rights reserved.
//

import XCTest
@testable import DataLoader

class DataLoaderTests: XCTestCase {
    var loader: DataLoader<Int, Int>!
    
    override func setUp() {
        super.setUp()
        loader = DataLoader(loader: { (key, resolve, reject) in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                if key % 2 == 0{
                    resolve( key * key)
                }else {
                    reject(NSError(domain: "dataloader.loaderror", code: 1, userInfo: nil))
                }
            })
            
        })
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLoad() {
        let exp = expectation(description: "loader")
        loader.load(key: 6) { (value, error) in
            exp.fulfill()
            XCTAssertTrue(value == 36)
            XCTAssertTrue(error == nil)
            XCTAssertTrue(self.loader.memoryCache.get(for: 6) != nil)
        }
        waitForExpectations(timeout: 20, handler: nil)
    }
    
    func testErrorLoading() {
        let exp = expectation(description: "failed loader")
        loader.load(key: 7) { (value, error) in
            exp.fulfill()
            XCTAssertTrue(value == nil)
            XCTAssertTrue(error != nil)
        }
        
        waitForExpectations(timeout: 20, handler: nil)
    }
    
    
    func testLoadMany() {
        let exp = self.expectation(description: "loader")
        self.loader.load(keys: [2,4,6]) { (values, error) in
            exp.fulfill()
            XCTAssertTrue(values != nil)
            if let unwrappedValues = values {
                XCTAssertTrue(unwrappedValues == [4,16,36])
            }
            XCTAssertTrue(error == nil)
            
        }
        self.waitForExpectations(timeout: 8, handler: nil)
    }
    
    func testFailedLoadMany() {
        let exp = expectation(description: "loader")
        loader.load(keys: [2,5,6]) { (values, error) in
            exp.fulfill()
            XCTAssertTrue(values == nil)
            XCTAssertTrue(error != nil)
        }
        waitForExpectations(timeout: 8, handler: nil)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
