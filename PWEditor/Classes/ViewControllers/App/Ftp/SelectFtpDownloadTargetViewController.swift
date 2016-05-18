//
//  SelectFtpDownloadTargetViewController.swift
//  PWEditor
//
//  Created by mfuta1971 on 2016/05/19.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import UIKit
import GoogleMobileAds

/**
 FTPダウンロード先選択画面
 
 - Version: 1.0 新規作成
 - Author: paveway.info@gmail.com
 */
class SelectFtpDownloadTargetViewController: BaseTableViewController {

    // MARK: - Constatns

    /// 画面タイトル
    let kScreenTitle = LocalizableUtils.getString(LocalizableConst.kSelectFtpDownloadTargetScreenTitle)

    /// セルタイトルリスト
    let kCellTitleList = [
        LocalizableUtils.getString(LocalizableConst.kSelectFtpDownloadTargetCellTitleLocal),
//        LocalizableUtils.getString(LocalizableConst.kSelectFtpDownloadTargetCellTitleICloud),
//        LocalizableUtils.getString(LocalizableConst.kSelectFtpDownloadTargetCellTitleDropbox),
//        LocalizableUtils.getString(LocalizableConst.kSelectFtpDownloadTargetCellTitleGoogleDrive),
//        LocalizableUtils.getString(LocalizableConst.kSelectFtpDownloadTargetCellTitleOneDrive),
//        LocalizableUtils.getString(LocalizableConst.kSelectFtpDownloadTargetCellTitleBox),
    ]

    /// セルインデックス
    enum CellIndex: Int {
        case Local
        case ICloud
        case Dropbox
        case GoogleDrive
        case OneDrive
        case Box
    }

    // MARK: - Variables

    /// テーブルビュー
    @IBOutlet weak var tableView: UITableView!

    /// バナービュー
    @IBOutlet weak var bannerView: GADBannerView!

    /// FTPホスト情報
    private var ftpHostInfo: FtpHostInfo!

    /// パス名
    private var pathName: String!

    /// FTPファイル情報
    private var ftpFileInfo: NSDictionary!

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
     - Parameter pathName: パス名
     - Parameter ftpFileInfo: FTPファイル情報
     */
    init(ftpHostInfo: FtpHostInfo, pathName: String, ftpFileInfo: NSDictionary) {
        // 引数のデータを保存する。
        self.ftpHostInfo = ftpHostInfo
        self.pathName = pathName
        self.ftpFileInfo = ftpFileInfo

        // スーパークラスのメソッドを呼び出す。
        super.init(nibName: nil, bundle: nil)
    }

    // MARK: - UIViewController

    /**
     画面が生成された時に呼び出される。
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
        let cell = getTableViewCell(tableView)

        // GoogleDriveファイルリストが未取得の場合、処理を終了する。
        let row = indexPath.row
        let count = kCellTitleList.count
        if row + 1 > count {
            return cell
        }

        let title = kCellTitleList[row]
        cell.textLabel?.text = title
        cell.accessoryType = .DisclosureIndicator

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

        let row = indexPath.row
        switch row {
        case CellIndex.Local.rawValue:
            // ローカルの場合
            // ローカルディレクトリ選択一覧画面に遷移する。
            let localPathName = ""
            let vc = SelectLocalDirectoryListViewController(localPathName: localPathName, ftpHostInfo: ftpHostInfo, pathName: pathName, ftpFileInfo: ftpFileInfo)
            navigationController?.pushViewController(vc, animated: true)
            break

        case CellIndex.ICloud.rawValue:
            break

        case CellIndex.Dropbox.rawValue:
            break

        case CellIndex.GoogleDrive.rawValue:
            break

        case CellIndex.OneDrive.rawValue:
            break

        case CellIndex.Box.rawValue:
            break

        default:
            break
        }
    }
}
