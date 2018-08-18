//
//  SecondInterfaceController.swift
//  WCM_MultiViewController.watchkitapp Extension
//
//  Created by Takuji Hori on 2018/08/01.
//  Copyright © 2018 Takuji Hori. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class SecondInterfaceController: WKInterfaceController, WatchConnectManagerDelegate {
    
    let WatchConnectShared = WatchConnectManager.sharedConnectManager
    var type = ""

    @IBOutlet var textLabel: WKInterfaceLabel!
    @IBOutlet var titleLabel: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        type = "Second UserInfo"
        titleLabel.setText(type)

        Logger.debug(message: "\(#function): addDelegate")
        WatchConnectShared.addWatchConnectManagerDelegate(delegate: self)
    }
    
    deinit {
        Logger.debug(message: "\(#function): deinit")
//        WatchConnectShared.removeWatchConnectManagerDelegate(delegate: self)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
//        WatchConnectShared.addWatchConnectManagerDelegate(delegate: self)
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
//        WatchConnectShared.removeWatchConnectManagerDelegate(delegate: self)
        super.didDeactivate()
    }    
    
//    override func contextForSegue(withIdentifier segueIdentifier: String) -> Any? {
//        if segueIdentifier == "toThird"{
//            let context:[String:Any] = ["Title":"from Second" as Any]
//            return context as AnyObject
//        } else {
//            return nil
//        }
//    }

    // Sender
    @IBAction func sendButton() {
        if WatchConnectShared.zTransferUserInfo("zCommand$$", addInfo: ["I am watchOS.", "UserInfo", Date()]) == nil {
            showMessage(message: "request UserInfo error.")
            Logger.error(message: "\(#function): request UserInfo error.")
        }
    }
    
    // Send complete
    func receiveUserInfoDidFinish(command:String, timeStamp:Date, subInfo:[String:Any], userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
        if command == "zCommand$$" {
            showMessage(message: "send complete UserInfo.")
            Logger.info(message:"\(#function): send complete UserInfo.")
        }
    }

    // Receiver
    func receiveUserInfo(command:String, timeStamp:Date, subInfo:[String:Any]) {
        if command == "xCommand$$" {
            if let message = subInfo["xCommand$$00"] as? String,
                let sendtype = subInfo["xCommand$$01"] as? String,
                let sendtime = subInfo["xCommand$$02"] as? Date {                // same as timeStamp
                showMessage(message:message + "\n" + sendtype + "\n" +
                    dateformatter2.string(from: sendtime) + " " +  dateformatter2.string(from: Date()))
            }
        }
    }
    
    func showMessage(message: String) {
        DispatchQueue.main.async() {
            self.textLabel.setText(message)
        }
    }
}

