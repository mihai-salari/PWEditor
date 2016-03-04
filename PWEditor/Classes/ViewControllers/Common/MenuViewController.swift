//
//  MenuViewController.swift
//  PWEditor
//
//  Created by 二俣征嗣 on 2016/02/19.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import UIKit
import SwiftyDropbox

/**
 メニュー画面クラス

 - Version: 1.0 新規作成
 - Author: paveway.info@gmail.com
 */
class MenuViewController: BaseTableViewController, ReceiveSignInStateDelegate {

    // MARK: - Constants

    /// 画面タイトル
    let kScreenTitle = LocalizableUtils.getString(LocalizableConst.kMenuScreenTitle)

    /// セクションタイトルリスト
    let kSectionTitleList = [
        LocalizableUtils.getString(LocalizableConst.kMenuSectionTitleLocal),
        LocalizableUtils.getString(LocalizableConst.kMenuSectionTitleCloud),
        LocalizableUtils.getString(LocalizableConst.kMenuSectionTitleHelp),
    ]

    /// ローカルセクションタイトルリスト
    let kLocalTitleList = [
        LocalizableUtils.getString(LocalizableConst.kMenuCellTitleLocalFileList),
//        LocalizableUtils.getString(LocalizableConst.kMenuCellTitleRecentFileList)
    ]

    /// クラウドセクションタイトルリスト
    let kCloudTitleList = [
//        LocalizableUtils.getString(LocalizableConst.kMenuCellTitleICloud),
        LocalizableUtils.getString(LocalizableConst.kMenuCellTitleDropbox),
//        LocalizableUtils.getString(LocalizableConst.kMenuCellTitleGoogleDrive),
//        LocalizableUtils.getString(LocalizableConst.kMenuCellTitleOneDrive)
    ]

    /// ヘルプセクションタイトルリスト
    let kHelpTitleList = [
        LocalizableUtils.getString(LocalizableConst.kMenuCellTitleSettings),
        LocalizableUtils.getString(LocalizableConst.kMenuCellTitleAbout),
        LocalizableUtils.getString(LocalizableConst.kMenuCellTitleHistory),
        LocalizableUtils.getString(LocalizableConst.kMenuCellTitleOpenSourceLicense)
    ]

    /// セクションインデックス
    enum SectionIndex: Int {
        case Local = 0
        case Cloud = 1
        case Help = 2
    }

    /// ローカルセクションインデックス
    enum LocalIndex: Int {
        case LocalFileList = 0
        case RecentFileList = 1
    }

    /// クラウドセクションインデックス
    enum CloudIndex: Int {
//        case ICloud = 0
        case Dropbox = 0
        case GoogleDrive = 2
        case OneDrive = 3
    }

    /// ヘルプセクションインデックス
    enum HelpIndex: Int {
        case Settings = 0
        case About = 1
        case History = 2
        case OpenSourceLicense = 3
    }

    /// ルートパス名
    let kRootPathName = ""

    // MARK: - Variables

    @IBOutlet weak var tableView: UITableView!

    // MARK: - UIViewControllerDelegate

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = kScreenTitle

        setupTableView(tableView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
            title = kLocalTitleList[row]
            break

        case SectionIndex.Cloud.rawValue:
            title = kCloudTitleList[row]
            switch row {
            case CloudIndex.Dropbox.rawValue:
                if Dropbox.authorizedClient == nil {
                    cell.textLabel?.enabled = false
                } else {
                    cell.textLabel?.enabled = true
                }
                break

            default:
                break
            }
            break

        case SectionIndex.Help.rawValue:
            title = kHelpTitleList[row]
            break

        default:
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
            switch row {
            case LocalIndex.LocalFileList.rawValue:
                let vc = LocalFileListViewController(pathName: kRootPathName)
                resetTopView(vc)
                break

            case LocalIndex.RecentFileList.rawValue:
                break

            default:
                break
            }
            break

        case SectionIndex.Cloud.rawValue:
            switch row {
//            case CloudIndex.ICloud.rawValue:
//                let vc = ICloudFileListViewController(pathName: kRootPathName)
//                resetTopView(vc)
//                break

            case CloudIndex.Dropbox.rawValue:
                if Dropbox.authorizedClient != nil {
                    // Dropboxにログイン済みの場合
                    // Dropboxファイル一覧画面に遷移する。
                    let vc = DropboxFileListViewController(pathName: kRootPathName)
                    resetTopView(vc)
                }
                break

            case CloudIndex.GoogleDrive.rawValue:
                break

            case CloudIndex.OneDrive.rawValue:
                break

            default:
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
}
