//
//  SearchUserController.swift
//  comp90018
//
//  Created by Yiming Chen on 10/10/2015.
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
    var id:[String] = []
    var searchSequence = 0
    //user's access_token
    var access_token = User.sharedInstance.token
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
        //in storyboard, image view is tagged with 102,label is tagged with 101
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
        //if search text is empty, show nothing at the first time,
        //next time if it is empty, show the last data
        if searchText == "" {
            self.dataOfTableView = []
            self.picOfTableView = []
        }
        else {
            //make request for search text and get result back from API
            getUserdata(self.access_token, searchtext: searchText,sequence: self.searchSequence)
        }
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var m = sender as? UITableViewCell
        var row = tableView.indexPathForCell(m!)
        if segue.identifier == "gotoprofile"
        {   var vc = segue.destinationViewController as? ProfileOthers
            var theid = self.id[row!.row]
            var id = theid
            vc!.getid = id
        }
    }

    
    //get the result of searching the target text from instagram API
    func getUserdata(token:String,searchtext:String,sequence:Int) -> Void{
        var tempText:[String] = []
        var tempId:[String] = []
        var tempPic:[String] = []
        let url = "https://api.instagram.com/v1/users/search?q=\(searchtext)&access_token=\(token)"
        //asychronous request to API and characters like space are allowed in UPL request
        Alamofire.request(.GET,url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!).responseJSON{
            (_,_,data,error) in
            let json = JSON(data!)
                if json["data"].count>0 {
                for i in 0...(json["data"].count-1) {
                    tempText.append(json["data"][i]["username"].string!)
                    tempId.append(json["data"][i]["id"].string!)
                    tempPic.append(json["data"][i]["profile_picture"].string!)
                }
            }
            self.dataOfTableView = tempText
            self.picOfTableView = tempPic
            self.id = tempId
            //only reload the data that is correspond with the current search text
            if  sequence == self.searchSequence {
                self.tableView.reloadData()
            }
        }
    }
}