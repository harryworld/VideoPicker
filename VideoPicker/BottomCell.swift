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

        // UIMenuController
        let longPress = UILongPressGestureRecognizer(target: self, action: "handleLongPressGesture:")
        addGestureRecognizer(longPress)
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
    
    // ========================
    // MARK: - UIMenuController
    // ========================
    
    func handleLongPressGesture(recognizer: UILongPressGestureRecognizer) {
        if let recognizerView = recognizer.view,
            recognizerSuperView = recognizerView.superview
        {
            let menuController = UIMenuController.sharedMenuController()
            menuController.setTargetRect(recognizerView.frame, inView: recognizerSuperView)
            menuController.setMenuVisible(true, animated:true)
            
            let menuItemChoose = UIMenuItem(title: "Choose", action: "choose:")
            let menuItemTrim = UIMenuItem(title: "Trim", action: "trim:")
            let menuItemDelete = UIMenuItem(title: "Delete", action: "deleteVideo:")
            menuController.menuItems = [menuItemChoose, menuItemTrim, menuItemDelete]
            
            recognizerView.becomeFirstResponder()
            
        }
    }
    
    override func canBecomeFirstResponder() -> Bool {
        if let delegate = delegate as? AssetsPicker {
            switch delegate.mode {
            case .EditVideo:
                return false
            case .MagicPlay:
                return true
            }
        }
        
        return false
    }
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        return (action == "choose:" || action == "trim:" || action == "deleteVideo:")
    }
    
    func choose(sender: AnyObject) {
        delegate?.choose?(sender)
    }
    
    func trim(sender: AnyObject) {
        delegate?.trim?(sender)
    }
    
    func deleteVideo(sender: AnyObject) {
        delegate?.deleteVideo?(sender)
    }
    
}
