//
//  UserTableViewCell.swift
//  comp90018
//
//  Created by GaoMingyu on 8/10/2015.
//  Copyright (c) 2015 Pramudita. All rights reserved.
//

import UIKit
import SwiftyJSON
import Haneke

class UserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postLabel:UILabel!
    @IBOutlet weak var likeLabel:UILabel!
    @IBOutlet weak var topicLabel:UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var commentLabel:UILabel!
    @IBOutlet weak var userImageView:UIImageView!
    @IBOutlet weak var profileImage: UIImageView!

    @IBOutlet weak var toLike: UIButton!
    @IBOutlet weak var toComment: UIButton!
    
    
    var user: SwiftyJSON.JSON? {
        didSet {
            self.setupUser()
        }
    }
    
    //Prepare the contents of every cells
    func setupUser() {
        //if the data is swiping data
        if(self.user?["type"].string == "swipe"){
            //get the profpict
            let ppString = self.user?["profpict"]
            let pp = NSURL(string: ppString!.stringValue)
            profileImage.hnk_setImageFromURL(pp!)
            //get the imageString and decode it into NSData
            let imageString = self.user?["image"].string
            let decodedData = NSData(base64EncodedString: imageString!, options: NSDataBase64DecodingOptions(rawValue: 0))
            var decodedimage = UIImage(data: decodedData!)
            userImageView.image = decodedimage
            //get the username
            postLabel.text = self.user?["username"].string
            //disable unused view
            likeLabel.hidden=true
            topicLabel.hidden=true
            timeLabel.hidden=true
            commentLabel.hidden=true
            toLike.hidden=true
            toComment.hidden=true
        }
        //the data is from instagram api
        else{
            //Display the User Name
            self.postLabel.text = self.user?["user"]["username"].string
            
            //Display the time
            var date = self.user?["created_time"].string
            var dateString = NSString(string: date!)
            self.timeLabel.text = (NSDate(timeIntervalSince1970: dateString.doubleValue).description as NSString).substringToIndex(19)
            
            //Display the location
            self.locationLabel.text = ""
            if let location = self.user?["location"]["name"].string {
                self.locationLabel.text = location
            }
            
            //Display the image
            if let urlString = self.user?["images"]["standard_resolution"]["url"]{
                let url = NSURL(string: urlString.stringValue)
                self.userImageView.hnk_setImageFromURL(url!)
            }
            
            //Display the profile image
            if let urlString = self.user?["user"]["profile_picture"]{
                let url = NSURL(string: urlString.stringValue)
                self.profileImage.hnk_setImageFromURL(url!)
            }
            
            //Display the topic of the post
            self.topicLabel.text = ""
            if let topic = self.user?["caption"]["text"].string {
                self.topicLabel.text = topic
            }
            
            //Display the most recent people who like the post
            var numOfLike = (self.user?["likes"]["data"].count)!
            var likers: [String] = []
            
            self.likeLabel.text = ""
            
            if numOfLike >= 4 {
                for i in 0...3 {
                    if let liker = self.user? ["likes"]["data"][i]["username"].string {
                        likers.append(liker)
                    }
                }
                for j in 0...2 {
                    self.likeLabel.text? += "\(likers[j]), "
                }
                self.likeLabel.text? += "\(likers[3])"
            } else if numOfLike >= 2 && numOfLike <= 3 {
                for i in 0...numOfLike - 1 {
                    if let liker = self.user? ["likes"]["data"][i]["username"].string {
                        likers.append(liker)
                    }
                }
                for j in 0...numOfLike - 2 {
                    self.likeLabel.text? += "\(likers[j]), "
                }
                self.likeLabel.text? += "\(likers[numOfLike - 1])"
                
            } else if numOfLike == 1 {
                for i in 0...numOfLike - 1 {
                    if let liker = self.user? ["likes"]["data"][i]["username"].string {
                        likers.append(liker)
                    }
                }
                self.likeLabel.text? += "\(likers[0])"
            }
            
            //Display the first 3 comments
            var numOfComment = (self.user?["comments"]["data"].count)!
            self.commentLabel.text = ""
            
            if numOfComment >= 1 && numOfComment <= 3 {
                self.getComments(numOfComment)
                self.showConmments(numOfComment)
            } else if numOfComment > 3 {
                self.getComments(3)
                self.showConmments(3)
            }
        }
    }
    
    var comments: [String] = []
    var commentUsers: [String] = []
    
    //To get comments from API with this function
    func getComments(numOfComment: Int) {
        comments = []
        commentUsers = []
        
        for i in 0...numOfComment - 1 {
            //            println(i)
            if let comment = self.user? ["comments"]["data"][i]["text"].string {
                comments.append(comment)
            }
            if let commentUser = self.user? ["comments"]["data"][i]["from"]["username"].string {
                commentUsers.append(commentUser)
            }
        }
    }
    
    //To show the comments on the screen with this function
    func showConmments(numOfComment: Int) {
        for i in 0...numOfComment - 1 {
            self.commentLabel.text? += "\(commentUsers[numOfComment - 1 - i]): \(comments[numOfComment - 1 - i])\n"
        }
    }
}

