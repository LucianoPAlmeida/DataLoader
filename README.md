# DataLoader

This is a key/value memory cache convenience library for Swift.With DataLoader you can mantain your data loaded cached during an operation that sometimes requires you manage the state loaded and not loaded.

Inspired on the opensource [facebook/dataloader](https://github.com/facebook/dataloader) library.

# Instalation

## Carthage   
  ```
    github "LucianoPAlmeida/DataLoader" ~> 0.1.3
  ```
## CocoaPods
  ```
      pod 'DataLoader', :git => 'https://github.com/LucianoPAlmeida/DataLoader.git', :branch => 'master', :tag => '0.1.3'
  ``` 
  
## Usage
 ```
    var loader: DataLoader<Int, Int>!
    //Creating the loader object.
    loader = DataLoader(loader: { (key, resolve, reject) in
        //load data from your source
        if success { // In case of successfully load just call the resolve function.
          resolve(data)
        } else if error { // In case of fail load just call the reject function.
          reject(error)
        }
    })
    
    //Using the loader object. 
    loader.load(key: 6) { (value, error) in
      //do your stuff with data
    }
 ``` 
# Licence 
DataLoader is released under the MIT License.
