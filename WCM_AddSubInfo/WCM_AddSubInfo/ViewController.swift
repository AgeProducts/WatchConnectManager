//
//  ViewController.swift
//  WCM_AddSubInfo
//
//  Created by Takuji Hori on 2018/07/31.
//  Copyright © 2018 Takuji Hori. All rights reserved.
//

import UIKit
import WatchConnectivity

class ViewController: UIViewController, WatchConnectManagerDelegate {
    
    let WCMshare = WatchConnectManager.sharedConnectManager
    var infoArray:[Any] = []
    var Url:URL? = nil

    @IBOutlet weak var textView: UITextView!
    
    let imageFile = "CatImage00.png"
    let photoFile = "CatPhoto00.jpg"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if WCMshare.startSession() == false {
            loggerDebug(message: "No session stop")
            assertionFailure("No session stop")
        }
        WCMshare.addWatchConnectManagerDelegate(delegate: self)
        
        // Set Objects to addInfo
        infoArray.append(Date())
        infoArray.append("String....")
        infoArray.append(1 as Int)
        infoArray.append(2.2 as Double)
        infoArray.append(["Array0","Array1","Array2","Array3"])
        infoArray.append(["Dict0":00, "Dict1":01, "Dict2":02, "Dict3":03])
        if let image = UIImage(named: imageFile),
            let data = UIImagePNGRepresentation(image) {
            infoArray.append(data)
        }
        loggerDebug(message: "infoArray: \(infoArray)")

        if let path = Bundle.main.path(forResource: photoFile.deletingPathExtension, ofType: "jpg") {
            Url = URL(fileURLWithPath: path)
        } else {
            loggerDebug(message:"\(#function): URL nil error: \(photoFile)")
        }
    }
    
