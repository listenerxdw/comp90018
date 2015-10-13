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
import CoreLocation

var accessToken = User.sharedInstance.token

class UserViewController: UIViewController, UITableViewDataSource, PhotoChooseViewControllerDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate, MCSessionDelegate, CLLocationManagerDelegate {
    
    let serviceType = "COMP90018"
    var browser:MCNearbyServiceBrowser!
    var assistant:MCNearbyServiceAdvertiser!
    var session: MCSession!
    var peerID: MCPeerID!
    var parameter = ["access_token": accessToken]
    var results: [JSON]? = []
    var postId: [String]? = []
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var currentLocation = CLLocation(latitude: 0.0, longitude: 0.0)
    let locationManager = CLLocationManager()

    @IBOutlet var tableView:UITableView!
    @IBOutlet weak var sortController: UISegmentedControl!
    
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
        self.assistant.delegate=self
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
                    self.postId = []
                    for i in 0...num - 1 {
                        if let id = self.results?[i]["id"].string as String? {
                            self.postId?.append(id)
                        }
                    }
//                    println(self.postId!)
                    dispatch_async(dispatch_get_main_queue()){ () -> Void in
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    // MARK: - Table view data source
    
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
    
    // MARK: - Sort by time and location

    @IBAction func sortBy(sender: UISegmentedControl) {
        if sortController.selectedSegmentIndex == 0 {
            sortByTime()
        } else if sortController.selectedSegmentIndex == 1 {
            sortByLocation()
        }
    }
    
    //To sort loaded posts by time
    func sortByTime(){
        let url = "https://api.instagram.com/v1/users/self/feed?access_token=\(accessToken)"
        Alamofire.request(.GET, url).responseJSON { (request, response, json, error) in
            if (json != nil){
                var error: NSError?
                var data = JSON(json!)
                var rawData = data.rawData(options: nil, error: &error)
                if let jsonDic = NSJSONSerialization.JSONObjectWithData(rawData!, options: nil, error: &error) as? NSDictionary{
                    //store data into NSArray
                    if let unsortedEvents = jsonDic["data"] as? NSArray {
                        //sort the NSArray
                        let descriptor = NSSortDescriptor(key: "created_time", ascending: false, selector: "caseInsensitiveCompare:")
                        var num = unsortedEvents.count
                        
                        for i in 0...num - 1 {
                            self.results?[i] = JSON(unsortedEvents.sortedArrayUsingDescriptors([descriptor])[i])
                        }
                        self.postId = []
                        for i in 0...num - 1 {
                            if let id = self.results?[i]["id"].string as String? {
                                self.postId?.append(id)
                            }
                        }
                        dispatch_async(dispatch_get_main_queue()){ () -> Void in
                            self.tableView.reloadData()
                        }
                    }
                    self.tableView.reloadData()
                }
                
            }
        }
    }
    
    //get the latitude of target location
    func getTargetLatitude(data: [JSON], index: Int) -> Double{
        var tl: Double = 0 - self.latitude
        if let l = data[index]["location"]["latitude"].double{
            tl = l
        }
        return tl
    }
    
    //get the longitude of target location
    func getTargetLongitude(data: [JSON], index: Int) -> Double{
        var tl: Double = 0.0
        if self.longitude <= 0 {
            tl = self.longitude + 180
        } else {
            tl = self.longitude - 180
        }
        if let l = data[index]["location"]["longitude"].double{
            tl = l
        }
        return tl
    }
    
    //calculate the distance between target location and current location
    func distance(targetLatitude: Double, targetLongitude: Double) -> Double{
        var targetLocation = CLLocation(latitude: targetLatitude, longitude: targetLongitude)
        var distance:CLLocationDistance = currentLocation.distanceFromLocation(targetLocation)
        return distance
    }
    
    //To sort loaded posts by time
    func sortByLocation(){
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //        self.locationManager.distanceFilter = 10 // update when it exceeds a certain distance (meters)
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        println("start to record location...")
        
        self.results? = []
        let url = "https://api.instagram.com/v1/users/self/feed?access_token=\(accessToken)"
        Alamofire.request(.GET, url).responseJSON { (request, response, json, error) in
            if (json != nil){
                var jsonObj = JSON(json!)
                if let data = jsonObj["data"].arrayValue as [JSON]? {
                    var num = data.count
                    var dist = 0.0
                    var temp = 0
                    var tempArray: [Int] = []
                    //every iteration, find the ith small distance from data and then appent it to result array
                    for i in 0...num - 1 {
                        println(i)
                        dist = 100000000.0
                        temp = i
                        for j in 0...num - 1 {
                            if !contains(tempArray, j){
                                if self.distance(self.getTargetLatitude(data, index: j), targetLongitude: self.getTargetLongitude(data, index: j)) < dist {
                                    dist = self.distance(self.getTargetLatitude(data, index: j), targetLongitude: self.getTargetLongitude(data, index: j))
                                    temp = j
                                }
                            }
                        }
                        tempArray.append(temp)
                        self.results?.append(data[temp])
                    }
                    self.postId = []
                    for i in 0...num - 1 {
                        if let id = self.results?[i]["id"].string as String? {
                            self.postId?.append(id)
                        }
                    }
                }
                dispatch_async(dispatch_get_main_queue()){ () -> Void in
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    //get the current location
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        self.longitude = manager.location.coordinate.longitude
        self.latitude = manager.location.coordinate.latitude
        currentLocation = CLLocation(latitude: self.latitude, longitude: self.longitude)
        println(self.latitude)
        println(self.longitude)
        self.locationManager.stopUpdatingLocation()
        
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Error: \(error.localizedDescription)")
    }

    // MARK: - Action 'LIKE'
    
    @IBAction func like(sender: UIButton) {
        var senderBtn:UIButton = sender as UIButton
        let currentPostId = self.postId?[sender.tag]
        var errorMsg: String = "error:"
        self.sendLike(currentPostId!)
    }
    
    //send the action 'like' to server
    func sendLike(currentPostId: String) {
        let url = "https://api.instagram.com/v1/media/\(currentPostId)/likes"
        var errorMsg: String = ""
        
        Alamofire.request(.POST, url, parameters: parameter, encoding: .JSON).responseJSON { (request, response, json, error) in
            if json == nil {
                println(error)
            } else {
                if let data: AnyObject = json{
                    let error = JSON(data)
                    errorMsg = error.description
                }
                var alert = UIAlertController(title: "Error", message: errorMsg, preferredStyle: UIAlertControllerStyle.Alert)
                
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel){ (ACTION) -> Void in
                    }
                )
                self.presentViewController(alert, animated: true, completion: nil)
                println(json)
            }
        }
    }
    
    // MARK: - Action 'COMMENT'

    //this button is for leave a comment
    @IBAction func comment(sender: UIButton) {
        var comment: UITextField?
        
        var alert = UIAlertController(title: "Add Comment", message: " ", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "Enter a comment:"
            comment = textField
        })
        let sendAction = UIAlertAction(title: "Send", style: UIAlertActionStyle.Default) { (ACTION) -> Void in
            let currentPostId = self.postId?[sender.tag]
            var commentStr = comment?.text
            self.sendComment(currentPostId!, content: commentStr!)
        }
        alert.addAction(sendAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //send comment to server
    func sendComment(currentPostId: String, content: String){
        let url = "https://api.instagram.com/v1/media/\(currentPostId)/comments"
        var errorMsg: String = ""
        
        Alamofire.request(.POST, url, parameters: parameter, encoding: .JSON).responseJSON { (request, response, json, error) in
            if json == nil {
                println(error)
            } else {
                if let data: AnyObject = json{
                    let error = JSON(data)
                    errorMsg = error.description
                }
                var alert = UIAlertController(title: "Error", message: errorMsg, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel){ (ACTION) -> Void in
                    }
                )
                self.presentViewController(alert, animated: true, completion: nil)
                println(json)
            }
        }
    }
    
    // MARK: -
    
    //sending data function to be triggered outside by Photo
    func sendData(data: NSData){
        update(data,name: "test")
        var error: NSError?
        if error != nil {
            println("Error sending data: \(error!.localizedDescription)")
        }
        println("SEND DATA")
        //var a : [AnyObject] = self.session.connectedPeers
        //println(a[0].displayName)
        self.session.sendData(data, toPeers: self.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable, error:&error)
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
        browser.invitePeer(peerID, toSession: self.session, withContext: nil, timeout: 0)
    }
    func browser(browser: MCNearbyServiceBrowser!, lostPeer peerID: MCPeerID!) {
        print("Lost PeerID:")
        println(peerID)
        del(peerID.displayName)
    }
    //advertiser delegate
    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didReceiveInvitationFromPeer peerID: MCPeerID!, withContext context: NSData!, invitationHandler: ((Bool, MCSession!) -> Void)!) {
        print("RECEIVED FROM:")
        println(peerID)
        invitationHandler(true,self.session)
    }
    // session delegate's methods
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
        // when receiving a data
        dispatch_async(dispatch_get_main_queue(), {
            println("RECEIVED THE DATA FROM:" + peerID.displayName)
            self.update(data,name: peerID.displayName)
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