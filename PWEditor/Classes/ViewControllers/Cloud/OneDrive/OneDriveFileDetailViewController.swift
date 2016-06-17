//
//  OneDriveFileDetailViewController.swift
//  PWEditor
//
//  Created by mfuta1971 on 2016/04/28.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import UIKit
import GoogleMobileAds
import OneDriveSDK

/**
 OneDriveファイル詳細画面クラス

 - Version: 1.0 新規作成
 - Author: paveway.info@gmail.com
 */
class OneDriveFileDetailViewController: BaseTableViewController {

    // MARK: - Constants

    /// 画面タイトル
    let kScreenTitle = LocalizableUtils.getString(LocalizableConst.kOneDriveFileDetailScreenTitle)

    /// セルタイトルリスト
    let kCellTitleList = [
        LocalizableUtils.getString(LocalizableConst.kOneDriveFileDetailCellTitleName),
        LocalizableUtils.getString(LocalizableConst.kOneDriveFileDetailCellTitleSize),
        LocalizableUtils.getString(LocalizableConst.kOneDriveFileDetailCellTitleCreatedDateTime),
        LocalizableUtils.getString(LocalizableConst.kOneDriveFileDetailCellTitleLastModifiedDateTime),
    ]

    /// セルインデックス
    enum CellIndex: Int {
        case Name
        case Size
        case CreatedDateTime
        case LastModifiedDateTime
    }

    // MARK: - Variables

    /// テーブルビュー
    @IBOutlet weak var tableView: UITableView!

    /// ツールバー
    @IBOutlet weak var toolbar: UIToolbar!

    /// 編集ツールバーボタン
    @IBOutlet weak var editToolbarButton: UIBarButtonItem!

    /// 削除ツールバーボタン
    @IBOutlet weak var deleteToolbarButton: UIBarButtonItem!

    /// バナービュー
    @IBOutlet weak var bannerView: GADBannerView!

    /// OneDriveアイテム
    var item: ODItem!

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
     
     - Parameter item: OneDriveファイル
     */
    init(item: ODItem) {
        // 引数を保存する。
        self.item = item

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

        // テーブルビューを設定する。
        setupTableView(tableView)
        // 区切り線を非表示にする。
        tableView.tableFooterView = UIView()

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
        let count = kCellTitleList.count
        return count
    }

    /**
     セルを返却する。

     - Parameter tableView: テーブルビュー
     - Parameter indexPath: インデックスパス
     - Returns: セル
     */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // セルを取得する。
        let cell = getTableViewDetailCell(tableView)

        // セル番号を取得する。
        let row = indexPath.row

        // セルタイトルを設定する。
        cell.textLabel?.text = kCellTitleList[row]

        switch row {
        case CellIndex.Name.rawValue:
            cell.detailTextLabel?.text = item.name
            cell.detailTextLabel?.numberOfLines = 0
            cell.detailTextLabel?.lineBreakMode = .ByWordWrapping
            break

        case CellIndex.Size.rawValue:
            cell.detailTextLabel?.text = String(item.size)
            break

        case CellIndex.CreatedDateTime.rawValue:
            let createdDateTime = item.createdDateTime
            cell.detailTextLabel?.text = DateUtils.getDateString(createdDateTime)
            break

        case CellIndex.LastModifiedDateTime.rawValue:
            let lastModifiedDateTime = item.lastModifiedDateTime
            cell.detailTextLabel?.text = DateUtils.getDateString(lastModifiedDateTime)
            break

        default:
            break
        }

        return cell
    }

    // MARK: - Toolbar button

    /**
     編集ツールバーボタン押下時に呼び出される。
 
     - Parameter sender: 編集ツールバーボタン
     */
    @IBAction func editToolbarButtonPressed(sender: AnyObject) {
        // OneDriveファイル編集画面に遷移する。
        let vc = EditOneDriveFileViewController(item: item)
        navigationController?.pushViewController(vc, animated: true)
    }

    /**
     削除ツールバーボタン押下時に呼び出される。
 
     - Parameter sender: 削除ツールバーボタン
     */
    @IBAction func deleteToolbarButtonPressed(sender: AnyObject) {
        // ファイル削除確認アラートを表示する。
        showDeleteFileConfirmAlert()
    }

    /**
     ファイル削除確認アラートを表示する。
     */
    private func showDeleteFileConfirmAlert() {
        // ファイル削除確認アラートを生成する。
        let alertTitle = LocalizableUtils.getString(LocalizableConst.kAlertTitleConfirm)
        let name = item.name
        let alertMessage = LocalizableUtils.getStringWithArgs(LocalizableConst.kAlertMessageDeleteConfirm, name)
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .Alert)

        // キャンセルボタンを生成する。
        let cancelButtonTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleCancel)
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .Cancel, handler: nil)
        alert.addAction(cancelAction)

        // 削除ボタンを生成する。
        let deleteButtonTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleDelete)
        let okAction = UIAlertAction(title: deleteButtonTitle, style: .Default, handler: {(action: UIAlertAction) -> Void in
            // 削除する。
            self.deleteOneDriveFile()
        })
        alert.addAction(okAction)

        // アラートを表示する。
        self.presentViewController(alert, animated: true, completion: nil)
    }

    /**
     OneDriveファイルを削除する。
     */
    func deleteOneDriveFile() {
        let client = ODClient.loadCurrentClient()
        if client == nil {
            // OneDriveが無効な場合
            let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
            let message = LocalizableUtils.getString(LocalizableConst.kAlertMessageOneDriveInvalid)
            showAlert(title, message: message)
            return
        }

        // ネットワークアクセス通知を表示する。
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

        let itemId = item.id
        client.drive().items(itemId).request().deleteWithCompletion( { (error: NSError?) -> Void in
            // ネットワークアクセス通知を消す。
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false

            if error != nil {
                // エラーの場合、エラーアラートを表示して終了する。
                let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
                let message = LocalizableUtils.getString(LocalizableConst.kAlertMessageDeleteFileError)
                self.showAlertAsync(title, message: message)
                return
            }

            // UI処理はメインスレッドで行う。
            let queue = dispatch_get_main_queue()
            dispatch_async(queue) {
                // 遷移元画面に戻る。
                self.navigationController?.popViewControllerAnimated(true)
            }
        })
    }
}
