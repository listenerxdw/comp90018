//
//  User.swift
//  comp90018
//
//  Created by Pramudita on 28/09/2015.
//  Copyright © 2015 Pramudita. All rights reserved.
//

import UIKit
import SwiftyJSON

//This class is static, which means only 1 instance per user
// to get the user property just simply do : User.sharedInstance.<property_name> ex : User.sharedInstance.name ->for username
class User {
    //properties/attributes
    var profPict: String = ""
    var username: String = ""
    var fullname: String = ""
    var post: Int = 0
    var follower: Int = 0
    var following: Int = 0
    var bio: String = ""
    var id: String = ""
    var token: String = ""
    
    //an instance to make it static/singleton
    class var sharedInstance: User{
        struct Static{
            static let instance: User = User()
        }
        return Static.instance
    }
    
    //function to populate the user details
    func getProfile(token:String,nm:UILabel,img:UIImageView,tkn:String) -> Void {
        let url = "https://api.instagram.com/v1/users/self?access_token=\(token)"
        let requestURL = NSURL(string:url)
        let request = NSURLRequest(URL: requestURL!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
            let json = JSON(data: data!)
            self.username = json["data"]["username"].string!
            self.profPict = json["data"]["profile_picture"].string!
            self.fullname = json["data"]["full_name"].string!
            self.post = json["data"]["counts"]["media"].intValue
            self.follower = json["data"]["counts"]["followed_by"].intValue
            self.following = json["data"]["counts"]["follows"].intValue
            self.bio = json["data"]["bio"].string!
            self.id = json["data"]["id"].string!
            self.token = tkn
            //in order to quick show the name and profpict
            let url = NSURL(string: self.profPict)
            let data = NSData(contentsOfURL: url!)
            img.image = UIImage(data: data!)
            img.hidden = false
            nm.text = self.username
            nm.hidden = false
        }
    }

}