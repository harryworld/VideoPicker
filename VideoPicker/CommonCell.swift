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
    
    var op: ImageGenerator?
    
    var imageView: UIImageView!
    
    var selectionColor : UIColor!
    
    var assetURL : NSURL? {
        didSet {
            if let url = assetURL {
                
                op = ImageGenerator(URL: url, imageView: imageView)
                let queue = PendingOperations.sharedInstance.generationQueue
                queue.addOperation(op!)

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
        op!.cancelFetch()
    }
    
}
