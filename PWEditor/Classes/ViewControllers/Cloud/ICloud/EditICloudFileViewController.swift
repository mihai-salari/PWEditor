//
//  EditICloudFileViewController.swift
//  PWEditor
//
//  Created by mfuta1971 on 2016/05/11.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import UIKit
import GoogleMobileAds

/**
 iCloudファイル編集画面

 - Version: 1.0 新規作成
 - Author: paveway.info@gmail.com
 */
class EditICloudFileViewController: BaseEditViewController {

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

    // MARK: - UIViewController

    /**
     インスタンスが生成された時に呼び出される。
     */
    override func viewDidLoad() {
        // スーパークラスのメソッドを呼び出す。
        super.viewDidLoad()

        // 画面タイトルを設定する。
        navigationItem.title = fileName

        // 右上ボタンを設定する。
        // TODO: 暫定で表示しない。
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

        // OneDriveファイルをダウンロードする。
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

    // MARK: - iCloud

    /**
     iCloudファイルをダウンロードする。
     */
    func downloadFile() {
        // iCloudファイルをダウンロードする。
        let path: String
        if pathName == "/" {
            path = "/\(fileName)"
        } else {
            path = "\(pathName)/\(fileName)"
        }
        let cloud = iCloud.sharedCloud()
        cloud.retrieveCloudDocumentWithName(path, completion: { (cloudDocument: UIDocument!, documentData: NSData!, error: NSError!) -> Void in
            if error != nil {
                // エラーの場合
                let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
                let message = LocalizableUtils.getStringWithArgs(LocalizableConst.kEditOneDriveFileDownloadError, self.fileName)
                self.showAlert(title, message: message) {
                    // 遷移元画面に戻る。
                    self.popViewController()
                }
            }

            if !FileUtils.isTextData(documentData!) {
                // テキストデータではない場合
                let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
                let message = LocalizableUtils.getString(LocalizableConst.kAlertMessageNotTextFileError)
                self.showAlert(title, message: message) {
                    // 遷移元画面に戻る。
                    self.popViewController()
                }
                return
            }

            let text = String(data: documentData!, encoding: self.encoding)
            if text == nil {
                // 文字列に変換できない場合
                let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
                let message = LocalizableUtils.getString(LocalizableConst.kAlertMessageCovertEncodingError)
                self.showAlert(title, message: message) {
                    // 遷移元画面に戻る。
                    self.popViewController()
                }
                return
            }

            // 右バーボタンを有効にする。
            self.navigationItem.rightBarButtonItem?.enabled = true

            // ファイルデータ文字列をテキストビューに設定する。
            self.textView.text = text
        })
    }

    /**
     iCLoudファイルをアップロードする。

     - Parameter fileDataString: ファイルデータ文字列
     */
    func uploadFile(fileDataString: String) {
        let fileData = fileDataString.dataUsingEncoding(encoding)
        if fileData == nil {
            return
        }

        let path: String
        if pathName == "/" {
            path = "/\(fileName)"
        } else {
            path = "\(pathName)/\(fileName)"
        }
        let cloud = iCloud.sharedCloud()
        cloud.saveAndCloseDocumentWithName(path, withContent: fileData!, completion: { (cloudDocument: UIDocument!, documentData: NSData!, error: NSError!) -> Void in
            if error != nil {
                return
            }

            self.popViewController()
        })
    }

    // MARK: - Private method

    /**
     遷移元画面に戻る。
     文字エンコーディング選択画面から遷移した場合、iCloudファイル一覧画面に戻るための対応
     */
    func popViewController() {
        // 画面遷移数を取得する。
        let count = navigationController?.viewControllers.count
        // 最後に表示した画面から画面遷移数確認する。
        for var i = count! - 1; i >= 0; i-- {
            let vc = navigationController?.viewControllers[i]
            if vc!.dynamicType == ICloudFileListViewController.self {
                // 表示した画面がiCloudファイル一覧画面の場合
                // 画面を戻す。
                navigationController?.popToViewController(vc!, animated: true)
                break
            }
        }
    }
}
