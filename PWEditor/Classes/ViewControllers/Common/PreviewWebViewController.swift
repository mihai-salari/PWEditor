//
//  PreviewWebViewController.swift
//  PWEditor
//
//  Created by mfuta1971 on 2016/04/26.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import UIKit
import GoogleMobileAds

/**
 プレビュー画面
 
 - Version: 1.0 新規作成
 - Author: paveway.info@gmail.com
 */
class PreviewWebViewController: BaseWebViewController {

    // MARK: - Varialbles

    /// ウェブビュー
    @IBOutlet weak var webView: UIWebView!

    /// バナービュー
    @IBOutlet weak var bannerView: GADBannerView!

    /// ファイル名
    var fileName: String!

    /// ファイルデータ
    var fileData: String!

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

     - Parameter fileName: ファイル名
     - Parameter fileData: ファイルデータ
     */
    init(fileName: String, fileData: String) {
        // 引数のデータを保存する。
        self.fileName = fileName
        self.fileData = fileData

        // スーパークラスのメソッドを呼び出す。
        super.init(nibName: nil, bundle: nil)
    }

    // MARK: - UIViewController

    /**
     インスタンスが生成された時に呼び出される。
     */
    override func viewDidLoad() {
        // スーパークラスのメソッドを呼び出す。
        super.viewDidLoad()

        // バナービューを設定する。
        setupBannerView(bannerView)

        // ファイル拡張子を取得する。
        let fileType = FileUtils.getFileType(fileName)
        if fileType == CommonConst.FileType.HTML.rawValue {
            // HTMLファイルの場合
            loadHtmlData(fileData, webView: webView)

        } else if fileType == CommonConst.FileType.Markdown.rawValue {
            // Markdownファイルの場合
            loadMarkdownData(fileData, webView: webView)
        }
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
