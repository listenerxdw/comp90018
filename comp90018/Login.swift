//
//  Login.swift
//  comp90018
//
//  Created by Pramudita on 28/09/2015.
//  Copyright © 2015 Pramudita. All rights reserved.
//

/*
Login Page - is used in order for user to login, and after login, user information will be launched for a few seconds before proceed to main page.
*/


import UIKit
//information for Instagram API
let clientId = "085bfe1ee3c54cc886077ba51a5b8d7b"
let redirectUri = "http://backendlife.com"

class Login: UIViewController, UIWebViewDelegate {
    //UIvar and var declaration
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var ivProfPict: UIImageView!
    @IBOutlet weak var pvLoad: UIProgressView!
    var loading: NSTimer!
    var strReq: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //get the url
        let request = login(clientId,redirectUri: redirectUri)
        //manage the UI
        lblName.hidden = true
        ivProfPict.hidden = true
        webView.hidden = true
        webView.delegate = self
        webView.loadRequest(request)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        start()
        webView.hidden=true
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        let url = webView.request?.URL!.absoluteString
        let x = count(url!)
        let key: Character = "#"
        let ln = "#access_token=".length
        finish() //finish the loading timer
        if let idx = find(url!,key) { //if token can be obtained from url
            webView.hidden=true
            //acquire the token by doing substring
            let start: Int = distance(url!.startIndex,advance(idx,ln))
            let range = advance(url!.startIndex,start)..<url!.endIndex
            var token: String = url!
            token = token[range]
            //populate the singleton user instance with current user information
            let user = User.sharedInstance
            user.getProfile(token,nm: lblName,img: ivProfPict,tkn: token)
            //splash the user information for a few secs
            NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "goHome", userInfo: nil, repeats: false)
        }else{ //if its login/authorization page, show it.
            webView.hidden=false
        }
    }
    
    //go to main page
    func goHome(){
        self.performSegueWithIdentifier("goHome", sender: nil)
    }
    
    //update the loading bar
    func updateProgress() {
        pvLoad.progress += 0.02
    }
    
    //finish the loading bar
    func finish(){
        loading.invalidate()
        pvLoad.hidden=true
    }
    
    //start the loading bar
    func start(){
        pvLoad.progress = 0
        pvLoad.hidden = false
        loading = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "updateProgress", userInfo: nil, repeats: true)
    }
    
    //return login url
    func login(clientId: String, redirectUri: String) -> NSURLRequest {
        let url = "https://instagram.com/oauth/authorize/?client_id=\(clientId)&redirect_uri=\(redirectUri)&response_type=token&scope=basic+likes+comments+relationships"
        let requestURL = NSURL(string:url)
        let request = NSURLRequest(URL: requestURL!)
        return request
    }
}
