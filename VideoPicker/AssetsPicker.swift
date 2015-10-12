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


protocol AssetsPickerDataSource {
    
    func numberOfBottomItems() -> Int
    func numberOfTopItems() -> Int
    
    func indexOfBottomSelectedItem() -> Int
    func indexOfTopSelectedItem() -> Int
    
    func itemForBottomAtIndex(index:Int) -> NSURL?
    func itemForTopAtIndex(index:Int) -> NSURL?
    
    func bottomColorForSelectedState() -> UIColor
    func topColorForSelectedState() -> UIColor

}

protocol AssetsPickerDelegate {
    
    func didCommitChanges(bottomIndex: Int, topIndex: Int)
    
    func didSelectItemBottom(index:Int)
    func didSelectItemTop(index:Int)
    
    func didFinishEditing()
    func didApplyChanges()
    
}

let topCellIdentifier = "topCellIdentifier"
let bottomCellIdentifier = "bottomCellIdentifier"

class AssetsPicker : UIView {

    enum TopLayerState: Int {
        case Presented = 0, Dismissed
    }
    
    var topLayerState : TopLayerState = .Dismissed
    
    var delegate : AssetsPickerDelegate?
    var dataSource : AssetsPickerDataSource?
    
    var bottomCollectionView : UICollectionView!
    var topCollectionView : UICollectionView!
    
    var cellReload = false
    
    var topSelectedIndex : NSIndexPath!
    var bottomSelectedIndex : NSIndexPath!
    
    var cancelButton : UIButton!
    var okButton : UIButton!
    
    let topLayerCellMargin = (UIScreen.mainScreen().bounds.width / 6) / 5
    let bottomLayerCellMargin = (UIScreen.mainScreen().bounds.width / 12) / 11
    
    let heightRatio : CGFloat = 0.33
    
    override init(frame: CGRect) {
        super.init(frame: frame)

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
        topFlowLayout.minimumInteritemSpacing = bottomLayerCellMargin
        topFlowLayout.minimumLineSpacing = bottomLayerCellMargin
        
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
        cancelButton.frame = CGRect(x: 0, y: bottomYOffset, width: bottomHeight, height: bottomHeight)
        cancelButton.setImage(UIImage(named: "close1"), forState: .Normal)
        cancelButton.setImage(UIImage(named: "close1"), forState: .Highlighted)
        cancelButton.backgroundColor = UIColor(netHex: 0x444033)
        cancelButton.addTarget(self, action: "onCancel", forControlEvents: .TouchUpInside)
        self.addSubview(cancelButton)
        
        okButton = UIButton(type: .Custom)
        okButton.frame = CGRect(x: screenSize.width - bottomHeight, y: bottomYOffset, width: bottomHeight, height: bottomHeight)
        okButton.setImage(UIImage(named: "ok1"), forState: .Normal)
        okButton.setImage(UIImage(named: "ok1"), forState: .Highlighted)
        okButton.backgroundColor = UIColor(netHex: 0x444033)
        okButton.addTarget(self, action: "onApply", forControlEvents: .TouchUpInside)
        self.addSubview(okButton)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func onCancel() {
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
    
    func onApply() {
        if (topLayerState == .Presented) {
            toggleTopLayer(forceHide: true, forceShow: false)
            
            if let _ = bottomSelectedIndex, _ = topSelectedIndex {
                delegate?.didCommitChanges(bottomSelectedIndex.item, topIndex: topSelectedIndex.item)
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
        
        var cancelImageName = "close1"
        var okImageName = "ok1"
        
        var frame = topCollectionView.frame
        frame.origin.y = topCollectionView.frame.origin.y == bottomCollectionView.frame.origin.y ? 0 : bottomCollectionView.frame.origin.y
        frame.origin.y = forceHide ? bottomCollectionView.frame.origin.y : frame.origin.y
        frame.origin.y = forceShow ? 0 : frame.origin.y
        
        if (frame.origin.y == bottomCollectionView.frame.origin.y) {
            cancelImageName = "close1"
            okImageName = "ok1"
            topLayerState = .Dismissed
        }
        else {
            cancelImageName = "close2"
            okImageName = "ok2"
            topLayerState = .Presented
        }

        cancelButton.setImage(UIImage(named: cancelImageName), forState: .Normal)
        cancelButton.setImage(UIImage(named: cancelImageName), forState: .Normal)
        okButton.setImage(UIImage(named: okImageName), forState: .Normal)
        okButton.setImage(UIImage(named: okImageName), forState: .Normal)
        
        UIView.animateWithDuration(0.25) { _ in
            self.topCollectionView.frame = frame
        }
    }

}

extension AssetsPicker : UICollectionViewDelegate {
 
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        let selectedItem = collectionView.indexPathsForSelectedItems()
        
        if let selectedPath : NSIndexPath = selectedItem?.first where selectedPath.isEqual(indexPath) {
           return false
        }
        
        return true
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        if (collectionView == bottomCollectionView) {
            toggleTopLayer(forceHide: false, forceShow: true)
            topCollectionView.reloadData()
            bottomSelectedIndex = indexPath
        }
        else {
            
            topSelectedIndex = indexPath
            
            if let _ = delegate {
                delegate!.didSelectItemTop(indexPath.item)
            }
            
        }
   
    }


}

extension AssetsPicker : UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let dataSource = self.dataSource {
            return collectionView == bottomCollectionView ? dataSource.numberOfBottomItems() : dataSource.numberOfTopItems()
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let bottomLayer = collectionView == bottomCollectionView
        
        let identifier = bottomLayer ? bottomCellIdentifier : topCellIdentifier
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! CommonCell
        cell.assetURL = bottomLayer ? dataSource!.itemForBottomAtIndex(indexPath.item) : dataSource!.itemForTopAtIndex(indexPath.item)
        cell.selectionColor = bottomLayer ? dataSource?.bottomColorForSelectedState() : dataSource?.topColorForSelectedState()

        if (!bottomLayer && dataSource?.indexOfTopSelectedItem() >= 0) {
            cell.selected = indexPath.item == dataSource?.indexOfTopSelectedItem()
        }
        
        return cell
    }
}

extension AssetsPicker : UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        if (collectionView == bottomCollectionView) {
            return UIEdgeInsets(top: 0, left: bottomCollectionView.frame.size.width/2, bottom: 0, right: bottomCollectionView.frame.size.width/2)
        }
        return UIEdgeInsetsZero
    }
}