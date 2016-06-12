//
//  FtpHostListViewController.swift
//  PWEditor
//
//  Created by mfuta1971 on 2016/05/12.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import UIKit
import GoogleMobileAds

class FtpHostListViewController: BaseTableViewController, UIGestureRecognizerDelegate {

    // MARK: - Constatns

    /// 画面タイトル
    let kScreenTitle = LocalizableUtils.getString(LocalizableConst.kFtpHostListScreenTitle)

    // MARK: - Variables

    /// テーブルビュー
    @IBOutlet weak var tableView: UITableView!

    /// ツールバー
    @IBOutlet weak var toolbar: UIToolbar!

    /// 作成ツールバーボタン
    @IBOutlet weak var createToolbarButton: UIBarButtonItem!

    /// バナービュー
    @IBOutlet weak var bannerView: GADBannerView!

    /// FTPホスト情報リスト
    var ftpHostInfoList = [FtpHostInfo]()

    // MARK: - UIViewController

    /**
     画面が生成された時に呼び出される。
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
        super.didReceiveMemoryWarning()
    }

    /**
     画面が表示される時に呼び出される。
 
     - Parameter animated: アニメーション指定
     */
    override func viewWillAppear(animated: Bool) {
        // スーパークラスのメソッドを呼び出す。
        super.viewWillAppear(animated)

        ftpHostInfoList.removeAll(keepCapacity: false)

//        let realm = RLMRealm.defaultRealm()
//        let realmURL = realm.configuration.fileURL!
//        let realmURLs = [
//            realmURL,
//            realmURL.URLByAppendingPathExtension("lock"),
//            realmURL.URLByAppendingPathExtension("log_a"),
//            realmURL.URLByAppendingPathExtension("log_b"),
//            realmURL.URLByAppendingPathExtension("note")
//        ]
//        let manager = NSFileManager.defaultManager()
//        for URL in realmURLs {
//            do {
//                try manager.removeItemAtURL(URL)
//            } catch {
//                // handle error
//            }
//        }

        // NSUserDefaultに保存された旧データをRealmに保存し直す。
        let displayName = FtpHostUtils.getDisplayName()
        if !displayName.isEmpty {
            let ftpHostInfo = FtpHostInfo()
            ftpHostInfo.displayName = displayName
            ftpHostInfo.hostName = FtpHostUtils.getHostName()
            let userName = FtpHostUtils.getUserName()
            if userName.isEmpty {
                ftpHostInfo.userName = nil
            } else {
                ftpHostInfo.userName = userName
            }
            let password = FtpHostUtils.getPassword()
            if password.isEmpty {
                ftpHostInfo.password = nil
            } else {
                ftpHostInfo.password = password
            }

            // FTPホスト情報をRealmに保存する。
            let realm = RLMRealm.defaultRealm()
            do {
                try realm.transactionWithBlock() {
                    realm.addObject(ftpHostInfo)
                }
            } catch {
                let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
                let message = LocalizableUtils.getString(LocalizableConst.kFtpHostListSaveError)
                self.showAlert(title, message: message)
                return
            }

            // NSUserDefaultからFTPホスト情報を削除する。
            FtpHostUtils.delete()
        }

        // FTPホスト情報を取得する。
        let results = FtpHostInfo.allObjects()
        let count = results.count
        for i in 0 ..< count {
            let result = results.objectAtIndex(i)
            let ftpHostInfo = result as! FtpHostInfo
            self.ftpHostInfoList.append(ftpHostInfo)
        }
    }

    // MARK: - UITableViewDataSource

    /**
     セクション内のセル数を返却する。

     - Parameter tableView: テーブルビュー
     - Parameter section: セクション番号
     - Returns: セクション内のセル数
     */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = ftpHostInfoList.count
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
        let count = ftpHostInfoList.count
        if row + 1 > count {
            return cell
        }

        let ftpHost = ftpHostInfoList[row]
        cell.textLabel?.text = ftpHost.displayName
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

