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

@objc protocol AssetsPickerCellDelegate {
    optional func choose(sender: AnyObject, index: Int)
    optional func trim(sender: AnyObject, index: Int)
    optional func deleteVideo(sender: AnyObject, index: Int)
}

class CommonCell : UICollectionViewCell {
    
    var delegate: AssetsPickerCellDelegate?
    
    var imageGenerator : AVAssetImageGenerator?
    var imageView: UIImageView!
    let margin : CGFloat = 12.0
    
    var selectionColor : UIColor!
    
    var imagePath : String? {
        didSet {
            if let path = imagePath {
                let cache = Shared.imageCache
                cache.fetch(path: path).onSuccess({ (image) -> () in
                    self.imageView.image = image
                })
            }
        }
    }
    
    var image: UIImage? {
        didSet {
            if let image = image {
                self.imageView.image = image
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
    
}
