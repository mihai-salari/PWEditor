//
//  SelectFtpUploadDirectoryListViewController.swift
//  PWEditor
//
//  Created by mfuta1971 on 2016/05/19.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import UIKit
import GoogleMobileAds

@objc protocol FtpUplaodRequest {

    func startFtpUpload(ftpHostInfo: FtpHostInfo, pathName: String, ftpDirectoryInfo: NSDictionary)
}

class SelectFtpUploadDirectoryListViewController: BaseTableViewController, UIGestureRecognizerDelegate, BRRequestDelegate {

    // MARK: - Constatns

    /// 画面タイトル
    private let kScreenTitle = LocalizableUtils.getString(LocalizableConst.kSelectFtpUploadDirectoryListScreenTitle)

    // MARK: - Variables

    /// テーブルビュー
    @IBOutlet weak var tableView: UITableView!

    /// バナービュー
    @IBOutlet weak var bannerView: GADBannerView!

    /// 遷移元画面クラス名
    private var sourceClassName: String!

    /// FTPホスト情報
    private var ftpHostInfo: FtpHostInfo!

    /// パス名
    private var pathName: String!

    /// ファイル名
    private var fileName: String!

    /// ファイルデータ
    private var fileData: NSData?

    /// FTPディレクトリリスト処理
    private var ftpListDirectory: BRRequestListDirectory!

    /// FTPディレクトリ情報リスト
    private var ftpDirectoryInfoList: [NSDictionary]?

    /// FTPアップロード処理
    private var ftpUpload: BRRequestUpload?

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

     - Parameter sourceClassName: 遷移元画面クラス名
     - Parameter ftpHostInfo: FTPホスト情報
     - Parameter pathName: パス名
     - Parameter filename: ファイル名
     - Parameter fileData: ファイルデータ
     */
    init(sourceClassName: String, ftpHostInfo: FtpHostInfo, pathName: String, fileName: String, fileData: NSData) {
        // 引数のデータを保存する。
        self.sourceClassName = sourceClassName
        self.ftpHostInfo = ftpHostInfo
        self.pathName = pathName
        self.fileName = fileName
        self.fileData = fileData

        // スーパークラスのメソッドを呼び出す。
        super.init(nibName: nil, bundle: nil)
    }

    // MARK: - UIViewController

    /**
     画面が生成された時に呼び出される。
     */
    override func viewDidLoad() {
        // スーパークラスのメソッドを呼び出す。
        super.viewDidLoad()

        // 画面タイトルを設定する。
        navigationItem.title = kScreenTitle

        // 右バーボタンを作成する。
        createRightBarButton()
        navigationItem.rightBarButtonItem?.enabled = false

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

        // FTPディレクトリ情報リスト取得を開始する。
        startGetFtpDirectoryInfoList()
    }

    // MARK: - UITableViewDataSource

