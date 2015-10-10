//
//  SearchUserController.swift
//  comp90018
//
//  Created by 璐璐 on 10/10/2015.
//  Copyright (c) 2015 Pramudita. All rights reserved.
//

import UIKit
import SwiftyJSON
class SearchUserController: UIViewController,UISearchBarDelegate,
UITableViewDataSource,UITableViewDelegate{
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var ctrlsel:[String] = []
    var ctrls:[String] = []
    var finaltext:String = ""
    var picArray:[String] = []
    var picArray2:[String] = []
    var searchSequence = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ctrlsel = []
        self.picArray2 = []
        searchBar.delegate = self
        
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.ctrlsel.count}
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    { let cell = self.tableView.dequeueReusableCellWithIdentifier("todoCell") as! UITableViewCell
        
        var image = cell.viewWithTag(102) as? UIImageView
        var label = cell.viewWithTag(101) as? UILabel
        if self.ctrlsel.count>0 && self.picArray2.count>0 {
            var theText = self.ctrlsel[indexPath.row]
            label!.text = theText
            var url = NSURL(string: self.picArray2[indexPath.row])
            if self.picArray2[0] != "" {
                var data = NSData(contentsOfURL: url!)
                image!.image = UIImage(data: data!)}
        }
        return cell
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        searchBar.resignFirstResponder()
        
    }
    
    // 搜索代理UISearchBarDelegate方法，每次改变搜索内容时都会调用
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        self.searchSequence = self.searchSequence + 1
        println("input:\(searchText)")
        finaltext = searchText
        if finaltext == "" {
            self.ctrlsel = []
            self.picArray2 = []
        }
        else {
            getUserdata("1457552126.085bfe1.d38c9ac13cf14ca7a1bc3ce9b7bfa200", searchtext: finaltext,sequence: self.searchSequence)
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getUserdata(token:String,searchtext:String,sequence:Int) -> Void{
        var tempText:[String] = []
        var tempPic:[String] = []
        let url = "https://api.instagram.com/v1/users/search?q=\(searchtext)&access_token=\(token)"
        let requestURL = NSURL(string:url)
        let request = NSURLRequest(URL: requestURL!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue())
            {(response, data, error) in
                let json = JSON(data: data!)
                if json["data"].count>0
                {
                    for i in 0...(json["data"].count-1)
                    {
                        self.ctrls.append(json["data"][i]["username"].string!)
                        self.picArray.append(json["data"][i]["profile_picture"].string!)
                    }
                }
                for ctrl in self.ctrls {
                    tempText.append(ctrl)
                }
                for pic in self.picArray {
                    tempPic.append(pic)
                }
                self.ctrlsel = tempText
                self.picArray2 = tempPic
                self.ctrls = []
                self.picArray = []
                if  sequence == self.searchSequence
                {   self.tableView.reloadData()
                    println("searchtext: \(searchtext)")}
                
        }
    }
}