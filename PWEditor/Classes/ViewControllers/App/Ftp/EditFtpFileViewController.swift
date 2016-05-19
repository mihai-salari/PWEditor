//
//  EditFtpFileViewController.swift
//  PWEditor
//
//  Created by mfuta1971 on 2016/05/18.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import UIKit
import GoogleMobileAds

/**
 FTPファイル編集画面

 - Version: 1.0 新規作成
 - Author: paveway.info@gmail.com
 */
class EditFtpFileViewController: BaseViewController, UITextViewDelegate, BRRequestDelegate {

    // MARK: - Variables

    /// Myビュー
    @IBOutlet weak var myView: MyView!

    /// バナービュー
    @IBOutlet weak var bannerView: GADBannerView!

    /// FTPダウンロード処理
    private var ftpDownload: BRRequestDownload?

    /// FTPダウンロードデータ
    private var ftpDownloadData: NSMutableData?

    /// FTPアップロード処理
    private var ftpUpload: BRRequestUpload?

    /// FTPアップロードデータ
    private var ftpUploadData: NSData?

    /// FTPホスト情報
    private var ftpHostInfo: FtpHostInfo!

    /// パス名
    private var pathName: String!

    /// FTPファイル情報
    private var ftpFileInfo: NSDictionary!

    /// ファイルデータ
    private var fileData: NSData!

    /// 文字エンコーディングタイプ
    private var encodingType: Int!

    /// 文字エンコーディング
    private var encoding: UInt!

    /// 改行コードタイプ
    private var retCodeType: Int!

    /// プレオフセット
    private var preOffset: CGPoint?

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

     - Parameter ftpHostInfo: FTPホスト情報
     - Parameter pathName: パス名
     - Parameter ftpFileInfo: ftpFileInfo
     - Parameter fileData: ファイルデータ(デフォルト空文字列)
     - Parameter encodingType: 文字エンコーディングタイプ(デフォルト"UTF-8")
     - Parameter retCodeType: 改行コードタイプ(デフォルト"Unix(LF)")
     */
    init(ftpHostInfo: FtpHostInfo, pathName: String, ftpFileInfo: NSDictionary, fileData: NSData? = nil, encodingType: Int = CommonConst.EncodingType.Utf8.rawValue, retCodeType: Int = CommonConst.RetCodeType.LF.rawValue) {
        // 引数を保存する。
        self.ftpHostInfo = ftpHostInfo
        self.pathName = pathName
        self.ftpFileInfo = ftpFileInfo
        self.encodingType = encodingType
        self.retCodeType = retCodeType
        self.fileData = fileData
        self.encoding = CommonConst.EncodingList[self.encodingType]

        // スーパークラスのイニシャライザを呼び出す。
        super.init(nibName: nil, bundle: nil)
    }

    // MARK: - UIViewController

    /**
     インスタンスが生成された時に呼び出される。
     */
    override func viewDidLoad() {
        // スーパークラスのメソッドを呼び出す。
        super.viewDidLoad()

        // 画面タイトルを設定する。
        let fileName = FtpFileInfoUtils.getName(ftpFileInfo)
        navigationItem.title = fileName

        // 右上ボタンを設定する。
        createRightBarButton()
        if fileData == nil {
            // FTPダウンロードする場合
            // 右上バーボタンを無効にする。
            navigationItem.rightBarButtonItem?.enabled = false

            // FTPファイルダウンロードを行う。
            downloadFtpFile()

        } else {
            // FTPダウンロードしない場合
            // 右上バーボタンを有効にする。
            navigationItem.rightBarButtonItem?.enabled = true

            let text = String(data: fileData, encoding: NSUTF8StringEncoding)
            if text == nil {
                // 文字列に変換できない場合
                // エラーアラートを表示する。
                let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
                let message = LocalizableUtils.getString(LocalizableConst.kAlertMessageCovertEncodingError)
                self.showAlert(title, message: message) {
                    // 遷移元画面に戻る。
                    self.navigationController?.popViewControllerAnimated(true)
                }
                return
            }

            // データを表示する。
            self.myView.textView.text = text
        }

        // テキストビューを設定する。
        listNumber = 0
        setupTextView()
        let selector = #selector(EditDropboxFileViewController.textChanged(_:))
        NSNotificationCenter.defaultCenter().addObserver(self, selector: selector, name: UITextViewTextDidChangeNotification, object: nil)
        myView.textView.delegate = self

        // テキストビューがキーボードに隠れないための処理
        // 参考 : https://teratail.com/questions/2915
        let notificationCenter = NSNotificationCenter.defaultCenter()
        let keyboardWillShow = #selector(EditDropboxFileViewController.keyboardWillShow(_:))
        notificationCenter.addObserver(self, selector: keyboardWillShow, name: UIKeyboardWillShowNotification, object: nil)
        let keyboardWillHide = #selector(EditDropboxFileViewController.keyboardWillHide(_:))
        notificationCenter.addObserver(self, selector: keyboardWillHide, name: UIKeyboardWillHideNotification, object: nil)
        let keyboardDidHide = #selector(EditDropboxFileViewController.keyboardDidHide(_:))
        notificationCenter.addObserver(self, selector: keyboardDidHide, name: UIKeyboardDidHideNotification, object: nil)

        // バナービューを設定する。
        setupBannerView(bannerView)
    }

