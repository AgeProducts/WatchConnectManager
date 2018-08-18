//
//  ViewController.swift
//  WCM_ConcurrentTransfer
//
//  Created by Takuji Hori on 2018/07/31.
//  Copyright © 2018 Takuji Hori. All rights reserved.
//

//import UIKit
import WatchKit
import WatchConnectivity

class ViewController: UIViewController, WatchConnectManagerDelegate, CommonHandlerDelegate, ImageHandlerDelegate, FileHandlerDelegate {
    
    @IBOutlet weak var numLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var RNDTextLabel: UILabel!
    
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var randomButton: UIButton!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var fileLabel: UILabel!
    
    @IBOutlet weak var progressBar: UIProgressView!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func plusButtonAct(_ sender: Any) {
        stopTimer()
        var value = currentNumber + 1
        if value > maxValue {
            value = maxValue
        }
        currentNumber = value
        performConnectCommon()
    }

    @IBAction func minusButtonAct(_ sender: Any) {
        stopTimer()
        var value = currentNumber - 1
        if value < -maxValue {
            value = -maxValue
        }
        currentNumber = value
        performConnectCommon()
    }
    
    @IBAction func resetButtonAct(_ sender: Any) {
        stopTimer()
        currentNumber = 0
        performConnectCommon()
    }

    @IBAction func randomButtonAct(_ sender: Any) {
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
        progressBar.isHidden = true
    }
    
    @objc func timerUpdate() {
        progressTimer =  progressTimer - progressDivider
        if progressTimer < 0 {
            progressTimer = randomRepeatSec
            currentNumber = RandomMaker.randomNumIntegerWithLimits(lower: -maxValue, upper: maxValue)
            performConnectCommon()
        }
        progressBar.progress = Float(progressTimer / randomRepeatSec)
    }
    
    func startTimer() -> Bool {
        if let timer = timer, timer.isValid {
            timer.invalidate()
            progressBar.isHidden = true
            return false
        } else {
            progressTimer = randomRepeatSec
            progressBar.progress = Float(progressTimer / randomRepeatSec)
            timer = Timer.scheduledTimer(timeInterval: progressDivider, target: self, selector: #selector(timerUpdate), userInfo: nil, repeats: true)
            progressBar.isHidden = false
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
            self.imageView.image = UIImage(data: image)
        }
    }
    
   // FileHandlerDelegate function
    func showFileMessage(message: String) {
        DispatchQueue.main.async {
            self.fileLabel.text = message
        }
    }
    
    func showNumber(value: Int) {
        DispatchQueue.main.async {
            self.numLabel.text = value.description
        }
        showTitile()
#if NO_FILE_TRANSFER
        showFileMessage(message: "last update: " + dateformatter.string(from: Date()))
#endif
    }

    func showText(value: String) {
        DispatchQueue.main.async {
            self.RNDTextLabel.text = value
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
            self.titleLabel.text = "AplContext" + reachMark
#elseif TRNS_USERINFO
            self.titleLabel.text = "UserInfo" + reachMark
#elseif INTRACT_MSG
            self.titleLabel.text = "SendMsg" + reachMark
#else   // INTRACT_MSG with reply (default)
            self.titleLabel.text = "SendMsg w/reply" + reachMark
#endif
        }
    }
}

