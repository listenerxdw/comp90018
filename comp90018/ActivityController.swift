//
//  ActivityController.swift
//  comp90018
//
//  Created by 璐璐 on 10/10/2015.
//  Copyright (c) 2015 Pramudita. All rights reserved.
//

import UIKit

class ActivityController:  UIViewController {
    
    var ctrlsel:[String] = []
    var ctrls:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //called when click friends activity button
        if segue.identifier == "gotofriend"
        {   var m = sender as? UITableViewCell
            var vc = segue.destinationViewController as? UserController
            vc!.getUserActivity()
            
        }
        //called when click me activity button
        if segue.identifier == "gotome"{
            var m = sender as? UITableViewCell
            var vc = segue.destinationViewController as? MeController
            var access_token = User.sharedInstance.token
            vc!.getMeLike(access_token)
            vc!.getFollowedBy(access_token)
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

