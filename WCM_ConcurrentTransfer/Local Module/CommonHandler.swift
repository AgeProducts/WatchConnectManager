//
//  CommonHandler.swift
//  WCM_ConcurrentTransfer
//
//  Created by Takuji Hori on 2018/07/06.
//  Copyright © 2018 Takuji Hori. All rights reserved.
//

import UIKit
import WatchConnectivity

protocol CommonHandlerDelegate: class {
    func responseNumber(value: Int)
    func responseText(value: String)
}

class CommonHandler : NSObject, WatchConnectManagerDelegate {
    
    weak var commonHandlerDelegate: CommonHandlerDelegate?
    let WCMshare = WatchConnectManager.sharedConnectManager
    
    override init () {
        super.init()
        startUp()
    }
    
    func startUp() {
        WCMshare.addWatchConnectManagerDelegate(delegate: self)
    }
    
//    deinit {
//        WCMshare.removeWatchConnectManagerDelegate(delegate: self)
//    }
    
    // WatchConnectManager Request
    // Sender number
    func requestSendNum(value: Int) {
#if APL_CONTEXT
        if  WCMshare.zUpdateApplicationContext("number$$", addInfo:[value]) == false {
            Logger.error(message: "\(#function): request AplContext error")
        }
#elseif TRNS_USERINFO
        if WCMshare.zTransferUserInfo("number$$", addInfo:[value]) == nil {
            Logger.error(message: "\(#function): request UserInfo error.")
        }
#elseif INTRACT_MSG
        if WCMshare.zSendInteractiveMessage("number$$", addInfo:[value]) == false {
            Logger.error(message: "\(#function): request SendMsg w/reply error. It seems to be Not Reachable.")
        }
#else   // INTRACT_MSG with reply (default)
        if WCMshare.zSendInteractiveMessage("number$$", addInfo:[value], replyHandler: { replyDict in
            Logger.info(message: "reply from Remote: \(replyDict)")
        }, errorHandler: { error in
            Logger.error(message: "error: \(error.localizedDescription)")
        }) == false {
            Logger.error(message: "\(#function): request SendMsg w/reply error. It seems to be Not Reachable.")
        }
#endif
    }
    
    // Sender text
    func requestSendText(value: String) {
#if APL_CONTEXT
        if  WCMshare.zUpdateApplicationContext("text$$", addInfo:[value]) == false {
            Logger.error(message: "\(#function): request AplContext error")
        }
#elseif TRNS_USERINFO
        if WCMshare.zTransferUserInfo("text$$", addInfo:[value]) == nil {
            Logger.error(message: "\(#function): request UserInfo error.")
        }
#elseif INTRACT_MSG
        if WCMshare.zSendInteractiveMessage("text$$", addInfo:[value]) == false {
            Logger.error(message: "\(#function): request SendMsg w/reply error. It seems to be Not Reachable.")
        }
#else   // INTRACT_MSG with reply (default)
        if WCMshare.zSendInteractiveMessage("text$$", addInfo:[value], replyHandler: { replyDict in
            Logger.info(message: "reply from Remote: \(replyDict)")
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
        if command == "number$$",
            let value = subInfo["number$$00"] as? Int {
            Logger.debug(message: "\(#function): command: \(command), value: \(value)")
        } else if command == "text$$",
            let value = subInfo["text$$00"] as? String {
            Logger.debug(message: "\(#function): command: \(command), value: \(value)")
        }
    }
#endif
    
    // Receiver number & text
#if APL_CONTEXT
    func receiveApplicationContext(command:String, timeStamp:Date, subInfo:[String:Any]) {
        if command == "number$$",
            let value = subInfo["number$$00"] as? Int {
            Logger.debug(message: "\(#function): command: \(command), value: \(value)")
            commonHandlerDelegate?.responseNumber(value: value)
        } else if command == "text$$",
            let value = subInfo["text$$00"] as? String {
            Logger.debug(message: "\(#function): command: \(command), value: \(value)")
            commonHandlerDelegate?.responseText(value: value)
        }
    }
#elseif TRNS_USERINFO
    func receiveUserInfo(command:String, timeStamp:Date, subInfo:[String:Any]) {
        if command == "number$$",
            let value = subInfo["number$$00"] as? Int {
            Logger.debug(message: "\(#function): command: \(command), value: \(value)")
            commonHandlerDelegate?.responseNumber(value: value)
        } else if command == "text$$",
            let value = subInfo["text$$00"] as? String {
            Logger.debug(message: "\(#function): command: \(command), value: \(value)")
            commonHandlerDelegate?.responseText(value: value)
        }
    }
#else  // INTRACT_MSG or INTRACT_MSG with reply (default)
    func receiveInteractiveMessage(command:String, timeStamp:Date, subInfo:[String:Any], replyHandler: @escaping ([String:Any]) -> Void) {
        if command == "number$$",
            let value = subInfo["number$$00"] as? Int {
            Logger.debug(message: "\(#function): command: \(command), value: \(value)")
            commonHandlerDelegate?.responseNumber(value: value)
    #if os(iOS)
            replyHandler(["Hello":"World", "reply":"number$$", "I am":"iOS"])
    #else // watchOS
            replyHandler(["Hello":"World", "reply":"number$$", "I am":"watchOS"])
    #endif
        } else if command == "text$$",
            let value = subInfo["text$$00"] as? String {
            Logger.debug(message: "\(#function): command: \(command), value: \(value)")
            commonHandlerDelegate?.responseText(value: value)
    #if os(iOS)
            replyHandler(["Hello":"World", "reply":"text$$", "I am":"iOS"])
    #else // watchOS
            replyHandler(["Hello":"World", "reply":"text$$", "I am":"watchOS"])
    #endif
        }
    }
#endif
}

