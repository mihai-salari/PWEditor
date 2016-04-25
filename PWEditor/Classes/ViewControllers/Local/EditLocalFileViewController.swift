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
 ローカルファイル編集画面クラス

 - Version: 1.0 新規作成
 - Author: paveway.info@gmail.com
 */
class EditLocalFileViewController: BaseViewController, UITextViewDelegate {

    // MARK: - Variables

    /// マイビュー
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

    /// grep単語
    var grepWord = ""

    /// プレオフセット
    var preOffset: CGPoint?

    /// テキスト変更フラグ
    var textChanged = false

    /// シンタックスハイライトパターン
    var pattern: String!

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

        let fileExtention = FileUtils.getFileExtention(fileName)
        pattern = ReserveWordUtils.getPattern(fileExtention)

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
        let selector = #selector(EditLocalFileViewController.textChanged(_:))
        NSNotificationCenter.defaultCenter().addObserver(self, selector: selector, name: UITextViewTextDidChangeNotification, object: nil)
        myView.textView.delegate = self
        myView.textView.circularSearch = true
        myView.textView.scrollPosition = ICTextViewScrollPositionMiddle
        myView.textView.searchOptions = .CaseInsensitive

        // バナービューを設定する。
        setupBannerView(bannerView)

        // ファイルデータを取得する。
        let localFilePath = FileUtils.getLocalPath(pathName, name: fileName)
        let result = FileUtils.getFileData(localFilePath, encoding: encoding)
        myView.textView.text = result.1

        // テキストビューがキーボードに隠れないための処理
        // 参考 : https://teratail.com/questions/2915
        let notificationCenter = NSNotificationCenter.defaultCenter()
        let keyboardWillShow = #selector(EditLocalFileViewController.keyboardWillShow(_:))
        notificationCenter.addObserver(self, selector: keyboardWillShow, name: UIKeyboardWillShowNotification, object: nil)
        let keyboardWillHide = #selector(EditLocalFileViewController.keyboardWillHide(_:))
        notificationCenter.addObserver(self, selector: keyboardWillHide, name: UIKeyboardWillHideNotification, object: nil)
        let keyboardDidHide = #selector(EditLocalFileViewController.keyboardDidHide(_:))
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

        myView.textView.scrollRectToVisible(CGRectZero, animated: true, consideringInsets: true)
        myView.textView.scrollToMatch(pattern)
    }

    /**
     画面が閉じる前に呼び出される。
     */
    override func viewWillDisappear(animated: Bool) {
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
                if textChanged {
                    showAlert("確認", message: "データが変更されています。保存しますか。", okButtonTitle: "保存", handler: { () -> Void in
                    })
                }
            }
        }

        super.viewWillDisappear(animated)
    }

    /**
     画面が閉じた後に呼び出される。
     */
    override func viewDidDisappear(animated: Bool) {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        
        super.viewDidDisappear(animated)
    }

    // MARK: - Button Handler

    /**
    右上ボタンを押下された時に呼び出される。

    - Parameter sender: 押下されたボタン
    */
    override func rightBarButtonPressed(sender: UIButton) {
        // キーボードを閉じる。
        myView.textView.resignFirstResponder()

        let localFilePath = FileUtils.getLocalPath(pathName, name: fileName)
        let fileData = myView.textView.text
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

    // MARK: - UITextViewDelegate

    /**
     テキストが変更された時に呼び出される。
     
     - Parameter notification: 通知
     */
    func textChanged(notification: NSNotification?) -> (Void) {
        textChanged = true
        myView.textView.scrollToMatch(pattern)
    }

    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        LogUtils.d("textViewShouldBeginEditing")
        myView.textView.scrollToMatch(pattern)
        return true
    }
    func textViewDidBeginEditing(textView: UITextView){
        LogUtils.d("textViewDidBeginEditing")
    }
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        LogUtils.d("textViewShouldEndEditing")
        return true
    }
    func textViewDidEndEditing(textView: UITextView) {
        LogUtils.d("textViewDidEndEditing")
    }
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        LogUtils.d("shouldChangeTextInRange")
        myView.textView.scrollToMatch(pattern)
        return true
    }
    func textViewDidChange(textView: UITextView) {
        LogUtils.d("textViewDidChange")
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
        myView.textView.setContentOffset(preOffset!, animated: true)
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
