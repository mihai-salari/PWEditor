//
//  SettingViewController.swift
//  pwhub
//
//  Created by 二俣征嗣 on 2015/10/13.
//  Copyright © 2015年 Masatsugu Futamata. All rights reserved.
//

import UIKit
import GoogleMobileAds
import SwiftyDropbox

/**
 サインイン状態受信デリゲート
 */
@objc protocol ReceiveSignInStateDelegate {

    /**
     サインイン状態を受信する。

     - Parameter cloudNo: クラウド番号
     - Parameter state: サインイン状態
     */
    func receiveSignInState(cloudNo: Int, state: Bool)
}

/**
 設定画面

 - Version: 1.0 新規作成
 - Authoer: paveway.info@gmail.com
 */
class SettingsViewController: BaseTableViewController, ReceiveNumberDelegate {

    // MARK: - Constants

    /// 画面タイトル
    let kScreenTitle = LocalizableUtils.getString(LocalizableConst.kSettingsScreenTitle)

    let kSectionTitleList = [
        LocalizableUtils.getString(LocalizableConst.kSettingsSectionTitleFont),
        LocalizableUtils.getString(LocalizableConst.kSettingsSectionTitleCloud)
    ]

    /// フォントセルタイトルリスト
    let kFontCellTitleList = [
        LocalizableUtils.getString(LocalizableConst.kSettingsCellTitleEnterDataFontName),
        LocalizableUtils.getString(LocalizableConst.kSettingsCellTitleEnterDataFontSize)
    ]

    /// クラウドセルタイトル
    let kCloudCellTitleList = [
        LocalizableUtils.getString(LocalizableConst.kSettingsCellTitleDropbox)
    ]

    /// セクションインデックス
    enum SectionIndex: Int {
        case Font = 0
        case Cloud = 1
    }

    /// フォントセルインデックス
    enum FontCellIndex: Int {
        /// コンテンツ用フォント名
        case ContentsFontName = 0

        /// コンテンツ用フォントサイズ
        case ContentsFontSize = 1
    }

    /// クラウドセルインデックス
    enum CloudCellIndex: Int {
        case Dropbox = 0
        case GoogleDrive = 1
        case OneDrive = 2
    }

    // Variables

    /// テーブルビュー
    @IBOutlet weak var tableView: UITableView!

    /// バナービュー
    @IBOutlet weak var bannerView: GADBannerView!

    var delegate: ReceiveSignInStateDelegate?

    // MARK: - UIViewControllerDelegate

    /**
     インスタンスが生成された時に呼び出される。
     */
    override func viewDidLoad() {
        // スーパークラスのメソッドを呼び出す。
        super.viewDidLoad()

        // 画面タイトルを設定する。
        navigationItem.title = kScreenTitle

        // 左上バーボタンを生成する。
        createLeftBarButton()

        // テーブルビューを設定する。
        setupTableView(tableView)

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

        tableView?.reloadData()
    }

    // MARK: - UITableViewDataSource

