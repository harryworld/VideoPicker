//
//  ImageGenerator.swift
//  VideoPicker
//
//  Created by Harry Ng on 21/10/15.
//  Copyright © 2015 STAY REAL LIMITED. All rights reserved.
//

import UIKit
import Haneke
import AVFoundation

class ImageGenerator: NSOperation {

    let assetUrl: NSURL
    let imageView: UIImageView
    
    var fetcher: ThumbnailFetcher<UIImage>?
    
    var _executing = false
    var _finished = false
    
    override var executing: Bool {
        get { return _executing }
        set {
            willChangeValueForKey("isExecuting")
            _executing = newValue
            didChangeValueForKey("isExecuting")
        }
    }
    
    override var finished: Bool {
        get { return _finished }
        set {
            willChangeValueForKey("isFinished")
            _finished = newValue
            didChangeValueForKey("isFinished")
        }
    }
    
    init(URL: NSURL, imageView: UIImageView) {
        self.assetUrl = URL
        self.imageView = imageView
    }
    
    override func start() {
        if self.cancelled {
            finished = true
            return
        }
        
        executing = true
        
        main()
    }
    
    override func main() {
        let cache = Shared.imageCache
        fetcher = ThumbnailFetcher<UIImage>(URL: self.assetUrl)
        cache.addFormat(iconFormat)
        
        cache.fetch(fetcher: fetcher!).onSuccess { [weak self] image in
            if let _self = self {
                dispatch_async(dispatch_get_main_queue(), { _ in
                    _self.imageView.image = image
                    _self.imageView.setNeedsDisplay()
                })
                _self.imageGenerationComplete()
            }
        }
    }
    
    func cancelFetch() {
        if let fetcher = fetcher {
            fetcher.cancelFetch()
        }
    }
    
    // MARK: VideoExporterDelegate methods
    
    func imageGenerationComplete() {
        executing = false
        
        finished = true
    }
    
}
