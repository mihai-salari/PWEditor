//
//  SelectStorageViewController.swift
//  PWEditor
//
//  Created by mfuta1971 on 2016/06/09.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import UIKit
import GoogleMobileAds
import SwiftyDropbox
import OneDriveSDK

/**
 ストレージ選択画面クラス

 - Version: 1.0 新規作成
 - Author: paveway.info@gmail.com
 */
class SelectStorageViewController: BaseTableViewController {

    // MARK: - Constants

    /// 画面タイトル
    let kScreenTitle = LocalizableUtils.getString(LocalizableConst.kSelectStorageScreenTitle)

    /// セルタイトルリスト
    let kCellTitleList = [
        LocalizableUtils.getString(LocalizableConst.kSelectStorageCellTitleLocal),
        LocalizableUtils.getString(LocalizableConst.kSelectStorageCellTitleICloud),
        LocalizableUtils.getString(LocalizableConst.kSelectStorageCellTitleDropbox),
        LocalizableUtils.getString(LocalizableConst.kSelectStorageCellTitleGoogleDrive),
        LocalizableUtils.getString(LocalizableConst.kSelectStorageCellTitleOneDrive),
    ]

    /// セルインデックス
    enum CellIndex: Int {
        case Local
        case ICloud
        case Dropbox
        case GoogleDrive
        case OneDrive
    }

    // MARK: - Variables

    /// テーブルビュー
    @IBOutlet weak var tableView: UITableView!

    /// バナービュー
    @IBOutlet weak var bannerView: GADBannerView!

    /// 遷移元クラス名
    private var sourceClassName: String!

    /// ファイル名
    private var fileName: String!

    /// ファイルデータ
    private var fileData: NSData!

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

     - Parameter sourceClassName: 遷移元クラス名
     - Parameter fileName: ファイル名
     - Parameter fileData: ファイルデータ
     */
    init(sourceClassName: String, fileName: String, fileData: NSData) {
        // 引数のデータを保存する。
        self.sourceClassName = sourceClassName
        self.fileName = fileName
        self.fileData = fileData

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

        // テーブルビューを設定する。
        setupTableView(tableView)
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
        // セルタイトルリストの件数を返却する。
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

        let row = indexPath.row
        let cellTitle = kCellTitleList[row]
        cell.textLabel!.text = cellTitle

        switch row {
        case CellIndex.Local.rawValue:
            // ローカルセルの場合
            cell.accessoryType = .DisclosureIndicator
            cell.textLabel?.enabled = true
            break

        case CellIndex.ICloud.rawValue:
            // iCloudセルの場合
            let cloud = iCloud.sharedCloud()
            if cloud.checkCloudUbiquityContainer() {
                // iCloudが有効な場合
                cell.accessoryType = .DisclosureIndicator
                cell.textLabel?.enabled = true

            } else {
                // iCloudが無効な場合
                cell.accessoryType = .None
                cell.textLabel?.enabled = false
            }
            break

        case CellIndex.Dropbox.rawValue:
            // Dropboxセルの場合
            if Dropbox.authorizedClient != nil {
                // Dropboxが有効な場合
                cell.accessoryType = .DisclosureIndicator
                cell.textLabel?.enabled = true

            } else {
                // Dropboxが無効な場合
                cell.accessoryType = .None
                cell.textLabel?.enabled = false
            }
            break

        case CellIndex.GoogleDrive.rawValue:
            // GoogleDriveセルの場合
            let appDelegate = EnvUtils.getAppDelegate()
            let serviceDrive = appDelegate.googleDriveServiceDrive
            if let authorizer = serviceDrive.authorizer, canAuth = authorizer.canAuthorize where canAuth {
                // GoogleDriveが有効な場合
                cell.accessoryType = .DisclosureIndicator
                cell.textLabel?.enabled = true

            } else {
                // GoogleDriveが無効な場合
                cell.accessoryType = .None
                cell.textLabel?.enabled = false
            }
            break

        case CellIndex.OneDrive.rawValue:
            // OneDriveセルの場合
            let client = ODClient.loadCurrentClient()
            if client != nil {
                // OneDriveが有効な場合
                cell.accessoryType = .DisclosureIndicator
                cell.textLabel?.enabled = true

            } else {
                // OneDriveが無効な場合
                cell.accessoryType = .None
                cell.textLabel?.enabled = false
            }
            break

        default:
            // 上記以外、何もしない。
            break
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

        let row = indexPath.row
        switch row {
        case CellIndex.Local.rawValue:
            // ローカルセルの場合
            // ローカルエクスポート画面に遷移する。
            let pathName = "/"
            let vc = ExportLocalFileViewController(sourceClassName: sourceClassName, pathName:pathName, fileName: fileName, fileData: fileData)
            navigationController?.pushViewController(vc, animated: true)
            break

        case CellIndex.ICloud.rawValue:
            // iCloudセルの場合
            // iCloudエクスポート画面に遷移する。
            break

        case CellIndex.Dropbox.rawValue:
            // Dropboxセルの場合
            // Dropboxファイルエクスポート画面に遷移する。
            let pathName = "/"
            let vc = ExportDropboxFileViewController(sourceClassName: sourceClassName, pathName: pathName, fileName: fileName, fileData: fileData)
            navigationController?.pushViewController(vc, animated: true)
            break

        case CellIndex.GoogleDrive.rawValue:
            // Google driveセルの場合
            // Google driveエクスポート画面に遷移する。
            let parentId = ""
            let vc = ExportGoogleDriveFileViewController(sourceClassName: sourceClassName, parentId: parentId, fileName: fileName, fileData: fileData)
            navigationController?.pushViewController(vc, animated: true)
            break

        case CellIndex.OneDrive.rawValue:
            // One driveセルの場合
            // One driveエクスポート画面に遷移する。
            break

        default:
            // 上記以外、何もしない。
            break
        }
    }

    // MARK: - Private method

    /**
     遷移元画面に戻る。
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
