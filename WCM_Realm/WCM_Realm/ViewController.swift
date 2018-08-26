//
//  ViewController.swift
//  WCM_Realm
//
//  Created by Takuji Hori on 2018/08/24.
//  Copyright © 2018 Takuji Hori. All rights reserved.
//

import UIKit
import RealmSwift
import WatchConnectivity

let viewCont = 10

class ViewController: UIViewController {
    //class ViewController: UIViewController, WatchConnectManagerDelegate {

    let WatchConnectShared = WatchConnectManager.sharedConnectManager
    var realm:Realm?
    var url:URL?
    var sendResult:WCSessionFileTransfer?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        realm = try! Realm()
        url = realm?.configuration.fileURL

        WatchConnectShared.startSession()
//        WatchConnectShared.addWatchConnectManagerDelegate(delegate: self)
    }
    
    func makeObject(count:Int) {
        for i in 0..<count {
            let obj = SampleRealm()
            obj.id = realm!.objects(SampleRealm.self).count + 1
            obj.string = RandomMaker.randomStringWithLength(16)
            try! realm!.write() {
                realm!.add(obj)
            }
        }
    }
    
    func listObject(count:Int) {        // show new items
        let df = DateFormatter()
        df.dateFormat = "HH:mm:ss"
        
        let results = realm!.objects(SampleRealm.self).sorted(byKeyPath: "id", ascending: false)
        let Min = min(count, results.count)
        for i in 0..<Min {
            let obj = results[i]
            let message = String(format: "[%d] %@ %@",obj.id,df.string(from: obj.date),obj.string)
            loggerDebug(message: message, clear:false)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendButtonAct(_ sender: Any) {
        loggerDebug(message: "Send Realm files...", clear: false)

        WatchConnectShared.zTransferFile(url!, command: "RealmFileTransfer$$", addInfo:nil)
//        if let sendResult = WatchConnectShared.zTransferFile(url!, command: "RealmFileTransfer$$", addInfo:nil) {
//            loggerDebug(message: "Send....", clear: false)
//        } else {
//            loggerDebug(message: "Send error!!!", clear: false)
//        }
    }
    
//    func receiveFileTransferDidFinish(command:String, timeStamp:Date, subInfo:[String:Any], fileTransfer: WCSessionFileTransfer, error: Error?) {
//        if command == "RealmFileTransfer$$" {
//            loggerDebug(message: "Send complete...", clear:false)
//        }
//    }
    
    @IBAction func makeButtonAct(_ sender: Any) {
        loggerDebug(message: "Remake Realm record...", clear: true)
        makeObject(count: viewCont)
        listObject(count: viewCont)
    }
    
    func loggerDebug(message: String, clear:Bool) {
        NSLog("\(message)")
    }
}
