//
//  SelectGoogleDriveDirViewController.swift
//  PWEditor
//
//  Created by mfuta1971 on 2016/06/14.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import UIKit
import GoogleMobileAds

/**
 GoogleDriveディレクトリ選択画面

 - Version: 1.0 新規作成
 - Authoer: paveway.info@gmail.com
 */
class SelectGoogleDriveDirViewController: BaseTableViewController, UIGestureRecognizerDelegate {

    // MARK: - Constatns

    /// 画面タイトル
    let kScreenTitle = LocalizableUtils.getString(LocalizableConst.kSelectGoogleDriveDirScreenTitle)

    // MARK: - Variables

    /// テーブルビュー
    @IBOutlet weak var tableView: UITableView!

    /// バナービュー
    @IBOutlet weak var bannerView: GADBannerView!

    /// 親ID
    private var parentId: String!

    /// 元ファイル
    private var fromFile: GTLDriveFile!

    /// 操作タイプ
    private var operateType: Int!

    /// ディレクトリ情報リスト
    private var dirInfoList = [GTLDriveFile]()

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
     - Parameter fromFile: 元ファイル
     - Parameter operateType: 操作タイプ
     */
    init(parentId: String, fromFile: GTLDriveFile, operateType: Int) {
        // 引数のデータを保存する。
        self.parentId = parentId
        self.fromFile = fromFile
        self.operateType = operateType

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

        // 右バーボタンを作成する。
        createRightBarButton()

        // テーブルビューを設定する。
        setupTableView(tableView)

        // セルロングタップを設定する。
        createCellLogPressed(tableView, delegate: self)

        // バナービューを設定する。
        setupBannerView(bannerView)

        if parentId.isEmpty {
            // ルートディレクトリの場合
            let dirInfo = GTLDriveFile()
            dirInfo.identifier = CommonConst.GoogleDrive.kRootParentId
            dirInfo.name = "/"
            dirInfoList.append(dirInfo)

        } else {
            // ルートディレクトリ以外の場合
            getDirInfoList()
        }
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
        // ディレクトリ情報リストの件数を返却する。
        let count = dirInfoList.count
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
        let dirInfo = dirInfoList[row]
        let name = dirInfo.name
        cell.textLabel!.text = name
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

        // 次のサブディレクトリパス名を取得する。
        let row = indexPath.row
        let dirInfo = dirInfoList[row]

        // ディレクトリ選択画面に遷移する。
        let parentId = dirInfo.identifier
        let vc = SelectGoogleDriveDirViewController(parentId: parentId, fromFile: fromFile, operateType: operateType)
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Button handler

    /**
     セルがロングタップされた時に呼び出される。

     - Parameter recognizer: セルロングタップジェスチャーオブジェクト
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
            // チェックマークを設定する。
            let cell = tableView.cellForRowAtIndexPath(indexPath!)
            if cell == nil {
                return
            }

            if cell!.accessoryType == .Checkmark {
                // チェックマークが設定されている場合
                cell!.accessoryType = .DisclosureIndicator

            } else {
                // チェックマークが設定されていない場合
                cell!.accessoryType = .Checkmark
            }

            // 選択されていないセルのチェックマークを外す。
            let count = dirInfoList.count
            let row = indexPath!.row
            for i in 0 ..< count {
                if i != row {
                    let unselectedIndexPath = NSIndexPath(forRow: i, inSection: 0)
                    let unselectedCell = tableView.cellForRowAtIndexPath(unselectedIndexPath)
                    unselectedCell?.accessoryType = .DisclosureIndicator
                }
            }
        }
    }

    // MARK: - Bar button

    /**
     右バーボタン押下時に呼び出される。

     - Parameter sender: 右バーボタン
     */
    override func rightBarButtonPressed(sender: UIButton) {
        // 選択されたディレクトリ情報を取得する。
        var dirInfo: GTLDriveFile? = nil
        let rowNum = tableView?.numberOfRowsInSection(0)
        for var i = 0; i < rowNum; i += 1 {
            let indexPath = NSIndexPath(forItem: i, inSection: 0)
            let cell = tableView?.cellForRowAtIndexPath(indexPath)
            let check = cell?.accessoryType

            if check == UITableViewCellAccessoryType.Checkmark {
                let row = indexPath.row
                dirInfo = dirInfoList[row]
                break
            }
        }

        if dirInfo == nil {
            // 選択されたディレクトリ情報が取得できない場合
            // エラーアラートを表示して終了する。
            let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
            let message = LocalizableUtils.getString(LocalizableConst.kAlertMessageDirNotSelectError)
            showAlert(title, message: message)
            return
        }

        // ディレクトリIDを取得する。
        let dirId = dirInfo!.identifier

        // 操作タイプにより処理を振り分ける。
        switch operateType {
        case CommonConst.OperateType.Copy.rawValue:
            // コピーを行う。
            copyFile(dirId)
            break

        case CommonConst.OperateType.Move.rawValue:
            // 移動を行う。
            moveFile(dirId)
            break

        default:
            // 上記以外、何もしない。
            break
        }
    }

    // MARK: - Google Drive API

    /**
     GoogleDriveディレクトリリストを取得する。
     */
    func getDirInfoList() {
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

        if let error = error {
            // エラーの場合、エラーアラートを表示して終了する。
            let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
            let message = error.localizedDescription
            showAlert(title, message: message)
            return
        }

        // GoogleDriveディレクトリ情報リストを更新する。
        dirInfoList.removeAll(keepCapacity: false)
        if let driveFiles = response.files where !driveFiles.isEmpty {
            let driveFileList = driveFiles as! [GTLDriveFile]
            for driveFile in driveFileList {
                let isDir = GoogleDriveUtils.isDir(driveFile)
                if isDir {
                    dirInfoList.append(driveFile)
                }
            }
        }

        let count = dirInfoList.count
        if count == 0 {
            // サブディレクトリが無い場合
            // エラーアラートを表示する。
            let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
            let message = LocalizableUtils.getString(LocalizableConst.kAlertMessageNoDirectoryError)
            let okButtonTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleClose)
            self.showAlert(title, message: message, okButtonTitle: okButtonTitle) {
                // 遷移元画面に戻る。
                self.navigationController?.popViewControllerAnimated(true)
            }
        }

        // テーブルビューを更新する。
        tableView.reloadData()
    }

