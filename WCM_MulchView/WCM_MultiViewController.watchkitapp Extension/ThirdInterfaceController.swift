//
//  ThirdInterfaceController.swift
//  WCM_MultiViewController.watchkitapp Extension
//
//  Created by Takuji Hori on 2018/08/01.
//  Copyright © 2018 Takuji Hori. All rights reserved.
//

import WatchKit
import Foundation

class ThirdInterfaceController: WKInterfaceController, WatchConnectManagerDelegate {
    
    let WatchConnectShared = WatchConnectManager.sharedConnectManager
    var type = ""

    @IBOutlet var textLabel: WKInterfaceLabel!
    @IBOutlet var titleLabel: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        type = "Third SendMsg w/Replay"
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
//        if segueIdentifier == "toFourth" {
//            let context:[String:Any] = ["Title":"from Second" as Any]
//            return context as AnyObject
//        } else {
//            return nil
//        }
//    }

    // Sender
    @IBAction func sendButton() {
        if WatchConnectShared.zSendInteractiveMessage("zCommand$$", addInfo: ["I am watchOS.", "SendMsg w/Replay", Date()], replyHandler: {  replyDict in
            self.showMessage(message: "reply: \(replyDict)")
            Logger.info(message: "reply: \(replyDict)")
        }, errorHandler: { error in
            self.showMessage(message: "error: \(error.localizedDescription)")
            Logger.error(message: "error: \(error.localizedDescription)")
        }) == false {
            showMessage(message: "request SendMsg w/Replay error. It seems to be Not Reachable.")
            Logger.error(message: "\(#function): request SendMsg w/Replay error. It seems to be Not Reachable.")
        }
    }

    // Receiver
    func receiveInteractiveMessage(command:String, timeStamp:Date, subInfo:[String:Any], replyHandler: @escaping ([String:Any]) -> Void) {
        if command == "xCommand$$" {
            if let message = subInfo["xCommand$$00"] as? String,
                let sendtype = subInfo["xCommand$$01"] as? String,
                let sendtime = subInfo["xCommand$$02"] as? Date {                // same as timeStamp
                showMessage(message: message + "\n" + sendtype + "\n" +
                    dateformatter2.string(from: sendtime) + " " +  dateformatter2.string(from: Date()))
            }
            replyHandler(["Hello":"World", "I am":"watchOS"])
        }
    }
    
    func showMessage(message: String) {
        DispatchQueue.main.async() {
            self.textLabel.setText(message)
        }
    }
}

