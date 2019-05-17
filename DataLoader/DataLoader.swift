//
//  DataLoader.swift
//  DataLoader
//
//  Created by Luciano Almeida on 01/02/17.
//  Copyright © 2017 Luciano Almeida. All rights reserved.
//

public final class DataLoader<K: Equatable&Hashable, V>: NSObject {
    public typealias Loader = (_ key: K, _ resolve: @escaping (_ value: V?) -> Void, _ reject: @escaping (_ error: Error) -> Void) -> Void
    public typealias ResultCallBack = (Result<V?, Error>) -> Void
    
    private var loader: Loader!
    public private(set) var cache: Cache<K, V> = Cache<K, V>()
    
    private var loaderQueue: DispatchQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
    
    private var awaitingCallBacks: [K: [ResultCallBack]] = [:]
    private var inloadKeys: [K] = []
    
    /**
     
     Create a DataLoader Object with an loader function.
     
     - parameter loader: The key for the data to be loaded.
     
     */
    public init(loader: @escaping Loader) {
        super.init()
        self.loader = loader
    }
    
    /**
     
     Create a DataLoader Object with an loader function.
     - parameter
        - loader: The key for the data to be loaded.
        - cacheMaxAge: The time from the moment it's cached moment that value is maintained on cache. The default value is 1800 seconds.
        - allowsExpiration: If cache values expires. If false the cache will only be removed from the cache if you do it by calling cacheRemove(key: K)
        - maxCacheItems: Max values that can be stored in memory cache.
    */

    public convenience init(loader: @escaping Loader, cacheMaxAge: TimeInterval, allowsExpiration: Bool, maxCacheItems: Int = 0) {
        self.init(loader: loader)
        cache = Cache<K, V>(allowsExpiration: allowsExpiration, maxAge: cacheMaxAge, maxCacheItems: maxCacheItems)
    }
    
    /**
     
     Create a DataLoader Object with an loader function.
     - parameter
        - loader: The key for the data to be loaded.
        - allowsExpiration: If cache values expires. If false the cache will only be removed from the cache if you do it by calling cacheRemove(key: K)
     */
    public convenience init(loader: @escaping Loader, allowsExpiration: Bool) {
        self.init(loader: loader)
        cache = Cache<K, V>(allowsExpiration: allowsExpiration)
    }
    
    /**
     
     Create a DataLoader Object with an loader function.
     - parameter
        - loader: The key for the data to be loaded.
        - cacheMaxAge: The time from the moment it's cached moment that value is maintained on cache. The default value is 1800 seconds.
     */
    public convenience init(loader: @escaping Loader, cacheMaxAge: TimeInterval) {
        self.init(loader: loader)
        cache = Cache<K, V>(maxAge: cacheMaxAge)
    }
    
    /**
     
     Create a DataLoader Object with an loader function.
     - parameter
        - loader: The key for the data to be loaded.
        - allowsExpiration: If cache values expires. If false the cache will only be removed from the cache if you do it by calling cacheRemove(key: K)
        - maxCacheItems: Max values that can be stored in memory cache.
     */

    public convenience init(loader: @escaping Loader, allowsExpiration: Bool, maxCacheItems: Int) {
        self.init(loader: loader)
        cache = Cache<K, V>(allowsExpiration: allowsExpiration, maxCacheItems: maxCacheItems)
    }
    
    /**
    
     Load a value based on the the provided key. The loader is perfomed by the function passed on the contructor and the loaded value is based on the resolve function.
     
     - parameter key: The key for the data to be loaded.
     - parameter shouldCache: The values that indicates if loaded values should be cached.
     - parameter completion: The callback called after load finishes with a value or an error.
     - parameter value: The loaded value.
     - parameter error: Error that occurs in loading.
     
     */
    public func load(key: K,
                     resultQueue: DispatchQueue = .main,
                     shouldCache: Bool = true,
                     completion : @escaping ResultCallBack) {
        _load(key: key,
              in: loaderQueue,
              resultQueue: resultQueue,
              shouldCache: shouldCache,
              completion: completion)
    }
    
    private func _load(key: K,
                       in queue: DispatchQueue,
                       resultQueue: DispatchQueue = .main,
                       shouldCache: Bool = true,
                       completion : @escaping ResultCallBack) {
        queue.async {
            if self.cache.contains(key: key) {
                resultQueue.async {
                    completion(.success(self.cache[key]))
                }
            } else {
                self.setWaitingCallBack(for: key, callback: completion)
                //In case the loader is already loading the key, just add to callback list and wait the loader finish.
                if !self.inloadKeys.contains(key) {
                    self.inloadKeys.append(key)
                    self.loader?(key, { (value) in
                        self.inloadKeys.remove(object: key)
                        if let value = value, shouldCache {
                            self.cache[key] = value
                        }
                        self.performCallbacks(for: key, on: resultQueue, value: value, error: nil)
                    }, { (error) in
                        self.inloadKeys.remove(object: key)
                        self.performCallbacks(for: key, on: resultQueue, value: nil, error: error)
                    })
                }
                
            }
        }
    }
    
    //Accumulate callbacks for in load key to call when load finishes.
    private func setWaitingCallBack(for key: K, callback : @escaping ResultCallBack) {
        if var cbs = awaitingCallBacks[key] {
            cbs.append(callback)
        } else {
            awaitingCallBacks.updateValue([callback], forKey: key)
        }
    }
    
    private func performCallbacks(for key: K, on queue: DispatchQueue, value: V?, error: Error?) {
        if let cbs = awaitingCallBacks[key] {
            queue.async {
                cbs.forEach({ $0(self._makeResult(value: value, error: error)) })
                self.awaitingCallBacks.removeValue(forKey: key)
            }
        }
    }
    
    private func _makeResult(value: V?, error: Error?) -> Result<V?, Error> {
        if let error = error {
            return .failure(error)
        }
        return .success(value)
    }
    
    /**
     
     Serial load values based on the the provided keys. The loader is perfomed by the function passed on the contructor and the loaded value is based on the resolve function.
     
     - parameter keys: The keys for the data set to be loaded.
     - parameter shouldCache: The values that indicates if loaded values should be cached.
     - parameter completion: The callback called after load finishes with a value or an error.
     - parameter values: The loaded values.
     - parameter error: Error that occurs in loading.
     
     - Important:
        This method perform the loads in sequece, that means its a serial process and the loads are performed one afer another and not in paralell.
     
     */
    public func load(keys: [K],
                     resultQueue: DispatchQueue = .main,
                     shouldCache: Bool = true,
                     completion : @escaping (Result<[V], Error>) -> Void) {
        var values: [V] = []
        var queue = keys
        loaderQueue.async {
            var loadError: Error?
            let semaphore = DispatchSemaphore(value: 0)
            while let key = queue.first, loadError == nil {
                self.load(key: key, resultQueue: self.loaderQueue, shouldCache: shouldCache, completion: { (result) in
                    self.handle(&values, loadError: &loadError, result: result)
                    semaphore.signal()
                })
                semaphore.wait()
                queue.removeFirst()
            }
            resultQueue.async {
                if values.count == keys.count {
                    completion(.success(values))
                } else {
                    if let error = loadError {
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
    private func handle(_ values: inout [V], loadError: inout Error?, result: Result<V?, Error>) {
        switch result {
        case .success(let value):
            if let loadedValue = value {
                values.append(loadedValue)
            }
        case .failure(let error):
            loadError = error
        }
    }
}
