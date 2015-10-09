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
}