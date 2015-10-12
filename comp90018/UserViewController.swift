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
import CoreLocation

var accessToken = User.sharedInstance.token

class UserViewController: UIViewController, UITableViewDataSource, CLLocationManagerDelegate {
    var parameter = ["access_token": accessToken]
    var results: [JSON]? = []
    var postId: [String]? = []
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    let locationManager = CLLocationManager()


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
        let url = "https://api.instagram.com/v1/users/self/feed?access_token=\(accessToken)"
        Alamofire.request(.GET, url).responseJSON { (request, response, json, error) in
            if (json != nil){
                var error: NSError?
                var data = JSON(json!)
                var rawData = data.rawData(options: nil, error: &error)
                if let jsonDic = NSJSONSerialization.JSONObjectWithData(rawData!, options: nil, error: &error) as? NSDictionary{
                    if let unsortedEvents = jsonDic["data"] as? NSArray {
                        let descriptor = NSSortDescriptor(key: "created_time", ascending: true, selector: "caseInsensitiveCompare:")
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
                        //println(sorted)
                        dispatch_async(dispatch_get_main_queue()){ () -> Void in
                            self.tableView.reloadData()
                        }
                    }
                }
    
            }
        }
    }
    
    func getTargetLatitude(data: [JSON], index: Int) -> Double{
        var tl: Double = 360.0
        if let l = data[index]["location"]["latitude"].double{
            tl = l
        }
        return tl
    }
    
    func getTargetLongitude(data: [JSON], index: Int) -> Double{
        var tl: Double = 360.0
        if let l = data[index]["location"]["longitude"].double{
            tl = l
        }
        return tl
    }
    
    func distance(targetLatitude: Double, targetLongitude: Double) -> Double{
        var approDistance = sqrt(pow((targetLatitude - self.latitude),2) + pow(targetLongitude - self.longitude, 2))
        return approDistance
    }
    
    func sortByLocation(){
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //        self.locationManager.distanceFilter = 10 // update when it exceeds a certain distance (meters)
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        println("start to record location...")

        
        let url = "https://api.instagram.com/v1/users/self/feed?access_token=\(accessToken)"
        Alamofire.request(.GET, url).responseJSON { (request, response, json, error) in
            if (json != nil){
                var error: NSError?
                var data = JSON(json!)
                var rawData = data.rawData(options: nil, error: &error)
                if let jsonDic = NSJSONSerialization.JSONObjectWithData(rawData!, options: nil, error: &error) as? NSDictionary{
                    if let unsortedEvents = jsonDic["data"] as? NSArray{
                        var unsortedData = NSMutableArray(array: unsortedEvents)
                        var num = unsortedEvents.count
                        var jsonObj = JSON(json!)
                        if let data = jsonObj["data"].arrayValue as [JSON]? {
                            //                    self.results = data
                            for i in 0...num - 1 {
                                var dist1 = self.distance(self.getTargetLatitude(data, index: i), targetLongitude: self.getTargetLongitude(data, index: i))
                                println(dist1)
                                for j in i...num - 1 {
                                    if self.distance(self.getTargetLatitude(data, index: j), targetLongitude: self.getTargetLongitude(data, index: j)) < dist1 {
                                        //                                dist1 = self.distance(self.getTargetLatitude(data, index: j), targetLongitude: self.getTargetLongitude(data, index: j))
                                        unsortedData.exchangeObjectAtIndex(i, withObjectAtIndex: j)
                                    }
                                }
                            }
//                            println(unsortedData)
                        }
                        for i in 0...num - 1 {
                            self.results?[i] = JSON(unsortedData[i])
                            println(self.results?[i]["location"])
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        self.sendLike(currentPostId!)
        

//        self.tableView.reloadData()
    }
//
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
                
                println(errorMsg)
                println(json)
            }
        }
      
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
//            self.tableView.reloadData()
        }
        alert.addAction(saveAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
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
                println(errorMsg)
                
                println(json)
            }
        }
    }

    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        self.longitude = manager.location.coordinate.longitude
        self.latitude = manager.location.coordinate.latitude
        println(self.latitude)
        println(self.longitude)
        self.locationManager.stopUpdatingLocation()

    }
    
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Error: \(error.localizedDescription)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
