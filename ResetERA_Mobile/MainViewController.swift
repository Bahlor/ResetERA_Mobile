//
//  ViewController.swift
//  ResetERA_Mobile
//
//  Created by Christian Weber on 26.10.17.
//  Copyright © 2017 CW-Internetdienste. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController,WKNavigationDelegate {
    
    @IBOutlet weak var web: WKWebView!
    @IBOutlet weak var navbar: UINavigationBar!
    
    @IBOutlet weak var MenuButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var progressBar: UIProgressView!
    
    var isInjected  :   Bool    =   false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.updateNavigationBar()
        
        self.setupWebView()
        self.loadResetERA()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(stylesManager.forceReload == true) {
            stylesManager.forceReload   =   false
            stylesManager.cachedCSS     =   ""
            self.web.reload()
        }
    }

    
    func updateNavigationBar() -> Void {
        
        
        if let image   :   UIImage     =   UIImage(named: "Logo") {
            let imageView   :   UIImageView =   UIImageView(image: image)
            imageView.isUserInteractionEnabled  =   true
            let tapGesture  :   UITapGestureRecognizer  =   UITapGestureRecognizer(target: self, action: #selector(ViewController.goToRoot))
            tapGesture.numberOfTapsRequired     =   1
            tapGesture.numberOfTouchesRequired  =   1
            
            imageView.addGestureRecognizer(tapGesture)
            
            self.navigationItem.titleView   =   imageView
        } else {
            self.navigationItem.title   =   APP_TITLE
        }
        
        let rightBarButton  :   UIBarButtonItem =   UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(ViewController.refreshPage))
        rightBarButton.tintColor    =   PURPLE_COLOR
        let leftBarButton   :   UIBarButtonItem =   UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(ViewController.showSettings))
        leftBarButton.tintColor     =   PURPLE_COLOR
        
        self.navigationItem.leftBarButtonItem   =   leftBarButton
        self.navigationItem.rightBarButtonItem  =   rightBarButton
    }

    
    func setupWebView() -> Void {
        self.web.allowsBackForwardNavigationGestures                =   true
        self.web.configuration.allowsAirPlayForMediaPlayback        =   true
        self.web.configuration.allowsInlineMediaPlayback            =   true
        self.web.configuration.allowsPictureInPictureMediaPlayback  =   true
        self.web.configuration.preferences.javaScriptEnabled        =   true
        self.web.configuration.preferences.setValue("true", forKey: "allowFileAccessFromFileURLs")
        self.web.configuration.applicationNameForUserAgent          =   "ResetEraMobile"
        self.web.configuration.userContentController                =   self.getUserContentController()
        self.web.configuration.websiteDataStore                     =   self.getDataStorage()

        self.web.navigationDelegate                                 =   self
        self.web.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
        self.web.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let k : String = keyPath {
            if(k == "loading") {
                if let c : [NSKeyValueChangeKey : Any] = change {
                    
                    self.progressBar.isHidden   =   !(c[NSKeyValueChangeKey.newKey] as! Bool)
                }
            }
            
            // we now inject in multiple times, mobile phones seem
            // to be fast enough to do this without a problem and
            // it prevents unwanted flickering of the screen
            // as css is not overwritten early enough in
            // webkit didfinishnavigation
            if(k == "estimatedProgress") {
                if let c : [NSKeyValueChangeKey : Any] = change {
                    self.progressBar.progress   =   c[NSKeyValueChangeKey.newKey] as! Float
                    if((c[NSKeyValueChangeKey.newKey] as! Float) >= 0.2) {
                        self.injectMobileCSS(into: self.web)
                    }
                }
            }
        }
    }
    
    func getUserContentController() -> WKUserContentController {
        let userContentController : WKUserContentController =   WKUserContentController()
        
        return userContentController
    }
    
    func getDataStorage() -> WKWebsiteDataStore {
        let dataStore   :   WKWebsiteDataStore  =   WKWebsiteDataStore.default()
        
        return dataStore
    }
    
    func loadResetERA() -> Void {
        if let url     :   URL     =   URL(string: WEBSITE_PATH) {
            self.web.load(URLRequest(url: url))
        }
    }
    
    func getMobileStylesheet() -> String {
        return stylesManager.getCSS()
    }
    
    func injectMobileCSS(into webView : WKWebView) -> Void {
        if(self.isInjected == true) {
            return
        }
        do {
            self.web.evaluateJavaScript(self.getMobileStylesheet()) { (data : Any?, error : Any?) in
                self.isInjected =   true
                print("We have some data: \(data) and possible error: \(error)")
            }
        } catch {
            print("it's dead jim");
        }
        
    }
    
    // MARK: - BarButtonItems
    @objc func showSettings() -> Void {
        guard let _vc : ERAStylesViewController = ERAStylesViewController(nibName: "ERAStylesViewController", bundle: nil) else {
            return
        }
        
        self.navigationController?.pushViewController(_vc, animated: true)
    }
    
    @objc func refreshPage() -> Void {
        self.web.reload()
    }
    
    @objc func goToRoot() -> Void {
        self.loadResetERA()
    }
    

    // MARK: - WKNavigationDelegate
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //self.injectMobileCSS(into: self.web)
    }
    
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // no more css injection in here... it's too late
        // as the background flickers white for a short amount of time
        self.isInjected =   false
    }
    
    
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        self.isInjected =   false
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        
    }

    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        decisionHandler(.allow)
    }
}

