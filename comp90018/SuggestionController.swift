//
//  SuggestionController.swift
//  comp90018
//
//  Created by 璐璐 on 10/10/2015.
//  Copyright (c) 2015 Pramudita. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
class SuggestionController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var theTable: UITableView!
    //show username in table view
    var dataOfTableView:[String] = []
    //all users that I follow
    var follow:[String] = []
    //all users'id that I follow
    var followId:[String] = []
    //number of users that I follow
    var numberFollow = 0
    //all users that followed by all users that I follow
    var allDataOfFollow = [[String]]()
    //store the final result of algorithm for suggestion
    var finalSugg:[String] = []
    //store the username and its corresponding url of profile picture
    var findProfile:[[String]] = []
    var userUpload:[[String]] = []
    var userandid:[[String]] = []
    var swipeNum = 0
    var access_token = User.sharedInstance.token

    @IBAction func getMore(sender: AnyObject) {
        commonFriends()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.finalSugg = []
        self.dataOfTableView = ["searching..."]
    }
    
    //return number of rows for tableview
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataOfTableView.count
    }
    //show data in tableview
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //reuse cell
        let cell = self.theTable.dequeueReusableCellWithIdentifier("cell") as! UITableViewCell
        var label = cell.viewWithTag(101) as? UILabel
        var image = cell.viewWithTag(90) as? UIImageView
        var theText = self.dataOfTableView[indexPath.row]
        label!.text = theText
        var profilePic = findPic(theText)
        //if the corresponding url of profile picture exists
        if profilePic != "wrong" {
            var url = NSURL(string: profilePic)
            var data = NSData(contentsOfURL: url!)
            image!.image = UIImage(data: data!)
        }
        var upload = findUpload(theText)
        if upload.count>0 {
            for i in 1...upload.count-1 {
                var picUrl = upload[i]
                var picture = cell.viewWithTag(i) as? UIImageView
                var url = NSURL(string: picUrl)
                var data = NSData(contentsOfURL: url!)
                picture!.image = UIImage(data: data!)
            }
            if upload.count == 2 {
                var empty2 = cell.viewWithTag(2) as? UIImageView
                var empty3 = cell.viewWithTag(3) as? UIImageView
                empty2!.image = UIImage(named: "10")
                empty3!.image = UIImage(named: "10")
            }
            if upload.count == 3 {
                var empty3 = cell.viewWithTag(3) as? UIImageView
                empty3!.image = UIImage(named: "10")
            }
        } else {
            var empty1 = cell.viewWithTag(1) as? UIImageView
            var empty2 = cell.viewWithTag(2) as? UIImageView
            var empty3 = cell.viewWithTag(3) as? UIImageView
            empty1!.image = UIImage(named: "10")
            empty2!.image = UIImage(named: "10")
            empty3!.image = UIImage(named: "10")
        }
        return cell
    }
    //find the corresponding url of profile picture according to the input username
    func findPic(text:String)-> String {
        if findProfile.count>0 {
            for i in 0...findProfile.count-1 {
                if text == self.findProfile[i][0] {
                    return self.findProfile[i][1]
                }
            }
        }
        return "wrong"
    }
    
    func findUpload(text:String) -> [String] {
        if userUpload.count>0 {
            for i in 0...userUpload.count-1 {
                if text == self.userUpload[i][0] {
                    return self.userUpload[i]
                }
            }
        }
        return []
    }
    func findId(username:String) -> String {
        if userandid.count>0 {
            for i in 0...userandid.count-1 {
                if username == self.userandid[i][0] {
                    return self.userandid[i][1]
                }
            }
        }
        return "wrong"
    }

    func goSuggestion() {
        
        //find the common friends of the users that I follow
        getCommonFriends()
        //get the users that follow me
        if self.finalSugg.count<25 {
            
            getFollowedBy(access_token,userId: "self")
        }
        
        //if the number of suggested users are less than 10,then the users that liked
        //the post tagged as travel and sports will be suggested.
        println(self.finalSugg.count)
        if self.finalSugg.count<25 {
            var expectNum = 25-self.finalSugg.count
            getTag(expectNum,token: access_token)
        }
        
        for m in 0...self.finalSugg.count-1 {
            var temp3:[String] = []
            var name = self.finalSugg[m]
            var id = findId(self.finalSugg[m])
            if id != "wrong" {
                var url = "https://api.instagram.com/v1/users/\(id)/media/recent?count=3&access_token=\(access_token)"
                Alamofire.request(.GET,url).responseJSON {
                    (_,_,data,error) in
                    let json = JSON(data!)
                    temp3.append(name)
                    if json["data"].count > 0 {
                        for j in 0...json["data"].count-1 {
                            temp3.append(json["data"][j]["images"]["thumbnail"]["url"].string!)
                        }
                        self.userUpload.append(temp3)
                    }
                    temp3 = []
                    self.dataOfTableView = self.finalSugg
                    self.theTable.reloadData()
                }
            }
        }
        self.dataOfTableView = self.finalSugg
        //update the table
        self.theTable.reloadData()
        println("over")
    }
    //find the users that liked the post tagged as travel and sports
    func travellAndsports(myurl:String,expected:Int) {
        //expectedNum is number of users that we need to find
        var expectedNum = expected
        var count = 0
        let url = myurl
        var temp:[String] = []
        var temp2:[String] = []
        Alamofire.request(.GET,url).responseJSON {
            (_,_,data,error) in
            let json = JSON(data!)
            if json["data"].count>0 {
                if json["data"].count < expectedNum {
                    count = json["data"].count
                }
                else {
                    count = expectedNum
                }
                for i in 0...count-1 {
                    var username = json["data"][i]["user"]["username"].string!
                    if !self.existFollows(username) && !self.checkExist(username) {
                        self.finalSugg.append(username)
                        temp.append(username)
                        temp.append(json["data"][i]["user"]["profile_picture"].string!)
                        temp2.append(username)
                        temp2.append(json["data"][i]["user"]["id"].string!)
                        self.findProfile.append(temp)
                        self.userandid.append(temp2)
                        temp = []
                        temp2 = []
                    }
                }
            }
            println("step3: \(self.finalSugg.count)")
            self.dataOfTableView = self.finalSugg
            //update the table
            self.theTable.reloadData()
        }
        
    }
    //this function is to find expected number of users from tag travel and sports separately
    func getTag(expectNum:Int,token:String) {
        var numOfsports = expectNum/2
        var numOftravell = expectNum - numOfsports
        //sports part
        travellAndsports("https://api.instagram.com/v1/tags/sports/media/recent?access_token=\(token)",expected: numOfsports)
        //travell part
        travellAndsports("https://api.instagram.com/v1/tags/travell/media/recent?access_token=\(token)",expected: numOftravell)
    }
    //this function is to find the users that follow me but I do not follow and haven't been suggested yet
    func getFollowedBy(token:String,userId:String) {
        var temp:[String] = []
        var temp2:[String] = []
        var count = 0
        let url = "https://api.instagram.com/v1/users/\(userId)/followed-by?access_token=\(token)"
        let requestURL = NSURL(string:url)
        let request = NSURLRequest(URL: requestURL!)
        var data = NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: nil)
        let json = JSON(data: data!)
        if json["data"].count > 0 {
            for i in 0...json["data"].count-1 {
                if !existFollows(json["data"][i]["username"].string!) && !checkExist(json["data"][i]["username"].string!) {
                    self.finalSugg.append(json["data"][i]["username"].string!)
                    temp.append(json["data"][i]["username"].string!)
                    temp.append(json["data"][i]["profile_picture"].string!)
                    temp2.append(json["data"][i]["username"].string!)
                    temp2.append(json["data"][i]["id"].string!)
                    findProfile.append(temp)
                    self.userandid.append(temp2)
                    temp = []
                    temp2 = []
                }
            }
        }
    }
    //this function is to find all the users that I follow
    func getMyFollows(token:String) -> Void {
        let url = "https://api.instagram.com/v1/users/self/follows?access_token=\(token)"
        let requestURL = NSURL(string:url)
        let request = NSURLRequest(URL: requestURL!)
        var data = NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: nil)
        let json = JSON(data: data!)
        for i in 0...(json["data"].count-1) {
            self.follow.append(json["data"][i]["username"].string!)
            self.followId.append(json["data"][i]["id"].string!)
        }
        //number of friends
        numberFollow = self.follow.count
    }
    //this function is to find all the users that followed by my friends
    func findFriend(token:String,potentialId:String) -> [String]{
        var id:[String] = []
        var temp:[String] = []
        var temp2:[String] = []
        let url = "https://api.instagram.com/v1/users/\(potentialId)/follows?access_token=\(token)"
        let requestURL = NSURL(string:url)
        let request = NSURLRequest(URL: requestURL!)
        var data = NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: nil)
        let json = JSON(data: data!)
        //do not include the users that have more than 500 friends, the data is too much
        if json["data"].count > 0 && json["data"].count <= 500 {
            for i in 0...(json["data"].count-1) {
                id.append(json["data"][i]["username"].string!)
                temp.append(json["data"][i]["username"].string!)
                temp.append(json["data"][i]["profile_picture"].string!)
                temp2.append(json["data"][i]["username"].string!)
                temp2.append(json["data"][i]["id"].string!)
                self.userandid.append(temp2)
                findProfile.append(temp)
                temp = []
                temp2 = []
            }
        }
        return id
    }
    func getLikedUser(){
        var temp:[String] = []
        var temp2:[String] = []
        var temp3:[String] = []
        var userId:[[String]] = []
        let url = "https://api.instagram.com/v1/users/self/media/liked?access_token=\(access_token)"
        Alamofire.request(.GET,url).responseJSON {
            (_,_,data,error) in
            println("like back")
            let json = JSON(data!)
            for i in 0...json["data"].count-1 {
                var username = json["data"][i]["user"]["username"].string!
                if !self.existFollows(username) && !self.checkExist(username){
                    self.finalSugg.append(username)
                    temp.append(username)
                    temp.append(json["data"][i]["user"]["profile_picture"].string!)
                    temp2.append(username)
                    temp2.append(json["data"][i]["user"]["id"].string!)
                    userId.append(temp2)
                    self.findProfile.append(temp)
                    temp = []
                    temp2 = []
                }
            }
            for i in 0...userId.count-1 {
                var id = userId[i][1]
                var name = userId[i][0]
                var url = "https://api.instagram.com/v1/users/\(id)/media/recent?count=3&access_token=\(self.access_token)"
                Alamofire.request(.GET,url).responseJSON {
                    (_,_,data,error) in
                    let json = JSON(data!)
                    println("\(id)")
                    println(i)
                    println(name)
                    temp3.append(name)
                    for j in 0...json["data"].count-1 {
                        temp3.append(json["data"][j]["images"]["thumbnail"]["url"].string!)
                    }
                    self.userUpload.append(temp3)
                    temp3 = []
                    self.dataOfTableView = self.finalSugg
                    self.theTable.reloadData()
                }
            }
        }
    }
    
    func commonFriends(){
        var subfollow:[String] = []
        var followArray = [[String]]()
        for var i=0; i<self.numberFollow; i++ {
            subfollow = self.findFriend(access_token,potentialId: self.followId[i])
            followArray.append(subfollow)
        }
        self.allDataOfFollow = followArray
        self.goSuggestion()
        
    }
    
    //this function is to get all users followed by my friends
    
    //find out the users that appear more than 2 times of a list of users of my friends
    func getCommonFriends() -> Void {
        var myname = User.sharedInstance.username
        var count = 1
        for var i=0; i<allDataOfFollow.count-1;i++ {
            for var m=0;m<allDataOfFollow[i].count;m++ {
                for var j=i+1;j<allDataOfFollow.count;j++ {
                    count = count + checkTarget(allDataOfFollow[i][m],friendList: allDataOfFollow[j])
                }
                if count >= 3 {
                    if !checkExist(allDataOfFollow[i][m]) && !(allDataOfFollow[i][m] == myname)
                        && !existFollows(self.allDataOfFollow[i][m]){
                            self.finalSugg.append(self.allDataOfFollow[i][m])}
                }
                count = 1
            }
            
        }
    }
    //check if the user has already been my friends
    func existFollows(username:String) -> Bool {
        for i in 0...self.follow.count-1 {
            if username == self.follow[i] {
                return true
            }
        }
        return false
    }
    //check if the user has already in the suggestion list
    func checkExist(target:String) -> Bool {
        if self.finalSugg.count > 0 {
            for i in 0...self.finalSugg.count-1 {
                if target == self.finalSugg[i] {
                    return true
                }
            }
        }
        return false
    }
    //check if the target user is one of the friends of a friend of mine
    func checkTarget(target: String, friendList:[String]) -> Int {
        for var i=0;i<friendList.count;i++ {
            if friendList[i] == target {
                //if target is one of the friends of a friend of mine then return 1
                return 1
            }
        }
        return 0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}