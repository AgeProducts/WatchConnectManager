
# WatchConnectManager (can Multiple Delegates)

## 概要

`"Watch Connectivity framework"` 管理パッケージです。
Singletonかつ複数のDelegateをサポートしています。

**[Demo Pj: WCM_ConcurrentTransfer]**
![WCM_ConcurrentTransfer](./README-Files/02_WatchCntMgr02_Demo.gif)

### 特徴
  - 簡単に `"Watch Connectivityフレームワーク"` 機能が使用できます。
  - 送信ファンクションや受信メソッドのフォーマットが統一されている。通信手段の切り替え(実験)等が容易にできます。
  - `"Multiple Delegates"`のため、適度に制約がかかる。このため、安全で柔軟な設計が可能です。

### ToDo
  - (実機で)Watch側 Background機能確認ができていません。
  - 複数 Watchでの動作確認ができていません。
  - MulticastDelegates実装の正当性(特にメモリ管理)。解釈に大間違いはないと思いますが、、
  - 実アプリでの実績がありません + Demo Pjがダサい。

### その他
  - Watch Connectivityのサンプルコードは notificationによる実装が一般的です。
  複数(Multiple)Delegateをサポートする例はあまりありません。実装事例としてご参照ください。
  - 拙作 "WatchRealmSync"は、まだ WatchConnectManagerを使用していません。そのうちアップデートします。

## インストール
  - 対象の Xcode projectに`"Share module/WatchConnectManager.swift"`をドラグしてください。

## Example (WCM_TinySample)
  - データ転送(AplContext)とファイル転送(TransferFile)の例です。
  単方向(iOS -> watchOS)通信です。パッケージを使用した、最小限の実装です(エラーチェックなし)。
  - より詳しいパッケージ使用法は Usage-J.mdをご覧ください。

#### 送信側 (iOS)

```swift:ViewController.swift
import UIKit
class ViewController: UIViewController {

    // Instantiation (+shortening)
    let WatchConnectShared = WatchConnectManager.sharedConnectManager
    var url:URL?
    @IBOutlet weak var textLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        url = URL(fileURLWithPath:Bundle.main.path(forResource: "CatPhoto00", ofType: "jpg")!)

        // Start session
        WatchConnectShared.startSession()
    }

    // Sender
    @IBAction func sendButton(_ sender: Any) {
        // Send AplContext
        WatchConnectShared.zUpdateApplicationContext("AplCommand$$", addInfo:["My name is iOS.", Date()])
    }

    @IBAction func fileTansferButton(_ sender: Any) {
        // Send TransferFile
        WatchConnectShared.zTransferFile(url!, command: "FileCommand$$", addInfo:["CatPhoto00.jpg", Date()])
    }
}
```

#### 受信側 (watchOS)

```swift:InterfaceController.swift
import WatchKit
import WatchConnectivity
                                              // Inheritance protocol
class InterfaceController: WKInterfaceController, WatchConnectManagerDelegate {

    // Instantiation (+shortening)
    let WatchConnectShared = WatchConnectManager.sharedConnectManager

    @IBOutlet var textLabel: WKInterfaceLabel!
    @IBOutlet var imageView: WKInterfaceImage!

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        // Start session
        WatchConnectShared.startSession()

        // Set self to delegate
        WatchConnectShared.addWatchConnectManagerDelegate(delegate: self)
    }

    // Receiver AplContext
    func receiveApplicationContext(command:String, timeStamp:Date, subInfo:[String:Any]) {

        // Check with my "command"
        if command == "AplCommand$$" {

            // Get Zero'th argument, and 01 arg
            if let string = subInfo["AplCommand$$00"] as? String,
                let date = subInfo["AplCommand$$01"] as? Date {

                  // Note: Not in main thread
                  DispatchQueue.main.async {
                    self.textLabel.setText(string + "\n\(date)")
                    self.imageView.setImage(UIImage(named: "CatImage00.png"))
                }
            }
        }
    }

    // Receive TransferFile
    func receiveTransferFile(fileURL:URL, command:String, timeStamp:Date, subInfo:[String:Any], file:WCSessionFile) {
        if command == "FileCommand$$" {
            if let fileName = subInfo["FileCommand$$00"] as? String,
                let date = subInfo["FileCommand$$01"] as? Date {

                // Get file path
                let path = fileURL.path
                DispatchQueue.main.async {
                    self.textLabel.setText(fileName + "\n\(date)")

                    // Read data and show
                    self.imageView.setImage(UIImage(data: self.readFileWithData(path: path)!))
                }
            }
        }
    }
    // File Handler etc. : Omitted !
}
```

### 注意事項
  - delegateメソッドやリプライハンドラーは、一般にメインスレッドではありません。
  呼び先で UI更新などを行う場合は注意ください。
  - 登録された delegateは HashTable (weak objects)で保存します。
  インスタンスが破棄された場合、HashTableからも削除されます。
  このため deinit{}や didDeactivate()での "removeWatchConnectManagerDelegate"は不要のようです。

