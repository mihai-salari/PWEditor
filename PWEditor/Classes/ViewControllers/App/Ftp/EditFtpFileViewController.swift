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
class EditFtpFileViewController: BaseEditViewController, BRRequestDelegate {

    // MARK: - Variables

    /// 編集ビュー
    @IBOutlet weak var editView: UIView!

    /// ツールバー
    @IBOutlet weak var toolbar: UIToolbar!

    /// ツールバーボタン
    @IBOutlet weak var previewToolbarButton: UIBarButtonItem!

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

        // テキストビューを設定する。
        let toolbarHeight = toolbar.frame.height
        let bannerViewHeight = bannerView.frame.height
        let heightOffset = toolbarHeight + bannerViewHeight
        createTextView(editView, fileName: fileName, heightOffset: heightOffset)

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
            textView.text = text
        }

        // プレビューツールバーボタンを設定する。
        let previewFileType = FileUtils.getPreviewFileType(fileName)
        if previewFileType == CommonConst.PreviewFileType.HTML.rawValue ||
            previewFileType == CommonConst.PreviewFileType.Markdown.rawValue {
            // プレビュー対象ファイルの場合
            previewToolbarButton.enabled = true

        } else {
            // プレビュー対象ファイルでは無い場合
            previewToolbarButton.enabled = false
        }

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

    // MARK: - Bar Button

    /**
     右上ボタンを押下された時に呼び出される。

     - Parameter sender: 押下されたボタン
     */
    override func rightBarButtonPressed(sender: UIButton) {
        // キーボードを閉じる。
        textView.resignFirstResponder()

        // FTPファイルをアップロードする。
        uploadFtpFile()
    }

    // MARK: - Toolbar Button

    @IBAction func previewToolbarButtonPressed(sender: AnyObject) {
        // プレビュー画面に遷移する。
        let fileName = FtpFileInfoUtils.getName(ftpFileInfo)
        let fileData = textView.text
        let vc = PreviewWebViewController(fileName: fileName, fileData: fileData)
        navigationController?.pushViewController(vc, animated: true)
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
            let fileData = self.textView.text
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
                self.textView.text = text

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
