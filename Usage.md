
# WatchConnectManager

## Usage

### Sender side

1. Initialize WatchConnectManager  

  ```swift:
                              // Inheritance Protocol (use results of transfer)
  class ViewController: UIViewController, WatchConnectManagerDelegate {

      // WatchConnectManager instantiation (+shortening)
      let WatchConnectShared = WatchConnectManager.sharedConnectManager

      override func viewDidLoad() {
          super.viewDidLoad()

          // start WatchConnectivity session
          WatchConnectShared.startSession()

          // Register "self" to delegates (use results of transfer)
          WatchConnectShared.addWatchConnectManagerDelegate(delegate: self)
      }
  ```  

2. Data transfer

  ```swift:
  // AplContext
  WatchConnectShared.zUpdateApplicationContext("Command$$", addInfo:["My name is iOS."])

  // UserInfo
  WatchConnectShared.zTransferUserInfo("Command$$", addInfo: ["My name is iOS"])

  // SendMsg (omitted)
  WatchConnectShared.zSendInteractiveMessage("Command$$", addInfo: ["My name is iOS"])

  // SendMsg (w/ReplyHandler)
  WatchConnectShared.zSendInteractiveMessage("Command$$", addInfo: ["My name is iOS."], replyHandler: {  replyDict in
      NSLog("reply: \(replyDict)")
  })
  ```

  - The sending function, AplContext (`"zUpdateApplicationContext"`) and UserInfo (`"zTransferUserInfo"`) are the same format.
If you omit the reply handler with SendMessage (`"zSendInteractiveMessage"`), it will be in the same format.
(Refer to the WatchConnectManager method list).    
  - First argument "command" is the communication identifier (arbitrary string + "$$", in the example "Command$$").    
  - Second argument "addInfo" is the transfer data ("Any" type array). Stores an object of arbitrary type as an array element.      


3.  Transfer file

  ```swift:
  // FileTransfer
  WatchConnectShared.zTransferFile(url, command: "Command$$", addInfo:["NekoIsCat.jpg"])
  ```

  - Transfer file uses `"zTransferFile"` function.    
  - First argument is the Url of the file to be transferred.    
  - The format of command identifier and addInfo is the same as for data transfer.    


4.  Results of UserInfo or FileTransfer

  ```swift:
  // UserInfo
  func receiveUserInfoDidFinish(command:String, timeStamp:Date, subInfo:[String:Any], userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
      if command == "Command$$" {
        if let error = error {
          NSLog(\(#function): is error. \(error.localizedDescription)")
          } else {
            NSLog("\(#function): UserInfo complete")
        }
      }
    }

  // FileTransfer
  func receiveFileTransferDidFinish(command:String, timeStamp:Date, subInfo:[String:Any], fileTransfer: WCSessionFileTransfer, error: Error?) {
      if command == "Command$$" {
        if let error = error {
          NSLog("\(#function): is error. \(error.localizedDescription)")
          } else {
            let fileName = subInfo["Command$$00"] as! String
            NSLog("\(#function): File Transfer complete: \(fileName)")
          }
        }
      }
  ```

  - In UserInfo or FileTransfer, completion is delivered to the (sender side) delagete method (`"receiveUserInfoDidFinish"` and `"receiveFileTransferDidFinish"`).    
  - Sending error if "error" is not nil. Error can be judged with error.localizedDescription.    
  - For "command" identifier and "subInfo", see below.    

### Receiver side

1. Initialize WatchConnectManager  

  ```swift:
                                                    // Inheritance protocol
  class InterfaceController: WKInterfaceController, WatchConnectManagerDelegate {

      // WatchConnectManager instantiation (+shortening)
      let WatchConnectShared = WatchConnectManager.sharedConnectManager

      override func awake(withContext context: Any?) {
          super.awake(withContext: context)

          // start Watch Connectivity session
          WatchConnectShared.startSession()

          // Register "self" to delegates
          WatchConnectShared.addWatchConnectManagerDelegate(delegate: self)
      }
  ```  

