//
//  Meme.swift
//  MemeMe
//
//  Created by Martin Janák on 04/05/2017.
//  Copyright © 2017 Martin Janák. All rights reserved.
//

import Foundation
import UIKit

struct Meme {
    
    let topText:String
    let bottomText:String
    let originalImage:UIImage
    let memedImage:UIImage
    
    init(topText: String, bottomText: String, originalImage: UIImage, memedImage: UIImage) {
        self.topText = topText
        self.bottomText = bottomText
        self.originalImage = originalImage
        self.memedImage = memedImage
    }
    
}
