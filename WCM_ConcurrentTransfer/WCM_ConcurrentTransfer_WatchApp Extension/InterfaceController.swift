//
//  InterfaceController.swift
//  WCM_ConcurrentTransfer_WatchApp Extension
//
//  Created by Takuji Hori on 2018/07/31.
//  Copyright © 2018 Takuji Hori. All rights reserved.
//

import WatchKit
import WatchConnectivity

class InterfaceController: WKInterfaceController, WatchConnectManagerDelegate, CommonHandlerDelegate, ImageHandlerDelegate, FileHandlerDelegate {

    @IBOutlet var numLabel: WKInterfaceLabel!
    @IBOutlet var minusButton: WKInterfaceButton!
    @IBOutlet var resetButton: WKInterfaceButton!
    @IBOutlet var randomButton: WKInterfaceButton!
    @IBOutlet var plusButton: WKInterfaceButton!
    @IBOutlet var titleLabel: WKInterfaceLabel!     // Dummy
    @IBOutlet var RNDTextLabel: WKInterfaceLabel!
    @IBOutlet var imageView: WKInterfaceImage!
    @IBOutlet var fileLabel: WKInterfaceLabel!
    @IBOutlet var timerLabel: WKInterfaceLabel!
    
    var currentNumber = 0
    var currentText = "Random Text"
    var timer: Timer?
    let progressDivider = 0.1
    var progressTimer = 0.0
    
    let WCMshare = WatchConnectManager.sharedConnectManager
    
    var commonHandler: CommonHandler?
    var imageHandler: ImageHandler?
#if !NO_FILE_TRANSFER
    var fileHandler: FileHandler?
#endif
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if WCMshare.startSession() == false {
            NSLog("No session stop")
            assertionFailure("No session stop")
        }
        
        commonHandler = CommonHandler()
        commonHandler?.commonHandlerDelegate = self
        imageHandler = ImageHandler()
        imageHandler?.imageHandlerDelegate = self
#if NO_FILE_TRANSFER
        showFileMessage(message: "No File Transfer!")
#else
        fileHandler = FileHandler()
        fileHandler?.fileHandlerDelegate = self
#endif
        
        stopTimer()
        showTitile()
        showNumber(value: currentNumber)
        showText(value: currentText)
        
        WCMshare.addWatchConnectManagerDelegate(delegate: self)
    }
    
//    deinit {
//        WCMshare.removeWatchConnectManagerDelegate(delegate: self)
//    }
//    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
//        WCMshare.addWatchConnectManagerDelegate(delegate: self)
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
//        WCMshare.removeWatchConnectManagerDelegate(delegate: self)
        super.didDeactivate()
    }

    @IBAction func plusButtonAct() {
        stopTimer()
        var value = currentNumber + 1
        if value > maxValue {
            value = maxValue
        }
        currentNumber = value
        performConnectCommon()
    }
    
    @IBAction func minusButtonAct() {
        stopTimer()
        var value = currentNumber - 1
        if value < -maxValue {
            value = -maxValue
        }
        currentNumber = value
        performConnectCommon()

    }
    
    @IBAction func resetButtonAct() {
        stopTimer()
        currentNumber = 0
        performConnectCommon()
    }
    
    @IBAction func randomButtonAct() {
        if startTimer() == true {
            currentNumber = RandomMaker.randomNumIntegerWithLimits(lower: -maxValue, upper: maxValue)
            performConnectCommon()
        }
    }
    
    func performConnectCommon() {
        currentText = RandomMaker.randomStringWithLength(randomTextLength)
        showNumber(value: currentNumber)
        showText(value: currentText)
        commonHandler?.requestSendNum(value:currentNumber)
        commonHandler?.requestSendText(value:currentText)
        imageHandler?.performRandomImage()
#if !NO_FILE_TRANSFER
        fileHandler?.performRandomFile()
#endif
    }
    
    func stopTimer() {
        if let timer = timer {
            timer.invalidate()
        }
        timerLabel.setHidden(true)
    }
    
    @objc func timerUpdate() {
        progressTimer =  progressTimer - progressDivider
        if progressTimer < 0 {
            progressTimer = randomRepeatSec
            currentNumber = RandomMaker.randomNumIntegerWithLimits(lower: -maxValue, upper: maxValue)
            performConnectCommon()
        }
        timerLabel.setText(String(format: "%02.02f/%02.02f", progressTimer, randomRepeatSec))
    }
    
    func startTimer() -> Bool {
        if let timer = timer, timer.isValid {
            timer.invalidate()
            timerLabel.setHidden(true)
            return false
        } else {
            progressTimer = randomRepeatSec
            timerLabel.setText(String(format: "%02.02f/%02.02f", progressTimer, randomRepeatSec))
            timer = Timer.scheduledTimer(timeInterval: progressDivider, target: self, selector: #selector(timerUpdate), userInfo: nil, repeats: true)
            timerLabel.setHidden(false)
            return true
        }
    }
    
    // WatchConnectManagerDelegate function
    func receiveStatusReachabilityDidChange(reachability: Bool) {
        showTitile()
    }
    
    // CommonHandlerDelegate function
    func responseNumber(value: Int) {
        currentNumber = value
        showNumber(value: value)
    }
    
    func responseText(value: String) {
        currentText = value
        showText(value: value)
    }
    
    // ImageHandlerDelegate function
    func showImage(image: Data) {
        DispatchQueue.main.async {
            self.imageView.setImage(UIImage(data: image))
        }
    }
    
    // FileHandlerDelegate function
    func showFileMessage(message: String) {
        DispatchQueue.main.async {
            self.fileLabel.setText(message)
        }
    }
    
    func showNumber(value: Int) {
        DispatchQueue.main.async {
            self.numLabel.setText(value.description)
        }
        showTitile()
#if NO_FILE_TRANSFER
        showFileMessage(message: "last update: " + dateformatter.string(from: Date()))
#endif
    }
    
    func showText(value: String) {
        DispatchQueue.main.async {
            self.RNDTextLabel.setText(value)
        }
        showTitile()
#if NO_FILE_TRANSFER
        showFileMessage(message: "last update: " + dateformatter.string(from: Date()))
#endif
    }

    
    func showTitile() {
        var reachMark = ""
        if let reach = WCMshare.sessionIsReachabie(),
            reach == true {
            reachMark = "*"
        }
        DispatchQueue.main.async {
#if APL_CONTEXT
            self.setTitle("AplContext" + reachMark)
#elseif TRNS_USERINFO
            self.setTitle("UserInfo" + reachMark)
#elseif INTRACT_MSG
            self.setTitle("SendMsg" + reachMark)
#else   // INTRACT_MSG with reply (default)
            self.setTitle("SendMsg w/reply" + reachMark)
#endif
        }
    }
}