2. Data transfer

  ```swift:
  //　WatchConnectManager DelegateMethod

  // AplContext
  func receiveApplicationContext(command:String, timeStamp:Date, subInfo:[String:Any]) {
    if command == "Command$$" {
      let string = subInfo["Command$$00"] as! String
      textLabel.setText(string)
    }
  }

  // UserInfo
  func receiveUserInfo(command:String, timeStamp:Date, subInfo:[String:Any]) {
    if command == "Command$$" {
      let string = subInfo["Command$$00"] as! String
      textLabel.setText(string)
    }
  }

  // SendMsg
  func receiveInteractiveMessage(command:String, timeStamp:Date, subInfo:[String:Any], replyHandler: @escaping ([String:Any]) -> Void) {
    if command == "Command$$" {
  	  let string = subInfo["Command$$00"] as! String
  		textLabel.setText(string)
      replyHandler(["Hello":"World", "I am":"watchOS"])
    }
  }
  ```

  - Receive data with the delagete method, corresponding to sending function.
  AplContext(`"receiveApplicationContext"`), UserInfo(`"receiveUserInfo"`), SendMessage(`"receiveInteractiveMessage"`).    
  - The receive method's AplContext and UserInfo have the same format.
  In SendMessage, a reply handler is added to the 4th argument (can not be omitted).    
  - First argument "command" determines the data addressed to itself with the communication identifier.
  If not, you will skip over. An example is "Command$$".    
  - Second argument "timeStamp" stores the transmission time.    
  - Third argument "subInfo" is the entity of the transfer data, and the array element of send "addInfo" is passed. "subInfo" is a dictionary type ([String:Any]). Key is command + "ArrayNumber".
  In the example it will be "Command$$00"..."Command$$99". Example above, "Command$$00" is used as the key and the file name is accessed.
  (Please see the demo "WCM_AddSubInfo" for the access manner of "subInfo" data type).    


3.  Transfer file
  ```swift:
  // FileTransfer
   receiveTransferFile(fileURL:URL, command:String, timeStamp:Date, subInfo:[String:Any], file: WCSessionFile) {
	 	if command == "Command$$" {
		    let fileName = subInfo["Command$$00"] as! String
        let path = fileURL.path
			  // ファイル操作
		 }
	 }
  ```

  - Use `"receiveTransferFile"` for the receive method.    
  - First argument "fileURL" is the received data file Url.
  However, WatchConnectManager copies the received file to a temporary file (tmp directory).
  (fileURL is not the original file received by the system).    
  - The format of command identifier, timeStamp, addInfo is the same for data transfer.    

-----------------------------

## WatchConnectManager method list

### Function

#### Sender

- zUpdateApplicationContext(_ command:String, addInfo:[Any]?) -> Bool    
- zTransferUserInfo(_ command:String, addInfo:[Any]?) -> WCSessionUserInfoTransfer?    
- zSendInteractiveMessage(_ command:String, addInfo:[Any]?, replyHandler: (([String:Any]) -> Void)? = nil , errorHandler: ((Error) -> Void)? = nil)  -> Bool    
- zTransferFile(_ file:URL, command:String, addInfo:[Any]?) -> WCSessionFileTransfer?    

#### Misc

- startSession() -> Bool    
- addWatchConnectManagerDelegate<T>(delegate: T)    
- removeWatchConnectManagerDelegate<T>(delegate: T)    
- hasTransferContentsPending() -> Bool?    
- sessionActivationState() -> WCSessionActivationState?    
- sessionIsReachabie() -> Bool?    
- outstandingUserInfoTransfers() -> [WCSessionUserInfoTransfer]?    
- outstandingFileTransfers() -> [WCSessionFileTransfer]?    

### Delagate method

#### Receiver

- receiveApplicationContext(command:String, timeStamp:Date, subInfo:[String:Any])    
- receiveUserInfo(command:String, timeStamp:Date, subInfo:[String:Any])    
- receiveInteractiveMessage(command:String, timeStamp:Date, subInfo:[String:Any], replyHandler: @escaping ([String:Any]) -> Void)    
- receiveTransferFile(fileURL:URL, command:String, timeStamp:Date, subInfo:[String:Any], file: WCSessionFile)    

#### Send result

- receiveUserInfoDidFinish(command:String, timeStamp:Date, subInfo:[String:Any], userInfoTransfer: WCSessionUserInfoTransfer, error: Error?)    
- receiveFileTransferDidFinish(command:String, timeStamp:Date, subInfo:[String:Any], fileTransfer: WCSessionFileTransfer, error: Error?)    


#### Connectivity status

- receiveStatusWatchStateDidChange(session : WCSession)     // iOS only    
- receiveStatusReachabilityDidChange(reachability: Bool)    

### Note

- All delegate methods are options.     
- "sendMessageData" is not supported.    
