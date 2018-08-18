//
//  FourthViewController.swift
//  WCM_MultiViewController
//
//  Created by 堀 卓司 on 2018/08/11.
//  Copyright © 2018 Takuji Hori. All rights reserved.
//

import UIKit
import WatchConnectivity

class FourthViewController: UIViewController, WatchConnectManagerDelegate {
    
    let WatchConnectShared = WatchConnectManager.sharedConnectManager
    var type = ""
    
    var urlIndex = 0
    var Urls = [URL]()
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        type = "Fourth TransferFile"
        titleLabel.text = type
        
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goBack(_ segue:UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }
    
    // Sender
    @IBAction func sendButton(_ sender: Any) {
        let url = Urls[urlIndex]
        if urlIndex == 0 { urlIndex = 1 } else { urlIndex = 0 }
        if FileHelper.fileExists(path: url.path) == false {
            Logger.error(message:"\(#function): TMP file not found error.")
            return
        }
        if WatchConnectShared.zTransferFile(url, command: "xCommand$$", addInfo: ["My name is iOS", "TransferFile", Date(), "CatPhoto0" + urlIndex.description]) == nil {
            showMessage(message: "request TansferFile error.")
            Logger.error(message: "\(#function): request TansferFile error.")
        }
    }
    
    // Send complete
    func receiveFileTransferDidFinish(command:String, timeStamp:Date, subInfo:[String:Any], fileTransfer: WCSessionFileTransfer, error: Error?) {
        if command == "xCommand$$" {
            showMessage(message: "send complete TansferFile.")
            Logger.info(message:"\(#function): send complete TansferFile.")
        }
    }

    // Receiver
    func receiveTransferFile(fileURL:URL, command:String, timeStamp:Date, subInfo:[String:Any], file: WCSessionFile) {
        if command == "zCommand$$" {
            if let message = subInfo["zCommand$$00"] as? String,
                let sendtype = subInfo["zCommand$$01"] as? String,
                let sendtime = subInfo["zCommand$$02"] as? Date,                // same as timeStamp
                let fileName = subInfo["zCommand$$03"] as? String {
                
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
                    self.imageView.image = UIImage(data: data)
                }
            } else {
                Logger.debug(message:"\(#function): subInfo format error.")
            }
        }
    }

    func showMessage(message: String) {
        DispatchQueue.main.async() {
            self.textLabel.text = message
        }
    }
}
