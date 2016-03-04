//
//  TopViewController.swift
//  PWEditor
//
//  Created by 二俣征嗣 on 2016/02/18.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import UIKit
import GoogleMobileAds

/**
 ローカルファイル一覧画面クラス

 - Version: 1.0 新規作成
 - Author: paveway.info@gmail.com
 */
class LocalFileListViewController: BaseTableViewController, UISearchBarDelegate, UISearchDisplayDelegate, UIGestureRecognizerDelegate, NotifyAddFileDelegate {

    // MARK: - Constants

    /// 画面タイトル
    let kScreenTitle = LocalizableUtils.getString(LocalizableConst.kLocalFileListScreenTitle)

    // MARK: - Variables

    /// テーブルビュー
    @IBOutlet weak var tableView: UITableView!

    /// ツールバー
    @IBOutlet weak var toolbar: UIToolbar!

    /// 追加ツールバーボタン
    @IBOutlet weak var addToobarButton: UIBarButtonItem!

    /// grepツールバーボタン
    @IBOutlet weak var grepToolbarButton: UIBarButtonItem!

    /// バナービュー
    @IBOutlet weak var bannerView: GADBannerView!

    /// パス名
    var pathName: String!

    /// ファイル情報リスト
    var fileInfoList = [FileInfo]()

    /// 開始位置
    // TODO: ナビゲーションバー引っ張って表示用
    //var beginingPoint = CGPointMake(0.0, 0.0)

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

     - Parameter pathName: パス名
     */
    init(pathName: String) {
        // 引数のデータを保存する。
        self.pathName = pathName

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

        if pathName.isEmpty {
            // パス名が空の場合
            // 左バーボタンを作成する。
            createLeftBarButton()
        }

        // テーブルビューを設定する。
        setupTableView(tableView)

        // 検索バーを作成する。
        createSearchBar()

        // セルロングタップを設定する。
        createCellLogPressed(tableView, delegate: self)

        // バナービューを設定する。
        setupBannerView(bannerView)

        // ファイル情報リストを取得する。
        let localPathName = FileUtils.getLocalPath(pathName)
        fileInfoList = FileUtils.getFileInfoListInDir(localPathName)
    }

    /**
     メモリ不足の時に呼び出される。
     */
    override func didReceiveMemoryWarning() {
        LogUtils.w("memory error.")

        // スーパークラスのメソッドを呼び出す。
        super.didReceiveMemoryWarning()
    }

    /*
    TODO: ナビゲーションバー引っ張って更新用
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        beginingPoint = scrollView.contentOffset
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        let currentPoint = scrollView.contentOffset
        let contentSize = scrollView.contentSize
        let frameSize = scrollView.frame
        let maxOffSet = contentSize.height - frameSize.height

        if currentPoint.y >= maxOffSet {
            navigationController?.hidesBarsOnSwipe = true
            navigationController?.setToolbarHidden(true, animated: true)

        } else if beginingPoint.y < currentPoint.y {
            navigationController?.hidesBarsOnSwipe = true
            navigationController?.setToolbarHidden(true, animated: true)

        } else {
            navigationController?.navigationBarHidden = false
            navigationController?.hidesBarsOnSwipe = false
            navigationController?.setToolbarHidden(false, animated: true)
        }
    }
    */

    // MARK: - UITableViewDataSource

    /**
    セクション内のセル数を返却する。

    - Parameter tableView: テーブルビュー
    - Parameter section: セクション番号
    - Returns: セクション内のセル数
    */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // ファイル情報リストの件数を返却する。
        let count = fileInfoList.count
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
        let cell = getTableViewCell(tableView)

        // ファイル情報リストが未取得の場合、処理を終了する。
        let row = indexPath.row
        let count = fileInfoList.count
        if row + 1 > count {
            return cell
        }

        // セル内容をクリアする。
        cell.textLabel?.text = ""
        cell.accessoryType = .None

        let fileInfo = fileInfoList[row]
        cell.textLabel?.text = fileInfo.name

        let isDir = fileInfo.isDir
        if isDir {
            cell.accessoryType = .DisclosureIndicator

        } else {
            cell.accessoryType = .DetailButton
        }

