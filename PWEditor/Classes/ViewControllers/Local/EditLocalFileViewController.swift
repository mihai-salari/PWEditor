//
//  EditFileViewController.swift
//  PWEditor
//
//  Created by 二俣征嗣 on 2016/02/21.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import UIKit
import GoogleMobileAds

/**
 ローカルファイル編集画面

 - Version: 1.0 新規作成
 - Author: paveway.info@gmail.com
 */
class EditLocalFileViewController: BaseEditViewController, SearchAndReplaceDelegate {

    // MARK: - Variables

    /// 編集ビュー
    @IBOutlet weak var editView: UIView!

    /// ツールバー
    @IBOutlet weak var toolbar: UIToolbar!

    /// プレビューツールバーボタン
    @IBOutlet weak var previewToolbarButton: UIBarButtonItem!

    /// 検索ツールバーボタン
    @IBOutlet weak var searchToolbarButton: UIBarButtonItem!

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

    /// 検索単語
    private var searchWord = ""

    /// 置換単語
    private var replaceWord = ""

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
        createRightBarButton()

        // テキストビューを設定する。
        let toolbarHeight = toolbar.frame.height
        let bannerViewHeight = bannerView.frame.height
        let heightOffset = toolbarHeight + bannerViewHeight
        createTextView(editView, fileName: fileName, heightOffset: heightOffset)

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

        // ファイルデータを取得する。
        let localFilePath = FileUtils.getLocalPath(pathName, name: fileName)
        let result = FileUtils.getFileData(localFilePath, encoding: encoding)
        textView.text = result.1
    }

    /**
     メモリ不足の時に呼び出される。
     */
    override func didReceiveMemoryWarning() {
        LogUtils.w("memory error.")

        // スーパークラスのメソッドを呼び出す。
        super.didReceiveMemoryWarning()
    }

    // MARK: - Button Handler

    /**
    右上ボタンを押下された時に呼び出される。

    - Parameter sender: 押下されたボタン
    */
    override func rightBarButtonPressed(sender: UIButton) {
        // キーボードを閉じる。
        editView.resignFirstResponder()

        let localFilePath = FileUtils.getLocalPath(pathName, name: fileName)
        let fileData = textView.text
        let covertedFileData = FileUtils.convertRetCode(fileData, encoding: encoding, retCodeType: retCodeType)
        if !FileUtils.writeFileData(localFilePath, fileData: covertedFileData) {
            let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
            let message = LocalizableUtils.getString(LocalizableConst.kEditLocalFileWriteFileDataError)
            let okButtonTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleClose)
            showAlert(title, message: message, okButtonTitle: okButtonTitle, handler: { () -> Void in
                // 呼び出し元画面に戻る。
                self.popViewController()
            })
        }

        // 呼び出し元画面に戻る。
        self.popViewController()
    }

    // MARK: - Toolbar Button

    /**
     プレビューツールバーボタン押下時に呼び出される。
 
     - Parameter sender: プレビューツールバーボタン
     */
    @IBAction func previewToolbarButtonPressed(sender: AnyObject) {
        // プレビュー画面に遷移する。
        let fileData = textView.text
        let vc = PreviewWebViewController(fileName: fileName, fileData: fileData)
        navigationController?.pushViewController(vc, animated: true)
    }

    /**
     検索ツールバーボタン押下時に呼び出される。
 
     - Parameter sender: 検索ツールバーボタン
     */
    @IBAction func searchToolbarButtonPressed(sender: AnyObject) {
        let fileData = textView.text
        let vc = SearchAndReplaceViewController(fileName: fileName, fileData: fileData, searchWord: searchWord, replaceWord: replaceWord)
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }

    func receiveData(searchWord: String) {
        self.searchWord = searchWord
    }

    func receiveData(searchWord: String, replaceWord: String) {
        self.searchWord = searchWord
        self.replaceWord = replaceWord
    }

    func receiveData(searchWord: String, replaceWord: String, fileData: String) {
        self.searchWord = searchWord
        self.replaceWord = replaceWord
        textView.text = fileData
    }

    // MARK: - Private method

    /**
    遷移元画面に戻る。
    文字エンコーディング選択画面から遷移した場合、ローカルファイル一覧画面に戻るための対応
    */
    func popViewController() {
        // 画面遷移数を取得する。
        let count = navigationController?.viewControllers.count
        // 最後に表示した画面から画面遷移数確認する。
        for var i = count! - 1; i >= 0; i-- {
            let vc = navigationController?.viewControllers[i]
            if vc!.dynamicType == LocalFileListViewController.self {
                // 表示した画面がローカルファイル一覧画面の場合
                // 画面を戻す。
                navigationController?.popToViewController(vc!, animated: true)
                break
            }
        }
    }
}
