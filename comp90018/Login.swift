//
//  Login.swift
//  comp90018
//
//  Created by Pramudita on 28/09/2015.
//  Copyright © 2015 Pramudita. All rights reserved.
// ABC

import UIKit

let clientId = "085bfe1ee3c54cc886077ba51a5b8d7b"
let redirectUri = "http://backendlife.com"
class Login: UIViewController, UIWebViewDelegate {
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var ivProfPict: UIImageView!
    @IBOutlet weak var pvLoad: UIProgressView!
    var lib: Libraries!
    var loading: NSTimer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //libraries
        let lib = Libraries()
        let request = lib.login(clientId,redirectUri: redirectUri)
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
        let url = webView.request?.URL!.absoluteString
        if url!.lowercaseString.rangeOfString("backendlife") != nil{
            webView.hidden = true
        }else{
            webView.hidden = false
        }
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        let url = webView.request?.URL!.absoluteString
        let x = count(url!)
        //println(url)
        let key: Character = "#"
        let ln = "#access_token=".length
        finish()
        if let idx = find(url!,key) { //if token can be obtained
            let start: Int = distance(url!.startIndex,advance(idx,ln))
            let range = advance(url!.startIndex,start)..<url!.endIndex
            var token: String = url!
            token = token[range]
            //print(token)
            //getUser and the details
            webView.hidden=true
            let user = User.sharedInstance
            user.getProfile(token,nm: lblName,img: ivProfPict,tkn: token)
            NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "goHome", userInfo: nil, repeats: false)
        }else{
            webView.hidden = false
        }
    }
    
    func goHome(){
        self.performSegueWithIdentifier("goHome", sender: nil)
    }
    
    func updateProgress() {
        pvLoad.progress += 0.02
    }
    
    func finish(){
        loading.invalidate()
        pvLoad.hidden=true
    }
    
    func start(){
        pvLoad.progress = 0
        pvLoad.hidden = false
        loading = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "updateProgress", userInfo: nil, repeats: true)
    }
}
