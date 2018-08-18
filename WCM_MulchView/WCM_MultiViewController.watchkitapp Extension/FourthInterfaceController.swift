//
//  FourthInterfaceController.swift
//  WCM_MultiViewController.watchkitapp Extension
//
//  Created by 堀 卓司 on 2018/08/11.
//  Copyright © 2018 Takuji Hori. All rights reserved.
//

import WatchKit
import WatchConnectivity

class FourthInterfaceController: WKInterfaceController, WatchConnectManagerDelegate {
    
    let WatchConnectShared = WatchConnectManager.sharedConnectManager
    var type = ""
    
    var urlIndex = 0
    var Urls = [URL]()
    
    @IBOutlet var textLabel: WKInterfaceLabel!
    @IBOutlet var titleLabel: WKInterfaceLabel!
    @IBOutlet var imageView: WKInterfaceImage!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        type = "Fourth TransferFile"
        titleLabel.setText(type)
        
        Logger.debug(message: "\(#function): addDelegate")
        WatchConnectShared.addWatchConnectManagerDelegate(delegate: self)
        
        if let path0 = Bundle.main.path(forResource: "CatPhoto00", ofType: "jpg"),
            let path1 = Bundle.main.path(forResource: "CatPhoto01", ofType: "jpg") {
            Urls.append(URL(fileURLWithPath: path0))
            Urls.append(URL(fileURLWithPath: path1))
        } else {
            Logger.error(message: "\(#function): CatPhoto file error")
        }
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
    
    // Sender
    @IBAction func sendButton() {
        let url = Urls[urlIndex]
        if urlIndex == 0 { urlIndex = 1 } else { urlIndex = 0 }
        if FileHelper.fileExists(path: url.path) == false {
            Logger.error(message:"\(#function): TMP file not found error")
            return
        }
        if WatchConnectShared.zTransferFile(url, command: "zCommand$$", addInfo: ["I am watchOS.", "TransferFile", Date(), "CatPhoto0" + urlIndex.description]) == nil {
            showMessage(message: "request TansferFile error.")
            Logger.error(message: "\(#function): request TansferFile error.")
        }
    }
    
    // Send complete
    func receiveFileTransferDidFinish(command:String, timeStamp:Date, subInfo:[String:Any], fileTransfer: WCSessionFileTransfer, error: Error?) {
        if command == "zCommand$$" {
            showMessage(message: "send complete TansferFile.")
            Logger.info(message:"\(#function): send complete TansferFile.")
        }
    }
    
    // Receiver
    func receiveTransferFile(fileURL:URL, command:String, timeStamp:Date, subInfo:[String:Any], file: WCSessionFile) {
        if command == "xCommand$$" {
            if let message = subInfo["xCommand$$00"] as? String,
                let sendtype = subInfo["xCommand$$01"] as? String,
                let sendtime = subInfo["xCommand$$02"] as? Date,                // same as timeStamp
                let fileName = subInfo["xCommand$$03"] as? String {
                
                let path = fileURL.path
                if FileHelper.fileExists(path: path) == false {
                    Logger.info(message:"\(#function): receive file not found")
                    return
                }
                guard let fileSize = FileHelper.fileSizePath(path: path),
                    let data = FileHelper.readFileWithData(path: path) else {
                    Logger.info(message:"\(#function): receive file read error")
                    return
                }
                let sizeUnit = Misc.unitSizeString(size: fileSize)
                showMessage(message: message + "\n" + sendtype + "\n" + "name: \(fileName), size: \(sizeUnit)" + "\n" +
                    dateformatter2.string(from: sendtime) + " " +  dateformatter2.string(from: Date()))
                Logger.info(message:"\(#function): receive: \(fileName), size: \(sizeUnit)")
                DispatchQueue.main.async() {
                    self.imageView.setImage(UIImage(data: data))
                }
            } else {
                Logger.debug(message:"\(#function): subInfo format error.")
                return
            }
        }
    }
    
    func showMessage(message: String) {
        DispatchQueue.main.async() {
            self.textLabel.setText(message)
        }
    }
}