        return cell
    }

    // MARK: - UITableViewDelegate

    /**
     セルが選択された時に呼び出される。

     - Parameter tableView: テーブルビュー
     - Parameter indexPath: インデックスパス
     */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // セルの選択状態を解除する。
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        // ファイル情報リストが未取得の場合、処理を終了する。
        let row = indexPath.row
        let count = fileInfoList.count
        if row + 1 > count {
            return
        }

        let fileInfo = fileInfoList[row]
        let isDir = fileInfo.isDir
        if isDir {
            // ディレクトリの場合
            // ローカルファイル一覧画面に遷移する。
            let pathName = fileInfo.name
            let vc = LocalFileListViewController(pathName: pathName)
            navigationController?.pushViewController(vc, animated: true)

        } else {
            // ファイルの場合
            // ファイル編集画面に遷移する。
            let fileName = fileInfo.name
            let vc = EditFileViewController(pathName: pathName, fileName: fileName)
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    /**
     アクセサリボタンが押下された時に呼び出される。

     - Parameter tableView: テーブルビュー
     - Parameter indexPath: インデックスパス
     */
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row

        let count = fileInfoList.count
        if row + 1 > count {
            return
        }

        let fileInfo = fileInfoList[row]
        let fileName = fileInfo.name
        let vc = FileInfoViewController(pathName: pathName, fileName: fileName)
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

        // 画面タイトルを変更する。
        navigationItem.title = LocalizableUtils.getString(LocalizableConst.kLocalFileListScreenTitleSearch)

        // 検索単語を取得する。
        // 未入力の場合、検索ボタンが押せないので未入力チェックは行わない。
        let searchText = searchBar.text

        // ファイル情報リストをクリアし、検索単語で該当パスのファイル・ディレクトリを検索する。
        fileInfoList.removeAll(keepCapacity: false)
        let documentsPath = FileUtils.getDocumentsPath()
        let localPathName = "\(documentsPath)/\(pathName)"
        let currentFileInfoList = FileUtils.getFileInfoListInDir(localPathName)
        for fileInfo in currentFileInfoList {
            let name = fileInfo.name
            if name == searchText {
                fileInfoList.append(fileInfo)
            }
        }

        // テーブルビューを更新する。
        tableView.reloadData()
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

            // 画面タイトルを変更する。
            navigationItem.title = LocalizableUtils.getString(LocalizableConst.kLocalFileListScreenTitle)

            // ファイル情報リストをクリアし、再取得する。
            fileInfoList.removeAll(keepCapacity: false)
            let localPath = FileUtils.getLocalPath(pathName)
            fileInfoList = FileUtils.getFileInfoListInDir(localPath)

            // テーブルビューを更新する。
            tableView.reloadData()
        }
    }

    // MARK: - Button handler

    /**
     セルがロングタップされた時に呼び出される。

     - Parameter recognizer: セルロングタップジェスチャーオブジェクト
     */
    override func cellLongPressed(recognizer: UILongPressGestureRecognizer) {
        // インデックスパスを取得する。
        let point = recognizer.locationInView(tableView)
        let indexPath = tableView!.indexPathForRowAtPoint(point)
        if indexPath == nil {
            // インデックスパスが取得できない場合、処理を終了する。
            return
        }

        if recognizer.state == UIGestureRecognizerState.Began {
            // ジェスチャーが開始状態の場合
            // ファイル情報リストが未取得の場合、処理を終了する。
            let row = indexPath!.row
            let count = fileInfoList.count
            if row + 1 > count {
                return
            }

            // ファイル情報から名前を取得する。
            let fileInfo = self.fileInfoList[row]
            let name = fileInfo.name

            // 削除確認アラートを表示する。
            let alertTitle = LocalizableUtils.getString(LocalizableConst.kAlertTitleConfirm)
            let alertMessage = LocalizableUtils.getStringWithArgs(LocalizableConst.kAlertMessageDeleteConfirm, name)
            let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .Alert)

            let okActionTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleDelete)
            let okAction = UIAlertAction(title: okActionTitle, style: .Default, handler: {(action: UIAlertAction!) -> Void in
                // OKボタン押下時の処理
                // 指定された名前のファイル・ディレクトリを削除する。
                let filePath = "\(self.pathName)/\(name)"
                let localFilePath = FileUtils.getLocalPath(filePath)
                let result = FileUtils.remove(localFilePath)
                if !result {
                    // 削除できない場合、エラーアラートを表示する。
                    // TODO: 未実装

                } else {
                    // 削除できた場合
                    // ファイル情報リストからファイル情報を削除し、テーブルビューを更新する。
                    self.fileInfoList.removeAtIndex(row)
                    self.tableView.reloadData()
                }
            })
            alert.addAction(okAction)

            let cancelActionTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleCancel)
            let cancelAction = UIAlertAction(title: cancelActionTitle, style: .Cancel, handler: nil)
            alert.addAction(cancelAction)

            presentViewController(alert, animated: true, completion: nil)
        }
    }

    /**
     追加ツールバーボタン押下時に呼び出される。

     - Parameter sender: 追加ツールバーボタン
     */
    @IBAction func addToolbarButtonPressed(sender: AnyObject) {
        // ファイル追加画面に遷移する。
        let vc = AddFileViewController(pathName: pathName)
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }

    /**
     grepツールバーボタン押下時に呼び出される。

     - Parameter sender: 追加ツールバーボタン
     */
    @IBAction func grepToolbarButtonPressed(sender: AnyObject) {
        // Grep一覧画面に遷移する。
        let vc = GrepListViewController(grepWord: "", pathName: pathName)
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - NotifyAddFileDelegate

    /**
     ファイル追加を通知する。
     */
    func notifyAddFile() {
        // ファイル情報リストを再取得する。
        fileInfoList.removeAll(keepCapacity: false)
        let localPathName = FileUtils.getLocalPath(pathName)
        fileInfoList = FileUtils.getFileInfoListInDir(localPathName)

        // テーブルビューを更新する。
        tableView?.reloadData()
    }

    // MARK: - Private method

    /**
     検索バーを作成する。
     */
    func createSearchBar() {
        let searchBarFrame = CGRectMake(0, 0, view.bounds.size.width, 44.0)
        let searchBar = UISearchBar(frame: searchBarFrame)
        searchBar.delegate = self
        searchBar.showsCancelButton = true

        let searchDisplayController = UISearchDisplayController(searchBar: searchBar, contentsController: self)
        searchDisplayController.delegate = self;
        searchDisplayController.searchResultsDelegate = self;
        searchDisplayController.searchResultsDataSource = self;
        tableView.tableHeaderView = searchBar;
    }
}
