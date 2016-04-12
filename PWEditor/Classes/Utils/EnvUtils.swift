//
//  EnvUtils.swift
//  pwhub
//
//  Created by 二俣征嗣 on 2015/10/21.
//  Copyright © 2015年 Masatsugu Futamata. All rights reserved.
//

import Foundation

/**
環境ユーティリティ

- Version: 1.0 新規作成
- Author: paveway.info@gmail.com
*/
class EnvUtils: NSObject {

    /// バージョンキー
    static let kVersionKey: String = "CFBundleShortVersionString"

    /// ビルドキー
    static let kBuildKey: String = "CFBundleVersion"

    /**
    バージョン番号を取得する。

    - Returns: バージョン番号
    */
    class func getVersion() -> String {
        let bundle = NSBundle.mainBundle()
        let version: String = bundle.objectForInfoDictionaryKey(kVersionKey) as! String
        return version
    }
    /**
    ビルド番号を取得する。

    - Returns: ビルド番号
    */
    class func getBuild() -> String {
        let bundle = NSBundle.mainBundle()
        let build: String =
            bundle.objectForInfoDictionaryKey(kBuildKey) as! String
        return build
    }

    class func getAppName() -> String {
        let bundle = NSBundle.mainBundle()
        let build: String =
        bundle.objectForInfoDictionaryKey("CFBundleDisplayName") as! String
        return build
    }

    /**
    アプリケーションデリゲートを取得する。

    - Returns: アプリケーションデリゲート
    */
    class func getAppDelegate() -> AppDelegate {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate
    }

    /**
    デフォルトフォント名を取得する。

    - Returns: デフォルトフォント名
    */
    class func getDefaultFontName() -> String {
        let appDelegate = getAppDelegate()
        let defaultFontName = appDelegate.defaultFontName
        return defaultFontName
    }

    /**
    デフォルトフォント名を設定する。

    - Parameter defaultFontName: デフォルトフォント名
    */
    class func setDefaultFontName(defaultFontName: String) {
        let appDelegate = getAppDelegate()
        appDelegate.defaultFontName = defaultFontName
    }

    /**
    入力用フォント名を取得する。

    - Returns: 入力用フォント名
    */
    class func getEnterDataFontName() -> String {
        let appDelegate = getAppDelegate()
        let contentsFontName = appDelegate.enterDataFontName
        return contentsFontName
    }

    /**
    入力用フォント名を設定する。

    - Parameter enterDataFontName: 入力用フォント名
    */
    class func setEnterDataFontName(enterDataFontName: String) {
        let appDelegate = getAppDelegate()
        appDelegate.enterDataFontName = enterDataFontName
    }

    /**
    デフォルトフォントサイズを取得する。

    - Returns: デフォルトフォントサイズ
    */
    class func getDefaultFontSize() -> CGFloat {
        let appDelegate = getAppDelegate()
        let defaultFontSize = appDelegate.defaultFontSize
        return defaultFontSize
    }

    /**
    デフォルトフォントサイズを設定する。

    - Parameter defaultFontSize: デフォルトフォントサイズ
    */
    class func setDefaultFontSize(defaultFontSize: CGFloat) {
        let appDelegate = getAppDelegate()
        appDelegate.defaultFontSize = defaultFontSize
    }

    /**
    入力用フォントサイズを取得する。

    - Returns: 入力用フォントサイズ
    */
    class func getEnterDataFontSize() -> CGFloat {
        let appDelegate = getAppDelegate()
        let contentsFontSize = appDelegate.enterDataFontSize
        return contentsFontSize
    }

    /**
    入力用フォントサイズを設定する。

    - Parameter enterDataFontSize: 入力用フォントサイズ
    */
    class func setEnterDataFontSize(enterDataFontSize: CGFloat) {
        let appDelegate = getAppDelegate()
        appDelegate.enterDataFontSize = enterDataFontSize
    }

    /**
    フォント名に対するフォントファミリー名を取得する。

    - Parameter fontName: フォント名
    - Returns: フォントファミリー名
    */
    class func getFontFamilyName(fontName: String) -> String {
        let count = CommonConst.FontNameList.count
        var index = 0
        for i in 0 ..< count {
            let name = CommonConst.FontNameList[i]
            if fontName == name {
                index = i
                break
            }
        }
        let fontFamilyName = CommonConst.FontFamilyNameList[index]
        return fontFamilyName
    }
}