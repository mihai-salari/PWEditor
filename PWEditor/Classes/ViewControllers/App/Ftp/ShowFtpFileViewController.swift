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
//        downloadToolbarButton.enabled = false
//        deleteToolbarButton.enabled = false

        // FTPファイルをダウンロードする。
        downloadData.length = 0
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
//        // FTPファイル操作アクションシートを表示する。
//        showOperateFtpFileInfoActionSheet()
    }

//    // MARK: - ActionSheet
//
//    /**
//     FTPファイル情報操作アクションシートを表示する。
//
//     - Parameter ftpFileInfo: FTPファイル情報
//     - Parameter index: FTPホスト情報リストの位置
//     - Parameter cell: テーブルビューセル
//     */
//    private func showOperateFtpFileInfoActionSheet(ftpFileInfo: NSDictionary, index: Int, cell: UITableViewCell) {
//        // FTPファイル情報操作アクションシートを生成する。
//        let alertTitle = LocalizableUtils.getString(LocalizableConst.kActionSheetTitleFtpFile)
//        let alert = UIAlertController(title: alertTitle, message: "", preferredStyle: .ActionSheet)
//        // iPadでクラッシュする対応
//        alert.popoverPresentationController?.sourceView = view
//        alert.popoverPresentationController?.sourceRect = cell.frame
//
//        // キャンセルボタンを生成する。
//        let cancelButtonTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleCancel)
//        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .Cancel, handler: nil)
//        alert.addAction(cancelAction)
//
//        let type = FtpFileInfoUtils.getType(ftpFileInfo)
//        if type == FtpConst.FtpFileType.File {
//            // ファイルの場合
//            // 編集ボタンを生成する。
//            let editButtonTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleEdit)
//            let editAction = UIAlertAction(title: editButtonTitle, style: .Default, handler: { (action: UIAlertAction) -> Void in
//                // FTPファイル編集画面に遷移する。
//                let vc = EditFtpFileViewController(ftpHostInfo: self.ftpHostInfo, pathName: self.pathName, ftpFileInfo: ftpFileInfo)
//                self.navigationController?.pushViewController(vc, animated: true)
//            })
//            alert.addAction(editAction)
//
//            // ダウンロードボタンを生成する。
//            let downloadButtonTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleDownload)
//            let downloadAction = UIAlertAction(title: downloadButtonTitle, style: .Default, handler: { (action: UIAlertAction) -> Void in
//                //              // FTPファイルダウンロード先選択画面に遷移する。
//                //              let vc = SelectFtpFileDownloadTarteViewController(ftpHostInfo: ftpHostInfo)
//                //              self.navigationController?.pushViewController(vc, animated: true)
//            })
//            alert.addAction(downloadAction)
//        }
//
//        // 削除ボタンを生成する。
//        let deleteButtonTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleDelete)
//        let deleteAction = UIAlertAction(title: deleteButtonTitle, style: .Default, handler: {(action: UIAlertAction) -> Void in
//            // FTPファイル情報削除確認アラートを表示する。
//            self.showDeleteFtpFileInfoConfirmAlert(ftpFileInfo, index: index)
//        })
//        alert.addAction(deleteAction)
//
//        // アラートを表示する。
//        self.presentViewController(alert, animated: true, completion: nil)
//    }
//
//    /**
//     FTPファイル情報削除確認アラートを表示する。
//
//     - Parameter ftpFileInfo: FTPファイル情報
//     - Parameter index: FTPファイル情報リストの位置
//     */
//    private func showDeleteFtpFileInfoConfirmAlert(ftpFileInfo: NSDictionary, index: Int) {
//        // FTPファイル情報削除確認アラートを生成する。
//        let alertTitle = LocalizableUtils.getString(LocalizableConst.kAlertTitleConfirm)
//        let name = FtpFileInfoUtils.getName(ftpFileInfo)
//        let alertMessage = LocalizableUtils.getStringWithArgs(LocalizableConst.kAlertMessageDeleteConfirm, name)
//        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .Alert)
//
//        // キャンセルボタンを生成する。
//        let cancelButtonTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleCancel)
//        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .Cancel, handler: nil)
//        alert.addAction(cancelAction)
//
//        // 削除ボタンを生成する。
//        let deleteButtonTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleDelete)
//        let okAction = UIAlertAction(title: deleteButtonTitle, style: .Default, handler: {(action: UIAlertAction) -> Void in
//            // 削除する。
//            let name = FtpFileInfoUtils.getName(ftpFileInfo)
//            let type = FtpFileInfoUtils.getType(ftpFileInfo)
//            if type == FtpConst.FtpFileType.Diretory {
//                // ディレクトリの場合
//                self.deleteFtpDir()
//
//            } else {
//                // ディレクトリ以外の場合
//                self.deleteFtpFile(name)
//            }
//        })
//        alert.addAction(okAction)
//        
//        // アラートを表示する。
//        self.presentViewController(alert, animated: true, completion: nil)
//    }

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

//    /**
//     FTPファイルを削除する。
//
//     - Parameter fileName: ファイル名
//     */
//    func deleteFtpFile(fileName: String) {
//        ftpDelete = BRRequestDelete(delegate: self)
//        if ftpDelete == nil {
//            return
//        }
//
//        // 処理中アラートを表示する。
//        showProcessingAlert() {
//            // FTPファイルの削除を開始する。
//            let path = FtpUtils.getPath(self.pathName, name: fileName)
//
//            self.ftpDelete!.hostname = self.ftpHostInfo.hostName
//            self.ftpDelete!.username = self.ftpHostInfo.userName
//            self.ftpDelete!.password = self.ftpHostInfo.password
//            self.ftpDelete!.path = path
//
//            self.ftpDelete!.start()
//        }
//    }

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

            // ファイルタイプによりデータを表示する。
            let fileName = FtpFileInfoUtils.getName(self.ftpFileInfo)
            let fileType = FileUtils.getPreviewFileType(fileName)
            switch fileType {
            case CommonConst.PreviewFileType.HTML.rawValue:
                self.loadHtmlData(text!, webView: self.webView)
                break

            case CommonConst.PreviewFileType.Markdown.rawValue:
                self.loadMarkdownData(text!, webView: self.webView)
                break

            default:
                self.loadData(text!, webView: self.webView)
                break
            }

            // ツールバーボタンを有効にする。
            self.editToolbarButton.enabled = true
//            self.downloadToolbarButton.enabled = true
//            self.deleteToolbarButton.enabled = true
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
        return false
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
