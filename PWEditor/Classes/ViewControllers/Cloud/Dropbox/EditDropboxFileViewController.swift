//
//  EditDropboxFileViewController.swift
//  PWEditor
//
//  Created by 二俣征嗣 on 2016/03/02.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import UIKit
import GoogleMobileAds
import SwiftyDropbox

class EditDropboxFileViewController: BaseViewController, UITextViewDelegate {

    // MARK: - Variables

    /// Myビュー
    @IBOutlet weak var myView: MyView!

    /// バナービュー
    @IBOutlet weak var bannerView: GADBannerView!

    /// パス名
    var pathName: String!

    /// ファイル名
    var fileName: String!

    /// 文字エンコーディングタイプ
    var encodingType: Int!

    /// 文字エンコーディング
    var encoding: UInt!

    /// 改行コードタイプ
    var retCodeType: Int!

    /// ダウンロード用Dropboxファイル情報
    var downloadFileInfo: DropboxFileInfo?

    /// ダウンロード先ローカルファイルパス名
    var loacalFilePathName: String?

    /// プレオフセット
    var preOffset: CGPoint?

    /// テキスト変更フラグ
    var textChanged = false

    // MARK: - Initializer

    /**
    イニシャライザ

    - parameter coder: デコーダー
    */
    required init?(coder aDecoder: NSCoder) {
        // スーパークラスのイニシャライザを呼び出す。
        super.init(coder: aDecoder)
    }

    /**
     イニシャライザ

     - Parameter pathName: パス名
     - Parameter fileName: ファイル名
     - Parameter encodingType: 文字エンコーディングタイプ(デフォルト"UTF-8")
     - Parameter retCodeType: 改行コードタイプ(デフォルト"Unix(LF)")
     */
    init(pathName: String, fileName: String, encodingType: Int = CommonConst.EncodingType.Utf8.rawValue, retCodeType: Int = CommonConst.RetCodeType.LF.rawValue) {
        // 引数を保存する。
        self.pathName = pathName
        self.fileName = fileName
        self.encodingType = encodingType
        self.retCodeType = retCodeType
        self.encoding = CommonConst.EncodingList[self.encodingType]

        // スーパークラスのイニシャライザを呼び出す。
        super.init(nibName: nil, bundle: nil)
    }

    // MARK: - UIViewDelegate

    /**
     インスタンスが生成された時に呼び出される。
     */
    override func viewDidLoad() {
        // スーパークラスのメソッドを呼び出す。
        super.viewDidLoad()

        // 画面タイトルを設定する。
        navigationItem.title = fileName

        // 右上ボタンを設定する。
        createRightBarButton()

        // テキストビューを設定する。
        listNumber = 0
        setupTextView()
        let selector = Selector("textChanged:")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: selector, name: UITextViewTextDidChangeNotification, object: nil)
        myView.textView.delegate = self

        // バナービューを設定する。
        setupBannerView(bannerView)

