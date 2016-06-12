//
//  CreateFtpHostViewController.swift
//  PWEditor
//
//  Created by mfuta1971 on 2016/05/12.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import UIKit
import GoogleMobileAds

/**
 FTPホスト作成画面
 
 - Version: 1.0 新規作成
 - Author: paveway.info@gmail.com
 */
class CreateFtpHostViewController: BaseTableViewController, UITextFieldDelegate {

    // MARK: - Constants

    /// 画面タイトル
    private let kScreenTitle = LocalizableUtils.getString(LocalizableConst.kCreateFtpHostScreenTitle)

    /// セクションタイトルリスト
    private let kSectionTitleList = [
        LocalizableUtils.getString(LocalizableConst.kCreateFtpHostSectionTitleDisplayName),
        LocalizableUtils.getString(LocalizableConst.kCreateFtpHostSectionTitleHostName),
        LocalizableUtils.getString(LocalizableConst.kCreateFtpHostSectionTitleUserName),
        LocalizableUtils.getString(LocalizableConst.kCreateFtpHostSectionTitlePassword),
    ]

    /// セクションインデックス
    private enum SectionIndex: Int {
        case DisplayName
        case HostName
        case UserName
        case Password
    }

    /// 編集タイプ
    private enum EditType: Int {
        case Create
        case Edit
    }

    // MARK: - Variables

    /// テーブルビュー
    @IBOutlet weak var tableView: UITableView!

    /// バナービュー
    @IBOutlet weak var bannerView: GADBannerView!

    /// FTPホスト情報
    private var ftpHostInfo: FtpHostInfo!

    /// 編集タイプ
    private var editType = EditType.Create

    // テーブルビューのY位置オフセット初期値
    var tableViewOffsetY: CGFloat?

    // フォーカスされているテーブルビューセルのインデックス
    var activeCellIndex: Int?

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
     */
    init(ftpHostInfo: FtpHostInfo? = nil) {
        // 引数のデータを保存する。
        if ftpHostInfo == nil {
            self.ftpHostInfo = FtpHostInfo()
            editType = EditType.Create

        } else {
            self.ftpHostInfo = ftpHostInfo
            editType = EditType.Edit
        }

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

        // 画面タイトルを設定する。
        navigationItem.title = kScreenTitle

        // 右バーボタンを作成する。
        createRightBarButton()

        // テーブルビューを設定する。
        setupTableView(tableView)

        // カスタムテーブルビューセルを設定する。
        let nib  = UINib(nibName: kLineDataTableViewCellNibName, bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: kLineDataCellName)

        // バナービューを設定する。
        setupBannerView(bannerView)

        // テキストフィールドがキーボードに隠れないための処理
        let notificationCenter = NSNotificationCenter.defaultCenter()
        let keyboardWillShow = #selector(CreateFtpHostViewController.keyboardWillShow(_:))
        notificationCenter.addObserver(self, selector: keyboardWillShow, name: UIKeyboardWillShowNotification, object: nil)
        let keyboardWillHide = #selector(CreateFtpHostViewController.keyboardWillHide(_:))
        notificationCenter.addObserver(self, selector: keyboardWillHide, name: UIKeyboardWillHideNotification, object: nil)
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
     画面が表示された後に呼び出される。
 
     - Parameter animated: アニメーション指定
     */
    override func viewDidAppear(animated: Bool) {
        // スーパークラスのメソッドを呼び出す。
        super.viewDidAppear(animated)

        // テーブルビューのY位置オフセット初期値を保存する。
        // 画面が表示された後でないと値が確定しないため、このタイミングで保存する。
        tableViewOffsetY = tableView.contentOffset.y
    }

    // MARK: - UITableViewDataSource

    /**
     セクション数を返却する。

     - Parameter tableView: テーブルビュー
     - Returns: セクション数
     */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return kSectionTitleList.count
    }

