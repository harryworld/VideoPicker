//
//  BottomCell.swift
//  VideoPicker
//
//  Created by Alex Troyanskij on 10/9/15.
//  Copyright © 2015 STAY REAL LIMITED. All rights reserved.
//

import Foundation
import UIKit

class TopCell : CommonCell {

    override var selectionColor : UIColor! {
        didSet {
            self.overlayView.backgroundColor = selectionColor
        }
    }
    
    var overlayView : UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = UIColor(netHex: 0x3D3C3D)
        
        imageView.snp_makeConstraints{ make in
            make.edges.equalTo(self.contentView).inset(UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        }
        
        overlayView = UIImageView()
        overlayView.hidden = true
        overlayView.clipsToBounds = true
        overlayView.contentMode = .Center
        overlayView.backgroundColor = UIColor.clearColor()
        overlayView.alpha = 0.33
        overlayView.layer.cornerRadius = imageView.layer.cornerRadius
        self.contentView.addSubview(overlayView)
        
        overlayView.snp_makeConstraints { make in
            make.edges.equalTo(self.imageView)
        }

    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
    }
    
    override var selected: Bool {
        didSet {
            self.overlayView.hidden = !selected
        }
    }
    
}
