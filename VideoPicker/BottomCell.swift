//
//  BottomCell.swift
//  VideoPicker
//
//  Created by Alex Troyanskij on 10/9/15.
//  Copyright © 2015 STAY REAL LIMITED. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class BottomCell : CommonCell {
    
    var dateLabel: UILabel!
    
    override var selectionColor : UIColor! {
        didSet {
            self.imageView.layer.borderColor = selectionColor.CGColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = UIColor(netHex: 0x444033)
        
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.clearColor().CGColor
        
        imageView.snp_makeConstraints { make in
            make.edges.equalTo(self.contentView).inset(UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        }
        
        dateLabel = UILabel()
        dateLabel.textColor = UIColor.whiteColor()
        self.addSubview(dateLabel)
        
        dateLabel.snp_makeConstraints { make in
            make.centerX.equalTo(self.snp_centerX)
            make.centerY.equalTo(self.snp_centerY)
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
            self.imageView.layer.borderWidth = selected ? 2 : 0
        }
    }
    
}
