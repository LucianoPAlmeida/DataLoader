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
            DispatchQueue.global(qos: .background).asyncAfter(deadline: DispatchTime.now() + 2.0, execute: {
                if key % 2 == 0 {
                    resolve( key * key)
                } else {
                    reject(NSError(domain: "dataloader.loaderror", code: 1, userInfo: nil))
                }
            })

        })
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInitWithAllParameters() {
        let loader: DataLoader<Int, String> = DataLoader(loader: { (key, resolve, _) in
            resolve("\(key)")
        }, cacheMaxAge: 30, allowsExpiration: true, maxCacheItems: 20)
        XCTAssertEqual(loader.cache.maxAge, 30)
        XCTAssertEqual(loader.cache.maxCacheItems, 20)
        XCTAssertEqual(loader.cache.allowsExpiration, true)

    }
    
    func testInitWithAllowsExceptionAndMaxItems() {
        let loader: DataLoader<Int, String> = DataLoader(loader: { (key, resolve, _) in
            resolve("\(key)")
        }, allowsExpiration: true, maxCacheItems: 30)
        XCTAssertEqual(loader.cache.maxAge, 1800)
        XCTAssertEqual(loader.cache.maxCacheItems, 30)
        XCTAssertEqual(loader.cache.allowsExpiration, true)
    }
    
    func testInitAllowsExpiration() {
        let loader: DataLoader<Int, String> = DataLoader(loader: { (key, resolve, _) in
            resolve("\(key)")
        }, allowsExpiration: true)
        XCTAssertEqual(loader.cache.maxAge, 1800)
        XCTAssertEqual(loader.cache.maxCacheItems, 0)
        XCTAssertEqual(loader.cache.allowsExpiration, true)
    }
    
    func testInitMaxAge() {
        let loader: DataLoader<Int, String> = DataLoader(loader: { (key, resolve, _) in
            resolve("\(key)")
        }, cacheMaxAge: 50)
        XCTAssertEqual(loader.cache.maxAge, 50)
        XCTAssertEqual(loader.cache.maxCacheItems, 0)
        XCTAssertEqual(loader.cache.allowsExpiration, true)
    }
    
    func testLoad() {
        let exp = expectation(description: "loader")
        loader.load(key: 6) { (value, error) in
            exp.fulfill()
            XCTAssertTrue(value == 36)
            XCTAssertTrue(error == nil)
            XCTAssertTrue(self.loader.cache.get(for: 6) != nil)
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
        self.loader.load(keys: [2, 4, 6]) { (values, error) in
            exp.fulfill()
            XCTAssertTrue(values != nil)
            if let unwrappedValues = values {
                XCTAssertEqual(unwrappedValues, [4, 16, 36])
            }
            XCTAssertTrue(error == nil)
            
        }
        self.waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testFailedLoadMany() {
        let exp = expectation(description: "loader")
        loader.load(keys: [2, 5, 6]) { (values, error) in
            exp.fulfill()
            XCTAssertTrue(values == nil)
            XCTAssertTrue(error != nil)
        }
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
