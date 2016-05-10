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

    // MARK: - Variables

    /// テーブルビュー
    @IBOutlet weak var tableView: UITableView!

    /// ツールバー
    @IBOutlet weak var toolbar: UIToolbar!

    /// 作成ツールバーボタン
    @IBOutlet weak var createToobarButton: UIBarButtonItem!

    /// バナービュー
    @IBOutlet weak var bannerView: GADBannerView!

    /// ファイル情報リスト
    var fileInfoList = NSMutableArray()

    /// ファイル名リスト
    var fileNameList = NSMutableArray()

    /// パス名
    var pathName: String!

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

        // 左バーボタンを作成する。
        createLeftBarButton()

        // テーブルビューを設定する。
        setupTableView(tableView)

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

        // iCloudのデリゲート設定を更新する。
        let cloud = iCloud.sharedCloud()
        cloud.delegate = self

        // iCloudのファイル一覧を更新する。
        cloud.updateFiles()
    }

//    override func viewDidDisappear(animated: Bool) {
//        let defaultCenter = NSNotificationCenter.defaultCenter()
//        defaultCenter.removeObserver(self)
//
//        super.viewDidDisappear(animated)
//    }

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

        let fileName = fileNameList[row] as! String
        cell.textLabel?.text = fileName
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .ByWordWrapping

        let fileInfo = fileInfoList[row]
//        let isDir = fileInfo.isDir
//        if isDir {
//            cell.accessoryType = .DisclosureIndicator
//
//        } else {
            cell.accessoryType = .DetailButton
