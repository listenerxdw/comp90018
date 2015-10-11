//
//  UserViewController.swift
//  comp90018
//
//  Created by GaoMingyu on 8/10/2015.
//  Copyright (c) 2015 Pramudita. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MultipeerConnectivity

var accessToken = User.sharedInstance.token

class UserViewController: UIViewController, UITableViewDataSource, PhotoChooseViewControllerDelegate, MCNearbyServiceBrowserDelegate, MCSessionDelegate {
    
    let serviceType = "COMP90018"
    var browser:MCNearbyServiceBrowser!
    var assistant:MCNearbyServiceAdvertiser!
    var session: MCSession!
    var peerID: MCPeerID!
    var parameter = ["access_token": accessToken]
    var results: [JSON]? = []
    var postId: [String]? = []
    var timeStamp: [Int]? = []
    var peers: [MCPeerID]? = []
    
    @IBOutlet var tableView:UITableView!
    @IBOutlet weak var sortController: UISegmentedControl!
    
    @IBAction func sortBy(sender: UISegmentedControl) {
        if sortController.selectedSegmentIndex == 0 {
            sortByTime()
            
        } else if sortController.selectedSegmentIndex == 1 {
            sortByLocation()
        }
    }
    
    func sortByTime(){
        /*let url = "https://api.instagram.com/v1/users/self/feed?access_token=\(accessToken)"
        Alamofire.request(.GET, url).responseJSON { (request, response, json, error) in
            if (json != nil){
                var jsonObj = JSON(json!)
                if let data = jsonObj["data"].arrayValue as [JSON]? {
                    self.results = data
                    let num = jsonObj["data"].count
                    for i in 0...num {
                        jsonObj["data"][i]
                    }
                    //println(self.postId!)
                    //println(self.timeStamp!)
                    self.tableView.reloadData()
                }
            }
        }*/
    }
    
    func sortByLocation(){
        
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true // Yes, the table view can be reordered
    }
    
//    func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
//        // update the item in my data source by first removing at the from index, then inserting at the to index.
//        let item = self.results?[fromIndexPath.row]
//        self.results?.removeAtIndex(fromIndexPath.row)
//        self.results?.insert(item!, atIndex: toIndexPath.row)
//    }
//    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //get the destination view controller to connect the delegate so it can communicate
        var destinationViewController = ((tabBarController!.viewControllers)![2] as! UINavigationController).topViewController as! PhotoChooseViewController
        destinationViewController.delegate = self
        // the session
        self.peerID = MCPeerID(displayName: UIDevice.currentDevice().name)
        self.session = MCSession(peer: peerID)
        self.session.delegate = self
        
        // the browser
        self.browser = MCNearbyServiceBrowser(peer: peerID,serviceType: serviceType)
        self.browser.delegate = self
        //start browsing
        self.browser.startBrowsingForPeers()
        
        // the advertiser
        self.assistant = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
        // start advertising
        self.assistant.startAdvertisingPeer()
        
