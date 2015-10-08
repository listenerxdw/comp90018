//
//  UserFeed.swift
//  comp90018
//
//  Created by Pramudita on 9/10/2015.
//  Copyright (c) 2015 Pramudita. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class UserFeed: UIViewController, MCBrowserViewControllerDelegate, MCSessionDelegate {
    
    let serviceType = "Local-Chat"
    
    var browser: MCBrowserViewController!
    var assistant: MCAdvertiserAssistant!
    var session: MCSession!
    var peerID: MCPeerID!
    
    var x = User.sharedInstance
    
    @IBOutlet weak var btnBrowse: UIButton!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var lblTest: UILabel!
    @IBOutlet weak var ivTest: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.peerID = MCPeerID(displayName: UIDevice.currentDevice().name)
        self.session = MCSession(peer: peerID)
        self.session.delegate = self
        
        // the browser
        self.browser = MCBrowserViewController(serviceType: serviceType, session: self.session)
        self.browser.delegate = self
        
        // the advertiser
        self.assistant = MCAdvertiserAssistant(serviceType: serviceType, discoveryInfo: nil, session: self.session)
        // start advertising
        self.assistant.start()
    }
    
    func updateChat(text: String, fromPeer peerID: MCPeerID) {
        var name: String
        
        switch peerID {
        case self.peerID:
            name = "Me"
        default:
            name = peerID.displayName
        }
        
        let message = "\(name): \(text)\n"
        self.lblTest.text = message
        let url = NSURL(string: text)
        let data = NSData(contentsOfURL: url!)
        ivTest.image = UIImage(data: data!)
        //self.chatView.text = self.chatView.text + message
    }
    
    @IBAction func showBrowser(sender: UIButton) {
        // show the browser view controller
        self.presentViewController(self.browser, animated: true, completion: nil)
    }
    
    @IBAction func sendChat(sender: UIButton) {
        
        //let msg = self.messageField.text.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        let msg = x.profPict.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        var error: NSError?
        
        self.session.sendData(msg, toPeers: self.session.connectedPeers, withMode: MCSessionSendDataMode.Unreliable, error: &error)
        
        if error != nil {
            println("Error sending data: \(error!.localizedDescription)")
        }
        
        self.updateChat(x.profPict, fromPeer: self.peerID)
        
        //self.messageField.text = ""
    }
    
    // browser delegate's methods
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController!) {
        // "Done" was tapped
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController!) {
        // "Cancel" was tapped
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // session delegate's methods
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
        // when receiving a data
        dispatch_async(dispatch_get_main_queue(), {
            var msg = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
            
            self.updateChat(msg, fromPeer: peerID)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
