//
//  ViewController.swift
//  WCM_TinySample
//
//  Created by Takuji Hori on 2018/08/01.
//  Copyright © 2018 Takuji Hori. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let WatchConnectShared = WatchConnectManager.sharedConnectManager                                                   // 1. Instantiation (+shortening)
    var url:URL?
    
    @IBOutlet weak var massageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        url = URL(fileURLWithPath:Bundle.main.path(forResource: "CatPhoto00", ofType: "jpg")!)

        WatchConnectShared.startSession()                                                                               // 2. Start session
    }
   
    // Sender
    @IBAction func sendButton(_ sender: Any) {
        WatchConnectShared.zUpdateApplicationContext("AplCommand$$", addInfo:["My name is iOS.", Date()])               // 3. Send AplContext
    }
    
    @IBAction func fileTansferButton(_ sender: Any) {
        WatchConnectShared.zTransferFile(url!, command: "FileCommand$$", addInfo:["CatPhoto00.jpg", Date()])            // 4. Send TransferFile
    }
}
