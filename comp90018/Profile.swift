//
//  Profile.swift
//  comp90018
//
//  Created by Pramudita on 29/09/2015.
//  Copyright © 2015 Pramudita. All rights reserved.
//

import UIKit

@available(iOS 9.0, *)
class Profile: UIViewController {
    @IBOutlet weak var lblPost: UILabel!
    @IBOutlet weak var lblBio: UILabel!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblFollowing: UILabel!
    @IBOutlet weak var lblFollower: UILabel!
    @IBOutlet weak var ivProfPict: UIImageView!
    @IBOutlet weak var gallery: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refresh()

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
        ivProfPict.image = UIImage(data: data!)
    }

}
