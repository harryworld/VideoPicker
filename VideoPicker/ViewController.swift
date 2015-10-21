//
//  ViewController.swift
//  VideoPicker
//
//  Created by Alex Troyanskij on 10/8/15.
//  Copyright © 2015 STAY REAL LIMITED. All rights reserved.
//

import UIKit
import SnapKit
import AVFoundation


import MobileCoreServices
import AssetsLibrary

import Foundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var assetPicker : AssetsPicker!
    
    var urls: [String] = []
    
    
    let yOffset : CGFloat = 200
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        let bundle = NSBundle.mainBundle()
        if let path = bundle.pathForResource("video", ofType: "mov") {
            for _ in 1 ..< 100 {
                urls.append(path)
            }
        }
        
        
        let showButton = UIButton(type: .Custom)
        showButton.setTitle("Show/Hide", forState: .Normal)
        showButton.setTitle("Show/Hide", forState: .Highlighted)
        showButton.setTitleColor(UIColor.darkTextColor(), forState: .Normal)
        showButton.setTitleColor(UIColor.darkTextColor(), forState: .Highlighted)
        showButton.addTarget(self, action: "togglePicker", forControlEvents: .TouchUpInside)
        
        self.view.addSubview(showButton)
        
        showButton.snp_makeConstraints { make in
            make.width.equalTo(100)
            make.height.equalTo(44)
            make.center.equalTo(self.view)
        }
        

        let size = UIScreen.mainScreen().bounds
        assetPicker = AssetsPicker(frame: CGRect(x: 0, y: yOffset, width: size.width, height: size.height-yOffset))
        assetPicker.delegate = self
        assetPicker.dataSource = self
        
        self.view.addSubview(assetPicker)
   
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print(info["UIImagePickerControllerMediaURL"])
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func togglePicker() {
        
        var frame = assetPicker.frame
        let dismissed = frame.origin.y == UIScreen.mainScreen().bounds.size.height
        frame.origin.y = dismissed ? yOffset : UIScreen.mainScreen().bounds.size.height
        
        UIView.animateWithDuration(0.25, animations: { _ in self.assetPicker.frame = frame }) { success in
            if (!dismissed) {
                self.assetPicker.topLayerState = .Presented
                self.assetPicker.onCancel()
            }
        }
        
    }
    

}

extension ViewController : AssetsPickerDataSource {
    
    func numberOfBottomItems() -> Int {
        return 99
    }
    func numberOfTopItems() -> Int {
        return urls.count
    }
    
    func indexOfBottomSelectedItem() -> Int {
        return -1
    }
    
    func indexOfTopSelectedItem() -> Int {
        return  -1
    }
    
    func itemForBottomAtIndex(index:Int) -> NSURL? {
        return NSURL.fileURLWithPath(urls[index])
    }
    
    func itemForTopAtIndex(index:Int) -> NSURL? {
//        return randomNumberFrom(0...1) == 1 ? NSURL(string: urls[index]) : nil
        return NSURL.fileURLWithPath(urls[index])
    }
    
    func randomNumberFrom(from: Range<Int>) -> Int {
        return from.startIndex + Int(arc4random_uniform(UInt32(from.endIndex - from.startIndex)))
    }
    
    func bottomColorForSelectedState() -> UIColor {
        return UIColor.yellowColor()
    }
    
    func topColorForSelectedState() -> UIColor {
        return UIColor.yellowColor()
    }
}

extension ViewController : AssetsPickerDelegate {
   
    func didCommitChanges(bottomIndex: Int, topIndex: Int) {
        
    }
    
    func didSelectItemBottom(index:Int) {
        
    }
    
    func didSelectItemTop(index:Int) {
        
    }

    func didApplyChanges() {
        togglePicker()
    }
    
    func didFinishEditing() {
        togglePicker()
    }
    
}


