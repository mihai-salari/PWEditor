//
//  ICloudFileDetailViewController.swift
//  PWEditor
//
//  Created by mfuta1971 on 2016/05/11.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import UIKit
import GoogleMobileAds

/**
 iCloudファイル詳細画面クラス

 - Version: 1.0 新規作成
 - Author: paveway.info@gmail.com
 */
class ICloudFileDetailViewController: BaseTableViewController {

    // MARK: - Constants

    /// 画面タイトル
    let kScreenTitle = LocalizableUtils.getString(LocalizableConst.kICloudFileDatailScreenTitle)

    /// セルタイトルリスト
    let kCellTitleList = [
        LocalizableUtils.getString(LocalizableConst.kICloudFileDetailCellTitleName),
        LocalizableUtils.getString(LocalizableConst.kICloudFileDetailCellTitleDisplayName),
        LocalizableUtils.getString(LocalizableConst.kICloudFileDetailCellTitleUrl),
        LocalizableUtils.getString(LocalizableConst.kICloudFileDetailCellTitlePath),
        LocalizableUtils.getString(LocalizableConst.kICloudFileDetailCellTitleSize),
        LocalizableUtils.getString(LocalizableConst.kICloudFileDetailCellTitleCreationDate),
        LocalizableUtils.getString(LocalizableConst.kICloudFileDetailCellTitleContentChangeDate),
    ]

    /// セルインデックス
    enum CellIndex: Int {
        case Name
        case DisplayName
        case Url
        case Path
        case Size
        case CreationDate
        case ContentChangeDate
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

    /// ファイル情報
    var fileInfo: NSMetadataItem!

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
     
     - Parameter fileInfo: ファイル情報
     */
    init(fileInfo: NSMetadataItem) {
        // 引数を保存する。
        self.fileInfo = fileInfo

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
            let name = fileInfo.valueForAttribute(NSMetadataItemFSNameKey)
            let nameString: String
            if name == nil {
                nameString = ""
            } else {
                nameString = name as! String
            }
            cell.detailTextLabel?.text = nameString
            break

        case CellIndex.DisplayName.rawValue:
            let displayName = fileInfo.valueForAttribute(NSMetadataItemDisplayNameKey)
            let displayNameString: String
            if displayName == nil {
                displayNameString = ""
            } else {
                displayNameString = displayName as! String
            }
            cell.detailTextLabel?.text = displayNameString
            break

        case CellIndex.Url.rawValue:
            let url = fileInfo.valueForAttribute(NSMetadataItemURLKey)
            let urlString: String
            if url == nil {
                urlString = ""
            } else {
                urlString = (url as! NSURL).absoluteString
            }
            cell.detailTextLabel?.text = urlString
            break

        case CellIndex.Path.rawValue:
            let path = fileInfo.valueForAttribute(NSMetadataItemPathKey) as! String
            cell.detailTextLabel?.text = path
            break

        case CellIndex.Size.rawValue:
            let size = fileInfo.valueForAttribute(NSMetadataItemFSSizeKey)
            let sizeString: String
            if size == nil {
                sizeString = ""
            } else {
                sizeString = String(size as! Int)
            }
            cell.detailTextLabel?.text = sizeString
            break

        case CellIndex.CreationDate.rawValue:
            let creationDate = fileInfo.valueForAttribute(NSMetadataItemFSCreationDateKey)
            let creationDateString: String
            if creationDate == nil {
                creationDateString = ""
            } else {
                creationDateString = DateUtils.getDateString(creationDate as! NSDate)
            }
            cell.detailTextLabel?.text = creationDateString

        case CellIndex.ContentChangeDate.rawValue:
            let contentChangeDate = fileInfo.valueForAttribute(NSMetadataItemFSContentChangeDateKey)
            let contentChangeDateString: String
            if contentChangeDate == nil {
                contentChangeDateString = ""
            } else {
                contentChangeDateString = DateUtils.getDateString(contentChangeDate as! NSDate)
            }
            cell.detailTextLabel?.text = contentChangeDateString
            break
            
        default:
            break
        }
        
        return cell
    }
}
