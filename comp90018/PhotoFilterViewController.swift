//
//  PhotoFilterViewController.swift
//  comp90018
//
//  Created by imac on 4/10/2015.
//  Copyright (c) 2015 Huabin Liu. All rights reserved.
//

import UIKit

class PhotoFilterViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var originalView: UIImageView!
    @IBOutlet weak var filter1View: UIImageView!
    @IBOutlet weak var filter2View: UIImageView!
    @IBOutlet weak var filter3View: UIImageView!
    
    @IBOutlet var tapOriginalView: UITapGestureRecognizer!
    @IBOutlet var tapFilter1View: UITapGestureRecognizer!
    @IBOutlet var tapFilter2View: UITapGestureRecognizer!
    @IBOutlet var tapFilter3View: UITapGestureRecognizer!
    
    var image: UIImage!
    
    let context = CIContext(options:[kCIContextUseSoftwareRenderer : true])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = image
        loadFilterViews(imageView.image!)
        
        tapOriginalView.addTarget(self, action: "pickOriginalView")
        tapFilter1View.addTarget(self, action: "pickFilter1View")
        tapFilter2View.addTarget(self, action: "pickFilter2View")
        tapFilter3View.addTarget(self, action: "pickFilter3View")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadFilterViews(image: UIImage) {
        originalView.contentMode = .ScaleAspectFit
        originalView.image = image
        
        let originalImage = CIImage(CGImage: image.CGImage)
        
        var filter = CIFilter(name: "CIPhotoEffectTonal")
        filter.setDefaults()
        filter.setValue(originalImage, forKey: kCIInputImageKey)
        
        var cgimg = context.createCGImage(filter.outputImage, fromRect: filter.outputImage.extent())
        var newImage = UIImage(CGImage: cgimg)
        
        filter1View.image = newImage
        
        filter = CIFilter(name: "CIPhotoEffectProcess")
        filter.setDefaults()
        filter.setValue(originalImage, forKey: kCIInputImageKey)
        
        cgimg = context.createCGImage(filter.outputImage, fromRect: filter.outputImage.extent())
        newImage = UIImage(CGImage: cgimg)
        filter2View.image = newImage
        
        filter = CIFilter(name: "CIPhotoEffectTransfer")
        filter.setDefaults()
        filter.setValue(originalImage, forKey: kCIInputImageKey)
        
        cgimg = context.createCGImage(filter.outputImage, fromRect: filter.outputImage.extent())
        newImage = UIImage(CGImage: cgimg)
        filter3View.image = newImage
    }
    
    func pickOriginalView() {
        imageView.image = originalView.image
    }
    
    func pickFilter1View() {
        imageView.image = filter1View.image
    }
    
    func pickFilter2View() {
        imageView.image = filter2View.image
    }
    
    func pickFilter3View() {
        imageView.image = filter3View.image
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if(segue.identifier == "push") {
            let navController = segue.destinationViewController as! UINavigationController
            let postController = navController.topViewController as! PhotoAdjustAndPostViewController
            postController.image = imageView.image
        }
    }
}
