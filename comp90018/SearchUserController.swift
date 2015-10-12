//
//  SearchUserController.swift
//  comp90018
//
//  Created by 璐璐 on 10/10/2015.
//  Copyright (c) 2015 Pramudita. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import Haneke

class SearchUserController: UIViewController,UISearchBarDelegate,
UITableViewDataSource,UITableViewDelegate{
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    //show username in table view
    var dataOfTableView:[String] = []
    //show profile picture in table view
    var picOfTableView:[String] = []
    //record number of times that search text changed
    var searchSequence = 0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.dataOfTableView = []
        self.picOfTableView = []
        searchBar.delegate = self
    }
    
    //return number of rows for tableview
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataOfTableView.count
    }
    
    //show data in tableview
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //reuse cell
        let cell = self.tableView.dequeueReusableCellWithIdentifier("todoCell") as! UITableViewCell
        var image = cell.viewWithTag(102) as? UIImageView
        var label = cell.viewWithTag(101) as? UILabel
        
        if self.dataOfTableView.count>0 && self.picOfTableView.count>0 {
            var theText = self.dataOfTableView[indexPath.row]
            label!.text = theText
            var url = NSURL(string: self.picOfTableView[indexPath.row])
            if self.picOfTableView[0] != "" {
                 image!.hnk_setImageFromURL(url!)
            }
        }
        return cell
    }
    
    //click search then keyboard will disappear
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        searchBar.resignFirstResponder()
    }
    
    //this function will be called for each time the searchtext changes
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        //record the number of changes of search text
        self.searchSequence = self.searchSequence + 1
        println("input:\(searchText)")
        //if search text is empty, show nothing at the first time,
        //next time if it is empty, show the last data
        if searchText == "" {
            self.dataOfTableView = []
            self.picOfTableView = []
        }
        else {
            var access_token = User.sharedInstance.token
            getUserdata(access_token, searchtext: searchText,sequence: self.searchSequence)
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //get the result of searching the target text from instagram API
    func getUserdata(token:String,searchtext:String,sequence:Int) -> Void{
        var tempText:[String] = []
        var tempPic:[String] = []
        let url = "https://api.instagram.com/v1/users/search?q=\(searchtext)&access_token=\(token)"
        //use asychronous request
        Alamofire.request(.GET,url).responseJSON{
            (_,_,data,error) in
            let json = JSON(data!)
            if json["data"].count>0 {
                for i in 0...(json["data"].count-1) {
                    tempText.append(json["data"][i]["username"].string!)
                    tempPic.append(json["data"][i]["profile_picture"].string!)
                }
            }
            self.dataOfTableView = tempText
            self.picOfTableView = tempPic
            //only reload the data that is correspond with the current search text
            if  sequence == self.searchSequence {
                self.tableView.reloadData()
                println("searchtext: \(searchtext)")
            }
            
        }
    }
}