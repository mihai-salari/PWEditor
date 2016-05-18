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

    /// FTPディレクトリリスト処理
    private var ftpListDirectory: BRRequestListDirectory!

    /// FTP削除処理
    private var ftpDelete: BRRequestDelete?

    /// FTPファイル情報リスト
    private var ftpFileInfoList: [NSDictionary]?

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

        // FTPファイル情報リスト取得を開始する。
        startGetFtpFileInfoList()
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
        if ftpFileInfoList == nil {
            count = 0
        } else {
            count = ftpFileInfoList!.count
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
        if ftpFileInfoList == nil {
            return cell
        }
        let row = indexPath.row
        let count = ftpFileInfoList!.count
        if row + 1 > count {
            return cell
        }

        // ファイル名、フォルダ名を設定する。
        let ftpFileInfo = ftpFileInfoList![row]

        let name = FtpFileInfoUtils.getName(ftpFileInfo)
        cell.textLabel?.text = name

        let type = FtpFileInfoUtils.getType(ftpFileInfo)
        if type == FtpConst.FtpFileType.File {
            // ファイルの場合
            cell.accessoryType = .DetailButton

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
        if ftpFileInfoList == nil {
            return
        }
        let row = indexPath.row
        let count = ftpFileInfoList!.count
        if row + 1 > count {
            return
        }

        // ファイルタイプにより処理を判別する。
        let ftpFileInfo = ftpFileInfoList![row]
        let type = FtpFileInfoUtils.getType(ftpFileInfo)
        if type == FtpConst.FtpFileType.File {
            // ファイルの場合
            // FTPファイル表示画面に遷移する。
            let vc = ShowFtpFileViewController(ftpHostInfo: ftpHostInfo, pathName: pathName, ftpFileInfo: ftpFileInfo)
            navigationController?.pushViewController(vc, animated: true)

        } else if type == FtpConst.FtpFileType.Diretory {
            // ディレクトリの場合
            // FTPファイル一覧画面に遷移する。
            let name = FtpFileInfoUtils.getName(ftpFileInfo)
            let path = FtpUtils.getPath(pathName, name: name)
            let vc = FtpFileListViewController(ftpHostInfo: ftpHostInfo, pathName: path)
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    /**
     アクセサリボタンが押下された時に呼び出される。

     - Parameter tableView: テーブルビュー
     - Parameter indexPath: インデックスパス
     */
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        // FTPファイル情報リストが未取得の場合、処理を終了する。
        if ftpFileInfoList == nil {
            return
        }
        let row = indexPath.row
        let count = ftpFileInfoList!.count
        if row + 1 > count {
            return
        }

        // FTPファイル詳細画面に遷移する。
        let ftpFileInfo = ftpFileInfoList![row]
        let vc = FtpFileDetailViewController(ftpHostInfo: ftpHostInfo, pathName: pathName, ftpFileInfo: ftpFileInfo)
        navigationController?.pushViewController(vc, animated: true)
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
            // FTPファイル操作アクションシートを表示する。
            let row = indexPath!.row
            let ftpFileInfo = ftpFileInfoList![row]
            let type = FtpFileInfoUtils.getType(ftpFileInfo)
            if type == FtpConst.FtpFileType.Diretory {
                let name = FtpFileInfoUtils.getName(ftpFileInfo)
                if name == "." || name == ".." {
                    return
                }
            }
            let cell = tableView.cellForRowAtIndexPath(indexPath!)
            showOperateFtpFileInfoActionSheet(ftpFileInfo, index: row, cell: cell!)
        }
    }

    // MARK: - ActionSheet

    /**
     FTPファイル情報操作アクションシートを表示する。

     - Parameter ftpFileInfo: FTPファイル情報
     - Parameter index: FTPホスト情報リストの位置
     - Parameter cell: テーブルビューセル
     */
    private func showOperateFtpFileInfoActionSheet(ftpFileInfo: NSDictionary, index: Int, cell: UITableViewCell) {
        // FTPファイル情報操作アクションシートを生成する。
        let alertTitle = LocalizableUtils.getString(LocalizableConst.kActionSheetTitleFtpFile)
        let alert = UIAlertController(title: alertTitle, message: "", preferredStyle: .ActionSheet)
        // iPadでクラッシュする対応
        alert.popoverPresentationController?.sourceView = view
        alert.popoverPresentationController?.sourceRect = cell.frame

        // キャンセルボタンを生成する。
        let cancelButtonTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleCancel)
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .Cancel, handler: nil)
        alert.addAction(cancelAction)

        let type = FtpFileInfoUtils.getType(ftpFileInfo)
        if type == FtpConst.FtpFileType.File {
            // ファイルの場合
            // 編集ボタンを生成する。
            let editButtonTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleEdit)
            let editAction = UIAlertAction(title: editButtonTitle, style: .Default, handler: { (action: UIAlertAction) -> Void in
                // FTPファイル編集画面に遷移する。
                let vc = EditFtpFileViewController(ftpHostInfo: self.ftpHostInfo, pathName: self.pathName, ftpFileInfo: ftpFileInfo)
                self.navigationController?.pushViewController(vc, animated: true)
            })
            alert.addAction(editAction)

            // ダウンロードボタンを生成する。
            let downloadButtonTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleDownload)
            let downloadAction = UIAlertAction(title: downloadButtonTitle, style: .Default, handler: { (action: UIAlertAction) -> Void in
              // FTPファイルダウンロード先選択画面に遷移する。
              let vc = SelectFtpDownloadTargetViewController(ftpHostInfo: self.ftpHostInfo, pathName: self.pathName, ftpFileInfo: ftpFileInfo)
              self.navigationController?.pushViewController(vc, animated: true)
            })
            alert.addAction(downloadAction)
        }

        // 削除ボタンを生成する。
        let deleteButtonTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleDelete)
        let deleteAction = UIAlertAction(title: deleteButtonTitle, style: .Default, handler: {(action: UIAlertAction) -> Void in
            // FTPファイル情報削除確認アラートを表示する。
            self.showDeleteFtpFileInfoConfirmAlert(ftpFileInfo, index: index)
        })
        alert.addAction(deleteAction)

        // アラートを表示する。
        self.presentViewController(alert, animated: true, completion: nil)
    }

    /**
     FTPファイル情報削除確認アラートを表示する。

     - Parameter ftpFileInfo: FTPファイル情報
     - Parameter index: FTPファイル情報リストの位置
     */
    private func showDeleteFtpFileInfoConfirmAlert(ftpFileInfo: NSDictionary, index: Int) {
        // FTPファイル情報削除確認アラートを生成する。
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
            let name = FtpFileInfoUtils.getName(ftpFileInfo)
            let type = FtpFileInfoUtils.getType(ftpFileInfo)
            if type == FtpConst.FtpFileType.Diretory {
                // ディレクトリの場合
                self.deleteFtpDir(name)

            } else {
                // ディレクトリ以外の場合
                self.deleteFtpFile(name)
            }
        })
        alert.addAction(okAction)

        // アラートを表示する。
        self.presentViewController(alert, animated: true, completion: nil)
    }

    // MARK: - Refresh control

    /**
     引っ張って更新の処理を行う。
     */
    override func pullRefresh() {
        // FTPファイル情報リスト取得を開始する。
        startGetFtpFileInfoList()
    }

    // MARK: - Toobar button

    /**
     作成ツールバーボタン押下時に呼び出される。
 
     - Parameter sender: 作成ツールバーボタン
     */
    @IBAction func createToobarButtonPressed(sender: AnyObject) {
        // FTPファイル作成画面に遷移する。
        let vc = CreateFtpFileViewController(ftpHostInfo: ftpHostInfo, pathName: pathName)
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - FTP

    /**
     FTPファイル情報リストの取得を開始する。
     */
    func startGetFtpFileInfoList() {
        if ftpListDirectory != nil {
            return
        }

        // 処理中アラートは表示しない。
        // ネットワークアクセス通知を表示する。
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

        ftpListDirectory = BRRequestListDirectory(delegate: self)
        ftpListDirectory.hostname = ftpHostInfo.hostName
        ftpListDirectory.username = ftpHostInfo.userName
        ftpListDirectory.password = ftpHostInfo.password
        ftpListDirectory.path = pathName
        ftpListDirectory.start()
    }

    /**
     FTPファイルを削除する。
 
     - Parameter fileName: ファイル名
     */
    func deleteFtpFile(fileName: String) {
        ftpDelete = BRRequestDelete(delegate: self)
        if ftpDelete == nil {
            return
        }

        // 処理中アラートを表示する。
        showProcessingAlert() {
            // FTPファイルの削除を開始する。
            let path = FtpUtils.getPath(self.pathName, name: fileName)

            self.ftpDelete!.hostname = self.ftpHostInfo.hostName
            self.ftpDelete!.username = self.ftpHostInfo.userName
            self.ftpDelete!.password = self.ftpHostInfo.password
            self.ftpDelete!.path = path

            self.ftpDelete!.start()
        }
    }

    func deleteFtpDir(dirName: String) {
        ftpDelete = BRRequestDelete(delegate: self)
        if ftpDelete == nil {
            return
        }

        // 処理中アラートを表示する。
        showProcessingAlert() {
            // FTPディレクトリ削除を開始する。
            let path = FtpUtils.getDirPath(self.pathName, name: dirName)

            self.ftpDelete!.hostname = self.ftpHostInfo.hostName
            self.ftpDelete!.username = self.ftpHostInfo.userName
            self.ftpDelete!.password = self.ftpHostInfo.password
            self.ftpDelete!.path = path

            self.ftpDelete!.start()
        }
    }

    // MARK: - BRRequestDelegate

    /**
     リクエストが完了した時に呼び出される。
 
     - Parameter request: リクエスト
     */
    func requestCompleted(request: BRRequest) {
        // ネットワークアクセス通知を消す。
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false

        if ftpListDirectory != nil && request == ftpListDirectory {
            // FTPディレクトリリスト処理の場合
            // FTPファイル情報リストを取得する。
            ftpFileInfoList = ftpListDirectory.filesInfo as? [NSDictionary]

            // FTPディレクトリリスト処理をクリアする。
            ftpListDirectory = nil

            // リフレッシュコントロールを停止する。
            refreshControl?.endRefreshing()
            
            // テーブルビューを更新する。
            tableView.reloadData()

        } else if request == ftpDelete {
            // FTP削除処理の場合
            // 処理中アラートを閉じる。
            dismissProcessingAlert() {
                // FTP削除処理をクリアする。
                self.ftpDelete = nil

                // FTPファイル情報を再取得する。
                self.startGetFtpFileInfoList()
            }
        }
    }

    /**
     リクエストが失敗した時に呼び出される。
 
     - Parameter request: リクエスト
     */
    func requestFailed(request: BRRequest) {
        // ネットワークアクセス通知を消す。
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false

        if ftpListDirectory != nil && request == ftpListDirectory! {
            // FTPディレクトリリスト処理をクリアする。
            ftpListDirectory = nil

            // リフレッシュコントロールを停止する。
            refreshControl?.endRefreshing()

            // エラーの場合
            let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
            let errorCode = String(request.error.errorCode.rawValue)
            let errorMessage = request.error.message
            let message = LocalizableUtils.getStringWithArgs(LocalizableConst.kAlertMessageGetFileListError, errorCode, errorMessage)
            self.showAlert(title, message: message)

        } else if request == ftpDelete {
            // FTP削除処理の場合
            // 処理中アラートを閉じる。
            dismissProcessingAlert() {
                // FTP削除処理をクリアする。
                self.ftpDelete = nil

                // エラーアラートを表示する。
                let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
                let errorCode = String(request.error.errorCode.rawValue)
                let errorMessage = request.error.message
                let message = LocalizableUtils.getStringWithArgs(LocalizableConst.kAlertMessageFtpDeleteError, errorCode, errorMessage)
                self.showAlert(title, message: message)
            }
        }
    }

    /**
     上書きリクエストの時呼び出される。
 
     - Parameter request: リクエスト
     - Returns: 処理結果
     */
    func shouldOverwriteFileWithRequest(request: BRRequest) -> Bool {
        // 何もしない。
        return true
    }
}
