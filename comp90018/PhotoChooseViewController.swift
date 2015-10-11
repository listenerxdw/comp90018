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
    func update(data: NSData, name:String)
    func del(name:String)
}

class PhotoChooseViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MCNearbyServiceBrowserDelegate, MCSessionDelegate {
    var delegate: PhotoChooseViewControllerDelegate?
    
    @IBOutlet weak var imageView: UIImageView!
    
    let serviceType = "COMP90018"
    let x = User.sharedInstance
    var picker = UIImagePickerController()
    var didLoadImage: Bool!
    var browser:MCNearbyServiceBrowser!
    var assistant:MCNearbyServiceAdvertiser!
    var session: MCSession!
    var peerID: MCPeerID!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        didLoadImage = false
        imageView.image = UIImage(named: "add-picture")
        picker.delegate = self
        
        // the session
        self.peerID = MCPeerID(displayName: UIDevice.currentDevice().name)
        self.session = MCSession(peer: peerID)
        self.session.delegate = self
        
        // the browser
        self.browser = MCNearbyServiceBrowser(peer: peerID,serviceType: serviceType)
        self.browser.delegate = self
        
        // the advertiser
        self.assistant = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
        // start advertising
        self.assistant.startAdvertisingPeer()
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
                //send to peers and error checking
                var error: NSError?
                if error != nil {
                    println("Error sending data: \(error!.localizedDescription)")
                }
                self.session.sendData(data, toPeers: self.session.connectedPeers, withMode: MCSessionSendDataMode.Unreliable, error: &error)
                //go back to home
                self.delegate?.update(data,name: self.peerID.displayName)
                self.tabBarController?.selectedIndex = 0
            }))
            presentViewController(refreshAlert, animated: true, completion: nil)
        }
    }
    
    //browser delegate
    func browser(browser: MCNearbyServiceBrowser!, foundPeer peerID: MCPeerID!, withDiscoveryInfo info: [NSObject : AnyObject]!) {
        print("Found PeerID:")
        println(peerID)
    }
    func browser(browser: MCNearbyServiceBrowser!, lostPeer peerID: MCPeerID!) {
        print("Lost PeerID:")
        println(peerID)
        self.delegate?.del(peerID.displayName)
    }
    
    // session delegate's methods
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
        // when receiving a data
        dispatch_async(dispatch_get_main_queue(), {
            self.tabBarController?.selectedIndex = 0
            println("RECEIVED THE DATA FROM:" + peerID.displayName)
            self.delegate?.update(data,name: peerID.displayName)
        })
    }
    
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {
        
    }
    
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {
        
    }
    
    
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
        
    }
    
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        
    }
}