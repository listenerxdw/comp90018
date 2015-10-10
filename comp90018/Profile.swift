//
//  Profile.swift
//  comp90018
//
//  Created by Pramudita on 29/09/2015.
//  Copyright © 2015 Pramudita. All rights reserved.
// asdadsadsa

import UIKit
import SwiftyJSON

class Profile: UIViewController,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource{
    //UI var
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblPost: UILabel!
    @IBOutlet weak var lblBio: UILabel!
    @IBOutlet weak var lblFollowing: UILabel!
    @IBOutlet weak var lblFollower: UILabel!
    @IBOutlet weak var lblNoImage: UILabel!
    
    //global var
    var x = User.sharedInstance
    var gallery: UICollectionView!
    var ivProfPict: UIImageView!
    var json: JSON!
    var nextUrl: String = ""
    var total: Int = 0
    
    //logout button to clear cookies and exit from app
    @IBAction func cancelButton(sender: UIBarButtonItem) {
        var refreshAlert = UIAlertController(title: "Logout & Exit", message: "Do you really want to logout and exit?", preferredStyle: UIAlertControllerStyle.Alert)
        //if cancel do nothing
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
        }))
        
        //if okay
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!)
            in
            //clear cookies
            NSURLCache.sharedURLCache().removeAllCachedResponses()
            if let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies {
                for cookie in cookies {
                    NSHTTPCookieStorage.sharedHTTPCookieStorage().deleteCookie(cookie as! NSHTTPCookie)
                }
            }
            exit(0)
        }))
        presentViewController(refreshAlert, animated: true, completion: nil)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        refresh() //get user details and show it
        //Fetch Gallery
        let url = "https://api.instagram.com/v1/users/self/media/recent?access_token=\(x.token)&count=50"
        let requestURL = NSURL(string:url)
        let request = NSURLRequest(URL: requestURL!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
            self.json = JSON(data: data!)
            self.total = self.json["data"].count //get total photos
            self.nextUrl = self.json["pagination"]["next_url"].stringValue //next url of next gallery
            if(self.total>0){ //if there is at least one photo
                self.lblNoImage.hidden = true //remove the no image label
                //create layout for gallery
                let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
                layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
                layout.itemSize = CGSize(width: 110, height: 100)
                //create gallery and assign the datasource and delegate then add it to the view
                self.gallery = UICollectionView(frame: CGRectMake(0, 265, 375, 410), collectionViewLayout: layout)
                self.gallery!.dataSource = self
                self.gallery!.delegate = self
                self.gallery!.registerClass(CollectionViewCell.self, forCellWithReuseIdentifier: "CollectionViewCell")
                self.gallery!.backgroundColor = UIColor.whiteColor()
                self.view.addSubview(self.gallery!)
            }else{
                self.lblNoImage.hidden = false
            }
        }
        //End of fetching
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //function to populate the datils of user
    func refresh(){
        lblNoImage.hidden = true
        lblPost.text = String(x.post)
        lblFollowing.text = String(x.following)
        lblFollower.text = String(x.follower)
        lblBio.text = x.bio
        lblUsername.text = x.username
        let url = NSURL(string: x.profPict)
        let data = NSData(contentsOfURL: url!)
        ivProfPict = UIImageView(frame: CGRectMake(10, 70, 130, 120)); // set as you want
        ivProfPict.image = UIImage(data: data!)
        self.view.addSubview(ivProfPict);
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return total
    }
    
    //load an image of every cell
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // Configure the cell...
        let idx = indexPath.row
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionViewCell", forIndexPath: indexPath) as! CollectionViewCell
        let stringUrl = json["data",idx,"images","thumbnail","url"].stringValue
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
