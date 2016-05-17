//
//  ShowFtpFileViewController.swift
//  PWEditor
//
//  Created by mfuta1971 on 2016/05/13.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import UIKit
import GoogleMobileAds

/**
 FTPファイル表示画面
 
 - Version: 1.0 新規作成
 - Author: paveway.info@gmail.com
 */
class ShowFtpFileViewController: BaseWebViewController, BRRequestDelegate {

    // MARK: - Constants

    /// Webビュー
    @IBOutlet weak var webView: UIWebView!

    /// ツールバー
    @IBOutlet weak var toolbar: UIToolbar!

    /// 編集ツールバーボタン
    @IBOutlet weak var editToolbarButton: UIBarButtonItem!

    /// ダウンロードツールバーボタン
    @IBOutlet weak var downloadToolbarButton: UIBarButtonItem!

    /// 削除ツールバーボタン
    @IBOutlet weak var deleteToolbarButton: UIBarButtonItem!

    /// バナービュー
    @IBOutlet weak var bannerView: GADBannerView!

    /// FTPダウンロード処理
    var ftpDownload: BRRequestDownload?

    /// FTPホスト情報
    var ftpHostInfo: FtpHostInfo!

    /// パス名
    var pathName: String!

    /// FTPファイル情報
    var ftpFileInfo: NSDictionary!

    /// ダウンロードデータ
    var downloadData = NSMutableData()

    // MARK: - Initializer

    /**
     イニシャライザ

     - Parameter coder: デコーダー
     */
    required init?(coder aDecoder: NSCoder) {
        // スーパークラスのメソッドを呼び出す。
        super.init(coder: aDecoder)
    }

    /**
     イニシャライザ

     - Parameter ftpHostInfo: FTPホスト情報
     - Parameter pathName: パス名
     - Parameter ftpFileInfo: FTPファイル情報
     */
    init(ftpHostInfo: FtpHostInfo, pathName: String, ftpFileInfo: NSDictionary) {
        // 引数のデータを保存する。
        self.ftpHostInfo = ftpHostInfo
        self.pathName = pathName
        self.ftpFileInfo = ftpFileInfo

        // スーパークラスのメソッドを呼び出す。
        super.init(nibName: nil, bundle: nil)
    }

    // MARK: - UIViewController

    /**
     インスタンスが生成された時に呼び出される。
     */
    override func viewDidLoad() {
        // スーパークラスのメソッドを呼び出す。
        super.viewDidLoad()

        // 画面タイトルにファイル名を設定する。
        let name = FtpFileInfoUtils.getName(ftpFileInfo)
        navigationItem.title = name

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

    /**
     画面が表示される前に呼び出される。
 
     - Parameter animated: アニメーション指定
     */
    override func viewWillAppear(animated: Bool) {
        // スーパークラスのメソッドを呼び出す。
        super.viewWillAppear(animated)

        // ツールバーを無効にする。
        editToolbarButton.enabled = false
        downloadToolbarButton.enabled = false
        deleteToolbarButton.enabled = false

        // FTPファイルをダウンロードする。
        downloadFtpFile()
    }

    // MARK: - Toolbar button

    /**
     編集ツールバーボタンが謳歌された時に呼び出される。
 
 　  - Parameter sender: 編集ツールバーボタン
 　  */
    @IBAction func editToolbarButtonPressed(sender: AnyObject) {
        let vc = EditFtpFileViewController(ftpHostInfo: ftpHostInfo, pathName: pathName, ftpFileInfo: ftpFileInfo, fileData: downloadData)
        navigationController?.pushViewController(vc, animated: true)
    }

    /**
     ダウンロードツールバーボタンが謳歌された時に呼び出される。

     - Parameter sender: ダウンロードツールバーボタン
     */
    @IBAction func downloadToolbarButtonPressed(sender: AnyObject) {
    }

    /**
     削除ツールバーボタンが謳歌された時に呼び出される。

     - Parameter sender: 削除ツールバーボタン
     */
    @IBAction func deleteToolbarButtonPressed(sender: AnyObject) {
    }

    // MARK: - FTP

    /**
     FTPファイルをダウンロードする。
     */
    private func downloadFtpFile() {
        // FTPダウンロード処理を生成する。
        ftpDownload = BRRequestDownload(delegate: self)
        if ftpDownload == nil {
            //
            return
        }

        // 処理中アラートを表示する。
        showProcessingAlert() {
            // FTPファイルのダウンロードを開始する。
            self.ftpDownload!.hostname = self.ftpHostInfo.hostName
            self.ftpDownload!.username = self.ftpHostInfo.userName
            self.ftpDownload!.password = self.ftpHostInfo.password
            let fileName = FtpFileInfoUtils.getName(self.ftpFileInfo)
            let path = FtpUtils.getPath(self.pathName, name: fileName)
            self.ftpDownload!.path = path
            self.ftpDownload!.start()
        }
    }

    // MARK: - MBRequestDelegate

    /**
     リクエストが完了した時に呼び出される。

     - Parameter request: リクエスト
     */
    func requestCompleted(request: BRRequest) {
        // 処理中アラートを閉じる。
        dismissProcessingAlert() {
            // ネットワークアクセス通知を消す。
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false

            // FTPダウンロード処理をクリアする。
            self.ftpDownload = nil

            if !FileUtils.isTextData(self.downloadData) {
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
            let text = String(data: self.downloadData, encoding: NSUTF8StringEncoding)
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
            self.loadData(text!, webView: self.webView)

            // ツールバーボタンを有効にする。
            self.editToolbarButton.enabled = true
            self.downloadToolbarButton.enabled = true
            self.deleteToolbarButton.enabled = true
        }
    }

    /**
     リクエストが失敗した時に呼び出される。

     - Parameter request: リクエスト
     */
    func requestFailed(request: BRRequest) {
        // 処理中アラートを閉じる。
        dismissProcessingAlert() {
            // ネットワークアクセス通知を消す。
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false

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
    }

    /**
     上書きリクエスト時に呼び出される。
 
     - Parameter request: リクエスト
     */
    func shouldOverwriteFileWithRequest(request: BRRequest) -> Bool {
        // 何もしない。
        return true
    }

    /**
     データを受信した時に呼び出される。
 
     - Parameter request: ダウンロード要求
     */
    func requestDataAvailable(request: BRRequestDownload) {
        // 受信したデータを保存する。
        downloadData.appendData(request.receivedData)
    }
}
