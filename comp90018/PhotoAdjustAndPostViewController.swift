//
//  PhotoAdjustAndPostViewController.swift
//  comp90018
//
//  Created by imac on 4/10/2015.
//  Copyright (c) 2015 Pramudita. All rights reserved.
//

import Foundation
import UIKit

class PhotoAdjustAndPostViewController: UIViewController, UIDocumentInteractionControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var sliderBrightness: UISlider!
    @IBOutlet weak var sliderContrast: UISlider!
    
    var documentController: UIDocumentInteractionController!
    var image: UIImage!
    var originalImage: CIImage!
    
    let context = CIContext(options:[kCIContextUseSoftwareRenderer : true])
    let filter = CIFilter(name: "CIColorControls")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        originalImage = CIImage(CGImage: imageView.image!.CGImage)
        filter.setDefaults()
        filter.setValue(originalImage, forKey: kCIInputImageKey)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func brightnessChanged(sender: UISlider) {
        let sliderValue = sender.value
        filter.setValue(sliderValue, forKey: kCIInputBrightnessKey)
        let outputImage = filter.outputImage
        let cgimg = context.createCGImage(outputImage, fromRect: outputImage.extent())
        let newImage = UIImage(CGImage: cgimg)
        imageView.image = newImage
    }
 
    @IBAction func contrastChanged(sender: UISlider) {
        let sliderValue = sender.value
        filter.setValue(sliderValue, forKey: kCIInputContrastKey)
        let outputImage = filter.outputImage
        let cgimg = context.createCGImage(outputImage, fromRect: outputImage.extent())
        let newImage = UIImage(CGImage: cgimg)
        imageView.image = newImage
    }
    
    @IBAction func post(sender: UIButton) {
        let instagramUrl = NSURL(string: "instagram://app")
        if(UIApplication.sharedApplication().canOpenURL(instagramUrl!)){
            let imageData = UIImageJPEGRepresentation(imageView.image, 100)
            let captionString = "Your Caption"
            let writePath = NSTemporaryDirectory().stringByAppendingPathComponent("instagram.igo")
            
            if(!imageData.writeToFile(writePath, atomically: true)){
                return
            } else{
                let fileURL = NSURL(fileURLWithPath: writePath)
                self.documentController = UIDocumentInteractionController(URL: fileURL!)
                self.documentController.delegate = self
                self.documentController.UTI = "com.instagram.exclusivegram"
                self.documentController.annotation =  NSDictionary(object: captionString, forKey: "InstagramCaption")
                self.documentController.presentOpenInMenuFromRect(self.view.frame, inView: self.view, animated: true)
            }
        } else {
            let alert = UIAlertController(title: "Post Failed", message: "Please install instagram app first.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }

    }
}