//
//  DataLoader.swift
//  DataLoader
//
//  Created by Luciano Almeida on 01/02/17.
//  Copyright © 2017 Luciano Almeida. All rights reserved.
//


open class DataLoader<K: Equatable&Hashable, V>: NSObject {
    typealias Loader = (_ key: K ,_ resolve: @escaping (_ value: V) -> Void, _ reject: @escaping (_ error: Error) -> Void)-> Void

    private var loader: Loader!
    private(set) var memoryCache: Cache<K,V> = Cache<K,V>()
    
    private var dispatchQueue: DispatchQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
    
    init(loader: @escaping Loader) {
        super.init()
        self.loader = loader
    }
    
    open func load(key: K, shouldCache: Bool = true, completion : @escaping (_ value: V?, _ error: Error?) -> Void) {
        dispatchQueue.async {
            if let value = self.memoryCache.get(for: key) {
                completion(value, nil)
            }else {
                self.loader!(key ,{ (value) in
                    if shouldCache {
                        self.memoryCache.set(value: value, for: key)
                    }
                    completion(value, nil)
                }) { (error) in
                    completion(nil, error)
                }
            }
        }
    }
    
    open func load(keys: [K], shouldCache: Bool = true, completion : @escaping (_ values: [V]?, _ error: Error?) -> Void) {
        let queue = Queue<K>(values: keys)
        var values : [V] = []
        dispatchQueue.async {
            var loadError: Error?
            while let key = queue.dequeue(), loadError == nil  {
                let semaphore = DispatchSemaphore(value: 0)
                self.load(key: key, completion: { (value, error) in
                    if let loadedValue = value {
                        values.append(loadedValue)
                    }else {
                        loadError = error
                    }
                    semaphore.signal()
                })
                semaphore.wait()
            }
            if values.count == keys.count {
                completion(values, nil)
            }else {
                completion(nil, loadError)
            }
        }

    }
    
    open func clear(key: K) {
        self.memoryCache.remove(key: key)
    }
    
    open func clear(keys: [K]) {
        keys.forEach({ self.memoryCache.remove(key: $0) })
    }
}
