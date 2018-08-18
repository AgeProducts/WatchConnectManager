//
//  InterfaceController.swift
//  WCM_TinySample.watchkitapp Extension
//
//  Created by Takuji Hori on 2018/08/01.
//  Copyright © 2018 Takuji Hori. All rights reserved.
//

import WatchKit
import WatchConnectivity

class InterfaceController: WKInterfaceController, WatchConnectManagerDelegate {                     // 1. Inherit protocol
    
    let WatchConnectShared = WatchConnectManager.sharedConnectManager                               // 2. Instantiation (+shortening)

    @IBOutlet var messageLabel: WKInterfaceLabel!
    @IBOutlet var imageView: WKInterfaceImage!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        WatchConnectShared.startSession()                                                           // 3. Start session
        WatchConnectShared.addWatchConnectManagerDelegate(delegate: self)                           // 4. Set self to delegate
    }
    
    // Receive
    // AplContext
    func receiveApplicationContext(command:String, timeStamp:Date, subInfo:[String:Any]) {          // 5. Receive AplContext
        if command == "AplCommand$$" {                                                              // 6. Check with my "command"
            if let string = subInfo["AplCommand$$00"] as? String,                                   // 7. Get Zero'th argument
                let date = subInfo["AplCommand$$01"] as? Date {                                     // 8.  and 01 arg
                    DispatchQueue.main.async {                                                      // 9. Note: Not in main thread
                        self.messageLabel.setText(string + "\n\(date)")
                        self.imageView.setImage(UIImage(named: "CatImage00.png"))                   // Reset view
                }
            }
        }
    }
    
    // FileTransfer
    func receiveTransferFile(fileURL:URL, command:String, timeStamp:Date, subInfo:[String:Any], file:WCSessionFile) {  // 9. Receive TransferFile
        if command == "FileCommand$$" {
            if let fileName = subInfo["FileCommand$$00"] as? String,
                let date = subInfo["FileCommand$$01"] as? Date {
                let path = fileURL.path                                                                 // 10. Get file path
                DispatchQueue.main.async {
                    self.messageLabel.setText(fileName + "\n\(date)")
                    self.imageView.setImage(UIImage(data: self.readFileWithData(path: path)!))          // 12. Read date, show
                }
            }
        }
    }
    
    // File Handler
    func fileExists(path: String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }
    
    func readFileWithData(path: String) -> Data? {
        if fileExists(path: path) == false {
            return nil
        }
        guard let fileHandle = FileHandle(forReadingAtPath: path) else {
            return nil
        }
        let data = fileHandle.readDataToEndOfFile()
        fileHandle.closeFile()
        return data
    }
}

