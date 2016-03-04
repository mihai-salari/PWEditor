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
 ファイル編集画面クラス

 - Version: 1.0 新規作成
 - Author: paveway.info@gmail.com
 */
class EditFileViewController: BaseViewController {

    // MARK: - Variables

    /// マイビュー
    @IBOutlet weak var myView: MyView!

    /// バナービュー
    @IBOutlet weak var bannerView: GADBannerView!

    /// パス名
    var pathName: String!

    /// ファイル名
    var fileName: String!

    /// grep単語
    var grepWord = ""

    var preOffset: CGPoint?

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
     コンテンツ作成時呼び出される。
     */
    init(pathName: String, fileName: String) {
        // 引数を保存する。
        self.pathName = pathName
        self.fileName = fileName

        // スーパークラスのイニシャライザを呼び出す。
        super.init(nibName: nil, bundle: nil)
    }

    // MARK: - UIViewDelegate

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = fileName

        // 右上ボタンを設定する。
        createRightBarButton()

        listNumber = 0
        setupTextView()
        let selector = Selector("textChanged:")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: selector, name: UITextViewTextDidChangeNotification, object: nil)

        // バナービューを設定する。
        setupBannerView(bannerView)

        // ファイルデータを取得する。
        let localFilePath = FileUtils.getLocalPath(pathName, name: fileName)
        let fileData = FileUtils.getFileData(localFilePath)
        myView.textView.text = fileData

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
        if !FileUtils.writeFileData(localFilePath, fileData: fileData) {
            let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
            let message = LocalizableUtils.getString(LocalizableConst.kEditFileWriteFileDataError)
            let okButtonTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleClose)
            showAlert(title, message: message, okButtonTitle: okButtonTitle, handler: { () -> Void in
                // 呼び出し元画面に戻る。
                self.navigationController?.popViewControllerAnimated(true)
            })
        }

        // 呼び出し元画面に戻る。
        navigationController?.popViewControllerAnimated(true)
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
        myView.textView.setContentOffset(preOffset!, animated: true)
    }
}
