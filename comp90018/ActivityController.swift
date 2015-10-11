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
        if segue.identifier == "gotofriend"
        {   var m = sender as? UITableViewCell
            var vc = segue.destinationViewController as? UserController
            vc!.getUserActivity()
            
        }
        if segue.identifier == "gotome"{
            var m = sender as? UITableViewCell
            var vc = segue.destinationViewController as? MeController
            vc!.getMeLike("1457552126.085bfe1.d38c9ac13cf14ca7a1bc3ce9b7bfa200")
            vc!.getFollowedBy("1457552126.085bfe1.d38c9ac13cf14ca7a1bc3ce9b7bfa200")
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

