//
//  Login.swift
//  comp90018
//
//  Created by Pramudita on 28/09/2015.
//  Copyright © 2015 Pramudita. All rights reserved.
//

import UIKit
import Alamofire

let clientId = "085bfe1ee3c54cc886077ba51a5b8d7b"
let access_token = "2208426948.085bfe1.fb1f04160fd64355a77faecb23a2fc68"
let redirectUri = "http://backendlife.com"
class Login: UIViewController {
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var ivProfPict: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //libraries
        let lib = Libraries()
        let user = Libraries.User(libraries:lib)
        
        //check token
        let request = lib.login(clientId,redirectUri: redirectUri)
        webView.loadRequest(request)
        
        //getUser and the details
        user.getProfile(access_token)
        lblName.text = user.name
        let url = NSURL(string: user.profPict)
        let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
        ivProfPict.image = UIImage(data: data!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    


}
