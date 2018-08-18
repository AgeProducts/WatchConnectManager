//
//  InterfaceController.swift
//  WCM_TinySample2.watchkitapp Extension
//
//  Created by Takuji Hori on 2018/08/14.
//  Copyright © 2018 Takuji Hori. All rights reserved.
//

import WatchKit
import WatchConnectivity

class InterfaceController: WKInterfaceController {
    
    let WatchConnectShared = WatchConnectManager.sharedConnectManager
    var url:URL?
    
    @IBOutlet var messageLabel: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        url = URL(fileURLWithPath:Bundle.main.path(forResource: "CatPhoto01", ofType: "jpg")!)
        
        WatchConnectShared.startSession()
        
    }
    
    // Sender
    @IBAction func sendMassageButton() {
        WatchConnectShared.zSendInteractiveMessage("SendCommand$$", addInfo: ["I am watchOS.", Date()], replyHandler: {  replyDict in
            DispatchQueue.main.async() {
                self.messageLabel.setText("reply: \(replyDict)")
            }
        })
    }
    
    @IBAction func fileTansferButton(_ sender: Any) {
        WatchConnectShared.zTransferFile(url!, command: "FileCommand$$", addInfo:["CatPhoto00.jpg", Date()])
    }
}