        // テキストビューがキーボードに隠れないための処理
        // 参考 : https://teratail.com/questions/2915
        let notificationCenter = NSNotificationCenter.defaultCenter()
        let keyboardWillShow = Selector("keyboardWillShow:")
        notificationCenter.addObserver(self, selector: keyboardWillShow, name: UIKeyboardWillShowNotification, object: nil)
        let keyboardWillHide = Selector("keyboardWillHide:")
        notificationCenter.addObserver(self, selector: keyboardWillHide, name: UIKeyboardWillHideNotification, object: nil)
        let keyboardDidHide = Selector("keyboardDidHide:")
        notificationCenter.addObserver(self, selector: keyboardDidHide, name: UIKeyboardDidHideNotification, object: nil)
    }

    /**
     メモリ不足の時に呼び出される。
     */
    override func didReceiveMemoryWarning() {
        LogUtils.w("memory error.")

        // スーパークラスのメソッドを呼び出す。
        super.didReceiveMemoryWarning()
    }

    /**
     画面が表示される前に呼び出される。

     - Parameter animated: アニメーション指定
     */
    override func viewWillAppear(animated: Bool) {
        // スーパークラスのメソッドを呼び出す。
        super.viewWillAppear(animated)

        // 右バーボタンはデフォルト無効にする。
        self.navigationItem.rightBarButtonItem?.enabled = false
        loacalFilePathName = nil

        // Dropboxファイルをダウンロードする。
        downloadFile()
    }

    /**
     画面が閉じる前に呼び出される。
     
     - Parameter animated: アニメーション指定
     */
    override func viewWillDisappear(animated: Bool) {
        // 通知設定を解除する。
        // 画面遷移開始後は処理できないため、このタイミングで行う。
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)

        if loacalFilePathName != nil && !loacalFilePathName!.isEmpty {
            // ダウンロード用ローカルファイルが存在する場合、削除する。
            FileUtils.remove(loacalFilePathName!)
            loacalFilePathName = nil
        }

        // 戻るボタンが押下されたかチェックする。
        if let viewControllers = self.navigationController?.viewControllers {
            var existsSelfInViewControllers = true
            for viewController in viewControllers {
                // viewWillDisappearが呼ばれる時に、
                // 戻る処理を行っていれば、NavigationControllerのviewControllersの中にselfは存在していない
                if viewController == self {
                    existsSelfInViewControllers = false
                    // selfが存在した時点で処理を終える
                    break
                }
            }

            if existsSelfInViewControllers {
                // 戻るボタンが押下された場合
                if textChanged {
                    // テキストが変更されている場合
                    // 確認アラートを表示する。
                    // TODO: 確認アラートが表示される前に画面遷移してしまう。
                    showAlert("確認", message: "データが変更されています。保存しますか。", okButtonTitle: "保存", handler: { () -> Void in
                    })
                }
            }
        }

        // スーパークラスのメソッドを呼び出す。
        super.viewWillDisappear(animated)
    }

    // MARK: - Button Handler

    /**
    右上ボタンを押下された時に呼び出される。

    - Parameter sender: 押下されたボタン
    */
    override func rightBarButtonPressed(sender: UIButton) {
        // キーボードを閉じる。
        myView.textView.resignFirstResponder()

        // ファイルデータを取得する。
        let fileData = myView.textView.text

        // 改行コードを変換する。
        let convertedFileData = FileUtils.convertRetCode(fileData, encoding: encoding, retCodeType: retCodeType)

        // 変換されたファイルデータをアップロードする。
        uploadFile(convertedFileData)
    }

    // MARK: - UITextViewDelegate

    /**
    テキストが変更された時に呼び出される。

    - Parameter notification: 通知
    */
    func textChanged(notification: NSNotification?) -> (Void) {
        textChanged = true
    }

    // MARK: - Private Method

    /**
    テキストフィールドを設定する。
    */
    private func setupTextView() {
        // 対象のビューを設定する。
        targetView = myView.textView

        // データを設定する。
        //myView.textView.text = data

        // キーボードタイプを設定する。
        //myView.textView.keyboardType = keyboardType

        // フォントを設定する。
        let fontName = EnvUtils.getEnterDataFontName()
        let fontSize = EnvUtils.getEnterDataFontSize()
        myView.textView.font = UIFont(name: fontName, size: fontSize)

        // 拡張キーボードを生成する。
        let extendKeyboardItems = createExtendKeyboardItems(listNumber)
        let extendKeyboard = createExtendKeyboard()
        extendKeyboard.setItems(extendKeyboardItems, animated: false)
        myView.textView.inputAccessoryView = extendKeyboard
    }

    // MARK: - Notification handler

    /**
    キーボードが表示される時に呼び出される。

    - Parameter notification: 通知
    */
    func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let size = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue().size

        var contentInsets = UIEdgeInsetsMake(0.0, 0.0, size.height, 0.0)
        contentInsets = myView.textView.contentInset
        contentInsets.bottom = size.height

        myView.textView.contentInset = contentInsets
        myView.textView.scrollIndicatorInsets = contentInsets
    }

    /**
     キーボードが閉じる時に呼び出される。

     - Parameter notification: 通知
     */
    func keyboardWillHide(notification: NSNotification) {
        var contentsInsets = myView.textView.contentInset
        contentsInsets.bottom = 0
        myView.textView.contentInset = contentsInsets
        myView.textView.contentInset.bottom = 0
        preOffset = myView.textView.contentOffset
    }

    /**
     キーボードが閉じた後に呼び出される。

     - Parameter notification: 通知
     */
    func keyboardDidHide(notification: NSNotification) {
        if preOffset != nil {
            myView.textView.setContentOffset(preOffset!, animated: true)
        }
    }

    // MARK: - Dropbox

    /**
     Dropboxファイルをダウンロードする。

     - Parameter pathName: パス名
     - Parameter fileName: ファイル名
     */
    func downloadFile() {
        let client = Dropbox.authorizedClient
        if client == nil {
            // Dropboxが無効な場合
            // 画面構成をリセットする。
            resetScreen()
            return
        }

        // ダウンロード先URLを取得する。
        let destination : (NSURL, NSHTTPURLResponse) -> NSURL = { temporaryURL, response in
            let fileManager = NSFileManager.defaultManager()
            let directoryURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
            // generate a unique name for this file in case we've seen it before
            let UUID = NSUUID().UUIDString
            let pathComponent = "\(UUID)-\(response.suggestedFilename!)"
            return directoryURL.URLByAppendingPathComponent(pathComponent)
        }

        // Dropboxファイルをダウンロードする。
        let filePathName = "\(pathName)/\(fileName)"
        client!.files.download(path: filePathName, destination: destination).response { response, error in
            if error != nil || response == nil {
                // エラーの場合
                // エラーアラートを表示する。
                let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
                let message = LocalizableUtils.getStringWithArgs(LocalizableConst.kEditDropboxFileDownloadError, filePathName)
                self.showAlert(title, message: message, handler: nil)
                return
            }

            if let (metadata, url) = response {
                // ファイル属性情報を取得する。
                if metadata.dynamicType != Files.FileMetadata.self {
                    // ファイル属性情報ではない場合
                    // エラーアラートを表示する。
                    let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
                    let message = LocalizableUtils.getStringWithArgs(LocalizableConst.kEditDropboxFileDownloadError, filePathName)
                    self.showAlert(title, message: message, handler: nil)
                    return
                }
                let fileMetadata = metadata as Files.FileMetadata
                self.downloadFileInfo = DropboxFileInfo()
                self.downloadFileInfo!.id = fileMetadata.id!
                self.downloadFileInfo!.name = fileMetadata.name
                self.downloadFileInfo!.pathLower = fileMetadata.pathLower
                self.downloadFileInfo!.size = String(fileMetadata.size)
                self.downloadFileInfo!.rev = fileMetadata.rev
                self.downloadFileInfo!.serverModified = fileMetadata.serverModified
                self.downloadFileInfo!.clientModified = fileMetadata.clientModified

                // 画面遷移後の削除用にローカルファイルパス名を取得する。
                self.loacalFilePathName = url.path

                // ファイルデータを取得する。
                let fileData = NSData(contentsOfURL: url)
                
                var text: String?
                if fileData == nil {
                    // ファイルデータが取得できない場合
                    let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
                    let message = LocalizableUtils.getString(LocalizableConst.kAlertMessageGetFileDataError)
                    self.showAlert(title, message: message, handler: { () -> Void in
                        self.popViewController()
                    })

                } else {
                    // ファイルデータが取得できた場合
                    if FileUtils.isTextData(fileData!) {
                        // テキストデータの場合
                        // 文字列に変換する。
                        text = String(data: fileData!, encoding: self.encoding)
                        if text == nil {
                            // 文字列に変換できない場合
                            let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
                            let message = LocalizableUtils.getString(LocalizableConst.kAlertMessageCovertEncodingError)
                            self.showAlert(title, message: message, handler: { () -> Void in
                                self.popViewController()
                            })

                        } else {
                            // 文字列に変換できた場合
                            self.navigationItem.rightBarButtonItem?.enabled = true

                            // ファイルデータをテキストビューに設定する。
                            let winRetCode: [CChar] = [13, 10]
                            let winRetCodeString = String(winRetCode)
                            self.myView.textView.text = text!
                        }

                    } else {
                        let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
                        let message = LocalizableUtils.getString(LocalizableConst.kAlertMessageNotTextFileError)
                        self.showAlert(title, message: message, handler: { () -> Void in
                            self.popViewController()
                        })
                    }
                }
            }
        }
    }

    /**
     ファイルデータをDropboxファイルにアップロードする。

     - Parameter pathName: パス名
     - Parameter fileName: ファイル名
     */
    func uploadFile(fileDataString: String) {
        let client = Dropbox.authorizedClient
        if client == nil {
            // Dropboxが無効な場合
            // 画面構成をリセットする。
            resetScreen()
            return
        }

        // ファイルデータをアップロードする。
        let filePathName = "\(pathName)/\(fileName)"
        let fileData = fileDataString.dataUsingEncoding(encoding, allowLossyConversion: false)
        let rev = downloadFileInfo!.rev
        let date = NSDate()
        client!.files.upload(path: filePathName, mode: .Update(rev), clientModified: date, body: fileData!).response { response, error in
            if error != nil || response == nil {
                // エラーの場合
                // エラーアラートを表示する。
                let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
                let message = LocalizableUtils.getStringWithArgs(LocalizableConst.kEditDropboxFileUpdloadError, filePathName)
                self.showAlert(title, message: message, handler: nil)
                return
            }

            // 遷移元画面に戻る。
            self.popViewController()
        }
    }

    // MARK: - Private method

    /**
     遷移元画面に戻る。
     文字エンコーディング選択画面から遷移した場合、Dropboxファイル一覧画面に戻るための対応
     */
    func popViewController() {
        // 画面遷移数を取得する。
        let count = navigationController?.viewControllers.count
        // 最後に表示した画面から画面遷移数確認する。
        for var i = count! - 1; i >= 0; i-- {
            let vc = navigationController?.viewControllers[i]
            if vc!.dynamicType == DropboxFileListViewController.self {
                // 表示した画面がDropboxファイル一覧画面の場合
                // 画面を戻す。
                navigationController?.popToViewController(vc!, animated: true)
                break
            }
        }
    }
}
