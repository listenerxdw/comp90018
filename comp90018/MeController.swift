//
//  MeController.swift
//  comp90018
//
//  Created by 璐璐 on 10/10/2015.
//  Copyright (c) 2015 Pramudita. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
class MeController:  UIViewController,UITableViewDataSource,UITableViewDelegate  {
    
    @IBOutlet weak var tableView: UITableView!
    var ctrlsel:[[String]] = []
    var ctrls:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {return self.ctrlsel.count}
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {   let cell = self.tableView.dequeueReusableCellWithIdentifier("cell") as! UITableViewCell
        var label = cell.viewWithTag(100) as? UILabel
        var image = cell.viewWithTag(10) as? UIImageView
        var theText = self.ctrlsel[indexPath.row][0]
        label!.text = theText
        var url = NSURL(string: self.ctrlsel[indexPath.row][1])
        var data = NSData(contentsOfURL: url!)
        image!.image = UIImage(data: data!)
        //self.ctrlsel = []
        
        return cell
    }
    
    func getMeLike(token:String){
        self.ctrlsel = []
        let url="https://api.instagram.com/v1/users/self/media/liked?access_token=\(token)"
        Alamofire.request(.GET,url).responseJSON{
            (_,_,data,error) in
            let json = JSON(data!)
            if json["data"].count>0 {
            for i in 0...(json["data"].count-1)
            {   var name = json["data"][i]["user"]["username"].string!
                var picture = json["data"][i]["images"]["thumbnail"]["url"].string!
                self.ctrls.append("I liked \(name)'photo")
                self.ctrls.append(picture)
                self.ctrlsel.append(self.ctrls)
                self.ctrls = []
                
            }
            self.tableView.reloadData()
            }
        }
    }
    
    func getFollowedBy(token:String){
        let url = "https://api.instagram.com/v1/users/self/followed-by?access_token=\(token)"
        Alamofire.request(.GET,url).responseJSON{
            (_,_,data,error) in
            let json = JSON(data!)
            if json["data"].count>0 {
            for i in 0...(json["data"].count-1)
            {   var name = json["data"][i]["username"].string!
                var picture = json["data"][i]["profile_picture"].string!
                self.ctrls.append("\(name) followed me")
                self.ctrls.append(picture)
                self.ctrlsel.append(self.ctrls)
                self.ctrls = []
            }
            
            self.tableView.reloadData()
            }
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}

