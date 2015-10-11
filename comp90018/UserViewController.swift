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

//let parameter = ["access_token": "1929157665.5b9e1e6.3f2c4f742fab45d9b74d1f1b33271cf2"]
//let accessToken = "1929157665.5b9e1e6.3f2c4f742fab45d9b74d1f1b33271cf2"
var accessToken = User.sharedInstance.token

class UserViewController: UIViewController, UITableViewDataSource {
    var parameter = ["access_token": accessToken]
    var results: [JSON]? = []
    @IBOutlet var tableView:UITableView!
    @IBOutlet weak var sortController: UISegmentedControl!
    
    @IBAction func sortBy(sender: UISegmentedControl) {
        if sortController.selectedSegmentIndex == 0 {
            sortByTime(timeStamp!)
            
        } else if sortController.selectedSegmentIndex == 1 {
            sortByLocation()
        }
    }
    
    func sortByTime(timeStamp: [Int]){
        
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
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        self.loadUserPost()
    }
    
    var postId: [String]? = []
    var timeStamp: [Int]? = []


    
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
                    println(self.postId!)
                    println(self.timeStamp!)
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
            
            //println(request)
            //println("-----------------------------")
            if json == nil {
                println(error)

            } else {
                if let data: AnyObject = json{
                    let error = JSON(data)
                    errorMsg = error.description
                }
                println("XXXX"+errorMsg)
                println("YYYY")
                println(json)
            }
        }
//        println(errorMsg)
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
                println(error)
                
            } else {
                if let data: AnyObject = json{
                    let error = JSON(data)
                    errorMsg = error.description
                }
                println(errorMsg)
                
                println(json)
            }
        }
        //        println(errorMsg)
        
        
        
    }

}
