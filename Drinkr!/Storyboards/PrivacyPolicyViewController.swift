//
//  PrivacyPolicyViewController.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/6/16.
//

import UIKit
import WebKit

class PrivacyPolicyViewController: UIViewController, WKNavigationDelegate {

    var webView: WKWebView!
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: "https://www.privacypolicies.com/live/359b07a5-9ced-425e-8f83-6d697b0a0b58")!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }
}
