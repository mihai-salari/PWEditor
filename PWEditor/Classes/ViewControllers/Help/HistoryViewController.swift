//
//  HistoryViewController.swift
//  PWEditor
//
//  Created by 二俣征嗣 on 2016/02/22.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import UIKit
import GoogleMobileAds

class HistoryViewController: BaseWebViewController {

    // MARK: - Constants

    /// 画面タイトル
    let kScreenTitle = LocalizableUtils.getString(LocalizableConst.kHistoryScreenTitle)

    /// 更新履歴ファイル名
    let kHistoryFileName = "History"

    /// 更新履歴ファイル拡張子
    let kHistoryFileExtension = "txt"

    // MARK: - Variables

    @IBOutlet weak var webView: UIWebView!

    @IBOutlet weak var bannerView: GADBannerView!

    override func viewDidLoad() {
        // スーパークラスのメソッドを呼び出す。
        super.viewDidLoad()

        // 画面タイトルを設定する。
        navigationItem.title = kScreenTitle

        // 左上バーボタンを生成する。
        createLeftBarButton()

        // バナービューを設定する。
        setupBannerView(bannerView)

        // 更新履歴データをロードする。
        let historyData = getHistoryData()
        loadData(historyData, webView: webView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Private

    /**
    更新履歴データを返却する。

    - Returns: 更新履歴データ
    */
    private func getHistoryData() -> String {
        let fileData = FileUtils.getFileData(kHistoryFileName, type: kHistoryFileExtension)
        return fileData
    }
}
