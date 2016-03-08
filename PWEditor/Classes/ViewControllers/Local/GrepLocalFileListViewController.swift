//
//  GrepViewController.swift
//  PWEditor
//
//  Created by 二俣征嗣 on 2016/02/21.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import UIKit
import GoogleMobileAds

/**
 grep一覧画面クラス

 - Version: 1.0 新規作成
 - Author: paveway.info@gmail.com
 */
class GrepLocalFileListViewController: BaseTableViewController, UISearchBarDelegate, UISearchDisplayDelegate, UIGestureRecognizerDelegate  {

    // MARK: - Constants

    /// 画面タイトル
    let kScreenTitle = LocalizableUtils.getString(LocalizableConst.kGrepLocalFileListScreenTitle)

    /// テーブルビュー
    @IBOutlet weak var tableView: UITableView!

    /// バナービュー
    @IBOutlet weak var bannerView: GADBannerView!

    /// grep単語
    var grepWord: String!

    /// パス名
    var pathName: String!

    /// 文字エンコーディング
    var encoding: UInt!

    /// grep結果情報リスト
    var grepResultInfoList = [GrepResultInfo]()

    // MARK: - Initializer

    /**
     イニシャライザ

     - Parameter coder: デコーダー
     */
    required init?(coder aDecoder: NSCoder) {
        // スーパークラスのイニシャライザを呼び出す。
        super.init(coder: aDecoder)
    }

    /**
     イニシャライザ

     - Parameter grepWord: grep単語
     - Parameter pathName: パス名
     - Parameter encoding: 文字エンコーディング
     */
    init(grepWord: String, pathName: String, encoding: UInt) {
        // 引数のデータを保存する。
        self.grepWord = grepWord
        self.pathName = pathName
        self.encoding = encoding

        // スーパークラスのイニシャライザを呼び出す。
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

        // 検索バーを作成する。
        createSearchBar()

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

    - Parameter tableView: テーブルビュー
    - Parameter section: セクション番号
    - Returns: セクション内のセル数
    */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // grep結果情報リストの件数を返却する。
        let count = grepResultInfoList.count
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
        var cell = tableView.dequeueReusableCellWithIdentifier(kCellName) as UITableViewCell?
        // セルが取得できない場合
        if (cell == nil || cell?.detailTextLabel == nil) {
            // セルを生成する。
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: kCellName)
        }

        // grep結果情報リストが未取得の場合、処理を終了する。
        let row = indexPath.row
        let count = grepResultInfoList.count
        if row + 1 > count {
            return cell!
        }

        // セル番号のgrep結果情報を取得する。
        let grepResultInfo = grepResultInfoList[row]

        // セルのラベルにファイル名+行番号を設定する。
        let fileName = grepResultInfo.fileName
        let line = grepResultInfo.line
        cell?.textLabel!.text = "\(fileName)(\(line))"
        cell?.textLabel!.lineBreakMode = .ByTruncatingMiddle

        // セルの詳細ラベルにファイルデータを設定する。
        let data = grepResultInfo.data
        cell?.detailTextLabel!.text = data

        // アクセサリを設定する。
        cell?.accessoryType = .DisclosureIndicator

        // セルを返却する。
        return cell!
    }

    // MARK: - UITableViewDelagete

    /**
    セルが選択された時に呼び出される。

    - Parameter tableView: テーブルビュー
    - Parameter indexPath: インデックスパス
    */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // 選択状態を解除する。
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        // セル番号を取得する。
        let row = indexPath.row

        if row + 1 > grepResultInfoList.count {
            return
        }

        // セル番号のgrep結果情報を取得する。
        let grepResultInfo = grepResultInfoList[row]

        // ファイルパス名を組み立てる。
        let fileName = grepResultInfo.fileName
        let filePathName = "\(pathName)/\(fileName)"

        // ファイル名とパス名に分離する。
        let range = filePathName.rangeOfString("/", options: .BackwardsSearch, range: nil, locale: nil)
        let name = filePathName.substringFromIndex((range?.endIndex)!) as String
        let path = filePathName.substringToIndex((range?.startIndex)!) as String

        // ローカルファイル編集画面に遷移する。
        let vc = EditLocalFileViewController(pathName: path, fileName: name)
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - UISearchBarDelegate

    /**
    検索ボタン押下時に呼び出される。

    - Parameter searchBar: 検索バー
    */
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        // キーボードを閉じる。
        view.endEditing(true)

        // 検索する単語を取得する。
        // 未入力の場合、検索ボタンが押せないので未入力チェックは行わない。
        grepWord = searchBar.text!

        // grepを行う。
        grep()
    }

    /**
     検索バーのキャンセルボタン押下時に呼び出される。

     - Parameter searchBar: 検索バー
     */
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        // キーボードを閉じる。
        view.endEditing(true)
    }

    /**
     検索バーの検索文字が変更された時に呼び出される。
     検索バーのクリアボタン押下時の処理を行う。

     - Parameter searchBar: 検索バー
     - Parameter searchText: 検索テキスト
     */
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            // 検索テキストがない場合
            // キーボードを閉じる。
            view.endEditing(true)

            // grep単語をクリアする。
            grepWord = ""
            let searchBar = tableView?.tableHeaderView as! UISearchBar
            searchBar.text = grepWord

            // ファイル情報リストをクリアする。
            grepResultInfoList.removeAll(keepCapacity: false)
            
            // テーブルビューを更新する。
            tableView.reloadData()
        }
    }

    // MARK: - Private method

    /**
    検索バーを生成する。
    */
    func createSearchBar() {
        let searchBarFrame = CGRectMake(0, 0, view.bounds.size.width, 44.0)
        let searchBar = UISearchBar(frame: searchBarFrame)
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        searchBar.text = grepWord

        let searchDisplayController = UISearchDisplayController(searchBar: searchBar, contentsController: self)
        searchDisplayController.delegate = self;
        searchDisplayController.searchResultsDelegate = self;
        searchDisplayController.searchResultsDataSource = self;
        tableView?.tableHeaderView = searchBar;
    }

    /**
     grepを行う。
     */
    func grep() {
        // grep結果情報リストをクリアする。
        grepResultInfoList.removeAll(keepCapacity: false)

        let fileManager = NSFileManager.defaultManager()

        // ローカルパス名を取得する。
        let localPathName = FileUtils.getLocalPath(pathName)

        // ローカルパスのファイル・ディレクトリ分繰り返す。
        let dirEnum = fileManager.enumeratorAtPath(localPathName)!
        for name in dirEnum {
            let targetPathName = FileUtils.getLocalPath(pathName, name: name as! String)
            if !FileUtils.isDirectory(targetPathName) {
                let returns = FileUtils.getFileData(targetPathName, encoding: encoding)
                let result = returns.0
                if !result {
                    return
                }
                let fileData = returns.1
                var lineNo = 0
                // 行数分繰り返す。
                fileData.enumerateLines { line, stop in
                    lineNo++
                    let range = line.rangeOfString(self.grepWord)
                    if range != nil {
                        // 行にgrep単語が含まれる場合
                        let grepResultInfo = GrepResultInfo()
                        grepResultInfo.fileName = name as! String
                        grepResultInfo.line = String(lineNo)

                        let deleteTarget = NSCharacterSet.whitespaceCharacterSet
                        let trimedLine = line.stringByTrimmingCharactersInSet(deleteTarget())
                        grepResultInfo.data = trimedLine
                        
                        self.grepResultInfoList.append(grepResultInfo)
                    }
                }
            }
        }
        
        tableView.reloadData()
    }
}