    /**
     コピーする。

     - Parameter dirId: ディレクトリID
     */
    private func copyFile(dirId: String) {
        // ネットワークアクセス通知を表示する。
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

        // 元ID
        let fromId = fromFile.identifier

        // 名前
        let name = fromFile.name

        // コピー先ファイル
        let copyFile = GTLDriveFile()
        copyFile.name = name
        copyFile.parents = [dirId]
//        copyFile.mimeType = fromFile.mimeType

        // コピーする。
        let query = GTLQueryDrive.queryForFilesCopyWithObject(copyFile, fileId: fromId)
        let appDelegate = EnvUtils.getAppDelegate()
        let serviceDrive = appDelegate.googleDriveServiceDrive
        serviceDrive.executeQuery(query, completionHandler: { (ticket: GTLServiceTicket!, updatedFile: AnyObject!, error: NSError!) -> Void in
            // ネットワークアクセス通知を消す。
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false

            if error != nil {
                // エラーの場合
                let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
                let message = LocalizableUtils.getStringWithArgs(LocalizableConst.kAlertMessageCreateFileError, name)
                self.showAlert(title, message: message)
                return
            }

            // 遷移元画面に戻る。
            self.popViewController()
        })
    }

    /**
     移動する。

     - Parameter dirId: ディレクトリID
     */
    private func moveFile(dirId: String) {
        // ネットワークアクセス通知を表示する。
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

        // 元ID
        let fromId = fromFile.identifier

        // 名前
        let name = fromFile.name

        // コピー先ファイル
        let copyFile = GTLDriveFile()
        copyFile.name = name
        copyFile.parents = [dirId]
//        copyFile.mimeType = fromFile.mimeType

        // コピーする。
        let query = GTLQueryDrive.queryForFilesCopyWithObject(copyFile, fileId: fromId)
        let appDelegate = EnvUtils.getAppDelegate()
        let serviceDrive = appDelegate.googleDriveServiceDrive
        serviceDrive.executeQuery(query, completionHandler: { (ticket: GTLServiceTicket!, updatedFile: AnyObject!, error: NSError!) -> Void in

            // ネットワークアクセス通知を消す。
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false

            if error != nil {
                // エラーの場合
                let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
                let message = LocalizableUtils.getStringWithArgs(LocalizableConst.kAlertMessageCreateFileError, name)
                self.showAlert(title, message: message)
                return
            }

            // 元ファイルを削除する。
            self.deleteDriveFile(fromId)
        })
    }

    /**
     GoogleDriveファイルを削除する。
     */
    func deleteDriveFile(fromId: String) {
        // ネットワークアクセス通知を表示する。
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

        let query = GTLQueryDrive.queryForFilesDeleteWithFileId(fromId)
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

            // 遷移元画面に戻る。
            self.popViewController()
        })
    }

    /**
     遷移元画面に戻る。
     */
    func popViewController() {
        // 画面遷移数を取得する。
        let count = navigationController?.viewControllers.count
        // 最後に表示した画面から画面遷移数確認する。
        for var i = count! - 1; i >= 0; i-- {
            let vc = navigationController?.viewControllers[i]
            if vc!.dynamicType == GoogleDriveFileListViewController.self {
                // 表示した画面がGoogleDriveファイル一覧画面の場合
                // 画面を戻す。
                navigationController?.popToViewController(vc!, animated: true)
                break
            }
        }
    }
}
