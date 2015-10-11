//
//  UserFeed.swift
//  comp90018
//
//  Created by Pramudita on 9/10/2015.
//  Copyright (c) 2015 Pramudita. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class UserFeed: UIViewController, PhotoChooseViewControllerDelegate{

    @IBOutlet var lblTest: UILabel!
    @IBOutlet weak var ivTest: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //get the destination view controller to connect the delegate so it can communicate
        var destinationViewController = ((tabBarController!.viewControllers)![2] as! UINavigationController).topViewController as! PhotoChooseViewController
        destinationViewController.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //function to be triggered outside by Photo
    
    func update(data:NSData,name:String){
        //convert back to NSDictionary
        let dictionary:NSDictionary = NSKeyedUnarchiver.unarchiveObjectWithData(data)! as! NSDictionary
        //update the news feed
        let img = UIImage(data: dictionary.objectForKey("image") as! NSData)
        let username = dictionary.objectForKey("username") as! String
        self.ivTest.image = img
        self.lblTest.text = username
    }
    
    func del(name:String){
        //delete all images from this user
    }
}
