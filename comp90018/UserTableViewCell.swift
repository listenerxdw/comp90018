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
    
    @IBOutlet var postLabel:UILabel!
    @IBOutlet var likeLabel:UILabel!
    @IBOutlet var topicLabel:UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet var commentLabel:UILabel!
    @IBOutlet var userImageView:UIImageView!
    @IBOutlet weak var profileImage: UIImageView!

    @IBOutlet weak var toLike: UIButton!
    @IBOutlet weak var toComment: UIButton!
    
    
    var user: SwiftyJSON.JSON? {
        didSet {
            self.setupUser()
        }
    }
    
    
    func setupUser() {
        //if the data is swiping data
        if(self.user?["type"].string == "swipe"){
            let ppString = self.user?["profpict"]
            let pp = NSURL(string: ppString!.stringValue)
            profileImage.hnk_setImageFromURL(pp!)
            let imageString = self.user?["image"].string
            let decodedData = NSData(base64EncodedString: imageString!, options: NSDataBase64DecodingOptions(rawValue: 0))
            var decodedimage = UIImage(data: decodedData!)
            userImageView.image = decodedimage
            postLabel.text = self.user?["username"].string
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
        self.postLabel.text = self.user?["caption"]["from"]["username"].string
    
        var date = self.user?["created_time"].string
        var dateString = NSString(string: date!)
 
        self.timeLabel.text = NSDate(timeIntervalSince1970: dateString.doubleValue).description
        
        
        //Display the image
        if let urlString = self.user?["images"]["standard_resolution"]["url"]{
            let url = NSURL(string: urlString.stringValue)
            self.userImageView.hnk_setImageFromURL(url!)
        }
        
        //Display the profile image
        if let urlString = self.user?["caption"]["from"]["profile_picture"]{
            let url = NSURL(string: urlString.stringValue)
            self.profileImage.hnk_setImageFromURL(url!)
        }
        
        //Display the topic of the post
        self.topicLabel.text = self.user?["caption"]["text"].string

        
        //Display the first 3 people who like the post
        var numOfLike = (self.user?["likes"]["count"].int)!
        
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
                //            //////println(i)
                if let liker = self.user? ["likes"]["data"][i]["username"].string {
                    likers.append(liker)

                }
            }
            for j in 0...numOfLike - 2 {
//                ////println(j)
                self.likeLabel.text? += "\(likers[j]), "
            }
            self.likeLabel.text? += "\(likers[numOfLike - 1])"
            
        } else if numOfLike == 1 {
            for i in 0...numOfLike - 1 {
                //            //println(i)
                if let liker = self.user? ["likes"]["data"][i]["username"].string {
                    likers.append(liker)
                    
                }
            }
            self.likeLabel.text? += "\(likers[0])"

        }
    
        
        //Display the first 3 comments
        var numOfComment = (self.user?["comments"]["count"].int)!
        
        var comments: [String] = []
        var commentUsers: [String] = []
        
        self.commentLabel.text = ""
        
        if numOfComment >= 3 {
            for i in 0...2 {
                if let comment = self.user? ["comments"]["data"][i]["text"].string {
                    comments.append(comment)
                }
                if let commentUser = self.user? ["comments"]["data"][i]["from"]["username"].string {
                    commentUsers.append(commentUser)
                }
            }
            for j in 0...1 {
                self.commentLabel.text? += "\(commentUsers[j]): \(comments[j])\n"
            }
            self.commentLabel.text? += "\(commentUsers[2]): \(comments[2])"
        } else if numOfComment == 2 {
            for i in 0...numOfComment {
                //            //println(i)
                if let comment = self.user? ["comments"]["data"][i]["text"].string {
                    comments.append(comment)
                }
                if let commentUser = self.user? ["comments"]["data"][i]["from"]["username"].string {
                    commentUsers.append(commentUser)
                }
            }
            self.commentLabel.text? += "\(commentUsers[0]): \(comments[0])\n"
            self.commentLabel.text? += "\(commentUsers[1]): \(comments[1])\n"
        } else if numOfComment == 1 {
            for i in 0...numOfComment {
                //            //println(i)
                if let comment = self.user? ["comments"]["data"][i]["text"].string {
                    comments.append(comment)
                }
                if let commentUser = self.user? ["comments"]["data"][i]["from"]["username"].string {
                    commentUsers.append(commentUser)
                }
            }
            self.commentLabel.text? += "\(commentUsers[0]): \(comments[0])\n"
            
        }
        }
     
    }

}
