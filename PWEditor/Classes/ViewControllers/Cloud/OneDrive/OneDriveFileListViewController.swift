//
//  OneDriveFileListViewController.swift
//  PWEditor
//
//  Created by mfuta1971 on 2016/04/21.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import UIKit
import GoogleMobileAds
import OneDriveSDK

/**
 OneDriveファイル一覧画面

 - Version: 1.0 新規作成
 - Author: paveway.info@gamil.com
 */
class OneDriveFileListViewController: BaseTableViewController, UIGestureRecognizerDelegate {

    // MARK: - Constants

    /// 画面タイトル
    let kScreenTitle = LocalizableUtils.getString(LocalizableConst.kOneDriveFileListScreenTitle)

    // MARK: - Variables

    /// テーブルビュー
    @IBOutlet weak var tableView: UITableView!

    /// ツールバー
    @IBOutlet weak var toolbar: UIToolbar!

    /// 作成ツールバーボタン
    @IBOutlet weak var createToolbarButton: UIBarButtonItem!

    /// バナービュー
    @IBOutlet weak var bannerView: GADBannerView!

    /// OneDriveアイテムID
    var itemId: String!

    /// OneDriveアイテムリスト
    var itemList = [ODItem]()

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

     - Parameter itemId: アイテムID
     */
    init(itemId: String) {
        // 引数のデータを保存する。
        self.itemId = itemId

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

        if itemId == CommonConst.GoogleDrive.kRootParentId {
            // アイテムIDがrootの場合
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

        // OneDriveファイルリストを取得する。
        self.getOneDriveFileList()
    }

    /**
     画面が非表示になった時に呼び出される。

     - Paramenter animated: アニメーション指定
     */
    override func viewDidDisappear(animated: Bool) {
        // スーパークラスのメソッドを呼び出す。
        super.viewDidDisappear(animated)

        // ネットワークアクセス通知を消す。
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }

    // MARK: - UITableViewDataSource

    /**
     セクション内のセル数を返却する。

     - Parameter tableView: テーブルビュー
     - Parameter section: セクション番号
     - Returns: セクション内のセル数
     */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // OneDriveアイテムリストの件数を返却する。
        let count = itemList.count
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

        // OneDriveアイテムリストが未取得の場合、処理を終了する。
        let row = indexPath.row
        let count = itemList.count
        if row + 1 > count {
            return cell
        }

        // ファイル名、フォルダ名を設定する。
        let item = itemList[row]
        cell.textLabel?.text = item.name
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .ByWordWrapping

        let file = item.file
        if file != nil {
            // ファイルの場合
            cell.accessoryType = .DetailDisclosureButton

        } else {
            // フォルダの場合
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

        // OneDriveアイテムリストが未取得の場合、処理を終了する。
        let row = indexPath.row
        let count = itemList.count
        if row + 1 > count {
            return
        }

        let item = itemList[row]
        let file = item.file
        if file != nil {
            // ファイルの場合
            // OneDrive編集画面に遷移する。
            let vc = EditOneDriveFileViewController(item: item)
            navigationController?.pushViewController(vc, animated: true)

        } else {
            // フォルダーの場合
            // OneDriveファイル一覧画面に遷移する。
            let itemId = item.id
            let vc = OneDriveFileListViewController(itemId: itemId)
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    /**
     アクセサリボタンが押下された時に呼び出される。

     - Parameter tableView: テーブルビュー
     - Parameter indexPath: インデックスパス
     */
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        // OneDriveアイテムリストが未取得の場合、処理を終了する。
        let row = indexPath.row
        let count = itemList.count
        if row + 1 > count {
            return
        }

        // OneDriveファイル詳細画面に遷移する。
        let item = itemList[row]
        let vc = OneDriveFileDetailViewController(item: item)
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
            let count = itemList.count
            if row + 1 > count {
                return
            }

            let item = itemList[row]
            let cell = tableView.cellForRowAtIndexPath(indexPath!)
            showOperateOneDriveFileActionSheet(item, index: row, cell: cell!)
        }
    }

    // MARK: - ActionSheet

    /**
     OneDriveファイル操作アクションシートを表示する。

     - Parameter item: OneDriveアイテム
     - Parameter index: GoogleDriveファイルの位置
     - Parameter cell: テーブルビューセル
     */
    private func showOperateOneDriveFileActionSheet(item: ODItem, index: Int, cell: UITableViewCell) {
        // OneDriveファイル操作アクションシートを生成する。
        let alertTitle = LocalizableUtils.getString(LocalizableConst.kActionSheetTitleOneDriveFile)
        let alert = UIAlertController(title: alertTitle, message: "", preferredStyle: .ActionSheet)
        // iPadでクラッシュする対応
        alert.popoverPresentationController?.sourceView = view
        alert.popoverPresentationController?.sourceRect = cell.frame

        // キャンセルボタンを生成する。
        let cancelButtonTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleCancel)
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .Cancel, handler: nil)
        alert.addAction(cancelAction)

