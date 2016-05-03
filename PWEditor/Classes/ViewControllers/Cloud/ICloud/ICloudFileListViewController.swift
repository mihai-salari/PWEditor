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
class ICloudFileListViewController: BaseTableViewController {

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

    var query: NSMetadataQuery?

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

        // バナービューを設定する。
        setupBannerView(bannerView)

        // TODO: iCloud対応
        if query == nil {
            query = textDocumentQuery()

            let notificationCenter = NSNotificationCenter.defaultCenter()
            notificationCenter.addObserver(self, selector: #selector(ICloudFileListViewController.processFiles(_:)), name: NSMetadataQueryDidFinishGatheringNotification, object: nil)
            notificationCenter.addObserver(self, selector: #selector(ICloudFileListViewController.processFiles(_:)), name: NSMetadataQueryDidUpdateNotification, object: nil)
            query?.startQuery()
        }
/*
        iCoudTokenGets()

        // 初期化コードなど(Objective-C)
        // http://iphone-app-developer.seesaa.net/article/355206368.html
        // プロビジョニング、アプリの設定など
        // http://glassonion.hatenablog.com/entry/20120728/1343471940
        // iCloud上のファイル操作(少し)
        // http://miyano-harikyu.jp/sola/devlog/2013/11/22/post-113/
        // 書籍のプレビュー(一部)
        // https://books.google.co.jp/books?id=DUaLAgAAQBAJ&pg=PA232&lpg=PA232&dq=URLForUbiquityContainerIdentifier&source=bl&ots=2in1JS2xw7&sig=e53LM5zEBCbUAIifzFy2T1VPNQc&hl=ja&sa=X&ved=0ahUKEwjUh6mpgJTLAhVBjpQKHUriA_A4ChDoAQg0MAM#v=onepage&q=URLForUbiquityContainerIdentifier&f=false
        let fileManager = NSFileManager.defaultManager()

        let iCloudToken = fileManager.ubiquityIdentityToken
        if iCloudToken != nil {
            let defaultCenter = NSNotificationCenter.defaultCenter()
            let selector = Selector("iCloudAccountAvailabilityChanged:")
            defaultCenter.addObserver(self, selector: selector, name: NSUbiquityIdentityDidChangeNotification, object: nil)

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                let iCloudUrl = fileManager.URLForUbiquityContainerIdentifier(nil)
                LogUtils.d(iCloudUrl)
            });
        }
*/
    }

    func processFiles(notification: NSNotification) {
        LogUtils.d("processFiles IN")
        query?.disableUpdates()

        let results = query?.results
        let count = results?.count
        LogUtils.d("count=\(count)")
        for result in results! {
            LogUtils.d(result)
        }

        query?.enableUpdates()
    }

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

    /**
     メモリ不足の時に呼び出される。
     */
    override func didReceiveMemoryWarning() {
        LogUtils.w("memory error.")

        // スーパークラスのメソッドを呼び出す。
        super.didReceiveMemoryWarning()
    }

    override func viewDidDisappear(animated: Bool) {
        let defaultCenter = NSNotificationCenter.defaultCenter()
        defaultCenter.removeObserver(self)

        super.viewDidDisappear(animated)
    }

    // MARK: - Button handler

    /**
     作成ツールボタンが押下された時に呼び出される。

     - Parameter sender: 作成ツールバーボタン
     */
    @IBAction func createToolbarButtonPressed(sender: AnyObject) {
    }
}
