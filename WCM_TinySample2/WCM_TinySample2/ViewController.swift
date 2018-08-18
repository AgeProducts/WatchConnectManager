//
//  ViewController.swift
//  WCM_TinySample2
//
//  Created by Takuji Hori on 2018/08/14.
//  Copyright © 2018 Takuji Hori. All rights reserved.
//

import UIKit
import WatchConnectivity

class ViewController: UIViewController, WatchConnectManagerDelegate {
    
    let WatchConnectShared = WatchConnectManager.sharedConnectManager
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WatchConnectShared.startSession()
        WatchConnectShared.addWatchConnectManagerDelegate(delegate: self)
    }
    
    // Receiver
    // SendMessage w/R
    func receiveInteractiveMessage(command:String, timeStamp:Date, subInfo:[String:Any], replyHandler: @escaping ([String:Any]) -> Void) {
        if command == "SendCommand$$" {
            if let string = subInfo["SendCommand$$00"] as? String,
                let date = subInfo["SendCommand$$01"] as? Date {
                DispatchQueue.main.async {
                    self.messageLabel.text = string + "\n\(date)"
                    self.imageView.image = UIImage(named: "CatImage01.png")
                }
            }
            replyHandler(["Ohayo!!":"Wake up", "My name":"is iOS"])
        }
    }
    
    // FileTransfer
    func receiveTransferFile(fileURL:URL, command:String, timeStamp:Date, subInfo:[String:Any], file:WCSessionFile) {
        if command == "FileCommand$$" {
            if let fileName = subInfo["FileCommand$$00"] as? String,
                let date = subInfo["FileCommand$$01"] as? Date {
                let path = fileURL.path
                DispatchQueue.main.async {
                    self.messageLabel.text = fileName + "\n\(date)"
                    self.imageView.image = UIImage(data: self.readFileWithData(path: path)!)
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
