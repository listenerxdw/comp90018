//
//  PhotoChooseViewController.swift
//  comp90018
//
//  Created by Huabin Liu on 3/10/2015.
//  Copyright (c) 2015 Huabin Liu, Pramudita. All rights reserved.
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
        // initiate the flag for check whether there was an image loaded
        didLoadImage = false
        // initiate a default image to be shown
        imageView.image = UIImage(named: "add-picture")
        picker.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // choose image from camera
    @IBAction func chooseFromCamera(sender: UIButton) {
        picker.sourceType = .Camera
        
        // overlay a customerized control view of camera
        picker.showsCameraControls = false
        picker.cameraOverlayView = buildOverlayView()
        
        presentViewController(picker, animated: true, completion: nil)
    }
    
    // draw the new constomerized control view
    func buildOverlayView() -> UIView {
        // set the view size same with screen
        let overlayView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
        
        // add grid view on top of camera view
        let gridView = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height * 0.75))
        let size = gridView.frame.size
        gridView.image = drawGridView(size)
        overlayView.addSubview(gridView)
        
        // add photo capture button
        let snapButton = UIView(frame: CGRectMake((self.view.frame.width - 96) / 2 , self.view.frame.height - 106, 96, 96))
        snapButton.userInteractionEnabled = true
        let capture: UIImage! = UIImage(named: "capture")
        snapButton.backgroundColor = UIColor(patternImage: capture)
        overlayView.addSubview(snapButton)
        overlayView.bringSubviewToFront(snapButton)
        let recognizer = UITapGestureRecognizer(target: self, action:Selector("tapSnap:"))
        recognizer.delegate = self
        snapButton.addGestureRecognizer(recognizer)
        
        // add exit button
        let cancelButton = UIView(frame: CGRectMake(self.view.frame.width / 9, self.view.frame.height - self.view.frame.width / 5, 48, 48))
        let cancel: UIImage! = UIImage(named: "cancel")
        cancelButton.userInteractionEnabled = true
        cancelButton.backgroundColor = UIColor(patternImage: cancel)
        overlayView.addSubview(cancelButton)
        overlayView.bringSubviewToFront(cancelButton)
        let cancelRecognizer = UITapGestureRecognizer(target: self, action:Selector("tapCancel:"))
        cancelRecognizer.delegate = self
        cancelButton.addGestureRecognizer(cancelRecognizer)
        
        // add switch camera button
        let changeCameraButton = UIView(frame: CGRectMake(self.view.frame.width / 9, self.view.frame.height - self.view.frame.width / 2.5, 48, 48))
        changeCameraButton.userInteractionEnabled = true
        let switch_camera: UIImage! = UIImage(named: "switch_camera")
        changeCameraButton.backgroundColor = UIColor(patternImage: switch_camera)
        overlayView.addSubview(changeCameraButton)
        overlayView.bringSubviewToFront(changeCameraButton)
        let changeCameraRecognizer = UITapGestureRecognizer(target: self, action:Selector("tapChangeCamera:"))
        changeCameraRecognizer.delegate = self
        changeCameraButton.addGestureRecognizer(changeCameraRecognizer)
        
        // add flash contol button
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
    
    // take a photo once camera capture button is tapped
    func tapSnap(recognizer: UITapGestureRecognizer) {
        picker.takePicture()
    }
    
    // exit camera once cancel button is tapped
    func tapCancel(recognizer: UITapGestureRecognizer) {
        self.picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // change camera once switch button is tapped
    func tapChangeCamera(recognizer: UITapGestureRecognizer) {
        // default is using front camera
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
    
    // change flash mode once conctrol button is tapped
    func tapFlash(recognizer: UITapGestureRecognizer) {
        // default is using auto mode
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
    
    // draw a grid view
    func drawGridView(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        
        // set line param
        CGContextSetStrokeColorWithColor(context, UIColor.grayColor().CGColor)
        CGContextSetLineWidth(context, 1)
        
        // four lines to draw
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
    
    // choose image from photo library
    @IBAction func chooseFromLibrary(sender: UIButton) {
        picker.sourceType = .PhotoLibrary
        presentViewController(picker, animated: true, completion: nil)
    }
    
    // once image chosen, display it to the screen
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        didLoadImage = true
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // once the chosen methos is cancelled
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // navigate to the crop view, and send the image shown on current screen to it
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (didLoadImage == true) {
            if(segue.identifier == "pushToCrop") {
                let cropController = segue.destinationViewController as! PhotoCropViewController
                cropController.image = imageView.image
            }
        } else {
            // alert and refuse to navigate if the user do not load any image
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