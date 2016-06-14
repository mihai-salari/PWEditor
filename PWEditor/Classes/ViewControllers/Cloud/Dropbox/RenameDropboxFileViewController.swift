//
//  RenameDropboxFileViewController.swift
//  PWEditor
//
//  Created by mfuta1971 on 2016/06/09.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import UIKit
import GoogleMobileAds
import SwiftyDropbox

/**
 Dropboxファイルリネーム画面クラス

 - Version: 1.0 新規作成
 - Author: paveway.info@gmail.com
 */
class RenameDropboxFileViewController: BaseTableViewController, UITextFieldDelegate {

    // MARK: - Constants

    /// 画面タイトル
    let kScreenTitle = LocalizableUtils.getString(LocalizableConst.kRenameDropboxFileScreenTitle)

    // MARK: - Variables

    /// テーブルビュー
    @IBOutlet weak var tableView: UITableView!

    /// バナービュー
    @IBOutlet weak var bannerView: GADBannerView!

    /// パス名
    private var pathName = ""

    /// 変更前の名前
    private var srcName = ""

    // MARK: - Initializer

    /**
     イニシャライザ

     - Parameter coder: デコーダー
     */
    required init?(coder aDecoder: NSCoder) {
        // スーパークラスのイニシャライザを呼び出す。
        super.init(coder: aDecoder)
    }

    /**
     イニシャライザ

     - Parameter pathName: パス名
     - Parameter srcName: 変更前の名前
     */
    init(pathName: String, srcName: String) {
        // 引数を保存する。
        self.pathName = pathName
        self.srcName = srcName

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
        navigationItem.title = kScreenTitle

        // 右バーボタンを作成する。
        createRightBarButton()

        // テーブルビューを設定する。
        setupTableView(tableView)
        // 区切り線を非表示にする。
        tableView.separatorColor = UIColor.clearColor()

        // カスタムテーブルビューセルを設定する。
        let nib  = UINib(nibName: kLineDataTableViewCellNibName, bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: kLineDataCellName)

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

    // MARK: - UITableViewDataSource

    /**
     セクション内のセル数を返却する。

     - Parameter tableView: テーブルビュー
     - Parameter section: セクション番号
     - Returns: セクション内のセル数
     */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    /**
     セルを返却する。

     - Parameter tableView: テーブルビュー
     - Parameter indexPath: インデックスパス
     - Returns: セル
     */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let lineDataCell = getTableViewLineDataCell(tableView)

        let textField = lineDataCell.textField
        textField?.delegate = self
        textField?.keyboardType = .ASCIICapable
        textField?.returnKeyType = .Done
        textField?.clearButtonMode = .WhileEditing
        let cell = lineDataCell as UITableViewCell
        
        return cell
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
     キーボードのリターンキーが押下された時に呼び出される。

     - Parameter textField: テキストフィールド
     - Returns: 処理結果
     */
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        // キーボードを閉じる。
        textField.resignFirstResponder()
        return true
    }

    /**
     テキストフィールドのクリアボタン押下時に呼び出される。

     - Parameter textField: テキストフィールド
     - Returns: 処理結果 常にtrue
     */
    func textFieldShouldClear(textField: UITextField) -> Bool {
        // キーボードを閉じる。
        textField.resignFirstResponder()
        return true
    }

    // MARK: - Bar button

    /**
     右バーボタン押下時に呼び出される。

     - Parameter sender: 右バーボタン
     */
    override func rightBarButtonPressed(sender: UIButton) {
        // 変更後の名前を取得する。
        let indexPath = NSIndexPath(forItem: 0, inSection: 0)
        let cell = tableView?.cellForRowAtIndexPath(indexPath) as! EnterLineDataTableViewCell
        let textField = cell.textField
        let toName = textField.text
        if toName == nil || toName!.isEmpty {
            // 変更後の名前が取得できない場合
            // エラーアラートを表示して、処理を終了する。
            let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
            let message = LocalizableUtils.getString(LocalizableConst.kAlertMessageEnterNameError)
            showAlert(title, message: message)
            return
        }

        // 名前変更する。
        let fromPath: String
        let toPath: String
        if pathName == "" {
            // ルートディレクトリの場合
            fromPath = "/\(srcName)"
            toPath = "/\(toName!)"

        } else {
            // ルートディレクトリ以外の場合
            fromPath = "/\(pathName)/\(srcName)"
            toPath = "/\(pathName)/\(toName!)"
        }

        rename(fromPath, toPath: toPath)
    }

    /**
     リネームする。

     - Parameter fromPath: 移動元パス名
     - Parameter toPath: 移動先パス名
     */
    private func rename(fromPath: String, toPath: String) {
        let client = Dropbox.authorizedClient
        if client == nil {
            // Dropboxが無効な場合
            // エラーアラートを表示する。
            let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
            let message = LocalizableUtils.getString(LocalizableConst.kAlertMessageDropboxInvalid)
            self.showAlert(title, message: message)
            return
        }

        // ネットワークアクセス通知を表示する。
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

        // 移動する。
        client!.files.move(fromPath: fromPath, toPath: toPath).response { response, error in
            // ネットワークアクセス通知を消す。
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false

            if error != nil || response == nil {
                // エラーの場合
                // エラーアラートを表示する。
                let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
                let message = LocalizableUtils.getString(LocalizableConst.kAlertMessageRenameError)
                self.showAlert(title, message: message)
                return
            }

            // 遷移元画面に戻る。
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
}
