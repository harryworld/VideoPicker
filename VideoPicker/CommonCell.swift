//
//  BottomCell.swift
//  VideoPicker
//
//  Created by Alex Troyanskij on 10/9/15.
//  Copyright © 2015 STAY REAL LIMITED. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Haneke

let iconFormat = Format<UIImage>(name: "thumbnail", diskCapacity: 50 * 1024 * 1024) { image in return image }

class CommonCell : UICollectionViewCell {
    
    var imageGenerator : AVAssetImageGenerator?
    var imageView: UIImageView!
    let margin : CGFloat = 12.0
    
    var selectionColor : UIColor!
    
    var assetURL : NSURL? {
        didSet {
            if let url = assetURL {

                let cache = Shared.imageCache
                cache.addFormat(iconFormat)
                cache.fetch(key: url.absoluteString, formatName: "thumbnail").onSuccess { [unowned self] image in
                    
                    UIView.transitionWithView(self.imageView, duration: 0.25, options: [.TransitionNone, .BeginFromCurrentState, .AllowUserInteraction, .TransitionCrossDissolve],
                        animations: { _ in
                            self.imageView.image = image
                            self.imageView.setNeedsDisplay()
                        },
                        completion: { _ in }
                    )
                    
                    }.onFailure({ [unowned self] error in
                        self.previewImageForLocalVideo(url) { image in
                            self.imageView.image = image
                            self.imageView.setNeedsDisplay()
                            cache.set(value: image!, key: url.absoluteString, formatName: "thumbnail", success: nil)
                        }
                    })
            }
            else {
                // TODO: set placeholder image here
                self.imageView.image = nil
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.clipsToBounds = true

        imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .ScaleAspectFill
        imageView.layer.cornerRadius = 8
        self.contentView.addSubview(imageView!)
        
        // TODO: set placeholder image here
        self.imageView.image = nil

    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageGenerator?.cancelAllCGImageGeneration()
        self.imageView.image = nil
    }
    
    func previewImageForLocalVideo(url:NSURL, completion: (image: UIImage?)->())
    {
        let asset = AVAsset(URL: url)
        imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator!.appliesPreferredTrackTransform = true
        
        var time = asset.duration
        //First frame could be completely black or white on camara's videos
        time.value = min(time.value, 0)
        

        // Uncomment this and comment imageGenerator{} block below to see how syncronous method works
        /*
        var img : CGImageRef
        do {
            img = try imageGenerator!.copyCGImageAtTime(time, actualTime: nil)
            let frameImg    : UIImage = UIImage(CGImage: img)
            completion(image: frameImg)
        }
        catch let error as NSError {
            print(error)
            completion(image: nil)
        }
        */
        
        imageGenerator!.generateCGImagesAsynchronouslyForTimes([NSValue.init(CMTime:time)]) { (requestedTime, image, actualTime, result, error) -> Void in

            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if result == .Succeeded {
                    completion(image: UIImage(CGImage: image!))
                }
                else {
                    completion(image: nil)
                    print("Couldn't generate thumbnail, error:%@", error)
                }
            })
        }

        
    }
    
}
