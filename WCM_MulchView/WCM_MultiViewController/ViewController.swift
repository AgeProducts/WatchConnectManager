//
//  ViewController.swift
//  WCM_MultiViewController
//
//  Created by Takuji Hori on 2018/08/01.
//  Copyright © 2018 Takuji Hori. All rights reserved.
//

import UIKit

class ViewController: UIViewController, WatchConnectManagerDelegate {

    let WatchConnectShared = WatchConnectManager.sharedConnectManager
    var type = ""
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        type = "First AplContext"
        titleLabel.text = type
        
        WatchConnectShared.startSession()
        
        Logger.debug(message: "\(#function): addDelegate")
        WatchConnectShared.addWatchConnectManagerDelegate(delegate: self)
    }
    
    deinit {
        Logger.debug(message: "\(#function): deinit")
//        WatchConnectShared.removeWatchConnectManagerDelegate(delegate: self)
    }
   
    @IBAction func goNext(_ sender: Any) {
        performSegue(withIdentifier: "SecondSegue", sender: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Sender
    @IBAction func sendButton(_ sender: Any) {
        if WatchConnectShared.zUpdateApplicationContext("xCommand$$", addInfo: ["My name is iOS", "AplContext", Date()]) == false {
            showMessage(message: "request AplContext error")
            Logger.error(message: "\(#function): request AplContext error")
        }
    }
    
    // Receiver
    func receiveApplicationContext(command:String, timeStamp:Date, subInfo:[String:Any]) {
        if command == "zCommand$$" {
            if let message = subInfo["zCommand$$00"] as? String,
                let sendtype = subInfo["zCommand$$01"] as? String,
                let sendtime = subInfo["zCommand$$02"] as? Date {                // same as timeStamp
                showMessage(message: message + "\n" + sendtype + "\n" +
                    dateformatter2.string(from: sendtime) + " " +  dateformatter2.string(from: Date()))
            }
        }
    }
    
    func showMessage(message: String) {
        DispatchQueue.main.async() {
            self.textLabel.text = message
        }
    }
}

