//
//  ICloudFileListViewController.swift
//  PWEditor
//
//  Created by 二俣征嗣 on 2016/02/25.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import UIKit
import GoogleMobileAds

/**
 iCloudファイル一覧画面クラス

 - Version: 1.0 新規作成
 - Author: paveway.info@gmail.com
 */
class ICloudFileListViewController: BaseTableViewController, UIGestureRecognizerDelegate, iCloudDelegate {

    // MARK: - Constants

    /// 画面タイトル
    let kScreenTitle = LocalizableUtils.getString(LocalizableConst.kICloudFileListScreenTitle)

    /// 更新停止タイムアウト値
    let kStopRefreshTimeout = 10

    // MARK: - Variables

    /// テーブルビュー
    @IBOutlet weak var tableView: UITableView!

    /// ツールバー
    @IBOutlet weak var toolbar: UIToolbar!

    /// 作成ツールバーボタン
    @IBOutlet weak var createToobarButton: UIBarButtonItem!

    /// バナービュー
    @IBOutlet weak var bannerView: GADBannerView!

    /// iCloudファイル情報リスト
    private var iCloudFileInfoList = [ICloudFileInfo]()

    /// パス名
    private var pathName: String!

    /// 更新停止タイマー
    private weak var stopRefreshTimer: NSTimer?

    /// 更新停止カウンター
    private var stopRefreshCounter = 0

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

        if pathName == "/" {
            // ルートディレクトリの場合
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

        // iCloudのデリゲート設定を更新する。
        let cloud = iCloud.sharedCloud()
        cloud.delegate = self
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

        // iCloudのファイル一覧を更新する。
        // 引数のpathNameの更新のため、viewWillDisappearでクエリを停止するため、
        // 再起動する。
        // query.staredで停止中を確認すべきだが、query.staredで常にtrueが返却されるため
        // 無条件で開始する。
        let cloud = iCloud.sharedCloud()
        cloud.query.startQuery()
        cloud.updateFiles()
    }

    /**
     画面が消される前に呼び出される。
 
     - Parameter animated: アニメーション指定
     */
    override func viewWillDisappear(animated: Bool) {
        // 通知設定を解除する。
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self)

        // クエリを停止する。
        // サブディレクトリに移動した場合、クエリを停止しないと引数pathNameが更新されない。
        // viewDidDisappearで行うと遷移先画面のviewWillAppearが先に動くため、viewWillDisappearで行う。
        let cloud = iCloud.sharedCloud()
        cloud.query!.stopQuery()

        stopRefreshTimer?.invalidate()
        stopRefreshTimer = nil

        // スーパークラスのメソッドを呼び出す。
        super.viewDidDisappear(animated)
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
        let count = iCloudFileInfoList.count
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
        let count = iCloudFileInfoList.count
        if row + 1 > count {
            return cell
        }

        // セル内容をクリアする。
        cell.textLabel?.text = ""
        cell.accessoryType = .None

        let iCloudFileInfo = iCloudFileInfoList[row]
        cell.textLabel?.text = iCloudFileInfo.name

        if iCloudFileInfo.type == ICloudFileInfo.FileType.Dir.rawValue {
            // ディレクトリの場合
            cell.accessoryType = .DisclosureIndicator

        } else {
            // ファイルの場合
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
        let count = iCloudFileInfoList.count
        if row + 1 > count {
            return
        }

        let iCloudFileInfo = iCloudFileInfoList[row]
        let name = iCloudFileInfo.name
        if iCloudFileInfo.type == ICloudFileInfo.FileType.Dir.rawValue {
            // ディレクトリの場合
            // iCloudファイル一覧画面に遷移する。
            let path: String
            if pathName == "/" {
                path = "/\(name)"
            } else {
                path = "\(pathName)/\(name)"
            }
            let vc = ICloudFileListViewController(pathName: path)
            navigationController?.pushViewController(vc, animated: true)

        } else {
            // ファイルの場合
            // iCloudファイル編集画面に遷移する。
            let vc = EditICloudFileViewController(pathName: pathName, fileName: name)
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    /**
     アクセサリボタンが押下された時に呼び出される。

     - Parameter tableView: テーブルビュー
     - Parameter indexPath: インデックスパス
     */
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {

        // ファイル情報リストが未取得の場合、処理を終了する。
        let row = indexPath.row
        let count = iCloudFileInfoList.count
        if row + 1 > count {
            return
        }

        // iCloudファイル詳細画面に遷移する。
        let file = iCloudFileInfoList[row].file
        let vc = ICloudFileDetailViewController(fileInfo: file)
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Refresh control

    /**
     引っ張って更新の処理を行う。
     */
    override func pullRefresh() {
        stopRefreshCounter = 0
        let selector = #selector(update(_:))
        stopRefreshTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: selector, userInfo: nil, repeats: true)

        let cloud = iCloud.sharedCloud()
        cloud.updateFiles()
    }

    @objc private func update(timer: NSTimer) {
        stopRefreshCounter += 1
        if stopRefreshCounter > kStopRefreshTimeout {
            // リフレッシュコントロールを停止する。
            refreshControl?.endRefreshing()

            stopRefreshTimer?.invalidate()
            stopRefreshTimer = nil
        }
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
            let count = iCloudFileInfoList.count
            if row + 1 > count {
                return
            }

            // iCloudファイル操作アクションシートを表示する。
            let iCloudFileInfo = iCloudFileInfoList[row]
            let cell = tableView.cellForRowAtIndexPath(indexPath!)
            showOperateICloudFileActionSheet(iCloudFileInfo, index: row, cell: cell!)
        }
    }

    // MARK: - ActionSheet

    /**
     iCloudファイル操作アクションシートを表示する。

     - Parameter iCloudFileInfo: iCloudファイル情報
     - Parameter index: ファイルの位置
     - Parameter cell: テーブルビューセル
     */
    private func showOperateICloudFileActionSheet(iCloudFileInfo: ICloudFileInfo, index: Int, cell: UITableViewCell) {
        // iCloudファイル操作アクションシートを生成する。
        let alertTitle = LocalizableUtils.getString(LocalizableConst.kActionSheetTitleICloudFile)
        let alert = UIAlertController(title: alertTitle, message: "", preferredStyle: .ActionSheet)
        // iPadでクラッシュする対応
        alert.popoverPresentationController?.sourceView = view
        alert.popoverPresentationController?.sourceRect = cell.frame

        // キャンセルボタンを生成する。
        let cancelButtonTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleCancel)
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .Cancel, handler: nil)
        alert.addAction(cancelAction)

