//
//  User.swift
//  comp90018
//
//  Created by Pramudita on 28/09/2015.
//  Copyright © 2015 Pramudita. All rights reserved.
//

import Foundation
import SwiftyJSON

class User{
    
    var profPict: String = ""
    var name : String = ""
    
    func getProfile(token:String,nm:UILabel,img:UIImageView) -> Void {
        let url = "https://api.instagram.com/v1/users/self?access_token=\(token)"
        let requestURL = NSURL(string:url)
        let request = NSURLRequest(URL: requestURL!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
            //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            /*//print json format
            for (key,subJson):(String, JSON) in json {
            print(key)
            print(subJson)
            }*/
            let json = JSON(data: data!)
            self.name = json["data"]["username"].string!
            self.profPict = json["data"]["profile_picture"].string!
            
            let url = NSURL(string: self.profPict)
            let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
            img.image = UIImage(data: data!)
            nm.text = self.name
        }
    }
}

