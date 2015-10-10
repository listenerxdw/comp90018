//
//  SuggestionController.swift
//  comp90018
//
//  Created by 璐璐 on 10/10/2015.
//  Copyright (c) 2015 Pramudita. All rights reserved.
//

import UIKit
import SwiftyJSON

class SuggestionController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var theTable: UITableView!
    var ctrlsel:[String] = []
    var follow:[String] = []
    var followId:[String] = []
    var numberFollow = 0
    var allDataOfFollow = [[String]]()
    var finalSugg:[String] = []
    var findProfile:[[String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ctrlsel = [""]
        goSuggestion()

    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {return self.ctrlsel.count}
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {   let cell = self.theTable.dequeueReusableCellWithIdentifier("cell") as! UITableViewCell
        var label = cell.viewWithTag(101) as? UILabel
        var image = cell.viewWithTag(90) as? UIImageView
        var theText = self.ctrlsel[indexPath.row]
        label!.text = theText
        var profilePic = findPic(theText)
        if profilePic != "wrong" {
            var url = NSURL(string: profilePic)
            var data = NSData(contentsOfURL: url!)
            image!.image = UIImage(data: data!)}
        
        return cell
    }
    
    func findPic(text:String)-> String{
        if findProfile.count>0
        {
            for i in 0...findProfile.count-1
            {  if text == self.findProfile[i][0]
            { return self.findProfile[i][1]
                }
            }
        }
        return "wrong"
    }
    
     func goSuggestion() {
        self.finalSugg = []
        self.ctrlsel = []
        getAllsubFriends()
        getCommonFriends()
        //lulucheck
        println("step1: \(self.finalSugg.count)")
        if self.finalSugg.count<20{
            //推荐followed by
            var expectNum = 20-self.finalSugg.count
            getFollowedBy("1457552126.085bfe1.d38c9ac13cf14ca7a1bc3ce9b7bfa200",userId: "self",expectNum: expectNum)
        }
        println("step2: \(self.finalSugg.count)")
        if self.finalSugg.count<20 {
            //推荐tag,travell,sports
            var expectNum = 20-self.finalSugg.count
            getTag(expectNum,token: "1457552126.085bfe1.d38c9ac13cf14ca7a1bc3ce9b7bfa200")
        }
        self.ctrlsel = self.finalSugg
        //update the table
        self.theTable.reloadData()
        
    }
    
    func travellAndsports(myurl:String,expected:Int){
        var expectedNum = expected
        var count = 0
        let url = myurl
        var temp:[String] = []
        let requestURL = NSURL(string:url)
        let request = NSURLRequest(URL: requestURL!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue())
            {(response, data, error) in
                let json = JSON(data: data!)
                if json["data"].count>0
                {
                    if json["data"].count < expectedNum
                    {count = json["data"].count} else {count = expectedNum}
                    for i in 0...count-1
                    {
                        var username = json["data"][i]["user"]["username"].string!
                        if !self.existFollows(username) && !self.checkExist(username)
                        { self.finalSugg.append(username)
                            temp.append(username)
                            temp.append(json["data"][i]["user"]["profile_picture"].string!)
                            self.findProfile.append(temp)
                            temp = []
                        }
                    }
                }
                println("step3: \(self.finalSugg.count)")
                self.ctrlsel = self.finalSugg
                //update the table
                self.theTable.reloadData()
        }
        
    }
    
    func getTag(expectNum:Int,token:String)
    { var numOfsports = expectNum/2
        var numOftravell = expectNum - numOfsports
        //sports part
        travellAndsports("https://api.instagram.com/v1/tags/sports/media/recent?access_token=\(token)",expected: numOfsports)
        //travell part
        travellAndsports("https://api.instagram.com/v1/tags/travell/media/recent?access_token=\(token)",expected: numOftravell)
        
    }
    
    func getFollowedBy(token:String,userId:String,expectNum:Int)
    {   var temp:[String] = []
        var count = 0
        let url = "https://api.instagram.com/v1/users/\(userId)/followed-by?access_token=\(token)"
        let requestURL = NSURL(string:url)
        let request = NSURLRequest(URL: requestURL!)
        var data = NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: nil)
        let json = JSON(data: data!)
        if json["data"].count>expectNum
        {count = expectNum}
        else {count = json["data"].count}
        for i in 0...count-1
        {   if !existFollows(json["data"][i]["username"].string!) && !checkExist(json["data"][i]["username"].string!)
        {
            self.finalSugg.append(json["data"][i]["username"].string!)
            temp.append(json["data"][i]["username"].string!)
            temp.append(json["data"][i]["profile_picture"].string!)
            findProfile.append(temp)
            temp = []
            }
        }
    }
    
    func getFollows() -> Void {
        let url = "https://api.instagram.com/v1/users/self/follows?access_token=1457552126.085bfe1.d38c9ac13cf14ca7a1bc3ce9b7bfa200"
        let requestURL = NSURL(string:url)
        let request = NSURLRequest(URL: requestURL!)
        var data = NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: nil)
        let json = JSON(data: data!)
        for i in 0...(json["data"].count-1)
        {   self.follow.append(json["data"][i]["username"].string!)
            self.followId.append(json["data"][i]["id"].string!)
            //println(self.follow[i])
        }
        numberFollow = self.follow.count
        
    }
    
    func findFriend(potentialId:String) -> [String]{
        // println(potentialId)
        var id:[String] = []
        var temp:[String] = []
        let url = "https://api.instagram.com/v1/users/\(potentialId)/follows?access_token=1457552126.085bfe1.d38c9ac13cf14ca7a1bc3ce9b7bfa200"
        let requestURL = NSURL(string:url)
        let request = NSURLRequest(URL: requestURL!)
        var data = NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: nil)
        let json = JSON(data: data!)
        if json["data"].count > 0 && json["data"].count <= 300{ //去掉好友超过300个的人
            for i in 0...(json["data"].count-1)
            {
                id.append(json["data"][i]["username"].string!)
                temp.append(json["data"][i]["username"].string!)
                temp.append(json["data"][i]["profile_picture"].string!)
                findProfile.append(temp)
                temp = []
            }
        }
        return id
    }
    
    func getAllsubFriends(){
        self.follow = []
        self.followId = []
        numberFollow = 0
        var subfollow:[String] = []
        var followArray = [[String]]()
        getFollows()
        for var i=0; i<self.numberFollow; i++
        {
            subfollow = findFriend(followId[i])
            followArray.append(subfollow)
            
        }
        self.allDataOfFollow = followArray
    }
    
    func getCommonFriends() -> Void{
        var count = 1
        for var i=0; i<allDataOfFollow.count-1;i++
        { for var m=0;m<allDataOfFollow[i].count;m++
        { for var j=i+1;j<allDataOfFollow.count;j++
        { count = count + checkTarget(allDataOfFollow[i][m],s: allDataOfFollow[j])
            }
            if count >= 4 {
                if !checkExist(allDataOfFollow[i][m]) && !(allDataOfFollow[i][m] == "qijie19920618")
                    && !existFollows(self.allDataOfFollow[i][m]){
                        self.finalSugg.append(self.allDataOfFollow[i][m])}
            }
            count = 1
            }
            
        }
    }
    
    func existFollows(username:String) -> Bool{
        for i in 0...self.follow.count-1
        {  if username == self.follow[i]
        {return true}
        }
        
        return false
    }
    
    func checkExist(target:String) -> Bool {
        if self.finalSugg.count > 0 {
            for i in 0...self.finalSugg.count-1
            {  if target == self.finalSugg[i]
            {return true}
            }
        }
        return false
    }
    
    func checkTarget(target: String, s:[String]) -> Int {
        for var i=0;i<s.count;i++
        {  if s[i] == target
        { return 1
            }
        }
        return 0
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}