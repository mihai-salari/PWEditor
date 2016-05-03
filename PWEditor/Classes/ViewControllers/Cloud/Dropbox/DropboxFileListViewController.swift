//
//  DroboxFileListViewController.swift
//  PWEditor
//
//  Created by 二俣征嗣 on 2016/02/29.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import UIKit
import GoogleMobileAds
import SwiftyDropbox

/**
 Dropboxファイル一覧画面クラス

 - Version: 1.0 新規作成
 - Author: paveway.info@gmail.com
 */
class DropboxFileListViewController: BaseTableViewController, UIGestureRecognizerDelegate {

    // MARK: - Constatns

    /// 画面タイトル
    let kScreenTitle = LocalizableUtils.getString(LocalizableConst.kDropboxFileListScreenTitle)

    // MARK: - Variables

    /// テーブルビュー
    @IBOutlet weak var tableView: UITableView!

    /// ツールバー
    @IBOutlet weak var toolbar: UIToolbar!

    /// 追加ツールバーボタン
    @IBOutlet weak var addToobarButton: UIBarButtonItem!

    /// バナービュー
    @IBOutlet weak var bannerView: GADBannerView!

    /// パス名
    var pathName: String!

    /// Dropboxファイル情報リスト
    var fileInfoList = [DropboxFileInfo]()

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

     - Parameter pathName: パス名
     */
    init(pathName: String) {
        // 引数のデータを保存する。
        self.pathName = pathName

        // スーパークラスのメソッドを呼び出す。
        super.init(nibName: nil, bundle: nil)
    }

    // MARK: - UIViewControllerDelegate

    /**
    インスタンスが生成された時に呼び出される。
    */
    override func viewDidLoad() {
        // スーパークラスのメソッドを呼び出す。
        super.viewDidLoad()

        // 画面タイトルを設定する。
        navigationItem.title = kScreenTitle

        if pathName == "" {
            // パス名が空の場合
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
        LogUtils.w("memory error.")

        // スーパークラスのメソッドを呼び出す。
        super.didReceiveMemoryWarning()
    }

    /**
     画面が表示される前に呼び出される。

     - Parameter animated: アニメーション指定
     */
    override func viewWillAppear(animated: Bool) {
        // スーパークラスのメソッドを呼び出す。
        super.viewWillAppear(animated)

        // ファイル情報リストを取得する。
        getFileInfoList(pathName)
    }

    // MARK: - UITableViewDataSource

    /**
    セクション内のセル数を返却する。

    - Parameter tableView: テーブルビュー
    - Parameter section: セクション番号
    - Returns: セクション内のセル数
    */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // ファイル情報リストの件数を返却する。
        let count = fileInfoList.count
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

        // ファイル情報リストが未取得の場合、処理を終了する。
        let row = indexPath.row
        let count = fileInfoList.count
        if row + 1 > count {
            return cell
        }

        // セル内容をクリアする。
        cell.textLabel?.text = ""
        cell.accessoryType = .None

        let fileInfo = fileInfoList[row]
        cell.textLabel?.text = fileInfo.name
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .ByWordWrapping

        let isDir = fileInfo.isDir
        if isDir {
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

        // ファイル情報リストが未取得の場合、処理を終了する。
        let row = indexPath.row
        let count = fileInfoList.count
        if row + 1 > count {
            return
        }

        let fileInfo = fileInfoList[row]
        let isDir = fileInfo.isDir
        if isDir {
            // ディレクトリの場合
            // ドロップボックスファイル一覧画面に遷移する。
            let pathName = fileInfo.pathLower
            let vc = DropboxFileListViewController(pathName: pathName)
            navigationController?.pushViewController(vc, animated: true)

        } else {
            // ファイルの場合
            // ファイル編集画面に遷移する。
            let fileName = fileInfo.name
            let vc = EditDropboxFileViewController(pathName: pathName, fileName: fileName)
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    /**
     アクセサリボタンが押下された時に呼び出される。

     - Parameter tableView: テーブルビュー
     - Parameter indexPath: インデックスパス
     */
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row

        let count = fileInfoList.count
        if row + 1 > count {
            return
        }

        let fileInfo = fileInfoList[row]
        let vc = DropboxFileInfoViewController(fileInfo: fileInfo)
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Button handler

    /**
    セルを長押しした時に呼び出される。

    - Parameter recognizer: ジェスチャーオブジェクト
    */
    override func cellLongPressed(recognizer: UILongPressGestureRecognizer) {
        // インデックスパスを取得する。
        let point = recognizer.locationInView(tableView)
        let indexPath = tableView!.indexPathForRowAtPoint(point)

        if indexPath == nil {
            // インデックスパスが取得できない場合、処理を終了する。
            return
        }

        if recognizer.state == UIGestureRecognizerState.Began {
            // ジェスチャーが開始状態の場合
            // セル位置を取得する。
            let row = indexPath!.row
            let count = fileInfoList.count
            if row + 1 > count {
                return
            }

            // ファイル情報を取得する。
            let fileInfo = fileInfoList[row]

            // 名前を取得する。
            let name = fileInfo.name

            // Dropbox操作アクションシートを表示する。
            let cell = tableView.cellForRowAtIndexPath(indexPath!)
            showOperateDropboxActionSheet(name, index: row, cell: cell!)
        }
    }

    /**
     追加ツールバーボタンを押下した時に呼び出される。

     - Parameter sender: 追加ツールバーボタン
     */
    @IBAction func addToolbarButtonPressed(sender: AnyObject) {
        // Dropboxファイル追加画面に遷移する。
        let vc = AddDropboxFileViewController(pathName: pathName)
        navigationController?.pushViewController(vc, animated: true)
    }

    /**
     引っ張って更新の処理を行う。
     */
    override func pullRefresh() {
        // ファイル情報一覧を取得する。
        getFileInfoList(pathName)
    }

    // MARK: - ActionSheet

    /**
     Dropbox操作アクションシートを表示する。

     - Parameter name: ファイル名またはディレクトリ名
     - Parameter index: ファイル情報の位置
     - Parameter cell: テーブルビューセル
     */
    private func showOperateDropboxActionSheet(name: String, index: Int, cell: UITableViewCell) {
        // Dropbox操作アクションシートを生成する。
        let alertTitle = LocalizableUtils.getString(LocalizableConst.kActionSheetTitleDropboxFile)
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
            let vc = SelectEncodingViewController(sourceClassName: self.dynamicType.description(), pathName: self.pathName, fileName: name)
            self.navigationController?.pushViewController(vc, animated: true)
        })
        alert.addAction(openCharAction)

        // 削除ボタンを生成する。
        let deleteButtonTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleDelete)
        let deleteAction = UIAlertAction(title: deleteButtonTitle, style: .Default, handler: {(action: UIAlertAction) -> Void in
            // ファイル削除確認アラートを表示する。
            self.showDeleteFileConfirmAlert(name, index: index)
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
    private func showDeleteFileConfirmAlert(name: String, index: Int) {
        // ファイル削除確認アラートを生成する。
        let alertTitle = LocalizableUtils.getString(LocalizableConst.kAlertTitleConfirm)
        let alertMessage = LocalizableUtils.getStringWithArgs(LocalizableConst.kAlertMessageDeleteConfirm, "\(name)")
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .Alert)

        // キャンセルボタンを生成する。
        let cancelButtonTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleCancel)
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .Cancel, handler: nil)

        // 削除ボタンを生成する。
        let deleteButtonTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleDelete)
        let okAction = UIAlertAction(title: deleteButtonTitle, style: .Default, handler: {(action: UIAlertAction) -> Void in
            // 削除する。
            self.deleteFile(name, index: index)
        })