    /**
     メモリ不足の時に呼び出される。
     */
    override func didReceiveMemoryWarning() {
        LogUtils.w("memory error.")

        // スーパークラスのメソッドを呼び出す。
        super.didReceiveMemoryWarning()
    }

    // MARK: - UITextViewDelegate

    /**
     テキストが変更された時に呼び出される。

     - Parameter notification: 通知
     */
    func textChanged(notification: NSNotification?) -> (Void) {
    }

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
        // TODO: 暫定で拡張キーボードを表示しない。
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

    // MARK: - Bar Button

    /**
     右上ボタンを押下された時に呼び出される。

     - Parameter sender: 押下されたボタン
     */
    override func rightBarButtonPressed(sender: UIButton) {
        // キーボードを閉じる。
        myView.textView.resignFirstResponder()

        // FTPファイルをアップロードする。
        uploadFtpFile()
    }

    // MARK: - FTP

    /**
     FTPファイルをダウンロードする。
     */
    private func downloadFtpFile() {
        // FTPダウンロード処理を生成する。
        ftpDownload = BRRequestDownload(delegate: self)
        if ftpDownload == nil {
            return
        }

        // 処理中アラートを表示する。
        showProcessingAlert() {
            // FTPファイルのダウンロードを開始する。
            self.ftpDownloadData = NSMutableData()

            self.ftpDownload!.hostname = self.ftpHostInfo.hostName
            self.ftpDownload!.username = self.ftpHostInfo.userName
            self.ftpDownload!.password = self.ftpHostInfo.password
            let fileName = FtpFileInfoUtils.getName(self.ftpFileInfo)
            let path = FtpUtils.getPath(self.pathName, name: fileName)
            self.ftpDownload!.path = path

            self.ftpDownload!.start()
        }
    }

    /**
     FTPファイルをアップロードする。
 
     - Parameter fileData: ファイルデータ
     */
    private func uploadFtpFile() {
        // FTPアップロード処理を生成する。
        ftpUpload = BRRequestUpload(delegate: self)
        if ftpUpload == nil {
            return
        }

        // 処理中アラートを表示する。
        showProcessingAlert() {
            // FTPファイルのダウンロードを開始する。
            // ファイルデータを取得する。
            let fileData = self.myView.textView.text
            // 改行コードを変換する。
            let convertedFileData = FileUtils.convertRetCode(fileData, encoding: self.encoding, retCodeType: self.retCodeType)
            self.ftpUploadData = convertedFileData.dataUsingEncoding(self.encoding)

            self.ftpUpload!.hostname = self.ftpHostInfo.hostName
            self.ftpUpload!.username = self.ftpHostInfo.userName
            self.ftpUpload!.password = self.ftpHostInfo.password
            let fileName = FtpFileInfoUtils.getName(self.ftpFileInfo)
            let path = FtpUtils.getPath(self.pathName, name: fileName)
            self.ftpUpload!.path = path

            self.ftpUpload!.start()
        }
    }

    // MARK: - MBRequestDelegate

