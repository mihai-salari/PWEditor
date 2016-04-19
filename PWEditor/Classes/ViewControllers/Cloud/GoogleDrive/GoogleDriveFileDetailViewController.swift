//
//  GoogleDriveFileDetailViewController.swift
//  PWEditor
//
//  Created by mfuta1971 on 2016/04/19.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import UIKit
import GoogleMobileAds

class GoogleDriveFileDetailViewController: BaseTableViewController {

    // MARK: - Constants

    /// 画面タイトル
    let kScreenTitle = LocalizableUtils.getString(LocalizableConst.kGoogleDriveFileDetailScreenTitle)

    /// セルタイトルリスト
    let kCellTitleList = [
        LocalizableUtils.getString(LocalizableConst.kGoogleDriveFileDetailCellName),
        LocalizableUtils.getString(LocalizableConst.kGoogleDriveFileDetailCellSize),
        LocalizableUtils.getString(LocalizableConst.kGoogleDriveFileDetailCellMimeType),
        LocalizableUtils.getString(LocalizableConst.kGoogleDriveFileDetailCellFileExtention),
        LocalizableUtils.getString(LocalizableConst.kGoogleDriveFileDetailCellCreatedTime),
        LocalizableUtils.getString(LocalizableConst.kGoogleDriveFileDetailCellModifiedTime),
        LocalizableUtils.getString(LocalizableConst.kGoogleDriveFileDetailCellStarred)
    ]

    /// セルインデックス
    enum CellIndex: Int {
        case Name
        case Size
        case MimeType
        case FileExtention
        case CreatedTime
        case ModifiedTime
        case Starred
    }

    /// テーブルビュー
    @IBOutlet weak var tableView: UITableView!

    /// ツールバー
    @IBOutlet weak var toolbar: UIToolbar!

    /// バナービュー
    @IBOutlet weak var bannerView: GADBannerView!

    /// GoogleDriveファイル
    var driveFile: GTLDriveFile!

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
     
     - Parameter driveFile: GoogleDriveファイル
     */
    init(driveFile: GTLDriveFile) {
        // 引数を保存する。
        self.driveFile = driveFile

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

        let title = kCellTitleList[row]
        cell.textLabel?.text = title

        switch row {
        case CellIndex.Name.rawValue:
            cell.detailTextLabel?.text = driveFile.name
            break

        case CellIndex.Size.rawValue:
            let size = driveFile.size
            let sizeString: String
            if size == nil {
                sizeString = ""
            } else {
                sizeString = String(size)
            }
            cell.detailTextLabel?.text = sizeString
            break

        case CellIndex.MimeType.rawValue:
            cell.detailTextLabel?.text = driveFile.mimeType
            cell.detailTextLabel?.numberOfLines = 0
            cell.detailTextLabel?.lineBreakMode = .ByWordWrapping
            break

        case CellIndex.FileExtention.rawValue:
            cell.detailTextLabel?.text = driveFile.fileExtension
            break

        case CellIndex.CreatedTime.rawValue:
            let date = driveFile.createdTime.date
            let dateString = DateUtils.getDateString(date)
            cell.detailTextLabel?.text = dateString
            break

        case CellIndex.ModifiedTime.rawValue:
            let date = driveFile.createdTime.date
            let dateString = DateUtils.getDateString(date)
            cell.detailTextLabel?.text = dateString
            break

        case CellIndex.Starred.rawValue:
            let starred = driveFile.starred
            let starredString: String
            if starred == 0 {
                starredString = "false"
            } else {
                starredString = "true"
            }
            cell.detailTextLabel?.text = starredString
            break

        default:
            break
        }

        return cell
    }
}