        let type = iCloudFileInfo.type
        if type == ICloudFileInfo.FileType.File.rawValue {
            // ファイルの場合
            // 文字エンコーディングを指定して開くボタンを生成する。
            let openCharButtonTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleOpenChar)
            let openCharAction = UIAlertAction(title: openCharButtonTitle, style: .Default, handler: {(action: UIAlertAction) -> Void in
                // 文字エンコーディング選択画面に遷移する。
                let sourceClassName = self.dynamicType.description()
                let fileName = iCloudFileInfo.name
                let vc = SelectEncodingViewController(sourceClassName: sourceClassName, pathName: self.pathName, fileName: fileName)
                self.navigationController?.pushViewController(vc, animated: true)
            })
            alert.addAction(openCharAction)
        }

        // 削除ボタンを生成する。
        let deleteButtonTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleDelete)
        let deleteAction = UIAlertAction(title: deleteButtonTitle, style: .Default, handler: {(action: UIAlertAction) -> Void in
            // ファイル削除確認アラートを表示する。
            self.showDeleteFileConfirmAlert(iCloudFileInfo, index: index)
        })
        alert.addAction(deleteAction)

        // アラートを表示する。
        self.presentViewController(alert, animated: true, completion: nil)
    }

    /**
     ファイル削除確認アラートを表示する。

     - Parameter iCloudFileInfo: iCloudファイル情報
     - Parameter index: ファイル情報の位置
     */
    private func showDeleteFileConfirmAlert(iCloudFileInfo: ICloudFileInfo, index: Int) {
        // ファイル削除確認アラートを生成する。
        let fileName = iCloudFileInfo.name
        let alertTitle = LocalizableUtils.getString(LocalizableConst.kAlertTitleConfirm)
        let alertMessage = LocalizableUtils.getStringWithArgs(LocalizableConst.kAlertMessageDeleteConfirm, fileName)
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .Alert)

        // キャンセルボタンを生成する。
        let cancelButtonTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleCancel)
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .Cancel, handler: nil)
        alert.addAction(cancelAction)

        // 削除ボタンを生成する。
        let deleteButtonTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleDelete)
        let okAction = UIAlertAction(title: deleteButtonTitle, style: .Default, handler: {(action: UIAlertAction) -> Void in
            // 削除する。
            self.deleteICloudFile(iCloudFileInfo, index: index)
        })
        alert.addAction(okAction)

        // アラートを表示する。
        self.presentViewController(alert, animated: true, completion: nil)
    }

    // MARK: - Toolbar button

    /**
     作成ツールボタンが押下された時に呼び出される。

     - Parameter sender: 作成ツールバーボタン
     */
    @IBAction func createToolbarButtonPressed(sender: AnyObject) {
        // iCloudファイル作成画面に遷移する。
        let vc = CreateICloudFileViewController(pathName: pathName)
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - iCloud

    /**
     iCloudファイルを削除する。

     - Parameter iCloudFileInfo: iCloudファイル情報
     - Parameter index: インデックス
     */
    func deleteICloudFile(iCloudFileInfo: ICloudFileInfo, index: Int) {
        let name = iCloudFileInfo.name
        let path: String
        if pathName == "/" {
            path = "/\(name)"
        } else {
            path = "\(pathName)/\(name)"
        }
        let cloud = iCloud.sharedCloud()
        cloud.deleteDocumentWithName(path, completion: { (error: NSError?) -> Void in
            if error != nil {
                // エラーの場合、エラーアラートを表示する。
                let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
                let message = LocalizableUtils.getString(LocalizableConst.kAlertMessageDeleteFileError)
                self.showAlert(title, message: message)
                return
            }

            // ファイル情報リストから削除する。
            self.iCloudFileInfoList.removeAtIndex(index)

            // テーブルビューを更新する。
            self.tableView.reloadData()
        })
    }

    // MARK: - iCloudDelegate

    func iCloudFilesDidChange(files: NSMutableArray!, withNewFileNames fileNames: NSMutableArray!) {
        // リフレッシュコントロールを停止する。
        refreshControl?.endRefreshing()
        stopRefreshTimer?.invalidate()
        stopRefreshTimer = nil

        let cloud = iCloud.sharedCloud()
        let documentsUrl = cloud.ubiquitousDocumentsDirectoryURL()
        let documentsPath = documentsUrl.path

        iCloudFileInfoList.removeAll(keepCapacity: false)
        let fileNum = files.count
        for i in 0 ..< fileNum {
            let file = files[i] as! NSMetadataItem
            let path = file.valueForKey(NSMetadataItemPathKey)

            // ドキュメントディレクトリパス名より後を(paths[1])を取得する。
            // paths[0]は空文字列となる。
            let paths = path!.componentsSeparatedByString(documentsPath!)

            // 引数のパス名(現在の対象のパス名)を"/"で分割する。
            // pathNames[0]は空文字列となる。
            let pathNames = pathName.componentsSeparatedByString("/")

            // ドキュメントディレクトリパス名より後を"/"で分割する。
            // targetPaths[0]は空文字列となる。
            let targetPath = paths[1]
            let targetPaths = targetPath.componentsSeparatedByString("/")

            if pathNames[1].isEmpty {
                // 引数pathNameが"/"の場合、pathNames[1]は空文字列となる。
                // pathNames[1]が空文字列の場合
                let count = targetPaths.count
                if count == 2 {
                    // "/"配下のファイルの場合
                    let iCloudFileInfo = ICloudFileInfo()
                    iCloudFileInfo.name = fileNames[i] as! String
                    iCloudFileInfo.type = ICloudFileInfo.FileType.File.rawValue
                    iCloudFileInfo.file = file
                    iCloudFileInfoList.append(iCloudFileInfo)

                } else if count > 2 {
                    // "/"のサブディレクトリの場合
                    // すでにファイル情報リストに存在するかチェックする。
                    let name = targetPaths[1]
                    var existFlg = false
                    for iCloudFileInfo in iCloudFileInfoList {
                        if name == iCloudFileInfo.name {
                            existFlg = true
                            break
                        }
                    }
                    if !existFlg {
                        // ファイル情報リストに存在しない場合
                        // ファイル情報リストに追加する。
                        let iCloudFileInfo = ICloudFileInfo()
                        iCloudFileInfo.name = name
                        iCloudFileInfo.type = ICloudFileInfo.FileType.Dir.rawValue
                        iCloudFileInfo.file = file
                        iCloudFileInfoList.append(iCloudFileInfo)
                    }
                }

            } else {
                // 引数pathNamesが"/xxx"の場合
                let pathNamesCount = pathNames.count
                let targetPathsCount = targetPaths.count
                if pathNamesCount < targetPathsCount {
                    // 引数pathNameより階層が深いパス名の場合
                    // 引数pathNameと一致するパス名を検索する。
                    // 例
                    // pathName="/foo"
                    // targetPath="/foo/test.txt"->対象
                    // targetPath="/dummy.txt"->対象外
                    // targetPath="/foo/hoge/sample.txt"->対象
                    var targetFlg = true
                    let count = pathNames.count
                    var index = 0
                    for j in 0 ..< count {
                        index = j
                        if pathNames[j] != targetPaths[j] {
                            targetFlg = false
                            break
                        }
                    }
                    if targetFlg {
                        let iCloudFileInfo = ICloudFileInfo()
                        iCloudFileInfo.name = targetPaths[index + 1]
                        iCloudFileInfo.file = file
                        if targetPathsCount - pathNamesCount > 1 {
                            // サブディレクトリがある場合
                            iCloudFileInfo.type = ICloudFileInfo.FileType.Dir.rawValue

                        } else {
                            // サブディレクトリがない場合
                            iCloudFileInfo.type = ICloudFileInfo.FileType.File.rawValue
                        }

                        iCloudFileInfoList.append(iCloudFileInfo)
                    }
                }
            }
        }

        // テーブルビューを更新する。
        tableView.reloadData()
    }
}