    /**
     セクション内のセル数を返却する。

     - Parameter tableView: テーブルビュー
     - Parameter section: セクション番号
     - Returns: セクション内のセル数
     */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // FTPディレクトリ情報リストの件数を返却する。
        let count: Int
        if ftpDirectoryInfoList == nil {
            count = 0
        } else {
            count = ftpDirectoryInfoList!.count
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

        // FTPディレクトリ情報リストが未取得の場合、処理を終了する。
        if ftpDirectoryInfoList == nil {
            return cell
        }
        let row = indexPath.row
        let count = ftpDirectoryInfoList!.count
        if row + 1 > count {
            return cell
        }

        // ディレクトリ名を設定する。
        let ftpFileInfo = ftpDirectoryInfoList![row]
        let name = FtpFileInfoUtils.getName(ftpFileInfo)
        cell.textLabel?.text = name
        
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
        if ftpDirectoryInfoList == nil {
            return
        }
        let row = indexPath.row
        let count = ftpDirectoryInfoList!.count
        if row + 1 > count {
            return
        }

        // FTPアップロードディレクトリ一覧選択画面に遷移する。
        let ftpDirectoryInfo = ftpDirectoryInfoList![row]
        let name = FtpFileInfoUtils.getName(ftpDirectoryInfo)
        let path = FtpUtils.getPath(pathName, name: name)
        let vc = SelectFtpUploadDirectoryListViewController(sourceClassName: sourceClassName, ftpHostInfo: ftpHostInfo, pathName: path, fileName: fileName, fileData: fileData!)
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
            // チェックマークを設定する。
            let cell = tableView.cellForRowAtIndexPath(indexPath!)
            if cell == nil {
                return
            }

            if cell!.accessoryType == .Checkmark {
                cell!.accessoryType = .None
            } else {
                cell!.accessoryType = .Checkmark
            }

            // 選択されていないセルのチェックマークを外す。
            let count = ftpDirectoryInfoList!.count
            let row = indexPath!.row
            for i in 0 ..< count {
                if i != row {
                    let unselectedIndexPath = NSIndexPath(forRow: i, inSection: 0)
                    let unselectedCell = tableView.cellForRowAtIndexPath(unselectedIndexPath)
                    unselectedCell?.accessoryType = .None
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
        var ftpDirectoryInfo: NSDictionary? = nil
        let rowNum = tableView?.numberOfRowsInSection(0)
        for var i = 0; i < rowNum; i += 1 {
            let indexPath = NSIndexPath(forItem: i, inSection: 0)
            let cell = tableView?.cellForRowAtIndexPath(indexPath)
            let check = cell?.accessoryType

            if check == UITableViewCellAccessoryType.Checkmark {
                let row = indexPath.row
                ftpDirectoryInfo = ftpDirectoryInfoList![row]
                break
            }
        }

        if ftpDirectoryInfo == nil {
            // ディレクトリが選択されていない場合
            // エラーアラートを表示して、処理終了
            let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
            let message = LocalizableUtils.getString(LocalizableConst.kSelectLocalDirectoryNotSelectError)
            showAlert(title, message: message)
            return
        }

        let dirName = FtpFileInfoUtils.getName(ftpDirectoryInfo!)
        let path: String
        if pathName == "/" {
            path = "/\(dirName)/\(fileName)"
        } else {
            path = "\(pathName)/\(dirName)/\(fileName)"
        }
        startFtpUpload(path)
    }

    // MARK: - Refresh control

    /**
     引っ張って更新の処理を行う。
     */
    override func pullRefresh() {
        // FTPディレクトリ情報リスト取得を開始する。
        startGetFtpDirectoryInfoList()
    }

    // MARK: - FTP

    /**
     FTPディレクトリ情報リストの取得を開始する。
     */
    func startGetFtpDirectoryInfoList() {
        ftpListDirectory = BRRequestListDirectory(delegate: self)
        if ftpListDirectory == nil {
            return
        }

        // 処理中アラートは表示しない。
        // ネットワークアクセス通知を表示する。
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

        ftpListDirectory.hostname = ftpHostInfo.hostName
        ftpListDirectory.username = ftpHostInfo.userName
        ftpListDirectory.password = ftpHostInfo.password
        ftpListDirectory.path = pathName
        ftpListDirectory.start()
    }

    /**
     FTPアップロードを開始する。
     */
    func startFtpUpload(path: String) {
        ftpUpload = BRRequestUpload(delegate: self)
        if ftpUpload == nil {
            return
        }

        // ネットワークアクセス通知を表示する。
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

        // 処理中アラートを表示する。
        showProcessingAlert() {
            self.ftpUpload!.hostname = self.ftpHostInfo.hostName
            self.ftpUpload!.username = self.ftpHostInfo.userName
            self.ftpUpload!.password = self.ftpHostInfo.password
            self.ftpUpload!.path = path
            self.ftpUpload!.start()
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
            // FTPディレクトリ情報取得処理の場合
            // FTPディレクトリ情報リストを取得する。
            ftpDirectoryInfoList = [NSDictionary]()
            let ftpFileInfoList = ftpListDirectory.filesInfo as? [NSDictionary]
            if ftpFileInfoList != nil {
                for ftpFileInfo in ftpFileInfoList! {
                    let type = FtpFileInfoUtils.getType(ftpFileInfo)
                    if type == FtpConst.FtpFileType.Diretory {
                        let name = FtpFileInfoUtils.getName(ftpFileInfo)
                        if name != "." && name != ".." {
                            ftpDirectoryInfoList!.append(ftpFileInfo)
                        }
                    }
                }
            }

            // FTPディレクトリリスト処理をクリアする。
            ftpListDirectory = nil

            let count = ftpDirectoryInfoList!.count
            if count == 0 {
                // ディレクトリがない場合
                // エラーアラートを表示する。
                let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
                let message = LocalizableUtils.getString(LocalizableConst.kAlertMessageNoDirectoryError)
                self.showAlert(title, message: message) {
                    // 遷移元画面に戻る。
                    self.navigationController?.popViewControllerAnimated(true)
                }
                return
            }

            // 右上バーボタンを有効にする。
            navigationItem.rightBarButtonItem?.enabled = true

            // リフレッシュコントロールを停止する。
            refreshControl?.endRefreshing()

            // テーブルビューを更新する。
            tableView.reloadData()

        } else if request == ftpUpload {
            // FTPアップロード処理の場合
            // 処理中アラートを閉じる。
            dismissProcessingAlert() {
                // FTPアップロード処理をクリアする。
                self.ftpUpload = nil

                // 遷移元画面に戻る。
                self.popViewController()
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

        if ftpListDirectory != nil && request == ftpListDirectory {
            // FTPディレクトリ情報取得処理の場合
            // FTPディレクトリリスト処理をクリアする。
            ftpListDirectory = nil

            // リフレッシュコントロールを停止する。
            refreshControl?.endRefreshing()

            // エラーアラートを表示する。
            let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
            let errorCode = String(request.error.errorCode.rawValue)
            let errorMessage = request.error.message
            let message = LocalizableUtils.getStringWithArgs(LocalizableConst.kAlertMessageGetFileListError, errorCode, errorMessage)
            self.showAlert(title, message: message)

        } else if request == ftpUpload {
            // FTPアップロード処理の場合
            // FTPアップロード処理をクリアする。
            self.ftpUpload = nil

            // エラーアラートを表示する。
            let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
            let errorCode = String(request.error.errorCode.rawValue)
            let errorMessage = request.error.message
            let message = LocalizableUtils.getStringWithArgs(LocalizableConst.kAlertMessageGetFileListError, errorCode, errorMessage)
            self.showAlert(title, message: message)
        }
    }

    /**
     上書きリクエストの時呼び出される。

     - Parameter request: リクエスト
     - Returns: 処理結果
     */
    func shouldOverwriteFileWithRequest(request: BRRequest) -> Bool {
        if request == ftpUpload {
            return true

        } else {
            return false
        }
    }

    /**
     アップロードデータを送信する。

     - Parameter request: リクエスト
     - Returns: アップロードデータ
     */
    func requestDataToSend(request: BRRequestUpload) -> NSData? {
        if fileData == nil {
            return nil

        } else {
            let temp = fileData!
            fileData = nil
            return temp
        }
    }

    // MARK: - Private method

    /**
     遷移元画面に戻る。
     */
    func popViewController() {
        // 画面遷移数を取得する。
        let count = navigationController?.viewControllers.count
        // 最後に表示した画面から画面遷移数確認する。
        for var i = count! - 1; i >= 0; i-- {
            let vc = navigationController?.viewControllers[i]
            if vc!.dynamicType.description() == sourceClassName {
                // 遷移元画面クラス名の場合
                // 画面を戻す。
                navigationController?.popToViewController(vc!, animated: true)
                break
            }
        }
    }
}
