//
//  TGAssetImageFile.swift
//  TGCameraViewController
//
//  Created by Angel Cortez on 7/18/16.
//  Copyright © 2016 Tudo Gostoso Internet. All rights reserved.
//

import Foundation
import UIKit

open class TGAssetImageFile {
    var desc: String!
    var image: UIImage!
    var path: String!
    var title: String!
    
    public init(path: String, image: UIImage) {
        
        self.path = path
        self.image = image
        
    }
}
