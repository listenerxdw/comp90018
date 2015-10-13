//
//  DiscoveryController.swift
//  comp90018
//
//  Created by 璐璐 on 11/10/2015.
//  Copyright (c) 2015 Pramudita. All rights reserved.
//

import UIKit

class DiscoveryController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var access_token = User.sharedInstance.token
        //click suggest button then functions getMyFollows and getLikedUser are called
        //to get data from API
        if segue.identifier == "gotoSuggestion"
        {   var vc = segue.destinationViewController as? SuggestionController
            vc!.getMyFollows(access_token)
            vc!.getLikedUser()
        }
        
    }
    
}
