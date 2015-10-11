//
//  PhotoChooseViewController.swift
//  comp90018
//
//  Created by imac on 3/10/2015.
//  Copyright (c) 2015 Huabin Liu. All rights reserved.
//

import UIKit
import MultipeerConnectivity

//delegate protocol to communicate with userFeed
protocol PhotoChooseViewControllerDelegate {
    func sendData(data: NSData)
}

class PhotoChooseViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var delegate: PhotoChooseViewControllerDelegate?
    
    @IBOutlet weak var imageView: UIImageView!
    let x = User.sharedInstance
    var picker = UIImagePickerController()
    var didLoadImage: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        didLoadImage = false
        imageView.image = UIImage(named: "add-picture")
        picker.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func chooseFromCamera(sender: UIButton) {
        picker.sourceType = .Camera
        
        let pickerFrame = CGRectMake(0, picker.navigationBar.bounds.size.height, picker.view.bounds.width, picker.view.bounds.height - picker.navigationBar.bounds.size.height - picker.toolbar.bounds.size.height * 2.8)
        let size = pickerFrame.size
        let overlayView = UIImageView(frame: pickerFrame)
        overlayView.image = drawGridView(size)
        picker.cameraOverlayView = overlayView
        
        presentViewController(picker, animated: true, completion: nil)
    }
    
    
    func drawGridView(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetStrokeColorWithColor(context, UIColor.grayColor().CGColor)
        CGContextSetLineWidth(context, 1)
        
        CGContextBeginPath(context)
        CGContextMoveToPoint(context, size.width / 3, 0)
        CGContextAddLineToPoint(context, size.width / 3, size.height)
        CGContextMoveToPoint(context, size.width * 2 / 3, 0)
        CGContextAddLineToPoint(context, size.width * 2 / 3, size.height)
        CGContextMoveToPoint(context, 0, size.height / 3)
        CGContextAddLineToPoint(context, size.width, size.height / 3)
        CGContextMoveToPoint(context, 0, size.height * 2 / 3)
        CGContextAddLineToPoint(context, size.width, size.height * 2 / 3)
        CGContextStrokePath(context)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    @IBAction func chooseFromLibrary(sender: UIButton) {
        picker.sourceType = .PhotoLibrary
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        didLoadImage = true
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (didLoadImage == true) {
            if(segue.identifier == "pushToCrop") {
                let navController = segue.destinationViewController as! UINavigationController
                let cropController = navController.topViewController as! PhotoCropViewController
                cropController.image = imageView.image
            }
        } else {
            let alert = UIAlertController(title: "No Image Choosen", message: "Please choose an image first!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    //Swiping imageView gesture 
    @IBAction func rightSwiped(sender: UIGestureRecognizer) {
        if (didLoadImage==true){ //if picture has been chosen
            var refreshAlert = UIAlertController(title: "In Range Swiping", message: "Share it to nearby devices?", preferredStyle: UIAlertControllerStyle.Alert)
            //if cancel do nothing
            refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
            }))
            
            //if okay
            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!)
                in
                //message to be sent is NSDictionary bundled in NSData
                var imageData: NSData = UIImagePNGRepresentation(self.imageView.image)
                var dict : [String:AnyObject] = ["username":self.x.username, "profpict":self.x.profPict, "image":imageData]
                let data : NSData = NSKeyedArchiver.archivedDataWithRootObject(dict)
                //send to peers
                self.delegate?.sendData(data)
                //go back to home
                self.tabBarController?.selectedIndex = 0
            }))
            presentViewController(refreshAlert, animated: true, completion: nil)
        }
    }
}