# FontDownloader

UIFont Download Extensions.

```swift
UIFont.downloadFontWithName("HiraMaruPro-W4", size: 10, progress: { (downloadedSize, totalSize, percentage) -> Void in
    
    }) { (font) -> Void in
        
}
```


## Installation

### CocoaPods

```
use_frameworks!
pod FontDownloader
```

### Carthage

```
github "hoppenichu/FontDownloader"
```

### Manual

Add reference of `FontDownloader.swift` to your project.


## Requirements

- Swift 2
- Xcode 7
- iOS 6 or Later