## デモプロジェクト
6種のサンプルを準備しました。Break point等で挙動とデータをご確認ください。

1. WCM_TinySample:    
  - Exampleのコードです。単方向(iOS -> watchOS)通信の最小限の実装です。　    
  - AplContextと TransferFileを行います。    

2. WCM_TinySample2:    
  - WCM_TinySampleの逆方向です。単方向(watchOS- > iOS)通信です。　    
  - SendMessage(w/Reply)と TransferFileを行います。    
  - SendMessageによる iOSバックグラウンド起動のテスト用です。    

3. WCM_MultiViewController:    
  -  Multiple Delegates (MulticastDelegates)テスト用です。    
  - iOSとwatchOSの各ページで、各種通信手段 (AplContext/UserInfo/SendMessage/FileTransfer) を行います。    

4. WCM_AddSubInfo:    
  - 複数のデータ型を addInfo/subInfoで授受するサンプルです。    
  - 各種通信手段(AplContext, UserInfo, SendMessage(w/Reply), FileTransfer)を実行します。    
  - 送信ファンクションと受信メソッドの互換性をご確認ください。    
  - 交換するデータ種は、Date, String, Int, Double, NSArray, NSDictionary, Data(小容量アイコンデータ)です。    
  - コードの "subInfoDecomp"で subInfoデータ取得作法をご確認ください。    

5. WCM_ConcurrentTransfer:    
	- 実アプリを意識した、混在環境でのデータ転送のデモです。複数のデータ(文字, 数字, 小容量画像データ(アイコンイメージ)、大容量データ(写真)を同時双方向で転送するデモアプリです。    
	- "＋/-" ボタンで表示数字に１加算/減算します。"RST"で0にします。同時にランダムな文字列、アイコンイメージ、写真データを一回送信します。"RND"ボタンで15秒ごとにランダムデータを送信します。    
	- PROJECTの Swiftフラグ(-D)に下記設定を行うことで、データ転送種類とFileTransferの有無が切り替えられます。    

      - PROJECT WCM_DataTransfer -> Build Setting, Swift Compiler - Custom Flag -> Other Swift Flags    
      - -DAPL_CONTEXT: AplContext    
      - -DTRNS_USERINFO: UserInfo    
      - -DINTRACT_MSG: SendMessage(省略形)    
      - なし(default): SendMessage(w/Reply)    
      - -DNO_FILE_TRANSFER: FileTransfer抑止    

![Swift option](./README-Files/01_SwiftOptionFlags.png)

6. WCM_Realm:    
  - Realm file転送のコードです。単方向(iOS -> watchOS)の実装です。　    
  - エラー対応などは、コメントアウト行を参照ください。      
  - WCM_Realmは "RealmSwift"を使用します(名前のとおり)。このサンプルでは、podを使用して Realmをインストールしてください。　　
     - $ cd WCM_Realm     
     - $ pod install     



## 環境
  - WatchConnectManagerは Xcode Version 9.4.1.で開発しました。
  - iOS 11.4.1 (iPhone7 実機), 11.4 (iOS simulator) と watchOS 4.3.2 (Series2 実機), 4.3 (watchOS simulator) で検証しています。

## 参考文献

下記ドキュメントを参照しています。    
知識とリソースの共有に感謝いたします。

1. 初期処理とセッション操作    
[NatashaTheRobot / WatchConnectivitySingletonDemo.swift](https://gist.github.com/NatashaTheRobot/6bcbe79afd7e9572edf6)    
I was inspired by this Gist.    

2. Multiple Delegates    
[Multicast Delegates in Swift](http://www.gregread.com/2016/02/23/multicast-delegates-in-swift/)    
[Multicast Delegate and Delegates Composition](http://www.vadimbulavin.com/multicast-delegate/)    
[NSHashTableでDelegatesパターン](https://www.slideshare.net/jstarfruits/nshashtabledelegates)    

3. Code (Apple's sample)    
[QuickSwitch: Supporting Quick Watch Switching with WatchConnectivity](https://developer.apple.com/library/archive/samplecode/QuickSwitch/Introduction/Intro.html)    
[SimpleWatchConnectivity: Using the Watch Connectivity API](https://developer.apple.com/library/archive/samplecode/SimpleWatchConnectivity/Introduction/Intro.html#//apple_ref/doc/uid/TP40017663-Intro-DontLinkElementID_2)    

4. Illustration / photo image    
[かわいいフリー素材集 いらすとや](https://www.irasutoya.com)    
[Satoshi村 著作権フリーの写真](http://satoshi3.sakura.ne.jp/f_photo/f_photo.htm)    

## Author

Takuji Hori,    
agepro60@gmail.com

## License

"WatchConnectManager" is available under the MIT license. See the LICENSE file for more info.
