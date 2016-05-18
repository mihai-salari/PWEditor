//
//  SelectLocalDirectoryListViewController.swift
//  PWEditor
//
//  Created by mfuta1971 on 2016/05/19.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import UIKit
import GoogleMobileAds

/**
 ローカルディレクトリ選択画面
 
 - Version: 1.0 新規作成
 - Author: paveway.info@gmail.com
 */
class SelectLocalDirectoryListViewController: BaseTableViewController, UIGestureRecognizerDelegate, BRRequestDelegate {

    // MARK: - Variables

    /// テーブルビュー
    @IBOutlet weak var tableView: UITableView!

    /// バナービュー
    @IBOutlet weak var bannerView: GADBannerView!

    /// ローカルパス名
    private var localPathName: String!

    /// FTPホスト情報
    private var ftpHostInfo: FtpHostInfo!

    /// パス名
    private var pathName: String!

    /// FTPファイル情報
    private var ftpFileInfo: NSDictionary!

    /// ディレクトリ情報リスト
    private var dirInfoList = [FileInfo]()

    /// FTPダウンロード処理
    private var ftpDownload: BRRequestDownload?

    /// ダウンロードデータ
    private var downloadData = NSMutableData()

    /// ローカルファイルパス名
    private var localFilePathName: String?

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

