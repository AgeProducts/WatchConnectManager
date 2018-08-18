//
//  ThirdViewController.swift
//  WCM_MultiViewController
//
//  Created by Takuji Hori on 2018/08/04.
//  Copyright © 2018 Takuji Hori. All rights reserved.
//

import UIKit

class ThirdViewController: UIViewController, WatchConnectManagerDelegate {
    
    let WatchConnectShared = WatchConnectManager.sharedConnectManager
    var type = ""
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        type = "Third SendMsg w/Replay"
        titleLabel.text = type
        
        Logger.debug(message: "\(#function): addDelegate")
        WatchConnectShared.addWatchConnectManagerDelegate(delegate: self)
    }
    
    deinit {
        Logger.debug(message: "\(#function): deinit")
//        WatchConnectShared.removeWatchConnectManagerDelegate(delegate: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goNext(_ sender: Any) {
        performSegue(withIdentifier: "FourthSegue", sender: nil)
    }

    @IBAction func goBack(_ segue:UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }
    
    // Sender
    @IBAction func sendButton(_ sender: Any) {
        if WatchConnectShared.zSendInteractiveMessage("xCommand$$", addInfo: ["My name is iOS", "SendMsg w/Replay", Date()], replyHandler: {  replyDict in
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
        if command == "zCommand$$" {
            if let message = subInfo["zCommand$$00"] as? String,
                let sendtype = subInfo["zCommand$$01"] as? String,
                let sendtime = subInfo["zCommand$$02"] as? Date {                // same as timeStamp
                showMessage(message: message + "\n" + sendtype + "\n" +
                    dateformatter2.string(from: sendtime) + " " +  dateformatter2.string(from: Date()))
            }
            replyHandler(["Ohayo!!":"Wake up", "My name":"is iOS"])
        }
    }
    
    func showMessage(message: String) {
        DispatchQueue.main.async() {
            self.textLabel.text = message
        }
    }
}