    /**
     セクション数を返却する。

     - Parameter tableView: テーブルビュー
     - Returns: セクション数
     */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return kSectionTitleList.count
    }

    /**
     セクションのタイトルを返却する。

     - Parameter tableView: テーブルビュー
     - Parameter section: セクション
     - Returns: セクションのタイトル
     */
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return kSectionTitleList[section] as String
    }

    /**
     セクション内のセル数を返却する。
    
     - Parameter tableView: テーブルビュー
     - Parameter section: セクション番号
     - Returns: セクション内のセル数
     */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // セクションにより処理を振り分ける。
        switch section {
        case SectionIndex.Font.rawValue:
            // フォントセクションセルの場合
            return kFontCellTitleList.count

        case SectionIndex.Cloud.rawValue:
            // クラウドセクションセルの場合
            return kCloudCellTitleList.count

        default:
            // 上記以外、ダミー値を返却する。
            return 0;
        }
    }

    /**
     セルを返却する。

     - parameter tableView: テーブルビュー
     - parameter indexPath: インデックスパス
     - Returns: セル
     */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // セルを取得する。
        var cell = tableView.dequeueReusableCellWithIdentifier(kCellName) as UITableViewCell?
        // セルが取得できない場合
        if (cell == nil || cell?.detailTextLabel == nil) {
            // セルを生成する。
            cell = UITableViewCell(style: .Value1, reuseIdentifier: kCellName)
        }

        // セクション番号、セル番号を取得する。
        let section = indexPath.section
        let row = indexPath.row

        switch section {
        case SectionIndex.Font.rawValue:
            cell?.textLabel!.text = kFontCellTitleList[row]

            switch row {
            case FontCellIndex.ContentsFontName.rawValue:
                // 入力用フォント名の場合
                let fontName = EnvUtils.getEnterDataFontName()
                let fontSize = UIFont.systemFontSize()
                cell?.detailTextLabel?.font = UIFont(name: fontName, size: fontSize)

                let fontFamilyName = EnvUtils.getFontFamilyName(fontName)
                cell?.detailTextLabel?.text = fontFamilyName

                // アクセサリタイプを設定する。
                cell?.accessoryType = .DisclosureIndicator
                break

            case FontCellIndex.ContentsFontSize.rawValue:
                // 入力用フォントサイズセルの場合
                // 詳細タイトルにフォントサイズを設定する。
                let fontSize = EnvUtils.getEnterDataFontSize()
                cell?.detailTextLabel?.font = UIFont.systemFontOfSize(fontSize)

                let fontSizeString = fontSize.description
                cell?.detailTextLabel!.text = "\(fontSizeString)pt"

                // アクセサリタイプを設定する。
                cell?.accessoryType = .DisclosureIndicator
                break
                
            default:
                // 上記以外、何もしない。
                break
            }
            break

        case SectionIndex.Cloud.rawValue:
            // クラウドセクションの場合
            cell?.textLabel!.text = kCloudCellTitleList[row]

            // セル番号により処理を振り分ける。
            switch row {
            case CloudCellIndex.Dropbox.rawValue:
                // Dropboxセルの場合
                if Dropbox.authorizedClient == nil {
                    // 未ログインの場合
                    cell?.detailTextLabel?.text = LocalizableUtils.getString(LocalizableConst.kSignIn)
                } else {
                    // ログイン済みの場合
                    cell?.detailTextLabel?.text = LocalizableUtils.getString(LocalizableConst.kSignOut)
                }
                break

            default:
                // 上記以外、何もしない。
                break
            }

        default:
            // 上記以外、何もしない。
            break
        }

        // セルを返却する。
        return cell!
    }

    // MARK: - UITableViewDelegate

    /**
     セルが選択された時に呼び出される。
    
     - parameter tableView: テーブルビュー
     - parameter indexPath: インデックスパス
     */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // 選択状態を解除する。
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        // セクション番号、セル番号を取得する。
        let section = indexPath.section
        let row = indexPath.row

        // セクション番号により処理を振り分ける。
        switch section {
        case SectionIndex.Font.rawValue:
            // フォントセクションの場合
            // セル番号により処理を振り分ける。
            switch row {
            case FontCellIndex.ContentsFontName.rawValue:
                // コンテンツ用フォント名セルの場合
                let vc = SelectFontViewController(receiverNo: 0)
                navigationController?.pushViewController(vc, animated: true)
                break

            case FontCellIndex.ContentsFontSize.rawValue:
                // コンテンツ用フォントサイズセルの場合
                let number = Int(EnvUtils.getEnterDataFontSize()).description
                LogUtils.v("\(number)")
                let displayTitle = LocalizableUtils.getString(LocalizableConst.kFontSize)
                let vc = SelectNumberViewController(receiverNo: 0, number: number, rangeMin: 1, rangeMax: 30, displayTitle: displayTitle)
                vc.delegate = self
                navigationController?.pushViewController(vc, animated: true)
                break

            default:
                // 上記以外、何もしない。
                break
            }
            break

        case SectionIndex.Cloud.rawValue:
            // クラウドセクションの場合
            // セル番号により処理を振り分ける。
            switch row {
            case CloudCellIndex.Dropbox.rawValue:
                if Dropbox.authorizedClient == nil {
                    // 未ログインの場合
                    Dropbox.authorizeFromController(self)

                    tableView.reloadData()

                } else {
                    // ログイン済みの場合
                    let title = LocalizableUtils.getString(LocalizableConst.kSignOut)
                    let message = LocalizableUtils.getString(LocalizableConst.kAlertMessageSignOutDropbox)
                    showAlertWithCancel(title, message: message, handler: { () -> Void in
                        Dropbox.unlinkClient()

                        self.delegate?.receiveSignInState(0, state: true)

                        tableView.reloadData()
                    })
                }
                break

            default:
                break
            }
            break

        default:
            break
        }

    }

    // MARK: - ReceiveNumberDelegate

    func receiveNumber(receiverNo: Int, number: String) {
        switch (receiverNo) {
        case 0:
            let fontSize = CGFloat(Int(number)!)
            EnvUtils.setEnterDataFontSize(fontSize)
            SettingUtils.setFontSize("contentsFontSize", fontSize: fontSize)

            tableView?.reloadData()
            break

        default:
            break
        }
    }
}
