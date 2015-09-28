//
//  Libraries.swift
//  comp90018
//
//  Created by Pramudita on 28/09/2015.
//  Copyright © 2015 Pramudita. All rights reserved.
//

import Foundation
import Alamofire

class Libraries{
    
    class User{
        init(libraries: Libraries) {
        }
        var profPict: String = "https://scontent.cdninstagram.com/hphotos-xaf1/t51.2885-19/s150x150/11899719_833796180053093_1251280192_a.jpg";
        var name : String = "Supri";
        
        func getProfile(token:String) -> Void {
            let url = "https://api.instagram.com/v1/users/self"
            Alamofire.request(.GET, url, parameters: ["access_token": "\(token)"])
            .response { request, response, data, error in
                print(response)
                
                /*DataManager.getTopAppsDataFromFileWithSuccess { (data) -> Void in
                    // Get #1 app name using SwiftyJSON
                    let json = JSON(data: data)
                    if let appName = json["feed"]["entry"][0]["im:name"]["label"].string {
                        println("SwiftyJSON: \(appName)")
                    }
                }*/
            }
        }
    }
    
    func login(clientId: String, redirectUri: String) -> NSURLRequest {
        let url = "https://instagram.com/oauth/authorize/?client_id=\(clientId)&redirect_uri=\(redirectUri)&response_type=token"
        let requestURL = NSURL(string:url)
        let request = NSURLRequest(URL: requestURL!)
        return request
    }
    
}