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

    /// 作成ツールバーボタン
    @IBOutlet weak var createToolbarButton: UIBarButtonItem!

    /// バナービュー
    @IBOutlet weak var bannerView: GADBannerView!

    /// 親ID
    private var parentId: String!

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
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .ByWordWrapping

        let dir = GoogleDriveUtils.isDir(driveFile)
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
        let dir = GoogleDriveUtils.isDir(driveFile)
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

    // MARK: - Cell long press

    /**
     セルロングタップを生成する。
     */
    func createCellLogPressed() {
        let selector = #selector(cellLongPressed(_:))
        let cellLongPressedAction = selector
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: cellLongPressedAction)
        longPressRecognizer.delegate = self
        tableView.addGestureRecognizer(longPressRecognizer)
    }

    /**
     セルロングタップ時に呼び出される。

     - Parameter recognizer: ジェスチャー
     */
    override func cellLongPressed(recognizer: UILongPressGestureRecognizer) {
        let point = recognizer.locationInView(tableView)
        let indexPath = tableView!.indexPathForRowAtPoint(point)

        if indexPath == nil {
            return
        }

        if recognizer.state == UIGestureRecognizerState.Began {
            let row = indexPath!.row
            let count = driveFileList.count
            if row + 1 > count {
                return
            }

            let driveFile = driveFileList[row]
            let cell = tableView.cellForRowAtIndexPath(indexPath!)
            showOperateDriveFileActionSheet(driveFile, index: row, cell: cell!)
        }
    }

    // MARK: - ActionSheet

    /**
     GoolgeDriveファイル操作アクションシートを表示する。

     - Parameter driveFile: GoogleDriveファイル
     - Parameter index: GoogleDriveファイルの位置
     - Parameter cell: テーブルビューセル
     */
    private func showOperateDriveFileActionSheet(driveFile: GTLDriveFile, index: Int, cell: UITableViewCell) {
        // ローカルファイル操作アクションシートを生成する。
        let alertTitle = LocalizableUtils.getString(LocalizableConst.kActionSheetTitleGoogleDriveFile)
        let alert = UIAlertController(title: alertTitle, message: "", preferredStyle: .ActionSheet)
        // iPadでクラッシュする対応
        alert.popoverPresentationController?.sourceView = view
        alert.popoverPresentationController?.sourceRect = cell.frame

        // キャンセルボタンを生成する。
        let cancelButtonTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleCancel)
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .Cancel, handler: nil)
        alert.addAction(cancelAction)

        // 文字エンコーディングを指定して開くボタンを生成する。
        let openCharButtonTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleOpenChar)
        let openCharAction = UIAlertAction(title: openCharButtonTitle, style: .Default, handler: {(action: UIAlertAction) -> Void in
            // 文字エンコーディング選択画面に遷移する。
            let sourceClassName = self.dynamicType.description()
            let vc = SelectEncodingViewController(sourceClassName: sourceClassName, driveFile: driveFile)
            self.navigationController?.pushViewController(vc, animated: true)
        })
        alert.addAction(openCharAction)

        // 削除ボタンを生成する。
        let deleteButtonTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleDelete)
        let deleteAction = UIAlertAction(title: deleteButtonTitle, style: .Default, handler: {(action: UIAlertAction) -> Void in
            // ファイル削除確認アラートを表示する。
            self.showDeleteFileConfirmAlert(driveFile, index: index)
        })
        alert.addAction(deleteAction)

        // アラートを表示する。
        self.presentViewController(alert, animated: true, completion: nil)
    }

    /**
     ファイル削除確認アラートを表示する。

     - Parameter name: ファイル名またはディレクトリ名
     - Parameter index: ファイル情報の位置
     */
    private func showDeleteFileConfirmAlert(driveFile: GTLDriveFile, index: Int) {
        // ファイル削除確認アラートを生成する。
        let alertTitle = LocalizableUtils.getString(LocalizableConst.kAlertTitleConfirm)
        let name = driveFile.name
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
            self.deleteDriveFile(driveFile, index: index)
        })
        alert.addAction(okAction)

        // アラートを表示する。
        self.presentViewController(alert, animated: true, completion: nil)
    }

    // MARK: - Refresh control

    /**
     引っ張って更新する。
     */
    override func pullRefresh() {
        getDriveFileList()
    }

    // MARK: - Toolbar Button

    /**
     作成ツールバーボタン押下時に呼び出される。
 
     - Parameter sender: 作成ツールバーボタン
     */
    @IBAction func createToolbarButtonPressed(sender: AnyObject) {
        // GoogleDrive作成画面に遷移する。
        let vc = CreateGoogleDriveFileViewController(parentId: parentId)
        navigationController?.pushViewController(vc, animated: true)
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
            let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
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
     GoogleDriveファイルを削除する。

     - Parameter driveFile: GoogleDriveファイル
     - Parameter index: インデックス
     */
    func deleteDriveFile(driveFile: GTLDriveFile, index: Int) {
        // ネットワークアクセス通知を表示する。
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

        let id = driveFile.identifier
        let query = GTLQueryDrive.queryForFilesDeleteWithFileId(id)
        let appDelegate = EnvUtils.getAppDelegate()
        let serviceDrive = appDelegate.googleDriveServiceDrive
        serviceDrive.executeQuery(query, completionHandler: { (ticket: GTLServiceTicket!, updatedFile: AnyObject!, error: NSError!) -> Void in
            // ネットワークアクセス通知を消す。
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false

            if error != nil {
                // エラーの場合、エラーアラートを表示して終了する。
                let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
                let message = LocalizableUtils.getString(LocalizableConst.kAlertMessageDeleteFileError)
                self.showAlert(title, message: message)
                return
            }

            // GoogleDriveファイルリストから削除する。
            self.driveFileList.removeAtIndex(index)

            // テーブルビューを更新する。
            self.tableView.reloadData()
        })
    }
}
