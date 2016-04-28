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
    }

    /**
     削除ツールバーボタン押下時に呼び出される。
 
     - Parameter sender: 削除ツールバーボタン
     */
    @IBAction func deleteToolbarButtonPressed(sender: AnyObject) {
    }
}
