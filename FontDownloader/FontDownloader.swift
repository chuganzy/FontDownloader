//
//  FontDownloader.swift
//  FontDownloader
//
//  Created by Takeru Chuganji on 9/26/15.
//  Copyright © 2015 Takeru Chuganji. All rights reserved.
//

import UIKit
import CoreText

private let UndefinedFontSize = CGFloat(1)

public let FontDidBecomeAvailableNotification = "com.hoppenichu.FontDownloader.FontDidBecomeAvailableNotification"
public let FontNameInfoKey = "FontNameInfoKey"

public extension UIFont {
    public typealias DownloadProgressHandler = (downloadedSize: Int, totalSize: Int, percentage: Int) -> Void
    public typealias DownloadCompletionHandler = (font: UIFont?) -> Void
    
    public class func downloadableFontNames() -> [String] {
        let downloadableDescriptor = CTFontDescriptorCreateWithAttributes([
            (kCTFontDownloadableAttribute as NSString): kCFBooleanTrue
            ])
        guard let cfMatchedDescriptors = CTFontDescriptorCreateMatchingFontDescriptors(downloadableDescriptor, nil), matchedDescriptors = (cfMatchedDescriptors as NSArray) as? [CTFontDescriptor] else {
            return []
        }
        return matchedDescriptors.flatMap { (descriptor) -> String? in
            let attributes = CTFontDescriptorCopyAttributes(descriptor) as NSDictionary
            return attributes[kCTFontNameAttribute as String] as? String
        }
    }
    
    public class func fontExists(name: String) -> Bool {
        return UIFont(name: name, size: UndefinedFontSize) != nil
    }
    
    public class func preloadFontWithName(name: String) {
        if fontExists(name) {
            return
        }
        downloadFontWithName(name, size: UndefinedFontSize)
    }
    
    public class func downloadFontWithName(name: String, size: CGFloat, progress: DownloadProgressHandler? = nil, completion: DownloadCompletionHandler? = nil) {
        let wrappedCompletionHandler = { (postNotification: Bool) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let font = UIFont(name: name, size: size)
                if postNotification && font != nil {
                    NSNotificationCenter.defaultCenter().postNotificationName(FontDidBecomeAvailableNotification, object: nil, userInfo: [
                        FontNameInfoKey: name
                        ])
                }
                completion?(font: font)
            })
        }
        if fontExists(name) {
            wrappedCompletionHandler(false)
            return
        }
        let wrappedProgressHandler = { (param: NSDictionary) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let downloadedSize = param[kCTFontDescriptorMatchingTotalDownloadedSize as String] as? Int ?? 0
                let totalSize = param[kCTFontDescriptorMatchingTotalAssetSize as String] as? Int ?? 0
                let percentage = param[kCTFontDescriptorMatchingPercentage as String] as? Int ?? 0
                progress?(downloadedSize: downloadedSize, totalSize: totalSize, percentage: percentage)
            })
        }
        CTFontDescriptorMatchFontDescriptorsWithProgressHandler([
            CTFontDescriptorCreateWithNameAndSize(name, size)
            ], nil) { (state, param) -> Bool in
                switch state {
                case .WillBeginDownloading, .Stalled, .Downloading, .DidFinishDownloading:
                    wrappedProgressHandler(param)
                case .DidFinish:
                    wrappedCompletionHandler(true)
                default:
                    break
                }
                return true
        }
    }
}
