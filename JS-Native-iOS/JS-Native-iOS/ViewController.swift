//
//  ViewController.swift
//  JS-Native-iOS
//
//  Created by liuruilong on 2023/3/8.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler, WKScriptMessageHandlerWithReply {

    @IBOutlet weak var buttonView: UIView!
    
    var webView: WKWebView? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let path = Bundle.main.path(forResource: "TestJS-Native", ofType: "html") else {
            return
        }
        
        let webViewConfig = WKWebViewConfiguration()
        webViewConfig.userContentController.addScriptMessageHandler(self, contentWorld: WKContentWorld.page, name: "MessageHandlerWithReply")
        webViewConfig.userContentController.add(self, name: "MessageHandler")
        
        // 在 document 特定生命周期注入 JS
//        let userScript = WKUserScript(source: "methodFromNAForInjectAtDocumentEnd('document end')", injectionTime: .atDocumentEnd, forMainFrameOnly: true)
//        webViewConfig.userContentController.addUserScript(userScript)
        
        let webView = WKWebView(frame: CGRectMake(0, buttonView.bounds.size.height, self.view.bounds.width, self.view.bounds.height - buttonView.bounds.size.height), configuration: webViewConfig)
        
        webView.load(URLRequest(url: URL(filePath: path)))
        webView.navigationDelegate = self
        webView.uiDelegate = self
        view.addSubview(webView)
        self.webView = webView

    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
//        if let url = navigationAction.request.url, url.absoluteString.hasPrefix("myapp:") {
//            if let host = navigationAction.request.url?.host as? NSString {
//                let getTime = host.doubleValue
//                let currentTime = Date.now.timeIntervalSince1970 * 1000
//                print(" url router duration：\(currentTime - getTime)")
//            }
//            Thread.sleep(forTimeInterval: 3)
//            decisionHandler(.cancel)
//            return
//        }
     
        decisionHandler(.allow)
    }
    
    /*
     1. 回调线程：主线程
     2. 执行耗时会阻塞 JS
     */
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        print("recieve promt ")
        if let getTimeStr = defaultText as? NSString {
            let getTime = getTimeStr.doubleValue
            let currentTime = Date.now.timeIntervalSince1970 * 1000
            print(" js prompt duration：\(currentTime - getTime)")
        }
        Thread.sleep(forTimeInterval: 3)
        completionHandler(" promt OK ")
        
    }
    
    /*
     1. 回调线程：主线程
     2. OC 执行耗时会阻塞 JS
     */
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let messageBody = message.body as? NSString {
            let getTime = messageBody.doubleValue
            let currentTime = Date.now.timeIntervalSince1970 * 1000
            print(" user Content duration：\(currentTime - getTime)")
            Thread.sleep(forTimeInterval: 3)
        }
    }
    
    /*
     1. 回调线程：主线程
     2. OC 执行耗时会阻塞 JS
     */
//    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage, replyHandler: @escaping (Any?, String?) -> Void) {
//        guard let messageBody = message.body as? NSString else {
//            return
//        }
//        let getTime = messageBody.doubleValue
//        let currentTime = Date.now.timeIntervalSince1970 * 1000
//        print(" message Hanlder with call back duration：\(currentTime - getTime)")
//        Thread.sleep(forTimeInterval: 3)
//        replyHandler(String(currentTime), nil)
//    }
    
    
    /*
     1. 回调线程：主线程
     2. 线程级别的阻塞会阻塞住 JS，协程级别阻塞不会阻塞住 JS
     */
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) async -> (Any?, String?) {
        guard let messageBody = message.body as? NSString else {
            return (false, " error ! ")
        }
        let getTime = messageBody.doubleValue
        let currentTime = Date.now.timeIntervalSince1970 * 1000
        print(" message Hanlder with call back duration：\(currentTime - getTime)")
//        try! await Task.sleep(for: .seconds(3))
        return (String(currentTime), nil)
    }
    
    @IBAction func injectAct(_ sender: Any) {
        // JS 不阻塞 Native 线程
        self.webView?.evaluateJavaScript("methodFromNAForInject(' evaluate JavaScript')") { res, err in
            if let resStr = res as? String {
                print("javascript result : " + resStr)
            }
        }
        print(" after evaluate JavaScript ")
    }
    
}

