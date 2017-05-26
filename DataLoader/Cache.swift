//
//  Cache.swift
//  DataLoader
//
//  Created by Luciano Almeida on 02/02/17.
//  Copyright © 2017 Luciano Almeida. All rights reserved.
//

import Foundation

open class Cache<K: Equatable&Hashable, V> {

    
    private var cache : [K: (V,Date)] = [:]
    
    //The cache expiration time for data default is 30 minutes
    open var maxAge: TimeInterval = 1800
    open var allowsExpiration: Bool = true
    
    private(set) var maxCacheItems: Int = 0
    
    public convenience init(allowsExpiration: Bool) {
        self.init()
        self.allowsExpiration = allowsExpiration
    }
    
    public convenience init(maxAge: TimeInterval) {
        self.init()
        self.maxAge = maxAge
    }
    
    public convenience init(maxCacheItems: Int) {
        self.init()
        self.maxCacheItems = maxCacheItems
    }
    
    public convenience init(allowsExpiration: Bool, maxAge: TimeInterval, maxCacheItems: Int = 0) {
        self.init(allowsExpiration: allowsExpiration, maxCacheItems: maxCacheItems)
        self.maxAge = maxAge
    }
    
    public convenience init(allowsExpiration: Bool, maxCacheItems: Int = 0) {
        self.init(maxCacheItems: maxCacheItems)
        self.allowsExpiration = allowsExpiration
    }
    
    
    
    open func set(value: V, for key: K) {
        cache.updateValue((value,Date(timeIntervalSinceNow: maxAge)), forKey: key)
        if maxCacheItems > 0 && cache.keys.count > maxCacheItems {
            removeOldestItem()
        }
    }
    
    open func get(for key: K) -> V? {
        if allowsExpiration && isCacheValueExpired(for: key) {
            remove(key: key)
            return nil
        }
        return cache[key]?.0
    }
    
    open subscript (key: K) -> V? {
        get {
            return get(for: key)
        }
        set (value) {
            if let value = value {
                set(value: value, for: key)
            }
        }
    }
    
    open var count : Int {
        return cache.count
    }
    
    open func contains(key: K) -> Bool {
        if allowsExpiration {
            return  cache.keys.contains(key) && !isCacheValueExpired(for: key)
        }
        return cache.keys.contains(key)
    }
    
    private func removeOldestItem() {
        let oldest = cache.keys.reduce(nil) { (oldestKey, key) -> K? in
            if let oldestKey = oldestKey,
                let oldestDate = cache[oldestKey]?.1,
                let keyDate = cache[key]?.1 {
                if keyDate < oldestDate  {
                    return key
                }else {
                    return oldestKey
                }
            }else {
                return key
            }
        }
        if let oldest = oldest {
            remove(key: oldest)
        }
    }
        
    
    open func remove(key: K) {
        cache.removeValue(forKey: key)
    }
    
    open func clear() {
        cache.removeAll()
    }
    
    private func isCacheValueExpired(for key: K) -> Bool {
        if let expDate = cache[key]?.1 {
            return Date() > expDate
        }
        return false
    }
}