        // 各ボタンをアラートに設定する。
        alert.addAction(cancelAction)
        alert.addAction(okAction)

        // アラートを表示する。
        self.presentViewController(alert, animated: true, completion: nil)
    }

    // MARK: - Dropbox

    /**
     ファイル情報リストを取得する。

     - Parameter pathName: パス名
     - Parameter index: ファイル情報の位置
     */
    func getFileInfoList(pathName: String) {
        // リフレッシュコントロールを停止する。
        refreshControl?.endRefreshing()

        let client = Dropbox.authorizedClient
        if client == nil {
            // Dropboxが無効な場合
            // 画面構成をリセットする。
            resetScreen()
            return
        }

        // ネットワークアクセス通知を表示する。
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

        // ディレクトリ内のファイル一覧を取得する。
        client!.files.listFolder(path: pathName).response { response, error in
            // ネットワークアクセス通知を消す。
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false

            if error != nil || response == nil {
                // エラーの場合
                // エラーアラートを表示する。
                let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
                let message = LocalizableUtils.getString(LocalizableConst.kDropboxFileListGetFileInfoListError)
                self.showAlert(title, message: message, handler: nil)
                return
            }

            self.fileInfoList.removeAll(keepCapacity: false)
            let result = response
            for entry in result!.entries {
                let name = entry.name
                let pathLower = entry.pathLower
                let fileInfo = DropboxFileInfo()
                fileInfo.name = name
                fileInfo.pathLower = pathLower

                if entry.dynamicType == Files.FileMetadata.self {
                    // ファイルの場合
                    let fileMetadata = entry as! Files.FileMetadata
                    let id = fileMetadata.id
                    let size = fileMetadata.size
                    let rev = fileMetadata.rev
                    let serverModified = fileMetadata.serverModified
                    let clientModified = fileMetadata.clientModified
                    fileInfo.id = id!
                    fileInfo.size = String(size)
                    fileInfo.rev = rev
                    fileInfo.serverModified = serverModified
                    fileInfo.clientModified = clientModified
                    fileInfo.isDir = false

                } else if entry.dynamicType == Files.FolderMetadata.self {
                    // ディレクトリの場合
                    let folderMetadata = entry as! Files.FolderMetadata
                    let id = folderMetadata.id
                    fileInfo.id = id!
                    fileInfo.isDir = true
                }

                self.fileInfoList.append(fileInfo)
            }

            // テーブルビューを更新する。
            self.tableView.reloadData()
        }
    }

    /**
     ファイルを削除する。

     - Parameter name: ファイル名またはディレクトリ名
     - Parameter index: ファイル情報の位置
     */
    func deleteFile(name: String, index: Int) {
        let client = Dropbox.authorizedClient
        if client == nil {
            // Dropboxが無効な場合
            // 画面構成をリセットする。
            resetScreen()
            return
        }

        // ネットワークアクセス通知を表示する。
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

        // ファイルを削除する。
        let filePathName = "\(pathName)/\(name)"
        client!.files.delete(path: filePathName).response { response, error in
            // ネットワークアクセス通知を消す。
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false

            if error != nil || response == nil {
                // エラーの場合
                // エラーアラートを表示する。
                let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
                let message = LocalizableUtils.getString(LocalizableConst.kDropboxFileListGetFileInfoListError)
                self.showAlert(title, message: message, handler: nil)
                return
            }

            // ファイル情報リストから該当ファイル情報を削除する。
            self.fileInfoList.removeAtIndex(index)

            // テーブルビューをリロードする。
            self.tableView.reloadData()
        }
    }

    func getAccountInfo(client: DropboxClient) {
        client.users.getCurrentAccount().response { response, error in
            print("*** Get current account ***")
            if let account = response {
                print("Hello \(account.name.givenName)!")
            } else {
                print(error!)
            }
        }
    }
}
