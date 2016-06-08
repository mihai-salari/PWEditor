//
//  SearchWordViewController.swift
//  PWEditor
//
//  Created by mfuta1971 on 2016/04/27.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import UIKit
import GoogleMobileAds

/**
 単語検索画面
 
 - Version: 1.0 新規作成
 - Author: paveway.info@gmail.com
 */
class SearchWordViewController: BaseTableViewController, UISearchBarDelegate, UISearchDisplayDelegate {

    // MARK: - Constants

    /// 画面タイトル
    let kScreenTitle = LocalizableUtils.getString(LocalizableConst.kSearchWordScreenTitle)

    // MARK: - Variables

    /// テーブルビュー
    @IBOutlet weak var tableView: UITableView!

    /// バナービュー
    @IBOutlet weak var bannerView: GADBannerView!

    /// 検索結果情報リスト
    var searchResultInfoList = [SearchResultInfo]()

    /// 検索単語
    var searchWord: String!

    /// ファイルデータ
    var fileData: String!

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

     - Parameter searchWord: 検索単語
     - Parameter fileData: ファイルデータ
     */
    init(searchWord: String, fileData: String) {
        // 引数のデータを保存する。
        self.searchWord = searchWord
        self.fileData = fileData

        // スーパークラスのイニシャライザを呼び出す。
        super.init(nibName: nil, bundle: nil)
    }

    // MARK: - UIViewController

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
        // 検索結果情報リストの件数を返却する。
        let count = searchResultInfoList.count
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
        let cell = getTableViewDetailCell(tableView)

        // 検索結果情報リストが未取得の場合、処理を終了する。
        let row = indexPath.row
        let count = searchResultInfoList.count
        if row + 1 > count {
            return cell
        }

        // セル番号の検索結果情報を取得する。
        let searchResultInfo = searchResultInfoList[row]

        // セルのラベルにファイル名+行番号を設定する。
        let line = searchResultInfo.line
        cell.textLabel!.text = "(\(line))"

        // セルの詳細ラベルにファイルデータを設定する。
        let data = searchResultInfo.data
        cell.detailTextLabel!.text = data
        cell.detailTextLabel!.lineBreakMode = .ByTruncatingMiddle

        // セルを返却する。
        return cell
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

        // 検索結果情報リストが未取得の場合、処理を終了する。
        let row = indexPath.row
        let count = searchResultInfoList.count
        if row + 1 > count {
            return
        }
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
        searchWord = searchBar.text!

        // 単語検索を行う。
        search()
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

            // 検索単語をクリアする。
            searchWord = ""
            let searchBar = tableView?.tableHeaderView as! UISearchBar
            searchBar.text = searchWord

            // 検索結果情報リストをクリアする。
            searchResultInfoList.removeAll(keepCapacity: false)

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
        searchBar.text = searchWord

        let searchDisplayController = UISearchDisplayController(searchBar: searchBar, contentsController: self)
        searchDisplayController.delegate = self;
        searchDisplayController.searchResultsDelegate = self;
        searchDisplayController.searchResultsDataSource = self;
        tableView?.tableHeaderView = searchBar;
    }

    /**
     単語検索を行う。
     */
    func search() {
        // 検索結果情報リストをクリアする。
        searchResultInfoList.removeAll(keepCapacity: false)

        let lines = fileData.componentsSeparatedByString("\n")
        let count = lines.count
        for i in 0 ..< count {
            let line = lines[i]
            let range = line.rangeOfString(searchWord)
            if range != nil {
                // 行に検索単語が含まれる場合
                let searchResultInfo = SearchResultInfo()
                searchResultInfo.line = String(i + 1)

                let deleteTarget = NSCharacterSet.whitespaceCharacterSet
                let trimedLine = line.stringByTrimmingCharactersInSet(deleteTarget())
                searchResultInfo.data = trimedLine

                searchResultInfoList.append(searchResultInfo)
            }
        }

        tableView.reloadData()
    }
}
