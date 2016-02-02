//
//  AssetsPicker.swift
//  VideoPicker
//
//  Created by Alex Troyanskij on 10/8/15.
//  Copyright © 2015 STAY REAL LIMITED. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation


@objc public protocol AssetsPickerDataSource {
    
    func numberOfBottomItems() -> Int
    func numberOfTopItems() -> Int
    
    func indexOfBottomSelectedItem() -> Int
    func indexOfTopSelectedItem() -> Int
    
    optional func imagePathForBottomAtIndex(index:Int) -> String?
    optional func imageForBottomAtIndex(index: Int) -> UIImage?
    optional func imagePathForTopAtIndex(index:Int) -> String?
    optional func imageForTopAtIndex(index: Int) -> UIImage?
    
    func bottomColorForSelectedState() -> UIColor
    func topColorForSelectedState() -> UIColor
    
    func bottomTextForItem(index: Int) -> String
}

public protocol AssetsPickerDelegate {
    
    func didCommitChanges(bottomIndex: Int, topIndex: Int)
    
    func didSelectItemBottom(index:Int)
    func didSelectItemTop(index:Int)
    
    func didFinishEditing()
    func didApplyChanges()
    
}

@objc public protocol AssetsPickerMenuDelegate {
    
    optional func didChooseVideo()
    optional func didTrimVideo()
    optional func didDeleteVideo()
    
}

let topCellIdentifier = "topCellIdentifier"
let bottomCellIdentifier = "bottomCellIdentifier"

final public class AssetsPicker : UIView {

    public enum Mode: Int {
        case EditVideo = 0, MagicPlay
    }
    
    public var mode: Mode = .EditVideo
    
    public enum TopLayerState: Int {
        case Presented = 0, Dismissed
    }
    
    public var topLayerState : TopLayerState = .Dismissed
    
    public var delegate : AssetsPickerDelegate?
    public var dataSource : AssetsPickerDataSource?
    public var menuDelegate : AssetsPickerMenuDelegate?
    
    var bottomCollectionView : UICollectionView!
    var topCollectionView : UICollectionView!
    
    var cellReload = false
    
    var topSelectedIndex : NSIndexPath!
    var bottomSelectedIndex : NSIndexPath!
    
    var cancelButton : UIButton!
    var okButton : UIButton!
    
    let topLayerCellMargin = (UIScreen.mainScreen().bounds.width / 6) / 5
    let bottomLayerCellMargin = (UIScreen.mainScreen().bounds.width / 12) / 11
    
    let heightRatio : CGFloat = 0.4
    let buttonWidth : CGFloat = 54
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        let bundle = NSBundle(forClass: self.classForCoder)

        let screenSize = UIScreen.mainScreen().bounds.size
        let bottomYOffset = floor(frame.size.height*(1-heightRatio))
        let bottomHeight = frame.size.height - bottomYOffset
        let bottomFrame = CGRect(x: bottomHeight, y: bottomYOffset, width: frame.size.width - 2*bottomHeight, height: bottomHeight)
    
        
        // top layer
        
        let topFrame = CGRect(x: 0, y: bottomFrame.origin.y, width: frame.size.width, height: bottomYOffset)
        var itemSize = CGSize(width: screenSize.width/5, height: topFrame.size.height)
        
        let topFlowLayout = UICollectionViewFlowLayout()
        topFlowLayout.itemSize = itemSize
        topFlowLayout.scrollDirection = .Horizontal
        topFlowLayout.minimumInteritemSpacing = topLayerCellMargin
        topFlowLayout.minimumLineSpacing = topLayerCellMargin
        
        topCollectionView = UICollectionView(frame: topFrame, collectionViewLayout: topFlowLayout)
        topCollectionView.delegate = self
        topCollectionView.dataSource = self
        topCollectionView.backgroundColor = UIColor(netHex: 0x3D3C3D)
        topCollectionView.registerClass(TopCell.self, forCellWithReuseIdentifier: topCellIdentifier)
        self.addSubview(topCollectionView)
        
        
        // bottom layer

        itemSize = CGSize(width: screenSize.width/11, height: bottomFrame.size.height)
        
