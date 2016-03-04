//
//  BaseWebViewController.swift
//  pwhub
//
//  Created by 二俣征嗣 on 2015/10/27.
//  Copyright © 2015年 Masatsugu Futamata. All rights reserved.
//

import UIKit
import GoogleMobileAds

/**
 Webビューベースクラス

 - Version: 1.0 新規作成
 - Author: paveway.info@gmail.com
 */
class BaseWebViewController: BaseViewController {

    /**
     データをロードする。

     - Parameter data: データ
     - Parameter webView: Webビュー
     */
    func loadData(data: String, webView: UIWebView) {
        let htmlString = getHtmlString("content")
        let loadString = htmlString.stringByReplacingOccurrencesOfString("replaceString", withString: data)

        let path = getPath("content", type: "html")
        webView.loadHTMLString(loadString, baseURL: NSURL(string: path)!)
    }

    /**
     HTMLファイルを文字列として取得する。

     - Returns: HTMLファイルの文字列
     */
    func getHtmlString(filename: String) -> String {
        let path = getPath(filename, type: "html")
        let fileHandle = NSFileHandle(forReadingAtPath: path)
        let fileData = fileHandle!.readDataToEndOfFile()
        let htmlString = String(data: fileData, encoding: NSUTF8StringEncoding)
        return htmlString!
    }

    /**
     Markdownデータをロードする。

     - Parameter data: データ
     - Parameter webView: Webビュー
     */
    func loadMarkdownData(data: String, webView: UIWebView) {
        let htmlString = getHtmlString("marked")
        let loadString = htmlString.stringByReplacingOccurrencesOfString("replaceString", withString: data)

        let path = getPath("marked", type: "html")
        webView.loadHTMLString(loadString, baseURL: NSURL(string: path)!)
    }

    /**
     Diffデータをロードする。

     - Parameter data: データ
     - Parameter webView: Webビュー
     */
    func loadDiffData(data: String, webView: UIWebView) {
        let htmlString = getHtmlString("jsdifflib")
        let loadString = htmlString.stringByReplacingOccurrencesOfString("replaceString", withString: data)
        LogUtils.v("\(loadString)")

        let path = getPath("jsdifflib", type: "html")
        webView.loadHTMLString(loadString, baseURL: NSURL(string: path)!)
    }

    /**
     Diffデータをロードする。

     - Parameter data: データ
     - Parameter webView: Webビュー
     */
    func loadDiff2HtmlData(data: String, webView: UIWebView) {
        let htmlString = getHtmlString("diff2html")
        let loadString = htmlString.stringByReplacingOccurrencesOfString("replaceString", withString: data)
        //LogUtils.v("\(loadString)")

        let path = getPath("diff2html", type: "html")
        webView.loadHTMLString(loadString, baseURL: NSURL(string: path)!)
    }

    /**
     パスを取得する。

     - Parameter name: ファイル名
     - Parameter type: ファイル拡張子
     - Returns: パス
     */
    func getPath(name: String, type: String) -> String {
        let mainBundle = NSBundle.mainBundle()
        let path = mainBundle.pathForResource(name, ofType: type)!
        return path
    }
}
