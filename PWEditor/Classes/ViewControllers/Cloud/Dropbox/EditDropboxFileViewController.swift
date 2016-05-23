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

/**
 Dropboxファイル編集画面

 - Version: 1.0 新規作成
 - Author: paveway.info@gmail.com
 */
class EditDropboxFileViewController: BaseEditViewController {

    // MARK: - Variables

    /// 編集ビュー
    @IBOutlet weak var editView: UIView!

    /// バナービュー
    @IBOutlet weak var bannerView: GADBannerView!

    /// パス名
    private var pathName: String!

    /// ファイル名
    private var fileName: String!

    /// 文字エンコーディングタイプ
    private var encodingType: Int!

    /// 文字エンコーディング
    private var encoding: UInt!

    /// 改行コードタイプ
    private var retCodeType: Int!

    /// ダウンロード用Dropboxファイル情報
    private var downloadFileInfo: DropboxFileInfo?

    /// ダウンロード先ローカルファイルパス名
    private var loacalFilePathName: String?

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
        let heightOffset = bannerView.frame.height
        createTextView(editView, fileName: fileName, heightOffset: heightOffset)

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
        if loacalFilePathName != nil && !loacalFilePathName!.isEmpty {
            // ダウンロード用ローカルファイルが存在する場合、削除する。
            FileUtils.remove(loacalFilePathName!)
            loacalFilePathName = nil
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
        editView.resignFirstResponder()

        // ファイルデータを取得する。
        let fileData = textView.text

        // 改行コードを変換する。
        let convertedFileData = FileUtils.convertRetCode(fileData, encoding: encoding, retCodeType: retCodeType)

        // 変換されたファイルデータをアップロードする。
        uploadFile(convertedFileData)
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

        // ネットワークアクセス通知を表示する。
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

        // Dropboxファイルをダウンロードする。
        let filePathName = "\(pathName)/\(fileName)"
        client!.files.download(path: filePathName, destination: destination).response { response, error in
            // ネットワークアクセス通知を消す。
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false

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
                            self.textView.text = text!
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

        // ネットワークアクセス通知を表示する。
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

        // ファイルデータをアップロードする。
        let filePathName = "\(pathName)/\(fileName)"
        let fileData = fileDataString.dataUsingEncoding(encoding, allowLossyConversion: false)
        let rev = downloadFileInfo!.rev
        let date = NSDate()
        client!.files.upload(path: filePathName, mode: .Update(rev), clientModified: date, body: fileData!).response { response, error in
            // ネットワークアクセス通知を消す。
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false

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
