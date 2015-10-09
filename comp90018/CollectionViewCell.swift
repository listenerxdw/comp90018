//
//  CollectionViewCell.swift
//  comp90018
//
//  Created by Pramudita on 30/09/2015.
//  Copyright (c) 2015 Pramudita. All rights reserved.
//

import UIKit
import SwiftyJSON

class CollectionViewCell: UICollectionViewCell {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    var imageView: UIImageView!
    
    override func prepareForReuse() {
        // prevent from seeing old photos when reusing old cells, so
        // we first set its image to nil.
        // Try to comment the following statement, and see the effect.
        self.imageView.image = nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        contentView.addSubview(imageView)
    }
}
