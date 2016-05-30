//
//  MenuViewController.swift
//  PWEditor
//
//  Created by 二俣征嗣 on 2016/02/19.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import UIKit
import SwiftyDropbox
import OneDriveSDK
import BoxContentSDK

/**
 メニュー画面クラス

 - Version: 1.0 新規作成
 - Author: paveway.info@gmail.com
 */
class MenuViewController: BaseTableViewController, ReceiveSignInStateDelegate, iCloudDelegate {

    // MARK: - Constants

    /// 画面タイトル
    private let kScreenTitle = LocalizableUtils.getString(LocalizableConst.kMenuScreenTitle)

    /// セクションタイトルリスト
    private let kSectionTitleList = [
        LocalizableUtils.getString(LocalizableConst.kMenuSectionTitleLocal),
        LocalizableUtils.getString(LocalizableConst.kMenuSectionTitleCloud),
        LocalizableUtils.getString(LocalizableConst.kMenuSectionTitleApp),
        LocalizableUtils.getString(LocalizableConst.kMenuSectionTitleHelp),
    ]

    /// ローカルセクションタイトルリスト
    private let kLocalTitleList = [
        LocalizableUtils.getString(LocalizableConst.kMenuCellTitleLocalFileList),
//        LocalizableUtils.getString(LocalizableConst.kMenuCellTitleRecentFileList),
    ]

    /// クラウドセクションタイトルリスト
    private let kCloudTitleList = [
        LocalizableUtils.getString(LocalizableConst.kMenuCellTitleICloud),
        LocalizableUtils.getString(LocalizableConst.kMenuCellTitleDropbox),
        LocalizableUtils.getString(LocalizableConst.kMenuCellTitleGoogleDrive),
        LocalizableUtils.getString(LocalizableConst.kMenuCellTitleOneDrive),
//        LocalizableUtils.getString(LocalizableConst.kMenuCellTitleBox),
    ]

    /// アプリケーションセクションタイトルリスト
    private let kAppTitleList = [
        LocalizableUtils.getString(LocalizableConst.kMenuCellTitleFtp),
    ]

    /// ヘルプセクションタイトルリスト
    private let kHelpTitleList = [
        LocalizableUtils.getString(LocalizableConst.kMenuCellTitleSettings),
        LocalizableUtils.getString(LocalizableConst.kMenuCellTitleAbout),
        LocalizableUtils.getString(LocalizableConst.kMenuCellTitleHistory),
        LocalizableUtils.getString(LocalizableConst.kMenuCellTitleOpenSourceLicense),
    ]

    /// セクションインデックス
    private enum SectionIndex: Int {
        case Local
        case Cloud
        case App
        case Help
    }

    /// ローカルセクションインデックス
    private enum LocalIndex: Int {
        case LocalFileList
        case RecentFileList
    }

    /// クラウドセクションインデックス
    private enum CloudIndex: Int {
        case ICloud
        case Dropbox
        case GoogleDrive
        case OneDrive
        case Box
    }

    /// アプリケーションセクションインデックス
    private enum AppIndex: Int {
        case Ftp
    }

    /// ヘルプセクションインデックス
    private enum HelpIndex: Int {
        case Settings
        case About
        case History
        case OpenSourceLicense
    }

    /// ルートパス名
    private let kRootPathName = ""

    // MARK: - Variables

    /// テーブルビュー
    @IBOutlet weak var tableView: UITableView!

    // MARK: - UIViewControllerDelegate

