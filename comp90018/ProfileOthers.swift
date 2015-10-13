//
//  ProfileOthers.swift
//  comp90018
//
//  Created by Pramudita on 13/10/2015.
//  Copyright (c) 2015 Pramudita. All rights reserved.
//

import UIKit
import SwiftyJSON

class ProfileOthers: UIViewController,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource {
    //var
    @IBOutlet weak var lblPost: UILabel!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblBio: UILabel!
    @IBOutlet weak var lblFollower: UILabel!
    @IBOutlet weak var lblFollowing: UILabel!
    @IBOutlet weak var lblNoImage: UILabel!
    
    //global var
    var getid:String?
    var userid = ""
    var moreButton: UIBarButtonItem!
    var gallery: UICollectionView!
    var ivProfPict: UIImageView!
    var json: [JSON] = []
    var nextUrl: String = ""
    
    //back button
    func back(sender: UIBarButtonItem) {
        // Perform your custom actions
        // ...
        // Go back to the previous ViewController
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userid = getid!
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Bordered, target: self, action: "back:")
        self.navigationItem.leftBarButtonItem = newBackButton;
        
        self.navigationItem.hidesBackButton = true
        moreButton = UIBarButtonItem(title: "More..", style: UIBarButtonItemStyle.Bordered, target: self, action: "loadMore:")
        self.navigationItem.rightBarButtonItem = moreButton;
        
        //Fetch Gallery
        let url = "https://api.instagram.com/v1/users/\(userid)/media/recent?access_token=\(User.sharedInstance.token)&count=30"
        let requestURL = NSURL(string:url)
        let request = NSURLRequest(URL: requestURL!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
            let j = JSON(data: data!)
            self.json = j["data"].arrayValue as [JSON]
            //whether more should exist or not
            if let x = j["pagination"]["next_url"].string { //next url of next gallery
                self.nextUrl = x
                //show the button
                self.navigationItem.rightBarButtonItem = self.moreButton;
            }else{ //hide the button
                self.navigationItem.rightBarButtonItem = nil;
                
            }
            if(self.json.count>0){ //if there is at least one photo
                self.lblNoImage.hidden = true //remove the no image label
                //create layout for gallery
                let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
                layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
                layout.itemSize = CGSize(width: 110, height: 100)
                //create gallery and assign the datasource and delegate then add it to the view
                self.gallery = UICollectionView(frame: CGRectMake(0, 265, 375, 350), collectionViewLayout: layout)
                self.gallery!.dataSource = self
                self.gallery!.delegate = self
                self.gallery!.registerClass(CollectionViewCell.self, forCellWithReuseIdentifier: "CollectionViewCell")
                self.gallery!.backgroundColor = UIColor.whiteColor()
                self.view.addSubview(self.gallery!)
                
            }else{
                self.lblNoImage.hidden = false
            }
            self.refresh() //get user details and show it
        }
        //End of fetching
        
    }
    
    //function to loadmore images
    func loadMore(sender:UIButton!){
        let requestURL = NSURL(string:nextUrl)
        let request = NSURLRequest(URL: requestURL!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
            let j = JSON(data: data!)
            self.json += j["data"].arrayValue as [JSON]
            //whether more should exist or not
            if let x = j["pagination"]["next_url"].string { //next url of next gallery
                self.nextUrl = x
                //show the button
                self.navigationItem.rightBarButtonItem = self.moreButton;
            }else{ //hide the button
                self.navigationItem.rightBarButtonItem = nil;
                
            }
            self.gallery.reloadData()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //function to populate the datils of user
    func refresh(){
        lblNoImage.hidden = true
        let urlx = "https://api.instagram.com/v1/users/\(userid)?access_token=\(User.sharedInstance.token)"
        let requestURL = NSURL(string:urlx)
        let request = NSURLRequest(URL: requestURL!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
            let json = JSON(data: data!)
            self.lblUsername.text = json["data"]["username"].string!
            self.lblPost.text = String(json["data"]["counts"]["media"].intValue)
            self.lblFollower.text = String(json["data"]["counts"]["followed_by"].intValue)
            self.lblFollowing.text = String(json["data"]["counts"]["follows"].intValue)
            self.lblBio.text = json["data"]["bio"].string!
            let url = NSURL(string: json["data"]["profile_picture"].string!)
            let data = NSData(contentsOfURL: url!)
            self.ivProfPict = UIImageView(frame: CGRectMake(10, 70, 130, 120)); // set as you want
            self.ivProfPict.image = UIImage(data: data!)
            self.view.addSubview(self.ivProfPict);
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return json.count
    }
    
    //load an image of every cell
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // Configure the cell...
        let idx = indexPath.row
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionViewCell", forIndexPath: indexPath) as! CollectionViewCell
        let stringUrl = json[idx]["images","thumbnail","url"].stringValue
        //let url = NSURL(string: json["data",idx,"images","thumbnail","url"].stringValue)
        //let data = NSData(contentsOfURL: url!)
        // cell.imageView?.image =  UIImage(data: data!)
        cell.backgroundColor = UIColor.whiteColor()
        loadImageAsync(stringUrl, imageView: cell.imageView!)
        return cell
    }
    
    //function to load image asynchronously
    func loadImageAsync(stringURL: String, imageView: UIImageView, placeholder: UIImage! = nil) {
        imageView.image = placeholder
        
        let url = NSURL(string: stringURL as String)
        let requestedURL = NSURLRequest(URL: url!)
        
        NSURLConnection.sendAsynchronousRequest(requestedURL, queue: NSOperationQueue.mainQueue()) {
            response, data, error in
            
            if data != nil {
                imageView.image = UIImage(data: data)
            }
        }
    }
}