//    deinit {
//        WCMshare.removeWatchConnectManagerDelegate(delegate: self)
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Sender
    @IBAction func aplContextButtonAct(_ sender: Any) {
        loggerDebug(message: "request ApplicationContext.")
        if WCMshare.zUpdateApplicationContext("AplContextCMD$$", addInfo: infoArray) == false {
            loggerDebug(message: "request AplContext error")
        }
    }
    
    @IBAction func userInfoButtonAct(_ sender: Any) {
        loggerDebug(message: "request UserInfo.")
        if WCMshare.zTransferUserInfo("UserInfoCMD$$", addInfo:infoArray) == nil {
            loggerDebug(message: "request UserInfo error")
        }
    }
    
    @IBAction func interactiveLongButtonAct(_ sender: Any) {
        loggerDebug(message: "request SendMessage")
        if WCMshare.zSendInteractiveMessage("SendMessageCMD$$", addInfo:infoArray, replyHandler: {  replyDict in
            self.loggerDebug(message: "reply from watchOS: \(replyDict)")
        }, errorHandler: { error in
            self.loggerDebug(message: "error: \(error.localizedDescription)")
        }) == false {
            loggerDebug(message: "\(#function): request SendMsg w/Replay error. Pair is not reachable.")
        }
    }
    
    @IBAction func filetTansferButtonAct(_ sender: Any) {
        loggerDebug(message: "request FiletTansfer")
        if let url = Url {
            if FileHelper.fileExists(path: url.path) == false {
                loggerDebug(message:"\(#function): TMP file not found error")
                return
            }
            if WCMshare.zTransferFile(url, command: "FiletTansCND$$", addInfo: infoArray + [photoFile]) == nil {
                loggerDebug(message: "\(#function): request FiletTansfer error.")
            }
        }
    }

    // Status change / Delagete
    func receiveStatusReachabilityDidChange(reachability: Bool) {
        if reachability == true {
            loggerDebug(message: "Reachable")
        } else {
            loggerDebug(message: "Not_Reachable")
        }
    }

    // Sender / complete
    func receiveUserInfoDidFinish(command:String, timeStamp:Date, subInfo:[String:Any], userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
        if command == "UserInfoCMD$$" {
            loggerDebug(message:"\(#function): UserInfo complete")
        }
    }

    func receiveFileTransferDidFinish(command:String, timeStamp:Date, subInfo:[String:Any], fileTransfer: WCSessionFileTransfer, error: Error?) {
        if command == "FiletTansCND$$" {
            if let fileName = subInfo["FiletTansCND$$07"] as? String {
                loggerDebug(message:"\(#function): File Transfer complete: \(fileName)")
            }
        }
    }
    
    // Receiver / Delagete
    func receiveApplicationContext(command:String, timeStamp:Date, subInfo:[String:Any]) {
        if command == "AplContextCMD$$" {
            if subInfoDecomp(command: command, subInfo: subInfo) == true {
                loggerDebug(message: "\(#function): command: \(command), timeStamp: \(timeStamp)")
            } else {
                loggerDebug(message: "\(#function): command: \(command), subInfo error")
            }
        }
    }
    
    func receiveUserInfo(command:String, timeStamp:Date, subInfo:[String:Any]) {
        if command == "UserInfoCMD$$" {
            if subInfoDecomp(command: command, subInfo: subInfo) == true {
                loggerDebug(message: "\(#function): command: \(command), timeStamp: \(timeStamp)")
            } else {
                loggerDebug(message: "\(#function): command: \(command), subInfo error")
            }
        }
    }
    
    func receiveInteractiveMessage(command:String, timeStamp:Date, subInfo:[String:Any], replyHandler: @escaping ([String:Any]) -> Void) {
        if command == "SendMessageCMD$$" {
            if subInfoDecomp(command: command, subInfo: subInfo) == true {
                loggerDebug(message: "\(#function): command: \(command), timeStamp: \(timeStamp)")
            } else {
                loggerDebug(message: "\(#function): command: \(command), subInfo error")
            }
            replyHandler(["Hello":"World", "reply":"SendMessage Delegate (@iOS), reply"])
        }
    }
    
    func receiveTransferFile(fileURL:URL, command:String, timeStamp:Date, subInfo:[String:Any], file: WCSessionFile) {
        if command == "FiletTansCND$$" {
            loggerDebug(message: "\(#function): command: \(command), timeStamp: \(timeStamp)")
            if subInfoDecomp(command: command, subInfo: subInfo) == true {
                if let fileName = subInfo["FiletTansCND$$07"] as? String {
                    let path = fileURL.path
                    if FileHelper.fileExists(path: path) == false {
                        loggerDebug(message:"\(#function): receive file not found")
                        return
                    }
                    guard let fileSize = FileHelper.fileSizePath(path: path) else {
                        loggerDebug(message:"\(#function): receive file size error")
                        return
                    }
                    let sizeUnit = Misc.unitSizeString(size: fileSize)
                    loggerDebug(message:"\(#function): receive: \(fileName), size: \(sizeUnit)")
                }
            } else {
                loggerDebug(message: "\(#function): command: \(command), subInfo error")
            }
        }
    }
    
    // Common : Decomposition manner
    func subInfoDecomp(command:String, subInfo:[String:Any]) -> Bool {
        var result = true
        if let value = subInfo[command + "00"] as? Date {
//            loggerDebug(message: "subInfo[\"\(command)00\"]: \(value)")
        } else {
            loggerDebug(message: "subInfo[\"\(command)00\"] error")
            result = false
        }
        if let value = subInfo[command + "01"] as? String {
//            loggerDebug(message: "subInfo[\"\(command)01\"]: \(value)")
        } else {
            loggerDebug(message: "subInfo[\"\(command)01\"] error")
            result = false
        }
        if let value = subInfo[command + "02"] as? Int {
//            loggerDebug(message: "subInfo[\"\(command)02\"]: \(value)")
        } else {
            loggerDebug(message: "subInfo[\"\(command)02\"] error")
            result = false
        }
        if let value = subInfo[command + "03"] as? Double {
//            loggerDebug(message: "subInfo[\"\(command)03\"]: \(value)")
        } else {
            loggerDebug(message: "subInfo[\"\(command)03\"] error")
            result = false
        }
        if let value = subInfo[command + "04"] as? NSArray {
//            loggerDebug(message: "subInfo[\"\(command)04\"]: \(value)")
        } else {
            loggerDebug(message: "subInfo[\"\(command)04\"] error")
            result = false
        }
        if let value = subInfo[command + "05"] as? NSDictionary {
//            loggerDebug(message: "subInfo[\"\(command)05\"]: \(value)")
        } else {
            loggerDebug(message: "subInfo[\"\(command)05\"] error")
            result = false
        }
        if let value = subInfo[command + "06"] as? Data {
//            loggerDebug(message: "subInfo[\"\(command)06\"]: \(value)")
        } else {
            loggerDebug(message: "subInfo[\"\(command)06\"] error")
            result = false
        }
        return result
    }
    
    func loggerDebug(message: String) {
         DispatchQueue.main.async {
            self.textView.isScrollEnabled = false
            self.textView.text = self.textView.text + message + "\n"
            self.textView.selectedRange = NSRange(location: self.textView.text.characters.count, length: 0)
            self.textView.isScrollEnabled = true
            let scrollY = self.textView.contentSize.height - self.textView.bounds.height
            let scrollPoint = CGPoint(x: 0, y: scrollY > 0 ? scrollY : 0)
            self.textView.setContentOffset(scrollPoint, animated: true)
            Logger.debug(message:message)
        }
    }
}

