//
//  DataLoader.swift
//  DataLoader
//
//  Created by Luciano Almeida on 01/02/17.
//  Copyright © 2017 Luciano Almeida. All rights reserved.
//


open class DataLoader<K: Equatable&Hashable, V>: NSObject {
    public typealias Loader = (_ key: K ,_ resolve: @escaping (_ value: V?) -> Void, _ reject: @escaping (_ error: Error) -> Void)-> Void

    private var loader: Loader!
    private(set) var memoryCache: Cache<K,V> = Cache<K,V>()
    
    private var dispatchQueue: DispatchQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
    
    
    
    public init(loader: @escaping Loader) {
        super.init()
        self.loader = loader
    }
    
    public convenience init(loader: @escaping Loader, cacheMaxAge: TimeInterval, allowsExpiration: Bool) {
        self.init(loader: loader, cacheMaxAge: cacheMaxAge)
        memoryCache.allowsExpiration = allowsExpiration
    }
    
    public convenience init(loader: @escaping Loader, allowsExpiration: Bool) {
        self.init(loader: loader)
        memoryCache.allowsExpiration = allowsExpiration
    }
    
    public convenience init(loader: @escaping Loader, cacheMaxAge: TimeInterval) {
        self.init(loader: loader)
        memoryCache.maxAge = cacheMaxAge
    }
    
    
    /**
    
     Load a value based on the the provided key. The loader is perfomed by the function passed on the contructor and the loaded value is based on the resolve function.
     
     - parameter key: The key for the data to be loaded.
     - parameter shouldCache: The values that indicates if loaded values should be cached.
     - parameter completion: The callback called after load finishes with a value or an error.
     - parameter value: The loaded value.
     - parameter error: Error that occurs in loading.
     
     */
    open func load(key: K, shouldCache: Bool = true, completion : @escaping (_ value: V?, _ error: Error?) -> Void) {
        dispatchQueue.async {
            if let value = self.memoryCache.get(for: key) {
                completion(value, nil)
            }else {
                self.loader!(key ,{ (value) in
                    if shouldCache {
                        if let unwrappedValue = value {
                            self.memoryCache.set(value: unwrappedValue, for: key)
                        }
                    }
                    completion(value, nil)
                }) { (error) in
                    completion(nil, error)
                }
            }
        }
    }
    
    /**
     
     Load a value based on the the provided key. The loader is perfomed by the function passed on the contructor and the loaded value is based on the resolve function.
     
     - parameter keys: The keys for the data set to be loaded.
     - parameter shouldCache: The values that indicates if loaded values should be cached.
     - parameter completion: The callback called after load finishes with a value or an error.
     - parameter values: The loaded values.
     - parameter error: Error that occurs in loading.
     
     - Important:
        This method perform the loads in sequece, that means its a serial process and the loads are performed one afer another and not in paralell.
     
     */
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
    
    /**
     
     Removes a key from cache.
     
     - parameter key: The key to remove.

     
     */
    open func cacheRemove(key: K) {
        self.memoryCache.remove(key: key)
    }
    
    
    /**
     
     Removes keys from cache.
     
     - parameter keys: The keys to remove.
     
     */
    open func cacheRemove(keys: [K]) {
        keys.forEach({ self.memoryCache.remove(key: $0) })
    }
}
