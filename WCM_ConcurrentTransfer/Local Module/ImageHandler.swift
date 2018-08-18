//
//  ImageHandler.swift
//  WCM_ConcurrentTransfer
//
//  Created by Takuji Hori on 2018/07/29.
//  Copyright © 2018 Takuji Hori. All rights reserved.
//

import UIKit
import WatchConnectivity

// ImageHandler
protocol ImageHandlerDelegate: class {
    func showImage(image: Data)
}

class ImageHandler:NSObject, WatchConnectManagerDelegate {
    
    weak var imageHandlerDelegate: ImageHandlerDelegate?
    let WCMshare = WatchConnectManager.sharedConnectManager
    var images:[Data] = []
    var imagesCount = 0
    
    override init () {
        super.init()
        startUp()
    }
    
    func startUp() {
        for i in 0..<999 {
            let pngFileName = "CatsX90-\(i)"
            if let image = UIImage(named: pngFileName + ".png"),
                let data = UIImagePNGRepresentation(image) {
                images.append(data)
            } else {
                break
            }
        }
        imagesCount = images.count
        if imagesCount == 0 {
            assertionFailure()
        }
        WCMshare.addWatchConnectManagerDelegate(delegate: self)
    }
    
//    deinit {
//        WCMshare.removeWatchConnectManagerDelegate(delegate: self)
//    }
    
    func performRandomImage() {
        let imagedata = images[RandomMaker.randomNumIntegerWithLimits(lower: 0, upper: imagesCount-1)]
        imageHandlerDelegate?.showImage(image: imagedata)
        performConnectImage(image: imagedata)
    }
    
    // WatchConnectManager Request
    // Sender image data
    func performConnectImage(image: Data) {
#if APL_CONTEXT
        if  WCMshare.zUpdateApplicationContext("image$$", addInfo: [image]) == false {
            Logger.error(message: "\(#function): request AplContext error")
        }
#elseif TRNS_USERINFO
        if WCMshare.zTransferUserInfo("image$$", addInfo: [image]) == nil {
            Logger.error(message: "\(#function): request UserInfo error.")
        }
#elseif INTRACT_MSG
        if WCMshare.zSendInteractiveMessage("image$$", addInfo: [image]) == false {
            Logger.error(message: "\(#function): request SendMsg w/reply error. It seems to be Not Reachable.")
        }
#else  // INTRACT_MSG with reply (default)
        if WCMshare.zSendInteractiveMessage("image$$", addInfo: [image], replyHandler: { replyDict in
            Logger.info(message: "reply: \(replyDict)")
        }, errorHandler: { error in
            Logger.error(message: "error: \(error.localizedDescription)")
        }) == false {
            Logger.error(message: "\(#function): request SendMsg w/reply error. It seems to be Not Reachable.")
        }
#endif
    }
    
    // UserInfo Send complete
#if TRNS_USERINFO
    func receiveUserInfoDidFinish(command:String, timeStamp:Date, subInfo:[String:Any], userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
        if command == "image$$",
            let value = subInfo["image$$00"] as? Data {
            Logger.debug(message: "\(#function): command: \(command), value: \(value)")
        }
    }
#endif

    
    // Receiver image data
#if APL_CONTEXT
    func receiveApplicationContext(command:String, timeStamp:Date, subInfo:[String:Any]) {
        if command == "image$$",
            let value = subInfo["image$$00"] as? Data {
            Logger.debug(message: "\(#function): command: \(command), value: \(value)")
            imageHandlerDelegate?.showImage(image: value)
        }
    }
#elseif TRNS_USERINFO
    func receiveUserInfo(command:String, timeStamp:Date, subInfo:[String:Any]) {
        if command == "image$$",
            let value = subInfo["image$$00"] as? Data {
            Logger.debug(message: "\(#function): command: \(command), value: \(value)")
            imageHandlerDelegate?.showImage(image: value)
        }
    }
#else // INTRACT_MSG or INTRACT_MSG with reply (default)
    func receiveInteractiveMessage(command:String, timeStamp:Date, subInfo:[String:Any], replyHandler: @escaping ([String:Any]) -> Void) {
        if command == "image$$",
            let value = subInfo["image$$00"] as? Data {
            Logger.debug(message: "\(#function): command: \(command), value: \(value)")
            imageHandlerDelegate?.showImage(image: value)
        }
    }
#endif
}