    /**
     リクエストが完了した時に呼び出される。

     - Parameter request: リクエスト
     */
    func requestCompleted(request: BRRequest) {
        // ネットワークアクセス通知を消す。
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false

        if request == ftpDownload {
            // FTPダウンロード処理の場合
            // 処理中アラートを閉じる。
            dismissProcessingAlert() {
                // FTPダウンロード処理をクリアする。
                self.ftpDownload = nil

                if !FileUtils.isTextData(self.ftpDownloadData!) {
                    // テキストデータではない場合
                    // エラーアラートを表示する。
                    let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
                    let message = LocalizableUtils.getString(LocalizableConst.kAlertMessageNotTextFileError)
                    self.showAlert(title, message: message) {
                        // 遷移元画面に戻る。
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                    return
                }

                // FTPダウンロードデータを文字列に変換する。
                let text = String(data: self.ftpDownloadData!, encoding: NSUTF8StringEncoding)
                if text == nil {
                    // 文字列に変換できない場合
                    // エラーアラートを表示する。
                    let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
                    let message = LocalizableUtils.getString(LocalizableConst.kAlertMessageCovertEncodingError)
                    self.showAlert(title, message: message) {
                        // 遷移元画面に戻る。
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                    return
                }

                // データを表示する。
                self.myView.textView.text = text

                // 右上バーボタンを有効にする。
                self.navigationItem.rightBarButtonItem?.enabled = true
            }

        } else if ftpUpload != nil && request == ftpUpload! {
            // FTPアップロード処理の場合
            // 処理中アラートを閉じる。
            // 処理中アラートを閉じる。
            dismissProcessingAlert() {
                // FTPアップロード処理をクリアする。
                self.ftpUpload = nil

                // 遷移元画面に戻る。
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
    }

    /**
     リクエストが失敗した時に呼び出される。

     - Parameter request: リクエスト
     */
    func requestFailed(request: BRRequest) {
        // ネットワークアクセス通知を消す。
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false

        if request == ftpDownload {
            // FTPダウンロード処理の場合
            // 処理中アラートを閉じる。
            dismissProcessingAlert() {
                // FTPダウンロード処理をクリアする。
                self.ftpDownload = nil

                // エラーアラートを表示する。
                let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
                let errorCode = String(request.error.errorCode.rawValue)
                let errorMessage = request.error.message
                let message = LocalizableUtils.getStringWithArgs(LocalizableConst.kAlertMessageGetFileListError, errorCode, errorMessage)
                self.showAlert(title, message: message) {
                    // 遷移元画面に戻る。
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }

        } else if request == ftpUpload {
            // FTPアップロード処理の場合
            // 処理中アラートを閉じる。
            dismissProcessingAlert() {
                // FTPアップロード処理をクリアする。
                self.ftpUpload = nil

                // エラーコードを取得する。
                let errorCode = request.error.errorCode
                if errorCode == kBRFTPServerAbortedTransfer {
                    // サーバ切断の場合は正常終了とみなす。
                    // 遷移元画面に戻る。
                    self.navigationController?.popViewControllerAnimated(true)
                    return
                }

                // エラーアラートを表示する。
                let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
                let errorCodeString = String(errorCode.rawValue)
                let errorMessage = request.error.message
                let message = LocalizableUtils.getStringWithArgs(LocalizableConst.kAlertMessageGetFileListError, errorCodeString, errorMessage)
                self.showAlert(title, message: message) {
                    // 遷移元画面に戻る。
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }
        }
    }

    /**
     上書きリクエスト時に呼び出される。

     - Parameter request: リクエスト
     */
    func shouldOverwriteFileWithRequest(request: BRRequest) -> Bool {
        if request == ftpUpload {
            return true

        } else {
            return false
        }
    }

    /**
     データを受信した時に呼び出される。

     - Parameter request: ダウンロード要求
     */
    func requestDataAvailable(request: BRRequestDownload) {
        // 受信したデータを保存する。
        ftpDownloadData!.appendData(request.receivedData)
    }

    /**
     アップロードデータを送信する。

     - Parameter request: リクエスト
     - Returns: アップロードデータ
     */
    func requestDataToSend(request: BRRequestUpload) -> NSData? {
        if ftpUploadData == nil {
            return nil

        } else {
            let temp = ftpUploadData!
            ftpUploadData = nil
            return temp
        }
    }
}