        // FTPファイル一覧画面に遷移する。
        let row = indexPath.row
        let ftpHostInfo = ftpHostInfoList[row]
        let pathName = "/"
        let vc = FtpFileListViewController(ftpHostInfo: ftpHostInfo, pathName: pathName)
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
            let row = indexPath!.row
            let ftpHostInfo = ftpHostInfoList[row]
            let cell = tableView.cellForRowAtIndexPath(indexPath!)
            showOperateFtpHostInfoActionSheet(ftpHostInfo, index: row, cell: cell!)
        }
    }

    // MARK: - ActionSheet

    /**
     FTPホスト情報操作アクションシートを表示する。

     - Parameter ftpHostInfo: FTPホスト除法
     - Parameter index: FTPホスト情報リストの位置
     - Parameter cell: テーブルビューセル
     */
    private func showOperateFtpHostInfoActionSheet(ftpHostInfo: FtpHostInfo, index: Int, cell: UITableViewCell) {
        // FTPホスト情報操作アクションシートを生成する。
        let alertTitle = LocalizableUtils.getString(LocalizableConst.kActionSheetTitleFtpHostInfo)
        let alert = UIAlertController(title: alertTitle, message: "", preferredStyle: .ActionSheet)
        // iPadでクラッシュする対応
        alert.popoverPresentationController?.sourceView = view
        alert.popoverPresentationController?.sourceRect = cell.frame

        // キャンセルボタンを生成する。
        let cancelButtonTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleCancel)
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .Cancel, handler: nil)
        alert.addAction(cancelAction)

        // 編集ボタンを生成する。
        let editButtonTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleEdit)
        let editAction = UIAlertAction(title: editButtonTitle, style: .Default, handler: { (action: UIAlertAction) -> Void in
            // FTPホスト作成画面に遷移する。
            let vc = CreateFtpHostViewController(ftpHostInfo: ftpHostInfo)
            self.navigationController?.pushViewController(vc, animated: true)
        })
        alert.addAction(editAction)

        // 削除ボタンを生成する。
        let deleteButtonTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleDelete)
        let deleteAction = UIAlertAction(title: deleteButtonTitle, style: .Default, handler: {(action: UIAlertAction) -> Void in
            // FTPホスト情報削除確認アラートを表示する。
            self.showDeleteFtpHostInfoConfirmAlert(ftpHostInfo, index: index)
        })
        alert.addAction(deleteAction)

        // アラートを表示する。
        self.presentViewController(alert, animated: true, completion: nil)
    }

    /**
     FTPホスト情報削除確認アラートを表示する。

     - Parameter ftpHostInfo: FTPホスト情報
     - Parameter index: FTPホスト情報リストの位置
     */
    private func showDeleteFtpHostInfoConfirmAlert(ftpHostInfo: FtpHostInfo, index: Int) {
        // FTPホスト情報削除確認アラートを生成する。
        let alertTitle = LocalizableUtils.getString(LocalizableConst.kAlertTitleConfirm)
        let displayName = ftpHostInfo.displayName
        let alertMessage = LocalizableUtils.getStringWithArgs(LocalizableConst.kAlertMessageDeleteConfirm, displayName)
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .Alert)

        // キャンセルボタンを生成する。
        let cancelButtonTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleCancel)
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .Cancel, handler: nil)
        alert.addAction(cancelAction)

        // 削除ボタンを生成する。
        let deleteButtonTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleDelete)

        // OKボタンを生成する。
        let okAction = UIAlertAction(title: deleteButtonTitle, style: .Default, handler: {(action: UIAlertAction) -> Void in
            let realm = RLMRealm.defaultRealm()
            do {
                try realm.transactionWithBlock() {
                    realm.deleteObject(ftpHostInfo)
                }
            } catch {
                let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
                let message = LocalizableUtils.getString(LocalizableConst.kFtpHostListDeleteError)
                self.showAlert(title, message: message)
                return
            }

            // FTPホスト情報リストから削除する。
            self.ftpHostInfoList.removeAtIndex(index)

            // テーブルビューを更新する。
            self.tableView.reloadData()
        })
        alert.addAction(okAction)

        // アラートを表示する。
        self.presentViewController(alert, animated: true, completion: nil)
    }

    // MARK: - Toolbar button

    /**
     作成ツールバーボタン押下時に呼び出される。
 
     - Parameter sender: 作成ツールバーボタン
     */
    @IBAction func createToobarButtonPressed(sender: AnyObject) {
        // FTPホスト作成画面に遷移する。
        let vc = CreateFtpHostViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