     - Parameter localPathName: ローカルパス名
     - Parameter ftpHostInfo: FTPホスト情報
     - Parameter pathName: パス名
     - Parameter ftpFileInfo: FTPファイル情報
     */
    init(localPathName: String, ftpHostInfo: FtpHostInfo, pathName: String, ftpFileInfo: NSDictionary) {
        // 引数のデータを保存する。
        self.localPathName = localPathName
        self.ftpHostInfo = ftpHostInfo
        self.pathName = pathName
        self.ftpFileInfo = ftpFileInfo

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
        navigationItem.title = localPathName

        // 右バーボタンを作成する。
        createRightBarButton()
        navigationItem.rightBarButtonItem?.enabled = false

        // テーブルビューを設定する。
        setupTableView(tableView)

        // セルロングタップを設定する。
        createCellLogPressed(tableView, delegate: self)

        // バナービューを設定する。
        setupBannerView(bannerView)

        // ファイル情報リストを取得する。
        if localPathName.isEmpty {
            // ローカルパスが空の場合
            let dirInfo = FileInfo()
            dirInfo.name = "/"
            dirInfoList.append(dirInfo)

        } else if localPathName == "/" {
            // ローカルパスが"/"の場合
            let path = ""
            let localPath = FileUtils.getLocalPath(path)
            dirInfoList = FileUtils.getDirInfoListInDir(localPath)

        } else {
            // 上記以外
            let localPath = FileUtils.getLocalPath(localPathName)
            dirInfoList = FileUtils.getDirInfoListInDir(localPath)
        }

        let count = dirInfoList.count
        if count == 0 {
            // ディレクトリがない場合
            // エラーアラートを表示する。
            let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
            let message = LocalizableUtils.getString(LocalizableConst.kAlertMessageNoDirectoryError)
            self.showAlert(title, message: message) {
                // 遷移元画面に戻る。
                self.navigationController?.popViewControllerAnimated(true)
            }

        } else {
            // ディレクトリが存在する場合
            // 右上バーボタンを有効にする。
            navigationItem.rightBarButtonItem?.enabled = true
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

        // ディレクトリ情報リストが未取得の場合、処理を終了する。
        let row = indexPath.row
        let count = dirInfoList.count
        if row + 1 > count {
            return cell
        }

        let dirInfo = dirInfoList[row]
        let dirName = dirInfo.name
        cell.textLabel?.text = dirName
        cell.accessoryType = .None

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

        // ローカルディレクトリ選択画面に遷移する。
        let row = indexPath.row
        let dirInfo = dirInfoList[row]
        let dirName = dirInfo.name
        let localPath: String
        if localPathName.isEmpty {
            localPath = "/"

        } else if localPathName == "/" {
            localPath = "/\(dirName)"

        } else {
            localPath = "\(localPathName)/\(dirName)"
        }
        let vc = SelectLocalDirectoryListViewController(localPathName: localPath, ftpHostInfo: ftpHostInfo, pathName: pathName, ftpFileInfo: ftpFileInfo)
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
            let count = dirInfoList.count
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
        var dirInfo: FileInfo? = nil
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
            // ディレクトリが選択されていない場合
            // エラーアラートを表示して、処理終了
            let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
            let message = LocalizableUtils.getString(LocalizableConst.kSelectLocalDirectoryNotSelectError)
            showAlert(title, message: message)
            return
        }

        // ローカル
        let fileName = FtpFileInfoUtils.getName(ftpFileInfo)
        let dirName = dirInfo!.name
        let path: String
        if localPathName.isEmpty {
            path = ""

        } else if localPathName == "/" {
            path = "\(dirName)"

        } else {
            // 先頭の"/"以降を切り出す。
            let localPath = localPathName.substringFromIndex(localPathName.startIndex.advancedBy(1))
            path = "\(localPath)/\(dirName)"
        }
        let localFilePath = FileUtils.getLocalPath(path, name: fileName)

        if FileUtils.isExist(localFilePath) {
            // 同名のファイルが存在する場合
            // 確認アラートを表示する。
            let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleConfirm)
            let message = LocalizableUtils.getString(LocalizableConst.kAlertMessageSameFileName)
            let okButtonTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleOk)
            let cancelButtonTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleCancel)
            showAlertWithCancel(title, message: message, okButtonTitle: okButtonTitle, cancelButtonTitle: cancelButtonTitle) {
                // ローカルファイルパス名を保存する。
                self.localFilePathName = localFilePath

                // FTPファイルをダウンロードする。
                self.downloadFtpFile()
            }
            return
        }

        // ローカルファイルパス名を保存する。
        localFilePathName = localFilePath

        // FTPファイルをダウンロードする。
        downloadFtpFile()
    }

    // MARK: - FTP

    /**
     FTPファイルをダウンロードする。
     */
    private func downloadFtpFile() {
        // FTPダウンロード処理を生成する。
        ftpDownload = BRRequestDownload(delegate: self)
        if ftpDownload == nil {
            // FTPダウンロード処理を生成できない場合
            // エラーアラートを表示して、処理終了
            let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
            let message = LocalizableUtils.getString(LocalizableConst.kAlertMessageStartFtpError)
            showAlert(title, message: message)
            return
        }

        // 処理中アラートを表示する。
        showProcessingAlert() {
            // FTPファイルのダウンロードを開始する。
            self.ftpDownload!.hostname = self.ftpHostInfo.hostName
            self.ftpDownload!.username = self.ftpHostInfo.userName
            self.ftpDownload!.password = self.ftpHostInfo.password
            let fileName = FtpFileInfoUtils.getName(self.ftpFileInfo)
            let path = FtpUtils.getPath(self.pathName, name: fileName)
            self.ftpDownload!.path = path
            self.ftpDownload!.start()
        }
    }

    // MARK: - MBRequestDelegate

    /**
     リクエストが完了した時に呼び出される。

     - Parameter request: リクエスト
     */
    func requestCompleted(request: BRRequest) {
        // 処理中アラートを閉じる。
        dismissProcessingAlert() {
            // ネットワークアクセス通知を消す。
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false

            // FTPダウンロード処理をクリアする。
            self.ftpDownload = nil

            // ファイルを作成する。
            let fileManager = NSFileManager.defaultManager()
            let result = fileManager.createFileAtPath(self.localFilePathName!, contents: self.downloadData, attributes: nil)
            if !result {
                // ファイルが作成できない場合
                // エラーアラートを表示して、処理終了
                let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
                let pathList = self.localFilePathName!.componentsSeparatedByString("/")
                let index = pathList.count
                let fileName = pathList[index]
                let message = LocalizableUtils.getStringWithArgs(LocalizableConst.kCreateLocalFileCreateError, fileName)
                self.showAlert(title, message: message)
                return
            }

            // 遷移元画面に戻る。
            self.popViewController()
        }
    }

    /**
     リクエストが失敗した時に呼び出される。

     - Parameter request: リクエスト
     */
    func requestFailed(request: BRRequest) {
        // 処理中アラートを閉じる。
        dismissProcessingAlert() {
            // ネットワークアクセス通知を消す。
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false

            // FTPダウンロード処理をクリアする。
            self.ftpDownload = nil

            // エラーアラートを表示する。
            let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
            let pathList = self.localFilePathName!.componentsSeparatedByString("/")
            let index = pathList.count
            let fileName = pathList[index]
            let message = LocalizableUtils.getStringWithArgs(LocalizableConst.kAlertMessageFileDownloadError, fileName)
            self.showAlert(title, message: message)
        }
    }

    /**
     上書きリクエスト時に呼び出される。

     - Parameter request: リクエスト
     */
    func shouldOverwriteFileWithRequest(request: BRRequest) -> Bool {
        // 何もしない。
        return true
    }

    /**
     データを受信した時に呼び出される。

     - Parameter request: ダウンロード要求
     */
    func requestDataAvailable(request: BRRequestDownload) {
        // 受信したデータを保存する。
        downloadData.appendData(request.receivedData)
    }

    // MARK: - Private method

    /**
     遷移元画面に戻る。
     FTPファイル一覧画面に戻るための対応
     */
    func popViewController() {
        // 画面遷移数を取得する。
        let count = navigationController?.viewControllers.count
        // 最後に表示した画面から画面遷移数確認する。
        for var i = count! - 1; i >= 0; i-- {
            let vc = navigationController?.viewControllers[i]
            if vc!.dynamicType == FtpFileListViewController.self {
                // 表示した画面がFTPファイル一覧画面の場合
                // 画面を戻す。
                navigationController?.popToViewController(vc!, animated: true)
                break
            }
        }
    }
}
