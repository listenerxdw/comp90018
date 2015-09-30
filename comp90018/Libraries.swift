//
//  Libraries.swift
//  comp90018
//
//  Created by Pramudita on 28/09/2015.
//  Copyright © 2015 Pramudita. All rights reserved.
//

import Foundation
import SwiftyJSON

class Libraries{
    func login(clientId: String, redirectUri: String) -> NSURLRequest {
        let url = "https://instagram.com/oauth/authorize/?client_id=\(clientId)&redirect_uri=\(redirectUri)&response_type=token&scope=basic+likes+comments+relationships"
        let requestURL = NSURL(string:url)
        let request = NSURLRequest(URL: requestURL!)
        return request
    }
    
    func fetchGallery(token: String, count:Int) -> Void {
        let url = "https://api.instagram.com/v1/users/self/media/recent?access_token=\(token)&count=\(count)"
        let requestURL = NSURL(string:url)
        let request = NSURLRequest(URL: requestURL!)
        var json: JSON!
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
            json = JSON(data: data!)
            println(json["pagination"]["next_url"])
            for (key,subJson):(String, JSON) in json["data"] {
                println(subJson["images","thumbnail","url"].rawString())
            }
        }
        //return json
    }
}