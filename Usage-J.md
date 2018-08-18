
# WatchConnectManager

## 使用法

### Sender (送信側)

1. WatchConnectManager初期化  

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

2. データ転送

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
  - 送信ファンクション、AplContext(`"zUpdateApplicationContext"`)と UserInfo(`"zTransferUserInfo"`)は同一フォーマットです。
SendMessage(`"zSendInteractiveMessage"`)でリプライハンドラーを省略した場合も同一フォーマットになります。
(WatchConnectManager method listを参照してください)。
  - 第１引数 "command"は通信識別子です(任意文字列+"$$"、例では"Command$$")。
  - 第２引数 "addInfo"が転送データ("Any"型配列)です。配列要素として任意の objectを格納します。


3.  ファイル転送

  ```swift:
  // FileTransfer
  WatchConnectShared.zTransferFile(url, command: "Command$$", addInfo:["NekoIsCat.jpg"])
  ```
  - Transfer fileでは、`"zTransferFile"`を使用します。
  - 第１引数は転送するファイルのUrlです。  
  - command識別子と addInfoの書式はデータ転送に同じです。


4.  UserInfo または FileTransfer 送信完了通知

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
  - UserInfoと FileTransferでは、(送信側)delageteメソッド(`"receiveUserInfoDidFinish"`/`"receiveFileTransferDidFinish"`)に送信完了が届きます。
  - "error"が nilでない場合は送信エラーです。error.localizedDescriptionでエラー判定できます。
  - command識別子と subInfoについては下記を参照ください。

### Receiver (受信側)

1. WatchConnectManager初期化  

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

2. データ転送

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
  - 送信ファンクションに対応した delageteメソッドでデータを受信します。
  AplContext(`"receiveApplicationContext"`), UserInfo(`"receiveUserInfo"`), SendMessage(`"receiveInteractiveMessage"`)です。
  - 受信メソッドの、AplContextと UserInfoは同一フォーマットです。SendMessageでは第４引数にリプライハンドラーが追加されます(省略不可)。
  - 第１引数 "command" は通信識別子で自分宛データを判定します。異なれば読み飛ばします。例では "Command$$" です。
  - 第２引数 "timeStamp" には送信時刻が格納されます。
  - 第３引数 "subInfo" が転送データの実体で、送信 addInfoの配列要素が渡されます。subInfoは辞書型 ([String:Any])です。
  keyは command+"配列番号" です。例では "Command$$00"..."Command$$99"となります。上記例では "Command$$00"を keyに、ファイル名をアクセスしています。
  (subInfoのデータ型のアクセス作法は、デモアプリ WCM_AddSubInfoを参照ください)。


3.  ファイル転送

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
  - 受信メソッドに`"receiveTransferFile"`を使用します。
	- 第１引数 "fileURL" は受信データファイル Urlです。
  ただし WatchConnectManagerは受信ファイルを、一時ファイル(tmpディレクトリー)にコピーしています。
  (fileURLはシステムが受信したオリジナルファイルではありません)。
  - command識別子、timeStamp、addInfoのフォーマットはデータ転送に同じです。

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
