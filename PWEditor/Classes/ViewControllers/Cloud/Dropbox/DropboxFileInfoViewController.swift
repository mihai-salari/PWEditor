//
//  DropboxFileInfoViewController.swift
//  PWEditor
//
//  Created by 二俣征嗣 on 2016/03/01.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import UIKit
import GoogleMobileAds

class DropboxFileInfoViewController: BaseTableViewController {

    // MARK: - Constants

    /// 画面タイトル
    let kScreenTitle = LocalizableUtils.getString(LocalizableConst.kDropboxFileInfoScreenTitle)

    /// セルインデックス
    enum CellIndex: Int {
        case Id = 0
        case Name = 1
        case PathLower = 2
        case Size = 3
        case Rev = 4
        case ServerModified = 5
        case ClientModified = 6
        case CellMax = 7
    }

    // MARK: - Variables

    /// テーブルビュー
    @IBOutlet weak var tableView: UITableView!

    /// バナービュー
    @IBOutlet weak var bannerView: GADBannerView!

    /// Dropboxファイル情報
    var fileInfo: DropboxFileInfo!

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
    init(fileInfo: DropboxFileInfo) {
        // 引数を保存する。
        self.fileInfo = fileInfo

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
        return CellIndex.CellMax.rawValue
    }

    /**
     セルを返却する。

     - Parameter tableView: テーブルビュー
     - Parameter indexPath: インデックスパス
     - Returns: セル
     */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // セルを取得する。
        var cell = tableView.dequeueReusableCellWithIdentifier(kCellName) as UITableViewCell?
        // セルが取得できない場合
        if (cell == nil || cell?.detailTextLabel == nil) {
            // セルを生成する。
            cell = UITableViewCell(style: .Value1, reuseIdentifier: kCellName)
        }

        // セル番号を取得する。
        let row = indexPath.row

        switch row {
        case CellIndex.Id.rawValue:
            cell?.textLabel?.text = LocalizableUtils.getString(LocalizableConst.kDropboxFileInfoCellTitleId)
            cell?.detailTextLabel?.text = fileInfo.id
            break

        case CellIndex.Name.rawValue:
            cell?.textLabel?.text = LocalizableUtils.getString(LocalizableConst.kDropboxFileInfoCellTitleName)
            cell?.detailTextLabel?.text = fileInfo.name
            break

        case CellIndex.PathLower.rawValue:
            cell?.textLabel?.text = LocalizableUtils.getString(LocalizableConst.kDropboxFileInfoCellTitlePathLower)
            cell?.detailTextLabel?.text = fileInfo.pathLower
            break

        case CellIndex.Size.rawValue:
            cell?.textLabel?.text = LocalizableUtils.getString(LocalizableConst.kDropboxFileInfoCellTitleSize)
            cell?.detailTextLabel?.text = String(fileInfo.size)
            break

        case CellIndex.Rev.rawValue:
            cell?.textLabel?.text = LocalizableUtils.getString(LocalizableConst.kDropboxFileInfoCellTitleRev)
            cell?.detailTextLabel?.text = fileInfo.rev
            break

        case CellIndex.ServerModified.rawValue:
            cell?.textLabel?.text = LocalizableUtils.getString(LocalizableConst.kDropboxFileInfoCellTitleServerModified)
            cell?.detailTextLabel?.text = DateUtils.getDateString(fileInfo.serverModified)
            break

        case CellIndex.ClientModified.rawValue:
            cell?.textLabel?.text = LocalizableUtils.getString(LocalizableConst.kDropboxFileInfoCellTitleClientModified)
            cell?.detailTextLabel?.text = DateUtils.getDateString(fileInfo.clientModified)
            break


        default:
            break
        }

        return cell!
    }
}
