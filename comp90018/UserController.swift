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
class UserController:  UIViewController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView2: UITableView!
    var follow:[[String]] = []
    var ctrlsel:[[String]] = []
    var tempctr:[[String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView2.reloadData()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {return self.ctrlsel.count}
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = self.tableView2.dequeueReusableCellWithIdentifier("usercell") as! UITableViewCell
        var image = cell.viewWithTag(105) as? UIImageView
        var label = cell.viewWithTag(106) as? UILabel
        //label!.adjustsFontSizeToFitWidth = true
        var check:String = self.ctrlsel[indexPath.row][0]
        if check == "pic"
        { var theText = "\(self.ctrlsel[indexPath.row][1]) uploaded a photo"
            label!.text = theText
            var url = NSURL(string: self.ctrlsel[indexPath.row][2])
            var data = NSData(contentsOfURL: url!)
            image!.image = UIImage(data: data!)
        }
        else if check == "friend" {
            var theText = "\(self.ctrlsel[indexPath.row][1]) followed \(self.ctrlsel[indexPath.row][2])"
            label!.text = theText
            var url = NSURL(string: self.ctrlsel[indexPath.row][4])
            var data = NSData(contentsOfURL: url!)
            image!.image = UIImage(data: data!)
        }
        return cell
    }
    
    func getMyFollows(username:String,userid:String)->[[String]]{
        var myFriend:[[String]]=[]
        let url = "https://api.instagram.com/v1/users/\(userid)/follows?access_token=1457552126.085bfe1.d38c9ac13cf14ca7a1bc3ce9b7bfa200"
        let requestURL = NSURL(string:url)
        let request = NSURLRequest(URL: requestURL!)
        var data = NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: nil)
        let json = JSON(data: data!)
        if json["data"].count>0 {
            for i in 0...(json["data"].count-1)
            {   var temp:[String] = []
                temp.append(json["data"][i]["username"].string!)
                temp.append(json["data"][i]["id"].string!)
                myFriend.append(temp)
                
            }
        }
        myFriend = sort(myFriend)
        return myFriend
        
    }

    
    func getFollows(username:String,userid:String) {
        var friend = [[String]]()
        friend = []
        let url = "https://api.instagram.com/v1/users/\(userid)/follows?access_token=1457552126.085bfe1.d38c9ac13cf14ca7a1bc3ce9b7bfa200"
        Alamofire.request(.GET,url).responseJSON{
            (_,_,data,error) in
            let json = JSON(data!)
            if json["data"].count>0 {
                for i in 0...(json["data"].count-1)
                {   var temp:[String] = []
                    temp.append("friend")
                    temp.append(username)
                    temp.append(json["data"][i]["username"].string!)
                    temp.append(json["data"][i]["id"].string!)
                    temp.append(json["data"][i]["profile_picture"].string!)
                    friend.append(temp)
                    
                } }
            self.ctrlsel = self.ctrlsel + friend
            self.tempctr = self.tempctr + friend
            self.tableView2.reloadData()
        }
    }
    
    func getUpload(userid:String){
        var upload = [[String]]()
        let url="https://api.instagram.com/v1/users/\(userid)/media/recent?access_token=1457552126.085bfe1.d38c9ac13cf14ca7a1bc3ce9b7bfa200"
        Alamofire.request(.GET,url).responseJSON{
            (_,_,data,error) in
            let json = JSON(data!)
            if json["data"].count>0
            {   for i in 0...(json["data"].count-1)
            {   var temp:[String] = []
                temp.append("pic")
                temp.append(json["data"][i]["user"]["username"].string!)
                temp.append(json["data"][i]["images"]["thumbnail"]["url"].string!)
                upload.append(temp)
                
                }
            }
            self.ctrlsel = self.ctrlsel + upload
            self.tempctr = self.tempctr + upload
            self.tableView2.reloadData()
        }
    }
    
    func getUserActivity() -> Void{
        self.follow = []
        self.follow = getMyFollows("qijie19920618",userid: "self")
        for i in 0...self.follow.count-1 {
            var id = self.follow[i][1]
            var friendname = self.follow[i][0]
            getUpload(id)
            getFollows(friendname,userid: id)
        }
        
    }
    
    func sort(target:[[String]])-> [[String]]{
        var checknum = 0
        var temp:[[String]] = []
        if target.count>0 {
            temp.append(target[0])
            for i in 1...target.count-1
            { for j in 0...temp.count-1
            {   checknum = j
                if target[i][0]<temp[j][0]
                {   temp.insert(target[i], atIndex: j)
                    break
                }
                }
                if checknum == temp.count-1
                {
                    temp.append(target[i])
                }
            }
        }
        
        return temp
    }
    
    // 搜索代理UISearchBarDelegate方法，每次改变搜索内容时都会调用
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            self.ctrlsel = self.tempctr
        }
        else {
            self.ctrlsel = []
            for ctrl in self.tempctr {
                if ctrl[1].lowercaseString.hasPrefix(searchText.lowercaseString) {
                    self.ctrlsel.append(ctrl)
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
