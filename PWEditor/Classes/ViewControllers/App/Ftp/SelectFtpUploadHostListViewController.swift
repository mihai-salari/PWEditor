//
//  SelectFtpUploadHostViewController.swift
//  PWEditor
//
//  Created by mfuta1971 on 2016/05/19.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import UIKit
import GoogleMobileAds

class SelectFtpUploadHostListViewController: BaseTableViewController {

    // MARK: - Constatns

    /// 画面タイトル
    private let kScreenTitle = LocalizableUtils.getString(LocalizableConst.kSelectFtpUploadHostListScreenTitle)

    // MARK: - Variables

    /// テーブルビュー
    @IBOutlet weak var tableView: UITableView!

    /// バナービュー
    @IBOutlet weak var bannerView: GADBannerView!

    /// 遷移元画面クラス名
    private var sourceClassName: String!

    /// ファイル名
    private var fileName: String!

    /// ファイルデータ
    private var fileData: NSData!

    /// FTPホスト情報リスト
    private var ftpHostInfoList = [FtpHostInfo]()

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
     - Parameter fileName: ファイル名
     - Parameter fileData: ファイルデータ
     */
    init(sourceClassName: String, fileName: String, fileData: NSData) {
        // 引数のデータを保存する。
        self.sourceClassName = sourceClassName
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

        // テーブルビューを設定する。
        setupTableView(tableView)

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
        let vc = SelectFtpUploadDirectoryListViewController(sourceClassName: sourceClassName, ftpHostInfo: ftpHostInfo, pathName: pathName, fileName: fileName, fileData: fileData)
        navigationController?.pushViewController(vc, animated: true)
    }
}
