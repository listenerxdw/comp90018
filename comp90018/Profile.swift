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
    
    @IBOutlet weak var ivTest: UIImageView!
    
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblPost: UILabel!
    @IBOutlet weak var lblBio: UILabel!
    @IBOutlet weak var lblFollowing: UILabel!
    @IBOutlet weak var lblFollower: UILabel!
    @IBOutlet var gallery: UICollectionView?
    
    var ivProfPict: UIImageView!
    var lib: Libraries!
    var json: JSON!
    var total: Int = 9
    override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
        lib=Libraries()
        //json=
        lib.fetchGallery(User.sharedInstance.token,count:total)
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        layout.itemSize = CGSize(width: 110, height: 100)
        gallery = UICollectionView(frame: CGRectMake(0, 201, 375, 410), collectionViewLayout: layout)
        gallery!.dataSource = self
        gallery!.delegate = self
        gallery!.registerClass(CollectionViewCell.self, forCellWithReuseIdentifier: "CollectionViewCell")
        gallery!.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(gallery!)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh(){
        let x = User.sharedInstance
        lblPost.text = String(x.post)
        lblFollowing.text = String(x.following)
        lblFollower.text = String(x.follower)
        lblBio.text = x.bio
        lblUsername.text = x.username
        let url = NSURL(string: x.profPict)
        let data = NSData(contentsOfURL: url!)
        ivProfPict = UIImageView(frame: CGRectMake(10, 30, 130, 100)); // set as you want
        ivProfPict.image = UIImage(data: data!)
        self.view.addSubview(ivProfPict);
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return total
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let idx = indexPath.indexAtPosition(1)
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionViewCell", forIndexPath: indexPath) as! CollectionViewCell
        let x = User.sharedInstance
        let url = NSURL(string: x.profPict)//json[idx,"images","thumbnail","url"].stringValue)
        let data = NSData(contentsOfURL: url!)
        cell.backgroundColor = UIColor.whiteColor()
        cell.imageView?.image = UIImage(data: data!)
        return cell
    }
}
