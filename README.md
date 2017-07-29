# DataLoader

[![license](https://img.shields.io/github/license/mashape/apistatus.svg)](https://opensource.org/licenses/MIT)
[![Travis](https://img.shields.io/travis/LucianoPAlmeida/DataLoader.svg)](https://travis-ci.org/LucianoPAlmeida/DataLoader)
[![Codecov](https://img.shields.io/codecov/c/github/LucianoPAlmeida/DataLoader.svg)](https://codecov.io/gh/LucianoPAlmeida/DataLoader)

This is a key/value memory cache convenience library for Swift.With DataLoader you can mantain your data loaded cached during an operation that sometimes requires you manage the state loaded and not loaded.

Inspired on the opensource [facebook/dataloader](https://github.com/facebook/dataloader) library.

# Instalation

## Carthage   
  ```
    github "LucianoPAlmeida/DataLoader" ~> 0.1.8
  ```
## CocoaPods

  ```
      pod 'DataLoader', '~> 0.1.8'
  ``` 
  
## Usage
 ```swift
    var loader: DataLoader<Int, Int>!
    // Creating the loader object.
    loader = DataLoader(loader: { (key, resolve, reject) in
        //load data from your source (can be a file, or a resource from server, or an heavy calculation)
        Fetcher.data(value: key, { (value, error) -> Void in 
            if let error = error {
                reject(error)
            } else {
                resolve(value)
            }
        })
    })
    
    //Using the loader object. 
    loader.cache.load(key: 6) { (value, error) in
      //do your stuff with data
    }
    
    //Clear data from cache
    loader.cache.remove(key: 6) 
    
    or 
    
    loader.cache.clear()
    
 ```
# Licence 

DataLoader is released under the [MIT License](https://opensource.org/licenses/MIT).
