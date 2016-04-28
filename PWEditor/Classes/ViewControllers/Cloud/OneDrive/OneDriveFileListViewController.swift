//
//  OneDriveFileListViewController.swift
//  PWEditor
//
//  Created by mfuta1971 on 2016/04/21.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import UIKit
import GoogleMobileAds
import OneDriveSDK

/**
 OneDriveファイル一覧画面

 - Version: 1.0 新規作成
 - Author: paveway.info@gamil.com
 */
class OneDriveFileListViewController: BaseTableViewController, UIGestureRecognizerDelegate {

    // MARK: - Constants

    /// 画面タイトル
    let kScreenTitle = LocalizableUtils.getString(LocalizableConst.kOneDriveFileListScreenTitle)

    // MARK: - Variables

    /// テーブルビュー
    @IBOutlet weak var tableView: UITableView!

    /// ツールバー
    @IBOutlet weak var toolbar: UIToolbar!

    /// 作成ツールバーボタン
    @IBOutlet weak var createToolbarButton: UIBarButtonItem!

    /// バナービュー
    @IBOutlet weak var bannerView: GADBannerView!

    /// アイテムID
    var itemId: String!

    /// アイテムリスト
    var itemList = [ODItem]()

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

     - Parameter itemId: アイテムID
     */
    init(itemId: String) {
        // 引数のデータを保存する。
        self.itemId = itemId

        // スーパークラスのメソッドを呼び出す。
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        // スーパークラスのメソッドを呼び出す。
        super.viewDidLoad()

        // 画面タイトルを設定する。
        navigationItem.title = kScreenTitle

        if itemId == CommonConst.GoogleDrive.kRootParentId {
            // アイテムIDがrootの場合
            // 左バーボタンを作成する。
            createLeftBarButton()
        }

        // テーブルビューを設定する。
        setupTableView(tableView)

        // リフレッシュコントロールを作成する。
        createRefreshControl(tableView: tableView)

        // セルロングタップを設定する。
        createCellLogPressed(tableView, delegate: self)

        // バナービューを設定する。
        setupBannerView(bannerView)
    }

    /**
     メモリ不足の時に呼び出される。
     */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /**
     画面が表示される前に呼び出される。

     - Parameter animated: アニメーション指定
     */
    override func viewWillAppear(animated: Bool) {
        // スーパークラスのメソッドを呼び出す。
        super.viewWillAppear(animated)
        
        // OneDriveファイルリストを取得する。
        getDriveFileList()
    }

    /**
     画面が非表示になった時に呼び出される。
 
     - Paramenter animated: アニメーション指定
     */
    override func viewDidDisappear(animated: Bool) {
        // スーパークラスのメソッドを呼び出す。
        super.viewDidDisappear(animated)

        // ネットワークアクセス通知を消す。
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }

    // MARK: - UITableViewDataSource

    /**
     セクション内のセル数を返却する。

     - Parameter tableView: テーブルビュー
     - Parameter section: セクション番号
     - Returns: セクション内のセル数
     */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // アイテムリストの件数を返却する。
        let count = itemList.count
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
        let cell = getTableViewCell(tableView)

        // アイテムリストが未取得の場合、処理を終了する。
        let row = indexPath.row
        let count = itemList.count
        if row + 1 > count {
            return cell
        }

        // ファイル名、フォルダ名を設定する。
        let item = itemList[row]
        cell.textLabel?.text = item.name
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .ByWordWrapping

        let file = item.file
        if file != nil {
            // ファイルの場合
            cell.accessoryType = .DetailDisclosureButton

        } else {
            // フォルダの場合
            cell.accessoryType = .DisclosureIndicator
        }

        return cell
    }

    // MARK: - UITableViewDelegate

    /**
     セルが選択された時に呼び出される。

     - Parameter tableView: テーブルビュー
     - Parameter indexPath: インデックスパス
     */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // セルの選択状態を解除する。
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        // アイテムリストが未取得の場合、処理を終了する。
        let row = indexPath.row
        let count = itemList.count
        if row + 1 > count {
            return
        }

        let item = itemList[row]
        let file = item.file
        if file != nil {
            // ファイルの場合
            // OneDrive編集画面に遷移する。
            let vc = EditOneDriveFileViewController(item: item)
            navigationController?.pushViewController(vc, animated: true)

        } else {
            // フォルダーの場合
            // OneDriveファイル一覧画面に遷移する。
            let itemId = item.id
            let vc = OneDriveFileListViewController(itemId: itemId)
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    /**
     アクセサリボタンが押下された時に呼び出される。

     - Parameter tableView: テーブルビュー
     - Parameter indexPath: インデックスパス
     */
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {

        // アイテムリストが未取得の場合、処理を終了する。
        let row = indexPath.row
        let count = itemList.count
        if row + 1 > count {
            return
        }

        // OneDriveファイル詳細画面に遷移する。
        let item = itemList[row]
        let vc = OneDriveFileDetailViewController(item: item)
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - One Drive API

    /**
     OneDriveファイルリストを取得する。
     */
    func getDriveFileList() {
        let client = ODClient.loadCurrentClient()
        if client == nil {
            // OneDriveが無効な場合
            // 画面構成をリセットする。
            resetScreen()
            return
        }

        // ネットワークアクセス通知を表示する。
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

        // OneDriveファイルリストを取得する。
        client.drive().items(itemId).children().request().getWithCompletion( { (children: ODCollection?, nextRequest: ODChildrenCollectionRequest?, error: NSError?) -> Void in
            // ネットワークアクセス通知を消す。
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false

            if error != nil {
                // エラーの場合
                let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
                let message = "ファイルリストの取得でエラーが発生しました。"
                self.showAlert(title, message: message)
                return
            }
            if children == nil {
                let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
                let message = "ファイルリストが取得できません。"
                self.showAlert(title, message: message)
                return
            }
            self.itemList.removeAll(keepCapacity: false)
            for item in children!.value as! [ODItem] {
                self.itemList.append(item)
            }


            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                // テーブルビューを更新する。
                self.tableView.reloadData()
            })
        })
    }
}
