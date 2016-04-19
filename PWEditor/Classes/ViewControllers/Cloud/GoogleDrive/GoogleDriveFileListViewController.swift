//
//  GoogleDriveFileListViewController.swift
//  PWEditor
//
//  Created by mfuta1971 on 2016/04/19.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import UIKit
import GoogleMobileAds

/**
 GoogleDriveファイル一覧画面
 
 - Version: 1.0 新規作成
 - Author: paveway.info@gamil.com
 */
class GoogleDriveFileListViewController: BaseTableViewController, UIGestureRecognizerDelegate {

    // MARK: - Constants

    // 画面タイトル
    private let kScreenTitle = LocalizableUtils.getString(LocalizableConst.kGoogleDriveFileListScreenTitle)

    // MARK: - Variables

    /// テーブルビュー
    @IBOutlet weak var tableView: UITableView!

    /// ツールバー
    @IBOutlet weak var toolbar: UIToolbar!

    /// バナービュー
    @IBOutlet weak var bannerView: GADBannerView!

    /// 親ID
    private var parentId: String?

    /// GooleDriveファイルリスト
    private var driveFileList = [GTLDriveFile]()

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

     - Parameter parentId: 親ID
     */
    init(parentId: String) {
        // 引数のデータを保存する。
        self.parentId = parentId

        // スーパークラスのメソッドを呼び出す。
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        // スーパークラスのメソッドを呼び出す。
        super.viewDidLoad()

        // 画面タイトルを設定する。
        navigationItem.title = kScreenTitle

        if parentId == CommonConst.GoogleDrive.kRootParentId {
            // 親IDがrootの場合
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

        // GoogleDriveファイルリストを取得する。
        getDriveFileList()
    }

    // MARK: - UITableViewDataSource

    /**
     セクション内のセル数を返却する。

     - Parameter tableView: テーブルビュー
     - Parameter section: セクション番号
     - Returns: セクション内のセル数
     */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // GooleDriveファイルリストの件数を返却する。
        let count = driveFileList.count
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
        let count = driveFileList.count
        if row + 1 > count {
            return cell
        }

        // セル内容をクリアする。
        cell.textLabel?.text = ""
        cell.accessoryType = .None

        let driveFile = driveFileList[row]
        cell.textLabel?.text = driveFile.name

        let dir = isDir(driveFile)
        if dir {
            cell.accessoryType = .DisclosureIndicator

        } else {
            cell.accessoryType = .DetailButton
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

        // GoolgeDriveファイルリストが未取得の場合、処理を終了する。
        let row = indexPath.row
        let count = driveFileList.count
        if row + 1 > count {
            return
        }

        let driveFile = driveFileList[row]
        let dir = isDir(driveFile)
        if dir {
            // ディレクトリの場合
            // GooleDriveファイル一覧画面に遷移する。
            let parentId = driveFile.identifier
            let vc = GoogleDriveFileListViewController(parentId: parentId)
            navigationController?.pushViewController(vc, animated: true)

        } else {
            // ファイルの場合
            // GoogleDriveファイル編集画面に遷移する。
            let vc = EditGoogleDriveFileViewController(driveFile: driveFile)
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    /**
     アクセサリボタンが押下された時に呼び出される。

     - Parameter tableView: テーブルビュー
     - Parameter indexPath: インデックスパス
     */
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {

        // GoolgeDriveファイルリストが未取得の場合、処理を終了する。
        let row = indexPath.row
        let count = driveFileList.count
        if row + 1 > count {
            return
        }

        // GoogleDriveファイル詳細画面に遷移する。
        let driveFile = driveFileList[row]
        let vc = GoogleDriveFileDetailViewController(driveFile: driveFile)
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Refresh control

    /**
     引っ張って更新する。
     */
    override func pullRefresh() {
        getDriveFileList()
    }

    // MARK: - Google Drive API

    /**
     GoogleDriveファイルリストを取得する。
     */
    func getDriveFileList() {
        // ネットワークアクセス通知を表示する。
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

        let query = GTLQueryDrive.queryForFilesList()
        query.pageSize = 10
        query.fields = "nextPageToken, files(id, name, size, mimeType, fileExtension,  createdTime, modifiedTime, starred, trashed, iconLink, parents, properties, permissions)"
        query.q = "'\(parentId!)' in parents"
        let selector = #selector(displayResultWithTicket(_:finishedWithObject:error:))
        let appDelegate = EnvUtils.getAppDelegate()
        let serviceDrive = appDelegate.googleDriveServiceDrive
        serviceDrive.executeQuery(query, delegate: self, didFinishSelector: selector)
    }

    // Parse results and display
    /**
     GoogleDriveファイルの取得結果を表示する。

     - Parameter ticket: チケット
     - Parameter response: レスポンス
     - Parameter error: エラー情報
     */
    func displayResultWithTicket(ticket : GTLServiceTicket, finishedWithObject response : GTLDriveFileList, error : NSError?) {
        // ネットワークアクセス通知を消す。
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false

        // リフレッシュ動作を終了する。
        refreshControl!.endRefreshing()

        if let error = error {
            // エラーの場合、エラーアラートを表示して終了する。
            let title = "エラー"
            let message = error.localizedDescription
            showAlert(title, message: message)
            return
        }

        // GoogleDriveファイルリストを更新する。
        driveFileList.removeAll(keepCapacity: false)
        if let driveFiles = response.files where !driveFiles.isEmpty {
            driveFileList = driveFiles as! [GTLDriveFile]
        }

        // テーブルビューを更新する。
        tableView.reloadData()
    }

    /**
     ディレクトリか判定する。

     - Parameter file: ファイルオブジェクト
     - Returns: true:ディレクトリ / false:ファイル
     */
    private func isDir(file: GTLDriveFile) -> Bool {
        let mimeType = file.mimeType
        let mimeTypes = mimeType.componentsSeparatedByString(".")
        let lastIndex = mimeTypes.count - 1
        let type = mimeTypes[lastIndex]

        let result: Bool
        if type == "folder" {
            result = true
        } else {
            result = false
        }
        return result
    }
}
