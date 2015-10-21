//
//  PendingOperations.swift
//  VideoPicker
//
//  Created by Harry Ng on 21/10/15.
//  Copyright © 2015 STAY REAL LIMITED. All rights reserved.
//

import UIKit

class PendingOperations {
    
    static let sharedInstance = PendingOperations()
    
    lazy var generationQueue: NSOperationQueue = {
        var queue = NSOperationQueue()
        queue.name = "Thumbnail Generation Queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
}
