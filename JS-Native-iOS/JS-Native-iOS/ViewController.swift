//
//  ViewController.swift
//  JS-Native-iOS
//
//  Created by liuruilong on 2023/3/8.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate{

    @IBOutlet weak var webView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let path = Bundle.main.path(forResource: "TestJS-Native", ofType: "html") else {
            return
        }
        
        webView.load(URLRequest(url: URL(filePath: path)))
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        
        
        
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, url.absoluteString.hasPrefix("myapp:") {
//            Thread.sleep(forTimeInterval: 1000)
            decisionHandler(.cancel)
            return
        }
        
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        print("recieve promt ")
        
        completionHandler(" promt OK ")
        
    }
    
    
    @IBAction func injectAct(_ sender: Any) {
    }
    
}

