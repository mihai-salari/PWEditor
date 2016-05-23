//
//  EditGoogleDriveFileViewController.swift
//  PWEditor
//
//  Created by mfuta1971 on 2016/04/20.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import UIKit
import GoogleMobileAds

/**
 GoogleDriveファイル編集画面
 
 - Version: 1.0 新規作成
 - Author: paveway.info@gmail.com
 */
class EditGoogleDriveFileViewController: BaseEditViewController {

    // MARK: - Variables

    /// 編集ビュー
    @IBOutlet weak var editView: UIView!

    /// バナービュー
    @IBOutlet weak var bannerView: GADBannerView!

    // GoogleDriveファイル
    private var driveFile: GTLDriveFile!

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

     - Parameter driveFile: GoogleDriveファイル
     - Parameter encodingType: 文字エンコーディングタイプ(デフォルト"UTF-8")
     - Parameter retCodeType: 改行コードタイプ(デフォルト"Unix(LF)")
     */
    init(driveFile: GTLDriveFile, encodingType: Int = CommonConst.EncodingType.Utf8.rawValue, retCodeType: Int = CommonConst.RetCodeType.LF.rawValue) {
        // 引数を保存する。
        self.driveFile = driveFile
        self.encodingType = encodingType
        self.retCodeType = retCodeType
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
        let fileName = driveFile.name
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

        // Dropboxファイルをダウンロードする。
        downloadFile()
    }

    // MARK: - Bar Button

    /**
     右上ボタンを押下された時に呼び出される。

     - Parameter sender: 押下されたボタン
     */
    override func rightBarButtonPressed(sender: UIButton) {
        // キーボードを閉じる。
        textView.resignFirstResponder()

        // ファイルデータを取得する。
        let fileData = textView.text

        // 改行コードを変換する。
        let convertedFileData = FileUtils.convertRetCode(fileData, encoding: encoding, retCodeType: retCodeType)

        // 変換されたファイルデータをアップロードする。
        uploadFile(convertedFileData)
    }

    // MARK: - Google Drive API

    /**
     ファイルをダウンロードする。
     */
    func downloadFile() {
        // ネットワークアクセス通知を表示する。
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

        let id = driveFile.identifier
        let urlString = "https://www.googleapis.com/drive/v3/files/\(id)?alt=media"
        let appDelegate = EnvUtils.getAppDelegate()
        let serviceDrive = appDelegate.googleDriveServiceDrive
        let fetcher = serviceDrive.fetcherService.fetcherWithURLString(urlString)
        fetcher.beginFetchWithCompletionHandler( { (data: NSData?, error: NSError?) -> Void in
            // ネットワークアクセス通知を消す。
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false

            if error != nil {
                // エラーの場合
                let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
                let fileName = self.driveFile.name
                let message = LocalizableUtils.getStringWithArgs(LocalizableConst.kEditGoogleDriveFileDownloadError, fileName)
                self.showAlert(title, message: message, handler: { () -> Void in
                    // 遷移元画面に戻る。
                    self.popViewController()
                })
                return
            }

            if data == nil {
                // データが取得できない場合
                let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
                let fileName = self.driveFile.name
                let message = LocalizableUtils.getStringWithArgs(LocalizableConst.kEditGoogleDriveFileDownloadDataError, fileName)
                self.showAlert(title, message: message, handler: { () -> Void in
                    // 遷移元画面に戻る。
                    self.popViewController()
                })
                return
            }

            if !FileUtils.isTextData(data!) {
                // テキストデータではない場合
                let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
                let message = LocalizableUtils.getString(LocalizableConst.kAlertMessageNotTextFileError)
                self.showAlert(title, message: message, handler: { () -> Void in
                    // 遷移元画面に戻る。
                    self.popViewController()
                })
                return
            }

            // 文字列に変換する。
            let text = String(data: data!, encoding: self.encoding)
            if text == nil {
                // 文字列に変換できない場合
                let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
                let message = LocalizableUtils.getString(LocalizableConst.kAlertMessageCovertEncodingError)
                self.showAlert(title, message: message, handler: { () -> Void in
                    // 遷移元画面に戻る。
                    self.popViewController()
                })
                return
            }

            // 右バーボタンを有効にする。
            self.navigationItem.rightBarButtonItem?.enabled = true

            // ファイルデータ文字列をテキストビューに設定する。
            self.textView.text = text
        })
    }

    /**
     ファイルを更新する。

     - Parameter fileData: ファイルデータ文字列
     */
    func uploadFile(fileData: String) {
        let data = fileData.dataUsingEncoding(encoding)
        if data == nil {
            let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
            let message = LocalizableUtils.getString(LocalizableConst.kAlertMessageFileDataNotFound)
            showAlert(title, message: message)
            return
        }

        // ネットワークアクセス通知を表示する。
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

        let mimeType = CommonConst.MimeType.kText
        let uploadParameters = GTLUploadParameters(data: data!, MIMEType: mimeType)

        let fileId = driveFile.identifier
        let query = GTLQueryDrive.queryForFilesUpdateWithObject(driveFile, fileId: fileId, uploadParameters: uploadParameters)

        let appDelegate = EnvUtils.getAppDelegate()
        let serviceDrive = appDelegate.googleDriveServiceDrive
        serviceDrive.executeQuery(query, completionHandler: { (ticket: GTLServiceTicket!, updatedFile: AnyObject!, error: NSError!) -> Void in
            // ネットワークアクセス通知を消す。
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false

            if error != nil {
                // エラーの場合
                let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
                let message = error.localizedDescription
                self.showAlert(title, message: message)
                return
            }

            // 遷移元画面に戻る。
            self.popViewController()
        })
    }

    // MARK: - Private method

    /**
     遷移元画面に戻る。
     文字エンコーディング選択画面から遷移した場合、GoogleDriveファイル一覧画面に戻るための対応
     */
    func popViewController() {
        // 画面遷移数を取得する。
        let count = navigationController?.viewControllers.count
        // 最後に表示した画面から画面遷移数確認する。
        for var i = count! - 1; i >= 0; i-- {
            let vc = navigationController?.viewControllers[i]
            if vc!.dynamicType == GoogleDriveFileListViewController.self {
                // 表示した画面がGoogleDriveファイル一覧画面の場合
                // 画面を戻す。
                navigationController?.popToViewController(vc!, animated: true)
                break
            }
        }
    }
}
