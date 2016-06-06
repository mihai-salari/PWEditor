//
//  LicenseDetailViewController.swift
//  PWhub
//
//  Created by Masatsugu Futamata on 2015/06/27.
//  Copyright (c) 2015年 Paveway. All rights reserved.
//
import UIKit
import GoogleMobileAds
/**
 オープソースライセンス内容画面

 - version: 1.0 新規作成
 - Author: paveway.info@gmail.com
 */
class OpenSourceLicenseContentViewController: BaseWebViewController {
    /** 画面タイトルリスト */
    let kTitleList = [
        "ECSlidingViewController",
        "TextKit_LineNumbers",
        "highlight.js",
        "highlightjs-line-numbers.js",
        "Source Han Code JP",
        "SwiftyDropbox",
        "Google APIs Client Library for Objective-C",
        "One Drive SDK iOS",
        "BlackRaccoon",
        "CYRTextView",
        "iCloudDocumentSync",
//        "Box iOS SDK",
    ]
    
    /** ライセンスファイル名リスト */
    let kLicenseFileNameList = [
        "ECSlidingViewControllerLicense",
        "TextKitLineNumbers",
        "HighlightLicense",
        "Highlightjs-line-numbersLicense",
        "SourceHanCodeJPLicense",
        "SwiftyDropboxLicense",
        "GoogleApiObjectiveCClientLicense",
        "OneDriveSDKiOSLicense",
        "BlackRaccoonLicense",
        "CYRTextViewLicense",
        "ICloudDocumentSyncLicense",
//        "BoxiOSSDKLicense",
    ]
    
    /** ライセンスファイル拡張子 */
    let kLicenseFileExtention = "txt"

    @IBOutlet weak var webView: UIWebView!

    @IBOutlet weak var bannerView: GADBannerView!

    /** コンテンツビュー */
    var contentsView: UITextView!
    
    /** ライセンス番号 */
    var licenseNo: Int = 0
    
    /**
    イニシャライザ
    
    - parameter coder: デコーダー
    */
    required init?(coder aDecoder: NSCoder) {
        // スーパークラスのイニシャライザを呼び出す。
        super.init(coder: aDecoder)
    }
    
    /**
    イニシャライザ
    
    - parameter nibName: NIB名
    - parameter bundle: バンドル
    */
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        // スーパークラスのイニシャライザを呼び出す。
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    /**
    イニシャライザ
    
    - parameter lisenceNo: ライセンス番号
    */
    init(licenseNo: Int) {
        // 引数のライセンス番号を保存する。
        self.licenseNo = licenseNo
        
        // スーパークラスのイニシャライザを呼び出す。
        super.init(nibName: nil, bundle: nil)
    }
    
    /**
    インスタンスが生成された時に呼び出される。
    */
    override func viewDidLoad() {
        // スーパークラスのメソッドを呼び出す。
        super.viewDidLoad()
        
        // 画面タイトルを設定する。
        navigationItem.title = kTitleList[licenseNo]
        
        // バナービューを設定する。
        setupBannerView(bannerView)

        // ライセンスファイルの内容をWebビューに設定する。
        let fileData = FileUtils.getFileData(kLicenseFileNameList[licenseNo], type: kLicenseFileExtention)
        loadData(fileData, webView: webView)
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
