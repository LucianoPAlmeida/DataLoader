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
        loader.load(key: 6) { result in
            switch result {
            case .failure:
                assertionFailure()
            case .success(let value):
                XCTAssertTrue(value == 36)
                XCTAssertNotNil(self.loader.cache.get(for: 6))
            }
            exp.fulfill()
            
        }
        waitForExpectations(timeout: 20, handler: nil)
    }
    
    func testErrorLoading() {
        let exp = expectation(description: "failed loader")
        loader.load(key: 7) { (result) in
            switch result {
            case .failure: break
            case .success:
                assertionFailure()
            }
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 20, handler: nil)
    }
    
    func testLoadMany() {
        let exp = self.expectation(description: "loader")
        self.loader.load(keys: [2, 2, 4, 6]) { (result) in
            switch result {
            case .failure:
                assertionFailure()
            case .success(let value):
                XCTAssertEqual(value, [4, 4, 16, 36])
            }
            exp.fulfill()
        }
        self.waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testFailedLoadMany() {
        let exp = expectation(description: "loader")
        loader.load(keys: [2, 5, 6]) { (result) in
            switch result {
            case .failure: break
            case .success:
                assertionFailure()
            }
            exp.fulfill()

        }
        waitForExpectations(timeout: 10, handler: nil)
    }
}