        let bottomFlowLayout = UICollectionViewFlowLayout()
        bottomFlowLayout.itemSize = itemSize
        bottomFlowLayout.scrollDirection = .Horizontal
        bottomFlowLayout.minimumInteritemSpacing = bottomLayerCellMargin
        bottomFlowLayout.minimumLineSpacing = bottomLayerCellMargin
        
        bottomCollectionView = UICollectionView(frame: bottomFrame, collectionViewLayout: bottomFlowLayout)
        bottomCollectionView.delegate = self
        bottomCollectionView.dataSource = self
        bottomCollectionView.backgroundColor = UIColor(netHex: 0x444033)
        bottomCollectionView.registerClass(BottomCell.self, forCellWithReuseIdentifier: bottomCellIdentifier)
        self.addSubview(bottomCollectionView)

        
        // buttons
        
        cancelButton = UIButton(type: .Custom)
        cancelButton.frame = CGRect(x: 0, y: bottomYOffset, width: buttonWidth, height: bottomHeight)
        cancelButton.setImage(UIImage(named: "Cancel", inBundle: bundle, compatibleWithTraitCollection: nil), forState: .Normal)
        cancelButton.setImage(UIImage(named: "Cancel", inBundle: bundle, compatibleWithTraitCollection: nil), forState: .Highlighted)
        cancelButton.backgroundColor = UIColor(netHex: 0x444033)
        cancelButton.addTarget(self, action: "onCancel", forControlEvents: .TouchUpInside)
        self.addSubview(cancelButton)
        
        okButton = UIButton(type: .Custom)
        okButton.frame = CGRect(x: screenSize.width - buttonWidth, y: bottomYOffset, width: buttonWidth, height: bottomHeight)
        okButton.setImage(UIImage(named: "Choose", inBundle: bundle, compatibleWithTraitCollection: nil), forState: .Normal)
        okButton.setImage(UIImage(named: "Choose", inBundle: bundle, compatibleWithTraitCollection: nil), forState: .Highlighted)
        okButton.backgroundColor = UIColor(netHex: 0x444033)
        okButton.addTarget(self, action: "onApply", forControlEvents: .TouchUpInside)
        self.addSubview(okButton)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func onCancel() {
        if (topLayerState == .Presented) {
            toggleTopLayer(forceHide: true, forceShow: false)
            if let path = bottomCollectionView.indexPathsForSelectedItems()?.first {
                bottomCollectionView.deselectItemAtIndexPath(path, animated: true)
            }
        }
        else {
            if let _ = delegate {
                delegate?.didFinishEditing()
            }
        }

    }
    
    public func moveTo(var index: Int) {
        if let dataSource = self.dataSource {
            if index >= dataSource.numberOfBottomItems() {
                index = dataSource.numberOfBottomItems()
            }
        }
        bottomCollectionView.selectItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0), animated: false, scrollPosition: .CenteredHorizontally)
        self.collectionView(bottomCollectionView, didSelectItemAtIndexPath: NSIndexPath(forItem: index, inSection: 0))
    }
    
    func onApply() {
        if (topLayerState == .Presented) {
            toggleTopLayer(forceHide: true, forceShow: false)
            
            if let _ = bottomSelectedIndex, _ = topSelectedIndex {
                delegate?.didCommitChanges(bottomSelectedIndex.item, topIndex: topSelectedIndex.item)
                bottomCollectionView.reloadItemsAtIndexPaths([bottomSelectedIndex])
                bottomCollectionView.layoutIfNeeded()
            }

            if let path = bottomCollectionView.indexPathsForSelectedItems()?.first {
                bottomCollectionView.deselectItemAtIndexPath(path, animated: true)
            }
        }
        else {
            if let _ = delegate {
                delegate?.didApplyChanges()
            }
        }
    }
    
    func toggleTopLayer(forceHide forceHide : Bool, forceShow: Bool) {
        let bundle = NSBundle(forClass: self.classForCoder)
        
        let cancelImageName = "Cancel"
        let okImageName = "Choose"
        
        var frame = topCollectionView.frame
        frame.origin.y = topCollectionView.frame.origin.y == bottomCollectionView.frame.origin.y ? 0 : bottomCollectionView.frame.origin.y
        frame.origin.y = forceHide ? bottomCollectionView.frame.origin.y : frame.origin.y
        frame.origin.y = forceShow ? 0 : frame.origin.y
        
        if (forceShow) { topLayerState = .Presented }
        if (forceHide) { topLayerState = .Dismissed }
        
        cancelButton.setImage(UIImage(named: cancelImageName, inBundle: bundle, compatibleWithTraitCollection: nil), forState: .Normal)
        cancelButton.setImage(UIImage(named: cancelImageName, inBundle: bundle, compatibleWithTraitCollection: nil), forState: .Normal)
        okButton.setImage(UIImage(named: okImageName, inBundle: bundle, compatibleWithTraitCollection: nil), forState: .Normal)
        okButton.setImage(UIImage(named: okImageName, inBundle: bundle, compatibleWithTraitCollection: nil), forState: .Normal)
        
        UIView.animateWithDuration(0.25) { _ in
            self.topCollectionView.frame = frame
        }
    }

}

