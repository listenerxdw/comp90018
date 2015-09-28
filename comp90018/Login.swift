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
let token = "2208426948.085bfe1.fb1f04160fd64355a77faecb23a2fc68"
let redirectUri = "http://backendlife.com"

class Login: UIViewController {
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var lblTest: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let lib = Libraries()
        //lblTest.text = "1"
        let request = lib.login(clientId,redirectUri: redirectUri)
        webView.loadRequest(request)
        /*Alamofire.request(.GET, "https://api.instagram.com/oauth/authorize/?client_id=CLIENT-ID&redirect_uri=REDIRECT-URI&response_type=code", parameters: ["foo": "bar"])
        .response { request, response, data, error in
        print(response)
        }*/
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    


}