//        }

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

        // TODO: 本来はディレクトリとファイル判定が必要
        let fileName = fileNameList[row] as! String
        let vc = EditICloudFileViewController(fileName: fileName)
        navigationController?.pushViewController(vc, animated: true)
    }

    /**
     アクセサリボタンが押下された時に呼び出される。

     - Parameter tableView: テーブルビュー
     - Parameter indexPath: インデックスパス
     */
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {

        // ファイル情報リストが未取得の場合、処理を終了する。
        let row = indexPath.row
        let count = fileInfoList.count
        if row + 1 > count {
            return
        }

        // iCloudファイル詳細画面に遷移する。
        let fileInfo = fileInfoList[row] as! NSMetadataItem
        let vc = ICloudFileDetailViewController(fileInfo: fileInfo)
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
            let count = fileInfoList.count
            if row + 1 > count {
                return
            }

            let fileInfo = fileInfoList[row] as! NSMetadataItem
            let fileName = fileNameList[row] as! String
            let cell = tableView.cellForRowAtIndexPath(indexPath!)
            showOperateICloudFileActionSheet(fileInfo, fileName: fileName, index: row, cell: cell!)
        }
    }

    // MARK: - ActionSheet

    /**
     iCloudファイル操作アクションシートを表示する。

     - Parameter fileInfo: ファイル情報
     - Parameter fileName: ファイル名
     - Parameter index: ファイルの位置
     - Parameter cell: テーブルビューセル
     */
    private func showOperateICloudFileActionSheet(fileInfo: NSMetadataItem, fileName: String, index: Int, cell: UITableViewCell) {
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

//        let dir = GoogleDriveUtils.isDir(driveFile)
//        if !dir {
//            // ファイルの場合
//            // 文字エンコーディングを指定して開くボタンを生成する。
//            let openCharButtonTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleOpenChar)
//            let openCharAction = UIAlertAction(title: openCharButtonTitle, style: .Default, handler: {(action: UIAlertAction) -> Void in
//                // 文字エンコーディング選択画面に遷移する。
//                let sourceClassName = self.dynamicType.description()
//                let vc = SelectEncodingViewController(sourceClassName: sourceClassName, driveFile: driveFile)
//                self.navigationController?.pushViewController(vc, animated: true)
//            })
//            alert.addAction(openCharAction)
//        }

        // 削除ボタンを生成する。
        let deleteButtonTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleDelete)
        let deleteAction = UIAlertAction(title: deleteButtonTitle, style: .Default, handler: {(action: UIAlertAction) -> Void in
            // ファイル削除確認アラートを表示する。
            self.showDeleteFileConfirmAlert(fileInfo, fileName: fileName, index: index)
        })
        alert.addAction(deleteAction)

        // アラートを表示する。
        self.presentViewController(alert, animated: true, completion: nil)
    }

    /**
     ファイル削除確認アラートを表示する。

     - Parameter fileInfo: ファイル情報
     - Parameter fileName: ファイル名
     - Parameter index: ファイル情報の位置
     */
    private func showDeleteFileConfirmAlert(fileInfo: NSMetadataItem, fileName: String, index: Int) {
        // ファイル削除確認アラートを生成する。
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
            self.deleteICloudFile(fileName, index: index)
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
        let vc = CreateICloudFileViewController(pathName: "")
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - iCloud

    /**
     iCloudファイルを削除する。

     - Parameter fileName: ファイル名
     - Parameter index: インデックス
     */
    func deleteICloudFile(fileName: String, index: Int) {
        let cloud = iCloud.sharedCloud()
        cloud.deleteDocumentWithName(fileName, completion: { (error: NSError?) -> Void in
            if error != nil {
                // エラーの場合、エラーアラートを表示する。
                let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
                let message = LocalizableUtils.getString(LocalizableConst.kAlertMessageDeleteFileError)
                self.showAlert(title, message: message)
                return
            }

            // ファイル情報リストから削除する。
            self.fileInfoList.removeObjectAtIndex(index)

            // テーブルビューを更新する。
            self.tableView.reloadData()
        })
    }

    // MARK: - iCloudDelegate

    func iCloudFilesDidChange(files: NSMutableArray!, withNewFileNames fileNames: NSMutableArray!) {
        // ファイル情報リスト、ファイル名リストを保存する。
        fileInfoList = files
        fileNameList = fileNames

        // テーブルビューを更新する。
        tableView.reloadData()
    }














    func icloud() {
        //        // TODO: iCloud対応
        //        let cloud = ICloud.sharedManager
        //        cloud.delegate = self
        //        cloud.setupiCloudDocumentSyncWithUbiquityContainer(nil)
        //        let cloudAvailable = cloud.checkCloudAvailability()
        //        if !cloudAvailable {
        //            NSLog("iCloud not avaiable.")
        //        }

        //        if query == nil {
        //            query = textDocumentQuery()
        //
        //            let notificationCenter = NSNotificationCenter.defaultCenter()
        //            notificationCenter.addObserver(self, selector: #selector(ICloudFileListViewController.processFiles(_:)), name: NSMetadataQueryDidFinishGatheringNotification, object: nil)
        //            notificationCenter.addObserver(self, selector: #selector(ICloudFileListViewController.processFiles(_:)), name: NSMetadataQueryDidUpdateNotification, object: nil)
        //            query?.startQuery()
        //        }
        ///*
        //        iCoudTokenGets()
        //
        //        // 初期化コードなど(Objective-C)
        //        // http://iphone-app-developer.seesaa.net/article/355206368.html
        //        // プロビジョニング、アプリの設定など
        //        // http://glassonion.hatenablog.com/entry/20120728/1343471940
        //        // iCloud上のファイル操作(少し)
        //        // http://miyano-harikyu.jp/sola/devlog/2013/11/22/post-113/
        //        // 書籍のプレビュー(一部)
        //        // https://books.google.co.jp/books?id=DUaLAgAAQBAJ&pg=PA232&lpg=PA232&dq=URLForUbiquityContainerIdentifier&source=bl&ots=2in1JS2xw7&sig=e53LM5zEBCbUAIifzFy2T1VPNQc&hl=ja&sa=X&ved=0ahUKEwjUh6mpgJTLAhVBjpQKHUriA_A4ChDoAQg0MAM#v=onepage&q=URLForUbiquityContainerIdentifier&f=false
        //        let fileManager = NSFileManager.defaultManager()
        //
        //        let iCloudToken = fileManager.ubiquityIdentityToken
        //        if iCloudToken != nil {
        //            let defaultCenter = NSNotificationCenter.defaultCenter()
        //            let selector = Selector("iCloudAccountAvailabilityChanged:")
        //            defaultCenter.addObserver(self, selector: selector, name: NSUbiquityIdentityDidChangeNotification, object: nil)
        //
        //            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
        //                let iCloudUrl = fileManager.URLForUbiquityContainerIdentifier(nil)
        //                LogUtils.d(iCloudUrl)
        //            });
        //        }
        //*/
    }

//    func processFiles(notification: NSNotification) {
//        LogUtils.d("processFiles IN")
//        query?.disableUpdates()
//
//        let results = query?.results
//        let count = results?.count
//        LogUtils.d("count=\(count)")
//        for result in results! {
//            LogUtils.d(result)
//        }
//
//        query?.enableUpdates()
//    }

    func textDocumentQuery() -> NSMetadataQuery {
        LogUtils.d("textDocumentQuery IN")
        let query = NSMetadataQuery()
        query.searchScopes = [NSMetadataQueryAccessibleUbiquitousExternalDocumentsScope]
        let filePattern = "*.*"
        query.predicate = NSPredicate(format: "%K LIKE %@", NSMetadataItemFSNameKey, filePattern)
        LogUtils.d("textDocumentQuery OUT(OK)")
        return query
    }

    func iCoudTokenGets() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let firstLaunchWithiCloudAvailable = userDefaults.boolForKey("iCoudUse")

        let fileManager = NSFileManager.defaultManager()
        let currentiCloudToken = fileManager.ubiquityIdentityToken
        if currentiCloudToken != nil {
            let newTokenData = NSKeyedArchiver.archivedDataWithRootObject(currentiCloudToken!)
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(newTokenData, forKey: "info.paveway.PWEditor.UbiquityIdentityToken")

            let notificationCenter = NSNotificationCenter.defaultCenter()
            let selector = Selector("iCloudAccountAvailabilityChanged:")
            notificationCenter.addObserver(self, selector: selector, name: NSUbiquityIdentityDidChangeNotification, object: nil)

            let alert = UIAlertController(title: "ストレージオプション選択", message: "iCloudストレージを有効にしてもよろしいでしょうか。", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "iCloud使用", style: .Default, handler: { (alertAction: UIAlertAction) -> Void in
                let userDefaults = NSUserDefaults.standardUserDefaults()
                userDefaults.setBool(true, forKey: "iCoudUse")
                self.initializeiCloudAccess()
            })
            alert.addAction(okAction)

            let cancelAction = UIAlertAction(title: "ローカルのみ", style: .Cancel, handler: { (alertAction: UIAlertAction) -> Void in
                let userDefaults = NSUserDefaults.standardUserDefaults()
                userDefaults.setBool(false, forKey: "iCoudUse")
                self.initializeiCloudAccess()
            })
            alert.addAction(cancelAction)
            self.presentViewController(alert, animated: true, completion: nil)

        } else {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.removeObjectForKey("info.paveway.PWEditor.UbiquityIdentityToken")
        }
    }

    func iCloudAccountAvailabilityChanged(notification: NSNotification) {
        let fileManager = NSFileManager.defaultManager()
        let newICloudToken = fileManager.ubiquityIdentityToken
        if newICloudToken != nil {

        }
    }

    func initializeiCloudAccess() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let fileManager = NSFileManager.defaultManager()
            let iCoudId = fileManager.URLForUbiquityContainerIdentifier(nil)
            if iCoudId != nil {
                LogUtils.d("iCloud is avaiable")
            } else {
                LogUtils.d("This Apps requires iCloud, but it is not available.")
            }
        })
    }

    /*
    func initializeiCloudAccess() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let fileManager = NSFileManager.defaultManager()
            let iCloudToken = fileManager.ubiquityIdentityToken
            if iCloudToken != nil {
                let iCloudTokenData = NSKeyedArchiver.archivedDataWithRootObject(iCloudToken!)
                let userDefaults = NSUserDefaults.standardUserDefaults()
                userDefaults.setObject(iCloudTokenData, forKey: "info.paveway.PWEditor.UbiquityIdentityToken")

                let notificationCenter = NSNotificationCenter.defaultCenter()
                let selector = Selector("iCloudAccountAvailabilityChanged:")
                notificationCenter.addObserver(self, selector: selector, name: NSUbiquityIdentityDidChangeNotification, object: nil)
            }
        })
    }
    */


}
