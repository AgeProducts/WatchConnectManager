//
//  FileHandler.swift
//  WCM_ConcurrentTransfer
//
//  Created by Takuji Hori on 2018/07/29.
//  Copyright © 2018 Takuji Hori. All rights reserved.
//

import UIKit
import WatchConnectivity

// FileHandler
protocol FileHandlerDelegate: class {
    func showFileMessage(message: String)
    func showImage(image: Data)
}

class FileHandler: NSObject, WatchConnectManagerDelegate {
    
    weak var fileHandlerDelegate: FileHandlerDelegate?
    let WCMshare = WatchConnectManager.sharedConnectManager
    var imagePath:[String] = []
    var imagesCount = 0
    
    override init () {
        super.init()
        startUp()
    }
    
    func startUp() {
        for i in 0..<999 {
            let jpgFileName = "Photo\(i)"
            if let path = Bundle.main.path(forResource: jpgFileName, ofType: "jpg") {
                imagePath.append(path)
            } else {
                break
            }
        }
        imagesCount = imagePath.count
        if imagesCount == 0 {
            assertionFailure()
        }
        WCMshare.addWatchConnectManagerDelegate(delegate: self)
    }
    
//    deinit {
//        WCMshare.removeWatchConnectManagerDelegate(delegate: self)
//    }
    
    // Sender
    func performRandomFile() {
        let path = imagePath[RandomMaker.randomNumIntegerWithLimits(lower: 0, upper: imagesCount-1)]
        let fileName = path.lastPathComponent
        let Url = URL(fileURLWithPath: path)
        if FileHelper.fileExists(path: path) == true {
            if WCMshare.zTransferFile(Url, command:"file$$", addInfo:[fileName]) != nil {
                fileHandlerDelegate?.showFileMessage(message:"Send: " + fileName)
            } else {
                Logger.debug(message: "\(#function): request FiletTansfer error.")
                fileHandlerDelegate?.showFileMessage(message:"ERROR! S: " + fileName)
            }
        } else {
            Logger.debug(message:"\(#function): file not found")
        }
    }

    // File transfer Send complete
    func receiveFileTransferDidFinish(command:String, timeStamp:Date, subInfo:[String:Any], fileTransfer: WCSessionFileTransfer, error: Error?) {
        if command == "file$$",
            let _ = subInfo["file$$"] as? Date,
            let fileName = subInfo["file$$00"] as? String {
            Logger.debug(message:"\(#function): file transfer complete: \(fileName)")
            fileHandlerDelegate?.showFileMessage(message:"Complete: \(fileName)")
        }
    }

    // Receiver File transfer
    func receiveTransferFile(fileURL:URL, command:String, timeStamp:Date, subInfo:[String:Any], file: WCSessionFile) {
        if command == "file$$" {
            Logger.debug(message: "\(#function): command: \(command), timeStamp: \(timeStamp)")
            if let _ = subInfo["file$$"] as? Date,
                let fileName = subInfo["file$$00"] as? String {
                
                let path = fileURL.path
                if FileHelper.fileExists(path: path) == false {
                    Logger.debug(message:"\(#function): receive file not found")
                    return
                }
                guard let fileSize = FileHelper.fileSizePath(path: path) else {
                    Logger.debug(message:"\(#function): receive file size error")
                    return
                }
                let sizeUnit = Misc.unitSizeString(size: fileSize)
                Logger.debug(message:"\(#function): receive: \(fileName), size: \(sizeUnit)")
                
                let elapsedSec = Misc.elapsedTimeString(startDate: timeStamp)
                fileHandlerDelegate?.showFileMessage(message:"Rcv: " + fileName + "(\(sizeUnit), \(elapsedSec)s)")
                Logger.debug(message:"\(#function): Rcv: \(fileName), size: \(sizeUnit), sec: \(elapsedSec)")

                if let data = FileHelper.readFileWithData(path: path) {
                    fileHandlerDelegate?.showImage(image: data)
                } else {
                    Logger.debug(message:"\(#function): receive file read error")
                    fileHandlerDelegate?.showFileMessage(message:"Rcv: " + fileName + " - read error")
                }
            } else {
                Logger.debug(message:"\(#function): subInfo format error.")
            }
        }
    }
}
