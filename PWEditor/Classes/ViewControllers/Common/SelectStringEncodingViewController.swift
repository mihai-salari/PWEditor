//
//  SelectEncodeViewController.swift
//  PWEditor
//
//  Created by 二俣征嗣 on 2016/03/04.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import UIKit
import GoogleMobileAds

class SelectStringEncodingViewController: BaseTableViewController {

    // MARK: - Constants

    /// 画面タイトル
    let kScreenTitle = LocalizableUtils.getString(LocalizableConst.kSelectStringEncodingScreenTitle)

    let kStringEncodingNameList = [
        "ASCII",
        "Shift-JIS",
        "EUC",
        "Mac",
        "Windows CP1251",
        "Windows CP1252",
        "Windows CP1253",
        "Windows CP1254",
        "Windows CP1250",
        "Latin1",
        "Unicode",
        "ISO2022JP",
        "UTF-8"
    ]

    let kReturnCodeNameList = [
        "Unix(LF)",
        "Windows(CR/LF)",
        "Mac(CR)"
    ]

    enum StringEncodingIndex: Int {
        case Ascii = 0
        case ShiftJis = 1
        case Euc = 2
        case Mac = 3
        case WindowsCp1251 = 4
        case WindowsCp1252 = 5
        case WindowsCp1253 = 6
        case WindowsCp1254 = 7
        case WindowsCp1250 = 8
        case Latin1 = 9
        case Unicode = 10
        case Iso2022Jp = 11
        case Utf8 = 12
    }

    // MARK: - Variables

    /// テーブルビュー
    @IBOutlet weak var tableView: UITableView!

    /// バナービュー
    @IBOutlet weak var bannerView: GADBannerView!

    /// 遷移元クラス名
    var className: String!

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

     - Parameter className: 遷移元クラス名
     */
    init(className: String) {
        // 引数のデータを保存する。
        self.className = className

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
}