    /**
     セクションのタイトルを返却する。

     - Parameter tableView: テーブルビュー
     - Parameter section: セクション番号
     - Returns: セクションのタイトル
     */
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return kSectionTitleList[section] as String
    }

    /**
     セクション内のセル数を返却する。

     - Parameter tableView: テーブルビュー
     - Parameter section: セクション番号
     - Returns: セクション内のセル数
     */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SectionIndex.DisplayName.rawValue:
            // 表示名セクションの場合
            return 1

        case SectionIndex.HostName.rawValue:
            // ホスト名セクションの場合
            return 1

        case SectionIndex.UserName.rawValue:
            // ユーザ名セクションの場合
            return 1

        case SectionIndex.Password.rawValue:
            // パスワードセクションの場合
            return 1

        default:
            // 上記以外
            return 0;
        }
    }

    /**
     セルを返却する。

     - Parameter tableView: テーブルビュー
     - Parameter indexPath: インデックスパス
     - Returns: セル
     */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell?

        // セクションにより処理を振り分ける。
        let section = indexPath.section
        switch section {
        case SectionIndex.DisplayName.rawValue:
            // 表示名セクションの場合
            if editType == EditType.Create {
                cell = createCell(index: section)
            } else {
                let text = ftpHostInfo.displayName
                cell = createCell(text, index: section)
            }
            break

        case SectionIndex.HostName.rawValue:
            // ホスト名セクションの場合
            if editType == EditType.Create {
                cell = createCell(index: section)
            } else {
                let text = ftpHostInfo.hostName
                cell = createCell(text, index: section)
            }
            break

        case SectionIndex.UserName.rawValue:
            // ユーザ名セクションの場合
            if editType == EditType.Create {
                cell = createCell(index: section)
            } else {
                let text = ftpHostInfo.userName
                cell = createCell(text, index: section)
            }
            break

        case SectionIndex.Password.rawValue:
            // パスワードセクションの場合
            if editType == EditType.Create {
                cell = createCell(index: section)
            } else {
                let text = ftpHostInfo.password
                cell = createCell(text, index: section)
            }
            break

        default:
            // 上記以外、何もしない。
            break
        }

        return cell!
    }

    /**
     セルを作成する。
 
     - Parameter text: セルのタイトル
     - Parameter index: セルのインデックス(UITextFieldDelegateのメソッド内で判別するため、UITextFieldのタグに設定する)
     - Returns: セル
     */
    private func createCell(text: String? = nil, index: Int) -> UITableViewCell {
        let lineDataCell = createLineDataCell()
        let textField = lineDataCell.textField!
        textField.delegate = self
        textField.keyboardType = .ASCIICapable
        textField.returnKeyType = .Done
        if text != nil {
            textField.text = text
        }
        textField.tag = index
        let cell = lineDataCell as UITableViewCell
        return cell
    }

    /**
     1行データ入力セルを生成する。
 
     - Returns: 1行データ入力セル
     */
    private func createLineDataCell() -> EnterLineDataTableViewCell {
        var lineDataCell = tableView.dequeueReusableCellWithIdentifier(kLineDataCellName) as? EnterLineDataTableViewCell
        if (lineDataCell == nil) {
            // セルを生成する。
            lineDataCell = EnterLineDataTableViewCell()
        }

        return lineDataCell!
    }

    // MARK: - UITableViewDelegate

    /**
     セルが選択された時に呼び出される。

     - Parameter tableView: テーブルビュー
     - Parameter indexPath: インデックスパス
     */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // 選択状態を解除する。
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    // MARK: - UITextFieldDelegate

    /**
     リターンキーが押下された時に呼び出される。

     - Parameter textField: テキストフィールド
     - Returns: 処理結果
     */
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        // キーボードを閉じる。
        let result = textField.resignFirstResponder()
        return result
    }

    /**
     編集する前に呼び出される。
 
     - Parameter textField: 対象のテキストフィールド
     - Returns: 処理結果
     */
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        activeCellIndex = textField.tag
        return true
    }

    // MARK: - Notification handler

    /**
     キーボードが表示される時に呼び出される。

     - Parameter notification: 通知
     */
    func keyboardWillShow(notification: NSNotification) {
        // キーボードの上端位置を取得する。
        let userInfo = notification.userInfo!
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let keyboardLimit = tableView.frame.height - keyboardScreenEndFrame.size.height

        // セルの下端位置を取得する。
        if activeCellIndex == nil {
            return
        }
        let indexPath = NSIndexPath(forItem: 0, inSection: activeCellIndex!)
        let cell = tableView!.cellForRowAtIndexPath(indexPath)
        if cell == nil {
            return
        }
        let cellLimit = cell!.frame.origin.y + cell!.frame.height + 8.0

        if cellLimit >= keyboardLimit {
            // キーボードの上端位置がセルの下端位置より上にある場合
            // テーブルビューをスクロールする。
            tableView.contentOffset.y = keyboardLimit - keyboardLimit
        }
    }

    /**
     キーボードが閉じる時に呼び出される。

     - Parameter notification: 通知
     */
    func keyboardWillHide(notification: NSNotification) {
        // テーブルビューのオフセットをクリアする。
        tableView.contentOffset.y = tableViewOffsetY!
    }

    // MARK: - Button Handler

    /**
     右バーボタン押下時に呼び出される。

     - Parameter sender: 右バーボタン
     */
    override func rightBarButtonPressed(sender: UIButton) {
        // 入力された表示名を取得する。
        let displayName = getText(SectionIndex.DisplayName.rawValue)
        if displayName.isEmpty {
            // 表示名が未入力の場合
            // エラーアラートを表示して、処理終了
            let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
            let message = LocalizableUtils.getString(LocalizableConst.kCreateFtpHostEnterDisplayNameError)
            let okButtonTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleClose)
            showAlert(title, message: message, okButtonTitle: okButtonTitle)
            return
        }

        // 入力されたホスト名を取得する。
        let hostName = getText(SectionIndex.HostName.rawValue)
        if hostName.isEmpty {
            // ホスト名が未入力の場合
            // エラーアラートを表示して、処理終了
            let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
            let message = LocalizableUtils.getString(LocalizableConst.kCreateFtpHostEnterHostNameError)
            let okButtonTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleClose)
            showAlert(title, message: message, okButtonTitle: okButtonTitle)
            return
        }

        // 入力されたユーザ名を取得する。
        let userName = getText(SectionIndex.UserName.rawValue)

        // 入力されたパスワードを取得する。
        let password = getText(SectionIndex.Password.rawValue)

        let ftpHostInfo = FtpHostInfo()
        ftpHostInfo.displayName = displayName
        ftpHostInfo.hostName = hostName
        if !userName.isEmpty {
            ftpHostInfo.userName = userName
        } else {
            ftpHostInfo.userName = nil
        }
        if !password.isEmpty {
            ftpHostInfo.password = password
        } else {
            ftpHostInfo.password = nil
        }

        // 新規登録または更新を行う。
        let realm = RLMRealm.defaultRealm()
        do {
            try realm.transactionWithBlock() {
                realm.addOrUpdateObject(ftpHostInfo)
            }
        } catch {
            let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
            let message = LocalizableUtils.getString(LocalizableConst.kCreateFtpHostSaveOrUpdateError)
            self.showAlert(title, message: message)
            return
        }

        // 元画面に戻る。
        navigationController?.popViewControllerAnimated(true)
    }

    /**
     テキストを取得する。
 
     - Parameter section: セクション番号
     - Returns: テキスト
     */
    private func getText(section: Int) -> String {
        let indexPath = NSIndexPath(forItem: 0, inSection: section)
        let cell = tableView?.cellForRowAtIndexPath(indexPath) as! EnterLineDataTableViewCell
        let textField = cell.textField
        textField.resignFirstResponder()
        let text = textField.text!
        return text
    }
}