extension AssetsPicker : UICollectionViewDelegate {
 
    public func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        let selectedItem = collectionView.indexPathsForSelectedItems()
        
        if collectionView == topCollectionView {
            return true
        }
        
        if let selectedPath : NSIndexPath = selectedItem?.first where selectedPath.isEqual(indexPath) {
           return false
        }
        
        return true
    }
    
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        if (collectionView == bottomCollectionView) {
            switch mode {
            case .EditVideo:
                toggleTopLayer(forceHide: false, forceShow: true)
                topCollectionView.reloadData()
                bottomSelectedIndex = indexPath
            case .MagicPlay:
                collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: true)
            }
            
            delegate?.didSelectItemBottom(indexPath.item)
        }
        else {
            topSelectedIndex = indexPath
            
            delegate?.didSelectItemTop(indexPath.item)
            
        }
   
    }


}

extension AssetsPicker : UICollectionViewDataSource {
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let dataSource = self.dataSource {
            return collectionView == bottomCollectionView ? dataSource.numberOfBottomItems() : dataSource.numberOfTopItems()
        }
        return 0
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let bottomLayer = collectionView == bottomCollectionView
        
        let identifier = bottomLayer ? bottomCellIdentifier : topCellIdentifier
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! CommonCell
        cell.delegate = self
        
        // Use image by default, or else use imagePath
        if bottomLayer {
            if let image = dataSource?.imageForBottomAtIndex?(indexPath.item) {
                cell.image = image
            } else {
                cell.imagePath = dataSource?.imagePathForBottomAtIndex?(indexPath.item)
            }
        } else {
            if let image = dataSource?.imageForTopAtIndex?(indexPath.item) {
                cell.image = image
            } else {
                cell.imagePath = dataSource?.imagePathForTopAtIndex?(indexPath.item)
            }
        }
        
        // Selection Color
        cell.selectionColor = bottomLayer ? dataSource?.bottomColorForSelectedState() : dataSource?.topColorForSelectedState()

        // Selection state
        if (!bottomLayer && dataSource?.indexOfTopSelectedItem() >= 0) {
            cell.selected = indexPath.item == dataSource?.indexOfTopSelectedItem()
            if cell.selected {
                collectionView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .CenteredHorizontally)
            }
        }
        
        // Show text in the cell
        if let cell = cell as? BottomCell {
            cell.dateLabel.text = dataSource?.bottomTextForItem(indexPath.item)
        }
        
        return cell
    }
}

extension AssetsPicker : UICollectionViewDelegateFlowLayout {
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        if (collectionView == bottomCollectionView) {
            return UIEdgeInsets(top: 0, left: bottomCollectionView.frame.size.width/2, bottom: 0, right: bottomCollectionView.frame.size.width/2)
        }
        return UIEdgeInsetsZero
    }
}

extension AssetsPicker: AssetsPickerCellDelegate {
    
    func choose(sender: AnyObject) {
        menuDelegate?.didChooseVideo?()
    }
    
    func trim(sender: AnyObject) {
        menuDelegate?.didTrimVideo?()
    }
    
    func deleteVideo(sender: AnyObject) {
        menuDelegate?.didDeleteVideo?()
    }
    
}
