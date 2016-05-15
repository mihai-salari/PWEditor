//
//  FtpFileDetailViewController.swift
//  PWEditor
//
//  Created by mfuta1971 on 2016/05/13.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import UIKit
import GoogleMobileAds

class FtpFileDetailViewController: BaseTableViewController {

    // MARK: - Constants

    /// 画面タイトル
    private let kScreenTitle = LocalizableUtils.getString(LocalizableConst.kFtpFileDetailScreenTitle)

    /// セルタイトルリスト
    private let kCellTitleList = [
        LocalizableUtils.getString(LocalizableConst.kFtpFileDetailCellTitleName),
        LocalizableUtils.getString(LocalizableConst.kFtpFileDetailCellTitleLink),
        LocalizableUtils.getString(LocalizableConst.kFtpFileDetailCellTitleSize),
        LocalizableUtils.getString(LocalizableConst.kFtpFileDetailCellTitleType),
        LocalizableUtils.getString(LocalizableConst.kFtpFileDetailCellTitleMode),
        LocalizableUtils.getString(LocalizableConst.kFtpFileDetailCellTitleOwner),
        LocalizableUtils.getString(LocalizableConst.kFtpFileDetailCellTitleGroup),
        LocalizableUtils.getString(LocalizableConst.kFtpFileDetailCellTitleModDate),
    ]

    /// セルインデックス
    enum CellIndex: Int {
        case Name
        case Link
        case Size
        case FileType
        case Mode
        case Owner
        case Group
        case ModDate
    }

    // MARK: - Variables

    /// テーブルビュー
    @IBOutlet weak var tableView: UITableView!

    /// ツールバー
    @IBOutlet weak var toolbar: UIToolbar!

    /// ダウンロードツールバーボタン
    @IBOutlet weak var downloadToolbarButton: UIBarButtonItem!

    /// 削除ツールバーボタン
    @IBOutlet weak var deleteToolbarButton: UIBarButtonItem!

    /// バナービュー
    @IBOutlet weak var bannerView: GADBannerView!

    /// FTPファイル情報
    var ftpFileInfo: NSDictionary!

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

     - Parameter ftpFileInfo: FTPファイル情報
     */
    init(ftpFileInfo: NSDictionary) {
        // 引数を保存する。
        self.ftpFileInfo = ftpFileInfo

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

        let type = FtpFileInfoUtils.getType(ftpFileInfo)
        if type == FtpConst.FtpFileType.File {
            downloadToolbarButton.enabled = true
        } else {
            downloadToolbarButton.enabled = false
        }

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
            cell.detailTextLabel?.text = FtpFileInfoUtils.getName(ftpFileInfo)
            break

        case CellIndex.Link.rawValue:
            cell.detailTextLabel?.text = FtpFileInfoUtils.getLink(ftpFileInfo)
            break

        case CellIndex.Size.rawValue:
            cell.detailTextLabel?.text = String(FtpFileInfoUtils.getSize(ftpFileInfo))
            break

        case CellIndex.FileType.rawValue:
            cell.detailTextLabel?.text = String(FtpFileInfoUtils.getType(ftpFileInfo))
            break

        case CellIndex.Mode.rawValue:
            cell.detailTextLabel?.text = String(FtpFileInfoUtils.getMode(ftpFileInfo))
            break

        case CellIndex.Owner.rawValue:
            cell.detailTextLabel?.text = FtpFileInfoUtils.getOwner(ftpFileInfo)
            break

        case CellIndex.Group.rawValue:
            cell.detailTextLabel?.text = FtpFileInfoUtils.getGroup(ftpFileInfo)
            break

        case CellIndex.ModDate.rawValue:
            cell.detailTextLabel?.text = FtpFileInfoUtils.getModDate(ftpFileInfo)
            break

        default:
            break
        }

        return cell
    }

    // MARK: - Toolbar button

    /**
     ダウンロードツールバーボタン押下時に呼び出される。

     - Parameter sender: ダウンロードツールバーボタン
     */
    @IBAction func downloadToolbarButtonPressed(sender: AnyObject) {
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
        let name = FtpFileInfoUtils.getName(ftpFileInfo)
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
            self.deleteFile()
        })
        alert.addAction(okAction)

        // アラートを表示する。
        presentViewController(alert, animated: true, completion: nil)
    }

    /**
     ファイルを削除する。
     */
    func deleteFile() {
    }
}
