//
//  LicenseListViewController.swift
//  PWhub
//
//  Created by Masatsugu Futamata on 2015/06/27.
//  Copyright (c) 2015年 Paveway. All rights reserved.
//
import UIKit
import GoogleMobileAds

/**
 オープンソースライセンス一覧画面

 - version: 1.0 新規作成
 - Author: paveway.info@gmail.com
 */
class OpenSourceLicenseListViewController: BaseTableViewController {
    
    /** 画面タイトル */
    let kScreeTitle = LocalizableUtils.getString(LocalizableConst.kOpenSourceLicenseListScreenTitle)
    
    /** セルタイトルリスト */
    let kCellTitles = [
        "ECSlidingViewController",
        "TextKit_LineNumbers",
        "highlight.js",
        "highlightjs-line-numbers.js",
        "SourceHanCodeJP",
        "SwiftyDropbox"
    ]
    
    /** セルインデックス */
    enum CellIndex: Int {
        case ECSlidingViewController = 0
        case TextKitLineNumbers = 1
        case Highlightjs = 2
        case HighlightjsLineNumbersjs = 3
        case SourceHanCodeJP = 4
        case SwiftyDropbox = 5
    }
    
    /** URLリスト */
    let kUrlList = [
        "https://github.com/ECSlidingViewController/ECSlidingViewController",
        "https://github.com/alldritt/TextKit_LineNumbers",
        "https://highlightjs.org/",
        "https://github.com/wcoder/highlightjs-line-numbers.js",
        "https://github.com/adobe-fonts/source-han-code-jp",
        "https://github.com/dropbox/SwiftyDropbox"
    ]

    /// テーブルビュー
    @IBOutlet weak var tableView: UITableView!

    /// バナービュー
    @IBOutlet weak var bannerView: GADBannerView!

    /**
    インスタンスが生成された時に呼び出される。
    */
    override func viewDidLoad() {
        // スーパークラスのメソッドを呼び出す。
        super.viewDidLoad()
        
        // 画面タイトルを設定する。
        navigationItem.title = kScreeTitle

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

    // MARK: - UITableViewDataSource

    /**
    セクション内のセル数を返却する。
    
    - parameter tableView: テーブルビュー
    - parameter section: セクション番号
    :return: セクション内のセル数
    */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return kCellTitles.count
    }
    
    /**
    セルを返却する。
    
    - parameter tableView: テーブルビュー
    - parameter indexPath: インデックスパス
    :return: セル
    */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // セルを取得する。
        var cell = tableView.dequeueReusableCellWithIdentifier(kCellName) as UITableViewCell?
        // セルが取得できない場合
        if (cell == nil) {
            // セルを生成する。
            cell = UITableViewCell()
        }
        
        // セルにタイトルを設定する。
        cell?.textLabel!.text = kCellTitles[indexPath.row]
        
        // アクセサリタイプを設定する。
        cell?.accessoryType = UITableViewCellAccessoryType.DetailDisclosureButton
        
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
        
        // オープンソースライセンス内容画面に遷移する。
        let vc = OpenSourceLicenseContentViewController(licenseNo: indexPath.row)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /**
    アクセサリボタンが押下された時に呼び出される。
    
    - parameter tableView: テーブルビュー
    - parameter indexPath: インデックスパス
    */
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        // ブラウザを起動する。
        let url = NSURL(string: kUrlList[indexPath.row])
        UIApplication.sharedApplication().openURL(url!)
    }
}
