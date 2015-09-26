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
        guard let matchedDescriptors = CTFontDescriptorCreateMatchingFontDescriptors(downloadableDescriptor, nil) else {
            return []
        }
        let numberOfFonts = CFArrayGetCount(matchedDescriptors)
        var fontNames = [String]()
        for index in 0 ..< numberOfFonts {
            let descriptor = unsafeBitCast(CFArrayGetValueAtIndex(matchedDescriptors, index), CTFontDescriptor.self)
            let attributes = CTFontDescriptorCopyAttributes(descriptor) as NSDictionary
            guard let name = attributes[kCTFontNameAttribute as String] as? String else {
                continue
            }
            fontNames.append(name)
        }
        return fontNames
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
                let downloadedSize = param[kCTFontDescriptorMatchingTotalDownloadedSize as String] as? Int
                let totalSize = param[kCTFontDescriptorMatchingTotalAssetSize as String] as? Int
                let percentage = param[kCTFontDescriptorMatchingPercentage as String] as? Int
                progress?(downloadedSize: downloadedSize ?? 0, totalSize: totalSize ?? 0, percentage: percentage ?? 0)
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
