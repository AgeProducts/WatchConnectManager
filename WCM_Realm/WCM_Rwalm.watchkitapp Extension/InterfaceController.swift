//
//  InterfaceController.swift
//  WCM_Rwalm.watchkitapp Extension
//
//  Created by Takuji Hori on 2018/08/24.
//  Copyright © 2018 Takuji Hori. All rights reserved.
//

import WatchKit
import WatchConnectivity
import RealmSwift

let viewCont = 10

class InterfaceController: WKInterfaceController, WatchConnectManagerDelegate {
    
    @IBOutlet var messageLabel: WKInterfaceLabel!
    let WatchConnectShared = WatchConnectManager.sharedConnectManager
    var realm:Realm?
    var filePath = ""
    var messageString = ""

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        WatchConnectShared.startSession()
        WatchConnectShared.addWatchConnectManagerDelegate(delegate: self)
    }

    // Receive FileTransfer
    func receiveTransferFile(fileURL:URL, command:String, timeStamp:Date, subInfo:[String:Any], file:WCSessionFile) {  // 9. Receive TransferFile
        if command == "RealmFileTransfer$$" {
            
//            let config = Realm.Configuration(fileURL: fileURL, readOnly: true)
            let config = Realm.Configuration(fileURL: fileURL)
            realm = try! Realm(configuration: config)
            
            filePath = fileURL.path
            listObject(count:viewCont)
        }
    }
    
    func listObject(count:Int) {                // show 10 items
        
        var recivemsg = ""
        let df = DateFormatter()
        df.dateFormat = "HH:mm:ss"

        let results = realm!.objects(SampleRealm.self).sorted(byKeyPath: "id", ascending: false)
        if let firstObj = results.first {
            recivemsg = "(\(df.string(from: firstObj.date)))"
        } else {
            recivemsg = "(No Data)"
        }
        loggerDebug(message: recivemsg + " \(Misc.unitSizeString(size: FileHelper.fileSizePath(path: filePath)!))", clear: true)

        let Min = min(count, results.count)
        for i in 0..<Min {
            let obj = results[i]
            let message = String(format: "[%d] %@",obj.id, obj.string)
            loggerDebug(message: message, clear: false)
        }
    }

    func loggerDebug(message: String, clear:Bool) {
        DispatchQueue.main.async {
            if clear == true {
                self.messageString = ""
            }
            self.messageString = self.messageString + message + "\n"
            self.messageLabel.setText(self.messageString)
            Logger.debug(message: message)
        }
    }
}
