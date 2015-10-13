//
//  UserController.swift
//  comp90018
//
//  Created by 璐璐 on 10/10/2015.
//  Copyright (c) 2015 Pramudita. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import Haneke
class UserController:  UIViewController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView2: UITableView!
    
    var follow:[[String]] = []
    var dataOfTableView:[[String]] = []
    var tempctr:[[String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView2.reloadData()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    //return number of rows for tableview
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataOfTableView.count
    }
    
    //show data in tableview
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView2.dequeueReusableCellWithIdentifier("usercell") as! UITableViewCell
        //in storyboard, image view is tagged with 105 and label is tagged with 106
        var image = cell.viewWithTag(105) as? UIImageView
        var label = cell.viewWithTag(106) as? UILabel
        //check if the data is about uploading photos or following friends
        var check:String = self.dataOfTableView[indexPath.row][0]
        if check == "pic" {
            var theText = "\(self.dataOfTableView[indexPath.row][1]) uploaded a photo"
            label!.text = theText
            var url = NSURL(string: self.dataOfTableView[indexPath.row][2])
            image!.hnk_setImageFromURL(url!)
        }
        else if check == "friend" {
            var theText = "\(self.dataOfTableView[indexPath.row][1]) followed \(self.dataOfTableView[indexPath.row][2])"
            label!.text = theText
            var url = NSURL(string: self.dataOfTableView[indexPath.row][4])
            image!.hnk_setImageFromURL(url!)
        }
        return cell
    }
    //this function is used to find all followings of me
    func getMyFollows(token:String,username:String,userid:String)->[[String]]{
        var myFriend:[[String]]=[]
        let url = "https://api.instagram.com/v1/users/\(userid)/follows?access_token=\(token)"
        let requestURL = NSURL(string:url)
        let request = NSURLRequest(URL: requestURL!)
        //send sychronous request to API
        var data = NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: nil)
        let json = JSON(data: data!)
        if json["data"].count>0 {
            for i in 0...(json["data"].count-1) {
                var temp:[String] = []
                temp.append(json["data"][i]["username"].string!)
                temp.append(json["data"][i]["id"].string!)
                myFriend.append(temp)
            }
            //sort the users by their username
            myFriend = sort(myFriend)
        }
        return myFriend
    }

    //this function is used to find all followings of my followings
    func getFollows(token:String,username:String,userid:String) {
        var friend = [[String]]()
        friend = []
        //send asychronous request to API
        let url = "https://api.instagram.com/v1/users/\(userid)/follows?access_token=\(token)"
        Alamofire.request(.GET,url).responseJSON{
            (_,_,data,error) in
            let json = JSON(data!)
            if json["data"].count>0 {
                for i in 0...(json["data"].count-1) {
                    var temp:[String] = []
                    temp.append("friend")
                    temp.append(username)
                    temp.append(json["data"][i]["username"].string!)
                    temp.append(json["data"][i]["id"].string!)
                    temp.append(json["data"][i]["profile_picture"].string!)
                    friend.append(temp)
                }
            }
            self.dataOfTableView = self.dataOfTableView + friend
            self.dataOfTableView = self.sort(self.dataOfTableView)
            self.tempctr = self.tempctr + friend
            self.tableView2.reloadData()
        }
    }
    //find all photos that a user uploaded by the user id
    func getUpload(token:String,userid:String) {
        var upload = [[String]]()
        let url="https://api.instagram.com/v1/users/\(userid)/media/recent?access_token=\(token)"
        //send asychronous request to API
        Alamofire.request(.GET,url).responseJSON {
            (_,_,data,error) in
            let json = JSON(data!)
            if json["data"].count>0 {
                for i in 0...(json["data"].count-1) {
                var temp:[String] = []
                temp.append("pic")
                temp.append(json["data"][i]["user"]["username"].string!)
                temp.append(json["data"][i]["images"]["thumbnail"]["url"].string!)
                upload.append(temp)
                }
            }
            self.dataOfTableView = self.dataOfTableView + upload
            self.dataOfTableView = self.sort(self.dataOfTableView)
            self.tempctr = self.tempctr + upload
            self.tableView2.reloadData()
        }
    }
    func getUserActivity() {
        var myname = User.sharedInstance.username
        var access_token = User.sharedInstance.token
        self.follow = []
        self.follow = getMyFollows(access_token,username: myname,userid: "self")
        if self.follow.count>0 {
        for i in 0...self.follow.count-1 {
            var id = self.follow[i][1]
            var friendname = self.follow[i][0]
            //for each following, find what he uploaded and whom he followed witm
            getUpload(access_token,userid: id)
            getFollows(access_token,username: friendname,userid: id)
        }
    }
}
    //this function is used to sort the user by their username alphabetically
    func sort(target:[[String]])-> [[String]] {
        var checknum = 0
        var temp:[[String]] = []
        if target.count>0 {
            temp.append(target[0])
            if target.count>1 {
            for i in 1...target.count-1 {
                for j in 0...temp.count-1 {
                checknum = j
                if target[i][1]<temp[j][1] {
                temp.insert(target[i], atIndex: j)
                    break
                }
                }
                if checknum == temp.count-1 {
                    temp.append(target[i])
                }
            }
        }
        }
        return temp
    }
    
    // called when text changes (including clear)
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            self.dataOfTableView = self.tempctr
        }
        else {
            self.dataOfTableView = []
            for ctrl in self.tempctr {
                if ctrl[1].lowercaseString.hasPrefix(searchText.lowercaseString) {
                    self.dataOfTableView.append(ctrl)
                }
            }
        }
        self.tableView2.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