        //set the table view
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        self.loadUserPost()
    }
    
    func loadUserPost(){
        let url = "https://api.instagram.com/v1/users/self/feed?access_token=\(accessToken)"
        Alamofire.request(.GET, url).responseJSON { (request, response, json, error) in
            if (json != nil){
                var jsonObj = JSON(json!)
                if let data = jsonObj["data"].arrayValue as [JSON]? {
                    self.results = data
                    let num = jsonObj["data"].count
                    for i in 0...num {
                        if let id = jsonObj["data"][i]["id"].string as String? {
                            self.postId?.append(id)
                        }
                        if let time = jsonObj["data"][i]["created_time"].int as Int? {
                            self.timeStamp?.append(time)
                        }
                    }
                    //println(self.postId!)
                    //println(self.timeStamp!)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.results?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("userCell") as! UserTableViewCell
        
        // Configure the cell...
        cell.user = self.results?[indexPath.row]
        
        cell.toLike.tag = indexPath.row
        cell.toLike.addTarget(self, action: "like:", forControlEvents: .TouchUpInside)
        
        cell.toComment.tag = indexPath.row
        cell.toComment.addTarget(self, action: "comment:", forControlEvents: .TouchUpInside)
        return cell
    }
    
    @IBAction func like(sender: UIButton) {
        var senderBtn:UIButton = sender as UIButton
        let currentPostId = self.postId?[sender.tag]

        var errorMsg: String = "error:"
        errorMsg = self.sendLike(currentPostId!)


//        self.tableView.reloadData()
    }
//
    func sendLike(currentPostId: String) -> String {
        let url = "https://api.instagram.com/v1/media/\(currentPostId)/likes"
        var errorMsg: String = ""
        
        Alamofire.request(.POST, url, parameters: parameter, encoding: .JSON).responseJSON { (request, response, json, error) in
            
            ////println(request)
            ////println("-----------------------------")
            if json == nil {
                //println(error)

            } else {
                if let data: AnyObject = json{
                    let error = JSON(data)
                    errorMsg = error.description
                }
                //println("XXXX"+errorMsg)
                //println("YYYY")
                //println(json)
            }
        }
//        //println(errorMsg)
        var alert = UIAlertController(title: "Error", message: errorMsg, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel){ (ACTION) -> Void in
            }
        )
        self.presentViewController(alert, animated: true, completion: nil)
        return errorMsg

    }
    
    @IBAction func comment(sender: UIButton) {
        var comment: UITextField?

        
        var alert = UIAlertController(title: "Add Comment", message: " ", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "Enter comment:"
            comment = textField
        })
        let saveAction = UIAlertAction(title: "Send", style: UIAlertActionStyle.Default) { (ACTION) -> Void in
            
            let currentPostId = self.postId?[sender.tag]
            var commentStr = comment?.text
            self.sendComment(currentPostId!, content: commentStr!)
            self.tableView.reloadData()
        }
        alert.addAction(saveAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func sendComment(currentPostId: String, content: String){
        let url = "https://api.instagram.com/v1/media/\(currentPostId)/comments"
        var errorMsg: String = ""
        
        Alamofire.request(.POST, url, parameters: parameter, encoding: .JSON).responseJSON { (request, response, json, error) in
            if json == nil {
                //println(error)
                
            } else {
                if let data: AnyObject = json{
                    let error = JSON(data)
                    errorMsg = error.description
                }
                //println(errorMsg)
                
                //println(json)
            }
        }
        //        //println(errorMsg)
        
        
        
    }
    
    //sending data function to be triggered outside by Photo
    func sendData(data: NSData){
        update(data,name: "test")
        var error: NSError?
        if error != nil {
            println("Error sending data: \(error!.localizedDescription)")
        }
        println("SEND DATA")
        println(peers?[0].displayName)
        //var a : [AnyObject] = self.session.connectedPeers
        self.session.sendData(data, toPeers: peers, withMode: MCSessionSendDataMode.Reliable, error:&error)
    }
    
    //update the news feed - UI
    func update(data:NSData,name:String){
        //convert back to NSDictionary
        let dictionary:NSDictionary = NSKeyedUnarchiver.unarchiveObjectWithData(data)! as! NSDictionary
        //update the news feed
        let img = (dictionary.objectForKey("image")) as! NSData
        let imgString = img.base64EncodedStringWithOptions(.allZeros)
        let username = dictionary.objectForKey("username") as! String
        let profpict = dictionary.objectForKey("profpict") as! String
        let jsonObject : JSON  =
        [
        "username": username,
        "image":imgString,
        "type": "swipe",
        "profpict": profpict,
        "id": name
        ]
        results?.insert(jsonObject, atIndex: 0)
        self.tableView.reloadData()
        //self.ivTest.image = img
        //self.lblTest.text = username
        
        //self.results?.append(<#newElement: T#>)
    }
    
    func del(name:String){
        var total = (results?.count)! - 1
        for var index = 0; index < total; ++index {
            if(results?[index]["id"].string == name){
                results?.removeAtIndex(index)
                total -= 1
                index -= 1
            }
        }
        self.tableView.reloadData()
    }
    //browser delegate
    func browser(browser: MCNearbyServiceBrowser!, foundPeer peerID: MCPeerID!, withDiscoveryInfo info: [NSObject : AnyObject]!) {
        print("Found PeerID:")
        println(peerID)
        peers?.append(peerID)
    }
    func browser(browser: MCNearbyServiceBrowser!, lostPeer peerID: MCPeerID!) {
        print("Lost PeerID:")
        println(peerID)
        del(peerID.displayName)
    }
    
    // session delegate's methods
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
        println("R1")
        // when receiving a data
        dispatch_async(dispatch_get_main_queue(), {
            println("RECEIVED THE DATA FROM:" + peerID.displayName)
            self.update(data,name: peerID.displayName)
        })
    }
    
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {
        println("R2")
    }
    
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {
        println("R3")
    }
    
    
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
        println("R4")
    }
    
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        
    }

}
