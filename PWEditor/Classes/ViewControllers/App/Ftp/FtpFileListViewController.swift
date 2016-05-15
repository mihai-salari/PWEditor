//
//  FtpFileListViewController.swift
//  PWEditor
//
//  Created by mfuta1971 on 2016/05/12.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import UIKit
import GoogleMobileAds

/**
 FTPファイル一覧画面
 
 - Version: 1.0 新規作成
 - Author: paveway.info@gmail.com
 */
class FtpFileListViewController: BaseTableViewController, UIGestureRecognizerDelegate, BRRequestDelegate {

    // MARK: - Constatns

    /// 画面タイトル
    private let kScreenTitle = LocalizableUtils.getString(LocalizableConst.kFtpFileListScreenTitle)

    // MARK: - Variables

    /// テーブルビュー
    @IBOutlet weak var tableView: UITableView!

    /// ツールバー
    @IBOutlet weak var toolbar: UIToolbar!

    /// 作成ツールバーボタン
    @IBOutlet weak var createToolbarButton: UIBarButtonItem!

    /// バナービュー
    @IBOutlet weak var bannerView: GADBannerView!

    /// FTPホスト情報
    private var ftpHostInfo: FtpHostInfo!

    /// パス名
    private var pathName: String!

    /// FTPディレクトリリスト操作
    private var listDir: BRRequestListDirectory!

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
     */
    init(ftpHostInfo: FtpHostInfo, pathName: String) {
        // 引数のデータを保存する。
        self.ftpHostInfo = ftpHostInfo
        self.pathName = pathName

        // スーパークラスのメソッドを呼び出す。
        super.init(nibName: nil, bundle: nil)
    }

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

        // リフレッシュコントロールを作成する。
        createRefreshControl(tableView: tableView)

        // セルロングタップを設定する。
        createCellLogPressed(tableView, delegate: self)

        // バナービューを設定する。
        setupBannerView(bannerView)

        // FTPディレクトリリスト操作を設定する。
        listDir = BRRequestListDirectory(delegate: self)
        listDir.hostname = ftpHostInfo.hostName
        listDir.username = ftpHostInfo.userName
        listDir.password = ftpHostInfo.password
        listDir.path = pathName
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

        // FTPファイルリスト取得を開始する。
        listDir.start()
    }

    // MARK: - UITableViewDataSource

    /**
     セクション内のセル数を返却する。

     - Parameter tableView: テーブルビュー
     - Parameter section: セクション番号
     - Returns: セクション内のセル数
     */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // FTPファイル情報リストの件数を返却する。
        let count: Int
        let filesInfo = listDir.filesInfo
        if filesInfo == nil {
            count = 0
        } else {
            count = listDir.filesInfo.count
        }
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

        // FTPファイル情報リストが未取得の場合、処理を終了する。
        let row = indexPath.row
        let ftpFileInfoList = listDir.filesInfo
        let count = ftpFileInfoList.count
        if row + 1 > count {
            return cell
        }

        // ファイル名、フォルダ名を設定する。
        let ftpFileInfo = ftpFileInfoList[row] as! NSDictionary

        let name = FtpFileInfoUtils.getName(ftpFileInfo)
        cell.textLabel?.text = name

        let type = FtpFileInfoUtils.getType(ftpFileInfo)
        if type == FtpConst.FtpFileType.File {
            // ファイルの場合
            cell.accessoryType = .DetailDisclosureButton

        } else if type == FtpConst.FtpFileType.Link {
            // リンクの場合
            cell.accessoryType = .DetailButton

        } else if type == FtpConst.FtpFileType.Diretory {
            // ディレクトリの場合
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

        // FTPファイル情報リストが未取得の場合、処理を終了する。
        let row = indexPath.row
        let ftpFileInfoList = listDir.filesInfo
        let count = ftpFileInfoList.count
        if row + 1 > count {
            return
        }

        let ftpFileInfo = ftpFileInfoList[row] as! NSDictionary
        let type = FtpFileInfoUtils.getType(ftpFileInfo)
        if type == FtpConst.FtpFileType.File {
            // ファイルの場合
            // FTPファイル表示画面に遷移する。
//            let vc = ShowFtpFileViewController(ftpFileInfo: ftpFileInfo)
//            navigationController?.pushViewController(vc, animated: true)

        } else if type == FtpConst.FtpFileType.Diretory {
            // ディレクトリの場合
            // FTPファイル一覧画面に遷移する。
            let name = FtpFileInfoUtils.getName(ftpFileInfo)
            let path: String
            if pathName == "/" {
                path = "\(pathName)\(name)"
            } else {
                path = "\(pathName)/\(name)"
            }
            let vc = FtpFileListViewController(ftpHostInfo: ftpHostInfo, pathName: path)
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    // MARK: - Toobar button

    /**
     作成ツールバーボタン押下時に呼び出される。
 
     - Parameter sender: 作成ツールバーボタン
     */
    @IBAction func createToobarButtonPressed(sender: AnyObject) {
    }

    // MARK: - BRRequestDelegate

    /**
     リクエストが完了した時に呼び出される。
 
     - Parameter request: リクエスト
     */
    func requestCompleted(request: BRRequest) {
        // テーブルビューを更新する。
        tableView.reloadData()
    }

    /**
     リクエストが失敗した時に呼び出される。
 
     - Parameter request: リクエスト
     */
    func requestFailed(request: BRRequest) {
    }

    func shouldOverwriteFileWithRequest(reuqest: BRRequest) -> Bool {
        return true
    }
}
