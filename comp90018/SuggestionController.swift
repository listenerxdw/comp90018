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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.finalSugg = []
        self.dataOfTableView = []
        //get all the users followed by the users that I follow
        getAllsubFriends("1457552126.085bfe1.d38c9ac13cf14ca7a1bc3ce9b7bfa200")
        
    }
    
    //return number of rows for tableview
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println("update了~~~\(self.dataOfTableView.count)")
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
    
    //main algorithm for suggestion
    func goSuggestion() {
        
        //find the common friends of the users that I follow
        getCommonFriends()
        //get the users that follow me
        if self.finalSugg.count<25 {
            getFollowedBy("1457552126.085bfe1.d38c9ac13cf14ca7a1bc3ce9b7bfa200",userId: "self")
        }
        
        //if the number of suggested users are less than 10,then the users that liked
        //the post tagged as travel and sports will be suggested.
        println(self.finalSugg.count)
        if self.finalSugg.count<25 {
            var expectNum = 25-self.finalSugg.count
            getTag(expectNum,token: "1457552126.085bfe1.d38c9ac13cf14ca7a1bc3ce9b7bfa200")
        }
        
        self.dataOfTableView = self.finalSugg
        //update the table
        self.theTable.reloadData()
    }
    //find the users that liked the post tagged as travel and sports
    func travellAndsports(myurl:String,expected:Int) {
        //expectedNum is number of users that we need to find
        var expectedNum = expected
        var count = 0
        let url = myurl
        var temp:[String] = []
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
                        self.findProfile.append(temp)
                        temp = []
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
                    findProfile.append(temp)
                    temp = []
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
                findProfile.append(temp)
                temp = []
            }
        }
        return id
    }
    //this function is to find the users whose I liked the photos of but not my friend yet.
    func getLikedUser(){
        var temp:[String] = []
        let url = "https://api.instagram.com/v1/users/self/media/liked?access_token=1457552126.085bfe1.d38c9ac13cf14ca7a1bc3ce9b7bfa200"
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
                    self.findProfile.append(temp)
                    temp = []
                }
            }
            self.dataOfTableView = self.finalSugg
            //update the table
            self.theTable.reloadData()
            
        }
    }
    
    func commonFriends(){
        let url = "https://api.instagram.com/v1/users/self/media/liked?access_token=1457552126.085bfe1.d38c9ac13cf14ca7a1bc3ce9b7bfa200"
                Alamofire.request(.GET,url).responseJSON {
            (_,_,data,error) in
            println("common back")
            var subfollow:[String] = []
            var followArray = [[String]]()
            for var i=0; i<self.numberFollow; i++ {
                subfollow = self.findFriend("1457552126.085bfe1.d38c9ac13cf14ca7a1bc3ce9b7bfa200",potentialId: self.followId[i])
                followArray.append(subfollow)
            }
            self.allDataOfFollow = followArray
            self.goSuggestion()
        }
        
    }
    
    //this function is to get all users followed by my friends
    func getAllsubFriends(token:String){
        self.follow = []
        self.followId = []
        numberFollow = 0
        getMyFollows(token)
        getLikedUser()
        commonFriends()
    }
    //find out the users that appear more than 2 times of a list of users of my friends
    func getCommonFriends() -> Void {
        var count = 1
        for var i=0; i<allDataOfFollow.count-1;i++ {
            for var m=0;m<allDataOfFollow[i].count;m++ {
                for var j=i+1;j<allDataOfFollow.count;j++ {
                    count = count + checkTarget(allDataOfFollow[i][m],friendList: allDataOfFollow[j])
                }
                if count >= 3 {
                    if !checkExist(allDataOfFollow[i][m]) && !(allDataOfFollow[i][m] == "qijie19920618")
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