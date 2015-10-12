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

class PhotoChooseViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIGestureRecognizerDelegate {
    var delegate: PhotoChooseViewControllerDelegate?
    
    @IBOutlet weak var imageView: UIImageView!
    let flashButton = UIView()
    let x = User.sharedInstance
    var picker = UIImagePickerController()
    var didLoadImage: Bool!
    var hasChangedCamera: Bool!
    var hasTurnedOnFlash: Bool!
    
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
        
        picker.showsCameraControls = false
        picker.cameraOverlayView = buildOverlayView()
        
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func buildOverlayView() -> UIView {
        let overlayView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
        
        let gridView = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height * 0.75))
        let size = gridView.frame.size
        gridView.image = drawGridView(size)
        overlayView.addSubview(gridView)
        
        let snapButton = UIView(frame: CGRectMake((self.view.frame.width - 96) / 2 , self.view.frame.height - 106, 96, 96))
        snapButton.userInteractionEnabled = true
        let capture: UIImage! = UIImage(named: "capture")
        snapButton.backgroundColor = UIColor(patternImage: capture)
        overlayView.addSubview(snapButton)
        overlayView.bringSubviewToFront(snapButton)
        let recognizer = UITapGestureRecognizer(target: self, action:Selector("tapSnap:"))
        recognizer.delegate = self
        snapButton.addGestureRecognizer(recognizer)
        
        let cancelButton = UIView(frame: CGRectMake(self.view.frame.width / 9, self.view.frame.height - self.view.frame.width / 5, 48, 48))
        let cancel: UIImage! = UIImage(named: "cancel")
        cancelButton.userInteractionEnabled = true
        cancelButton.backgroundColor = UIColor(patternImage: cancel)
        overlayView.addSubview(cancelButton)
        overlayView.bringSubviewToFront(cancelButton)
        let cancelRecognizer = UITapGestureRecognizer(target: self, action:Selector("tapCancel:"))
        cancelRecognizer.delegate = self
        cancelButton.addGestureRecognizer(cancelRecognizer)
        
        let changeCameraButton = UIView(frame: CGRectMake(self.view.frame.width / 9, self.view.frame.height - self.view.frame.width / 2.5, 48, 48))
        changeCameraButton.userInteractionEnabled = true
        let switch_camera: UIImage! = UIImage(named: "switch_camera")
        changeCameraButton.backgroundColor = UIColor(patternImage: switch_camera)
        overlayView.addSubview(changeCameraButton)
        overlayView.bringSubviewToFront(changeCameraButton)
        let changeCameraRecognizer = UITapGestureRecognizer(target: self, action:Selector("tapChangeCamera:"))
        changeCameraRecognizer.delegate = self
        changeCameraButton.addGestureRecognizer(changeCameraRecognizer)
        
        flashButton.frame = CGRectMake(self.view.frame.width * 8 / 9 - 48, self.view.frame.height - self.view.frame.width / 2.5, 48, 48)
        flashButton.userInteractionEnabled = true
        let flash_auto: UIImage! = UIImage(named: "flash_auto")
        flashButton.backgroundColor = UIColor(patternImage: flash_auto)
        overlayView.addSubview(flashButton)
        overlayView.bringSubviewToFront(flashButton)
        let flashRecognizer = UITapGestureRecognizer(target: self, action:Selector("tapFlash:"))
        flashRecognizer.delegate = self
        flashButton.addGestureRecognizer(flashRecognizer)
        
        return overlayView
    }
    
    func tapSnap(recognizer: UITapGestureRecognizer) {
        picker.takePicture()
    }
    
    func tapCancel(recognizer: UITapGestureRecognizer) {
        self.picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tapChangeCamera(recognizer: UITapGestureRecognizer) {
        if (hasChangedCamera == nil){
            picker.cameraDevice = .Front
            hasChangedCamera = true
            return
        }
        
        if (hasChangedCamera == true){
            picker.cameraDevice = .Rear
            hasChangedCamera = false
            return
        }
        
        if (hasChangedCamera! == false){
            picker.cameraDevice = .Front
            hasChangedCamera = true
            return
            
        }
    }
    
    func tapFlash(recognizer: UITapGestureRecognizer) {
        if (hasTurnedOnFlash == nil){
            picker.cameraFlashMode = .Auto
            hasTurnedOnFlash = false
            return
        }
        
        if (hasTurnedOnFlash == true){
            picker.cameraFlashMode = .Off
            let flash_off: UIImage! = UIImage(named: "flash_off")
            flashButton.backgroundColor = UIColor(patternImage: flash_off)
            hasTurnedOnFlash = false
            return
        }
        
        if (hasTurnedOnFlash == false){
            picker.cameraFlashMode = .On
            let flash_on: UIImage! = UIImage(named: "flash_on")
            flashButton.backgroundColor = UIColor(patternImage: flash_on)
            hasTurnedOnFlash = true
            return
        }
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
                let cropController = segue.destinationViewController as! PhotoCropViewController
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