    override func viewDidLoad() {
        // スーパークラスのメソッドを呼び出す。
        super.viewDidLoad()

        // 画面タイトルを設定する。
        navigationItem.title = kScreenTitle

        // テーブルビューを設定する。
        setupTableView(tableView)

        // iCloudの初期化を行う。
        let cloud = iCloud.sharedCloud()
        cloud.delegate = self
        cloud.setupiCloudDocumentSyncWithUbiquityContainer(nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // iCloudのデリゲート設定を更新する。
        let cloud = iCloud.sharedCloud()
        cloud.delegate = self
        cloud.checkCloudAvailability()
    }

    // MARK: - UITableViewDataSource

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return kSectionTitleList.count
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return kSectionTitleList[section] as String
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SectionIndex.Local.rawValue:
            return kLocalTitleList.count

        case SectionIndex.Cloud.rawValue:
            return kCloudTitleList.count

        case SectionIndex.App.rawValue:
            return kAppTitleList.count

        case SectionIndex.Help.rawValue:
            return kHelpTitleList.count

        default:
            // 上記以外、ダミー値を返却する。
            return 0;
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = getTableViewCell(tableView)

        cell.textLabel?.text = ""
        cell.accessoryType = .None

        let section = indexPath.section
        let row = indexPath.row

        // セルにタイトルを設定する。
        var title = ""
        switch section {
        case SectionIndex.Local.rawValue:
            // ローカルセクションの場合
            title = kLocalTitleList[row]
            break

        case SectionIndex.Cloud.rawValue:
            // クラウドセクションの場合
            title = kCloudTitleList[row]
            switch row {
            case CloudIndex.ICloud.rawValue:
                // iCloudセルの場合
                let cloud = iCloud.sharedCloud()
                if cloud.checkCloudUbiquityContainer() {
                    // iCloudが有効な場合
                    cell.textLabel?.enabled = true

                } else {
                    // iCloudが無効な場合
                    cell.textLabel?.enabled = false
                }
                break

            case CloudIndex.Dropbox.rawValue:
                // Dropboxセルの場合
                if Dropbox.authorizedClient != nil {
                    // サインイン済みの場合
                    cell.textLabel?.enabled = true

                } else {
                    // 未サインインの場合
                    cell.textLabel?.enabled = false
                }
                break

            case CloudIndex.GoogleDrive.rawValue:
                // GoogleDriveセルの場合
                let appDelegate = EnvUtils.getAppDelegate()
                let serviceDrive = appDelegate.googleDriveServiceDrive
                if let authorizer = serviceDrive.authorizer, canAuth = authorizer.canAuthorize where canAuth {
                    // サインイン済みの場合
                    cell.textLabel?.enabled = true

                } else {
                    // 未サインインの場合
                    cell.textLabel?.enabled = false
                }
                break

            case CloudIndex.OneDrive.rawValue:
                // OneDriveセルの場合
                let client = ODClient.loadCurrentClient()
                if client != nil {
                    // サインイン済みの場合
                    cell.textLabel?.enabled = true

                } else {
                    // 未サインインの場合
                    cell.textLabel?.enabled = false
                }
                break

            case CloudIndex.Box.rawValue:
                // Boxセルの場合
                let client = BOXContentClient.defaultClient()
                client
                break

            default:
                // 上記以外、何もしない。
                break
            }
            break

        case SectionIndex.App.rawValue:
            // アプリケーションセクションの場合
            title = kAppTitleList[row]
            break

        case SectionIndex.Help.rawValue:
            // ヘルプセクションの場合
            title = kHelpTitleList[row]
            break

        default:
            // 上記以外、何もしない。
            break
        }
        cell.textLabel?.text = title

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        let section = indexPath.section
        let row = indexPath.row

        switch section {
        case SectionIndex.Local.rawValue:
            // ローカルセクションの場合
            // セルによって処理を振り分ける。
            switch row {
            case LocalIndex.LocalFileList.rawValue:
                // ローカルファイル一覧セルの場合
                // ローカルファイル一覧画面に遷移する。
                let vc = LocalFileListViewController(pathName: kRootPathName)
                resetTopView(vc)
                break

            case LocalIndex.RecentFileList.rawValue:
                // 最近使用したファイル一覧セルの場合
                // TODO: 未実装
                break

            default:
                // 上記以外、何もしない。
                break
            }
            break

        case SectionIndex.Cloud.rawValue:
            // クラウドセクションの場合
            // セルによって処理を振り分ける。
            switch row {
            case CloudIndex.ICloud.rawValue:
                // iCloudセルの場合
                let cloud = iCloud.sharedCloud()
                if cloud.checkCloudUbiquityContainer() {
                    // iCloudが有効な場合
                    // iCloudファイル一覧画面に遷移する。
                    let vc = ICloudFileListViewController(pathName: kRootPathName)
                    resetTopView(vc)
                }
                break

            case CloudIndex.Dropbox.rawValue:
                // Dropboxセルの場合
                if Dropbox.authorizedClient != nil {
                    // サインイン済みの場合
                    // Dropboxファイル一覧画面に遷移する。
                    let vc = DropboxFileListViewController(pathName: kRootPathName)
                    resetTopView(vc)
                }
                break

            case CloudIndex.GoogleDrive.rawValue:
                // GoogleDriveセルの場合
                let appDelegate = EnvUtils.getAppDelegate()
                let serviceDrive = appDelegate.googleDriveServiceDrive
                if let authorizer = serviceDrive.authorizer, canAuth = authorizer.canAuthorize where canAuth {
                    // サインイン済みの場合
                    // GoogleDriveファイル一覧画面に遷移する。
                    let parentId = CommonConst.GoogleDrive.kRootParentId
                    let vc = GoogleDriveFileListViewController(parentId: parentId)
                    resetTopView(vc)
                }
                break

            case CloudIndex.OneDrive.rawValue:
                // OneDriveセルの場合
                let client = ODClient.loadCurrentClient()
                if client != nil {
                    // サインイン済みの場合
                    // OneDriveファイル一覧画面に遷移する。
                    let itemId = "root"
                    let vc = OneDriveFileListViewController(itemId: itemId)
                    resetTopView(vc)
                }
                break

            case CloudIndex.Box.rawValue:
                // Boxセルの場合
                let client = BOXContentClient.defaultClient()
                client.authenticateWithCompletionBlock( { (user: BOXUser!, error: NSError!) -> Void in
                })
                break

            default:
                // 上記以外、何もしない。
                break
            }
            break

        case SectionIndex.App.rawValue:
            // アプリケーションセクションの場合
            switch row {
            case AppIndex.Ftp.rawValue:
                // FTPセルの場合
                // FTPホスト一覧画面に遷移する。
                let vc = FtpHostListViewController()
                resetTopView(vc)
                break

            default:
                // 上記以外、何もしない。
                break
            }
            break

        case SectionIndex.Help.rawValue:
            // ヘルプセクションの場合
            switch row {
            case HelpIndex.Settings.rawValue:
                // 設定の場合
                // 設定画面に遷移する。
                let vc = SettingsViewController()
                vc.delegate = self
                resetTopView(vc)
                break

            case HelpIndex.About.rawValue:
                // このアプリについての場合
                // バージョン情報アラートを表示する。
                let appName = EnvUtils.getAppName()
                let version: String = EnvUtils.getVersion()
                let title = LocalizableUtils.getStringWithArgs(LocalizableConst.kAlertTitleAbout, appName, version)
                let message = LocalizableUtils.getString(LocalizableConst.kAlertMessageAbout)
                let okButtonTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleClose)
                showAlert(title, message: message, okButtonTitle: okButtonTitle)
                break

            case HelpIndex.History.rawValue:
                // 更新履歴の場合
                // 更新履歴画面を表示する。
                let vc = HistoryViewController()
                resetTopView(vc)
                break

            case HelpIndex.OpenSourceLicense.rawValue:
                // オープンソースライセンスの場合
                // オープンソースライセンス一覧画面を表示する。
                let vc = OpenSourceLicenseListViewController()
                resetTopView(vc)
                break

            default:
                // 上記以外、何もしない。
                break
            }
            break

        default:
            // 上記以外、何もしない。
            break
        }
    }

    // MARK: - ReceiveSignInStateDelegate

    /**
     サインイン状態を受信する。

     - Parameter cloudNo: クラウド番号
     - Parameter state: サインイン状態
     */
    func receiveSignInState(cloudNo: Int, state: Bool) {
        // テーブルビューを更新する。
        tableView.reloadData()
    }

    // MARK: - iCloudDelegate

    /**
     iCloudの有効/無効が変更された時に呼び出される。

     - Parameter cloudIsAvailable: 有効/無効 true:有効 / false:無効
     - Parameter withUbiquityToken: ユビキタストークン
     - Parameter withUbiquityContainer: ユビキタスコンテナ
     */
    func iCloudAvailabilityDidChangeToState(cloudIsAvailable: Bool, withUbiquityToken ubiquityToken: AnyObject!, withUbiquityContainer ubiquityContainer: NSURL!) {
        NSLog("iCloudAvailabilityDidChangeToState")

        // テーブルビューを更新する。
        tableView.reloadData()
    }

    // MARK: - Google Drive API

    /**
     認証コントローラを作成する。

     - Returns: 認証コントローラ
     */
    private func createAuthController() -> GTMOAuth2ViewControllerTouch {
        let scopeString = CommonConst.GoogleDrive.kScopeList.joinWithSeparator(" ")
        let selector = #selector(viewAuthController(_:finishedWithAuth:error:))
        let appDelegate = EnvUtils.getAppDelegate()
        let clientId = appDelegate.googleDriveClientId
        let keychainItemName = CommonConst.GoogleDrive.kKeychainItemName
        let authController = GTMOAuth2ViewControllerTouch(scope: scopeString, clientID: clientId, clientSecret: nil, keychainItemName: keychainItemName, delegate: self, finishedSelector: selector)
        return authController
    }

    /**
     認証コントローラを表示する。

     - Parameter vc: ビューコントローラ
     - Parameter authResult: 認証結果
     - Parameter error: エラー情報
     */
    @objc private func viewAuthController(vc: UIViewController, finishedWithAuth authResult: GTMOAuth2Authentication, error: NSError?) {
        let appDelegate = EnvUtils.getAppDelegate()
        let serviceDrive = appDelegate.googleDriveServiceDrive
        if let error = error {
            serviceDrive.authorizer = nil
            let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
            let message = error.localizedDescription
            showAlert(title, message: message)
            return
        }

        // 認証情報を設定する。
        serviceDrive.authorizer = authResult

        // ログイン画面を閉じる。
        dismissViewControllerAnimated(true, completion: { () -> Void in
            // GoogleDriveファイル一覧画面に遷移する。
            let parentId = CommonConst.GoogleDrive.kRootParentId
            let vc = GoogleDriveFileListViewController(parentId: parentId)
            self.resetTopView(vc)
        })
    }
}
