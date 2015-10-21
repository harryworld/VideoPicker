//
//  ThumbnailFetcher.swift
//  VideoPicker
//
//  Created by Harry Ng on 21/10/15.
//  Copyright © 2015 STAY REAL LIMITED. All rights reserved.
//

import UIKit
import Haneke
import AVFoundation

extension HanekeGlobals {
    
    public struct ThumbnailFetcher {
        
        public enum ErrorCode : Int {
            case InvalidData = -400
            case MissingData = -401
            case InvalidStatusCode = -402
        }
        
    }
    
}

public class ThumbnailFetcher<T : DataConvertible> : Fetcher<T> {

    let assetUrl : NSURL
    
    public init(URL : NSURL) {
        self.assetUrl = URL
        
        let key =  URL.absoluteString
        super.init(key: key)
    }

    var cancelled = false
    
    // MARK: Fetcher
    
    public override func fetch(failure fail : ((NSError?) -> ()), success succeed : (T.Result) -> ()) {
        self.cancelled = false
        
        let asset = AVAsset(URL: self.assetUrl)
        let imageGenerator : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        var time = asset.duration
        time.value = min(time.value, 0)
        
        imageGenerator.generateCGImagesAsynchronouslyForTimes([NSValue.init(CMTime: time)]) { [weak self] (requestedTime, image, actualTime, result, error) -> Void in
            
            print(actualTime)
            
            if let strongSelf = self {
                
                switch result {
                case .Succeeded:
                    let uiimage = UIImage(CGImage: image!)
                    let data = UIImageJPEGRepresentation(uiimage, 1.0);
                    
                    strongSelf.onReceiveData(data, failure: fail, success: succeed)
                case .Failed:
                    let description = "Failed to generate thumbnail"
                    if let error = error {
                        print("Request \(strongSelf.assetUrl.absoluteString) failed", error)
                        return
                    }
                    strongSelf.failWithCode(.InvalidStatusCode, localizedDescription: description, failure: fail)
                case .Cancelled:
                    let description = "Cancelled generating thumbnail"
                    strongSelf.failWithCode(.InvalidStatusCode, localizedDescription: description, failure: fail)
                }
            }
            
        }
        
    }
    
    public override func cancelFetch() {
        self.cancelled = true
    }
    
    // MARK: Private
    
    private func onReceiveData(data: NSData!, failure fail: ((NSError?) -> ()), success succeed: (T.Result) -> ()) {
        
        if cancelled { return }
        
        let URL = self.assetUrl
        
        guard let value = T.convertFromData(data) else {
            let localizedFormat = NSLocalizedString("Failed to convert value from data at URL %@", comment: "Error description")
            let description = String(format:localizedFormat, URL.absoluteString)
            self.failWithCode(.InvalidData, localizedDescription: description, failure: fail)
            return
        }
        
        dispatch_async(dispatch_get_main_queue()) { succeed(value) }
        
    }
    
    private func failWithCode(code: HanekeGlobals.ThumbnailFetcher.ErrorCode, localizedDescription: String, failure fail: ((NSError?) -> ())) {
        let error = errorWithCode(code.rawValue, description: localizedDescription)
        print(localizedDescription, error)
        dispatch_async(dispatch_get_main_queue()) { fail(error) }
    }
}

func errorWithCode(code: Int, description: String) -> NSError {
    let userInfo = [NSLocalizedDescriptionKey: description]
    return NSError(domain: HanekeGlobals.Domain, code: code, userInfo: userInfo)
}
