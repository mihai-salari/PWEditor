//
//  PdfViewerViewController.swift
//  PWEditor
//
//  Created by mfuta1971 on 2016/05/05.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import UIKit
import GoogleMobileAds
import SwiftyDropbox

/**
 PDFビューワー画面
 
 - Version: 1.0 新規作成
 - Author: paveway.info@gmail.com
 */
class PdfViewerViewController: BaseViewController {

    /// Webビュー
    @IBOutlet weak var webView: UIWebView!

    /// バナービュー
    @IBOutlet weak var bannerView: GADBannerView!

    /// URL
    var url: NSURL!

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

     - Parameter url: URL
     */
    init(url: NSURL) {
        // 引数のデータを保存する。
        self.url = url

        // スーパークラスのメソッドを呼び出す。
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let request = NSURLRequest(URL: url)
        webView.loadRequest(request)

        // バナービューを設定する。
        setupBannerView(bannerView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