        if item.file != nil {
            // ファイルの場合
            // 文字エンコーディングを指定して開くボタンを生成する。
            let openCharButtonTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleOpenChar)
            let openCharAction = UIAlertAction(title: openCharButtonTitle, style: .Default, handler: {(action: UIAlertAction) -> Void in
                // 文字エンコーディング選択画面に遷移する。
                let sourceClassName = self.dynamicType.description()
                let vc = SelectEncodingViewController(sourceClassName: sourceClassName, item: item)
                self.navigationController?.pushViewController(vc, animated: true)
            })
            alert.addAction(openCharAction)

            let results = FtpHostInfo.allObjects()
            let count = results.count
            if count > 0 {
                // FTPアップロードボタンを生成する。
                let ftpUploadButtonTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleFtpUpload)
                let ftpUploadAction = UIAlertAction(title: ftpUploadButtonTitle, style: .Default, handler: { (action: UIAlertAction) -> Void in
                    self.downloadFileData(item)
                })
                alert.addAction(ftpUploadAction)
            }
        }

        // 名前変更ボタンを生成する。
        let renameButtonTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleRename)
        let renameAction = UIAlertAction(title: renameButtonTitle, style: .Default, handler: { (action: UIAlertAction) -> Void in
            // OneDriveファイル名前変更画面に遷移する。
            let vc = RenameOneDriveFileViewController(item: item)
            self.navigationController?.pushViewController(vc, animated: true)
        })
        alert.addAction(renameAction)

        // コピーボタンを生成する。
        let copyButtonTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleCopy)
        let copyAction = UIAlertAction(title: copyButtonTitle, style: .Default, handler: { (action: UIAlertAction) -> Void in
            // ディレクトリ選択画面に遷移する。
            let parentItemId = ""
            let operateType = CommonConst.OperateType.Copy.rawValue
            let vc = SelectOneDriveDirViewController(parentItemId: parentItemId, fromItem: item, operateType: operateType)
            self.navigationController?.pushViewController(vc, animated: true)
        })
        alert.addAction(copyAction)

        // 移動ボタンを生成する。
        let moveButtonTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleMove)
        let moveAction = UIAlertAction(title: moveButtonTitle, style: .Default, handler: { (action: UIAlertAction) -> Void in
            // ディレクトリ選択画面に遷移する。
            let parentItemId = ""
            let operateType = CommonConst.OperateType.Move.rawValue
            let vc = SelectOneDriveDirViewController(parentItemId: parentItemId, fromItem: item, operateType: operateType)
            self.navigationController?.pushViewController(vc, animated: true)
        })
        alert.addAction(moveAction)

        // 削除ボタンを生成する。
        let deleteButtonTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleDelete)
        let deleteAction = UIAlertAction(title: deleteButtonTitle, style: .Default, handler: {(action: UIAlertAction) -> Void in
            // ファイル削除確認アラートを表示する。
            self.showDeleteFileConfirmAlert(item, index: index)
        })
        alert.addAction(deleteAction)

        // アラートを表示する。
        self.presentViewController(alert, animated: true, completion: nil)
    }

    /**
     ファイル削除確認アラートを表示する。

     - Parameter item: OneDriveアイテム
     - Parameter index: ファイル情報の位置
     */
    private func showDeleteFileConfirmAlert(item: ODItem, index: Int) {
        // ファイル削除確認アラートを生成する。
        let alertTitle = LocalizableUtils.getString(LocalizableConst.kAlertTitleConfirm)
        let name = item.name
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
            self.deleteOneDriveFile(item, index: index)
        })
        alert.addAction(okAction)

        // アラートを表示する。
        self.presentViewController(alert, animated: true, completion: nil)
    }

    // MARK: - Toolbar Button

    /**
     作成ツールバーボタン押下時に呼び出される。
 
     - Parameter sender: 作成ツールバーボタン
     */
    @IBAction func createToolbarButtonPressed(sender: AnyObject) {
        // OneDriveファイル作成画面に遷移する。
        let vc = CreateOneDriveFileViewController(parentId: itemId)
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Refresh control

    /**
     引っ張って更新の処理を行う。
     */
    override func pullRefresh() {
        // OneDriveファイル情報一覧を取得する。
        getOneDriveFileList()
    }

    // MARK: - One Drive API

    /**
     OneDriveファイルリストを取得する。
     */
    func getOneDriveFileList() {
        // リフレッシュコントロールを停止する。
        refreshControl?.endRefreshing()

        let client = ODClient.loadCurrentClient()
        if client == nil {
            // OneDriveが無効な場合
            let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
            let message = LocalizableUtils.getString(LocalizableConst.kAlertMessageOneDriveInvalid)
            showAlert(title, message: message) {
                // 画面構成をリセットする。
                self.resetScreen()
            }
            return
        }

        // ネットワークアクセス通知を表示する。
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

        // OneDriveファイルリストを取得する。
        client.drive().items(self.itemId).children().request().getWithCompletion( { (children: ODCollection?, nextRequest: ODChildrenCollectionRequest?, error: NSError?) -> Void in
            // ネットワークアクセス通知を消す。
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false

            if error != nil {
                // エラーの場合
                let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
                let errorCode = error!.code
                let errorMessage = error!.localizedDescription
                let message = LocalizableUtils.getStringWithArgs(LocalizableConst.kAlertMessageGetFileListError, errorCode, errorMessage)
                let queue = dispatch_get_main_queue()
                dispatch_async(queue) {
                    self.showAlert(title, message: message)
                }
                return
            }

            if children == nil {
                // OneDriveファイルリストが取得できない場合
                let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
                let message = LocalizableUtils.getString(LocalizableConst.kAlertMessageGetFileListFailed)
                let queue = dispatch_get_main_queue()
                dispatch_async(queue) {
                    self.showAlert(title, message: message)
                }
                return
            }

            self.itemList.removeAll(keepCapacity: false)
            for item in children!.value as! [ODItem] {
                self.itemList.append(item)
            }

            // UI操作はメインスレッドで行う。
            let queue = dispatch_get_main_queue()
            dispatch_async(queue) {
                // テーブルビューを更新する。
                self.tableView.reloadData()
            }
        })
    }

    /**
     OneDriveファイルを削除する。

     - Parameter item: OneDriveアイテム
     - Parameter index: インデックス
     */
    func deleteOneDriveFile(item: ODItem, index: Int) {
        let client = ODClient.loadCurrentClient()
        if client == nil {
            // OneDriveが無効な場合
            let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
            let message = LocalizableUtils.getString(LocalizableConst.kAlertMessageOneDriveInvalid)
            showAlert(title, message: message)
            return
        }

        // ネットワークアクセス通知を表示する。
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

        let itemId = item.id
        client.drive().items(itemId).request().deleteWithCompletion( { (error: NSError?) -> Void in
            // ネットワークアクセス通知を消す。
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false

            if error != nil {
                // エラーの場合、エラーアラートを表示して終了する。
                let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
                let message = LocalizableUtils.getString(LocalizableConst.kAlertMessageDeleteFileError)
                self.showAlertAsync(title, message: message)
                return
            }

            // OneDriveファイルリストから削除する。
            self.itemList.removeAtIndex(index)

            // UI処理はメインスレッドで行う。
            let queue = dispatch_get_main_queue()
            dispatch_async(queue) {
                // テーブルビューを更新する。
                self.tableView.reloadData()
            }
        })
    }

    /**
     ファイルデータをダウンロードする。
     */
    func downloadFileData(item: ODItem) {
        let client = ODClient.loadCurrentClient()
        if client == nil {
            // OneDriveが無効な場合
            let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
            let message = LocalizableUtils.getString(LocalizableConst.kAlertMessageOneDriveInvalid)
            showAlert(title, message: message)
            return
        }

        // ネットワークアクセス通知を表示する。
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

        client.drive().items(item.id).contentRequest().downloadWithCompletion( { (filePath: NSURL?, urlResponse: NSURLResponse?, error: NSError?) -> Void in
            // ネットワークアクセス通知を消す。
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false

            if error != nil {
                // エラーの場合
                let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
                let fileName = item.name
                let message = LocalizableUtils.getStringWithArgs(LocalizableConst.kEditOneDriveFileDownloadError, fileName)
                self.showAlertAsync(title, message: message)
                return
            }

            if filePath == nil {
                // ファイルパスが取得できない場合
                let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
                let fileName = item.name
                let message = LocalizableUtils.getStringWithArgs(LocalizableConst.kEditOneDriveFileFilePathInvalid, fileName)
                self.showAlertAsync(title, message: message)
                return
            }

            let data = NSData(contentsOfURL: filePath!)
            if data == nil {
                // データが取得できない場合
                let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
                let fileName = item.name
                let message = LocalizableUtils.getStringWithArgs(LocalizableConst.kEditOneDriveFileDownloadDataError, fileName)
                self.showAlertAsync(title, message: message)
                return
            }

            // FTPアップロードホスト選択一覧画面に遷移する。
            let fileName = item.name
            let sourceClassName = self.dynamicType.description()
            let vc = SelectFtpUploadHostListViewController(sourceClassName: sourceClassName, fileName: fileName, fileData: data!)
            let queue = dispatch_get_main_queue()
            dispatch_async(queue) {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        })
    }
}
