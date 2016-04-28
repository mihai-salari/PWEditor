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

    var searchBar: UISearchBar?

    var deleteToolbarButton: UIBarButtonItem?

    var copyToolbarButton: UIBarButtonItem?

    var moveToolbarButton: UIBarButtonItem?

    var normalToolbarItems: [UIBarButtonItem]?

    var editingToolbarItems: [UIBarButtonItem]?

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

    // MARK: - UIViewController

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
        tableView.allowsMultipleSelectionDuringEditing = true

        // 検索バーを作成する。
        createSearchBar()

        // セルロングタップを設定する。
        createCellLogPressed(tableView, delegate: self)

        normalToolbarItems = toolbar.items

        let spaser = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let deleteToolbarButtonAction = Selector("deleteToolbarButtonPressed:")
        deleteToolbarButton = UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: deleteToolbarButtonAction)
        deleteToolbarButton!.enabled = false
        let moveToolbarButtonAction = #selector(LocalFileListViewController.moveToolbarButtonPressed(_:))
        moveToolbarButton = UIBarButtonItem(title: "move", style: .Plain, target: self, action: moveToolbarButtonAction)
        moveToolbarButton!.enabled = false
        editingToolbarItems = [deleteToolbarButton!, spaser, moveToolbarButton!]

        // バナービューを設定する。
        setupBannerView(bannerView)

        // ファイル情報リストを取得する。
        let localPathName = FileUtils.getLocalPath(pathName)
        fileInfoList = FileUtils.getFileInfoListInDir(localPathName)

        if fileInfoList.count > 0 {
            // ファイル情報が存在する場合、
            // 右上編集ボタンを表示する。
//            navigationItem.rightBarButtonItem = editButtonItem()
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

        // ファイル名、ディレクトリ名を設定する。
        let fileInfo = fileInfoList[row]
        cell.textLabel?.text = fileInfo.name
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .ByWordWrapping

        let isDir = fileInfo.isDir
        if isDir {
            // ディレクトリの場合
            cell.accessoryType = .DisclosureIndicator

        } else {
            // ファイルの場合
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
        if tableView.editing {
            let indexPaths = tableView.indexPathsForSelectedRows
            let count = indexPaths?.count
            if count > 0 {
                deleteToolbarButton!.enabled = true
                moveToolbarButton!.enabled = true
            } else {
                deleteToolbarButton!.enabled = false
                moveToolbarButton!.enabled = false
            }
            return
        }

        // セルの選択状態を解除する。
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        // ファイル情報リストが未取得の場合、処理を終了する。
        let row = indexPath.row
        let count = fileInfoList.count
        if row + 1 > count {
            // ファイル情報リストが範囲外の場合、処理しない。
            return
        }

        let fileInfo = fileInfoList[row]
        let isDir = fileInfo.isDir
        if isDir {
            // ディレクトリの場合
            // ローカルファイル一覧画面に遷移する。
            let localPathName: String
            if pathName.isEmpty {
                // パス名が空の場合
                localPathName = fileInfo.name
            } else {
                // パス名が空ではない場合
                localPathName = "\(pathName)/\(fileInfo.name)"
            }
            let vc = LocalFileListViewController(pathName: localPathName)
            navigationController?.pushViewController(vc, animated: true)

        } else {
            // ファイルの場合
            // ファイル編集画面に遷移する。
            let fileName = fileInfo.name
            let vc = EditLocalFileViewController(pathName: pathName, fileName: fileName)
            // TODO: ハイライト表示確認用
//            let vc = HighlightViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.editing {
            // 編集モードの場合
            let indexPaths = tableView.indexPathsForSelectedRows
            let count = indexPaths?.count
            if count > 0 {
                deleteToolbarButton!.enabled = true
                moveToolbarButton!.enabled = true
            } else {
                deleteToolbarButton!.enabled = false
                moveToolbarButton!.enabled = false
            }
            return
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
            // ファイル情報リストが範囲外の場合、処理しない。
            return
        }

        // ローカルファイル情報画面に遷移する。
        let fileInfo = fileInfoList[row]
        let fileName = fileInfo.name
        let vc = LocalFileInfoViewController(pathName: pathName, fileName: fileName, encoding: NSUTF8StringEncoding)
        navigationController?.pushViewController(vc, animated: true)
    }

    /**
     編集モードへ切り替える。

     - Parameter editing: 編集モード
     - Parameter animated: アニメーション指定
     */
    override func setEditing(editing: Bool, animated: Bool) {
        // スーパークラスのメソッドを呼び出す。
        super.setEditing(editing, animated: animated)

        // テーブルビューの編集モードを切り替える。
        tableView.editing = editing

        if editing {
            // 編集モードの場合
            // ツールバーを切り替える。
            toolbar.items = editingToolbarItems

            // 検索バーを非表示にする。
            searchBar!.hidden = true

        } else {
            // 通常モードの場合
            // ツールバーを切り替える。
            toolbar.items = normalToolbarItems

            // 検索バーを表示する。
            searchBar!.hidden = false
        }
    }

    /**
     編集可能か返却する。

     - Parameter tableView: テーブルビュー
     - Parameter indexPath: インデックスパス
     - Returns: 結果
     */
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
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

            // ファイル情報を取得する。
            let fileInfo = self.fileInfoList[row]

            // ローカルファイル操作アクションシートを表示する。
            let cell = tableView.cellForRowAtIndexPath(indexPath!)
            showOperateLocalFileActionSheet(fileInfo, index: row, cell: cell!)
        }
    }

    /**
     追加ツールバーボタン押下時に呼び出される。

     - Parameter sender: 追加ツールバーボタン
     */
    @IBAction func addToolbarButtonPressed(sender: AnyObject) {
        // ファイル追加画面に遷移する。
        let vc = AddLocalFileViewController(pathName: pathName)
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }

    /**
     grepツールバーボタン押下時に呼び出される。

     - Parameter sender: 追加ツールバーボタン
     */
    @IBAction func grepToolbarButtonPressed(sender: AnyObject) {
        // Grep一覧画面に遷移する。
        let vc = GrepLocalFileListViewController(grepWord: "", pathName: pathName, encoding: NSUTF8StringEncoding)
        navigationController?.pushViewController(vc, animated: true)
    }

    /**
     削除ツールバーボタン押下時に呼び出される。

     - Parameter sender: 削除ツールバーボタン
     */
    func deleteToolbarButtonPressed(sender: UIBarButtonItem) {

    }

    /**
     コピーツールバーボタン押下時に呼び出される。

     - Parameter sender: コピーツールバーボタン
     */
    func copyToolbarButtonPressed(sender: UIBarButtonItem) {
        // ディレクトリ選択画面に遷移する。
        let fileInfoList = getCheckedFileInfoList()
        let indexPaths = tableView.indexPathsForSelectedRows

        let vc = SelectDirViewController(pathName: "/", fileInfoList: fileInfoList)
        navigationController?.pushViewController(vc, animated: true)
    }

    /**
     移動ツールバーボタン押下時に呼び出される。

     - Parameter sender: 移動ツールバーボタン
     */
    func moveToolbarButtonPressed(sender: UIBarButtonItem) {
        // ディレクトリ選択画面に遷移する。
        let fileInfoList = getCheckedFileInfoList()

        let vc = SelectDirViewController(pathName: "/", fileInfoList: fileInfoList)
        navigationController?.pushViewController(vc, animated: true)
    }

    /**
     チェックされたファイル情報リストを取得する。

     - Returns: チェックされたファイル情報リスト
     */
    func getCheckedFileInfoList() -> [FileInfo] {
        var checkedFileInfoList = [FileInfo]()

        let rowNum = tableView.numberOfRowsInSection(0)
        for var i = 0; i < rowNum; i++ {
            let indexPath = NSIndexPath(forItem: i, inSection: 0)
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            let check = cell?.editingAccessoryType

            if check == UITableViewCellAccessoryType.Checkmark {
                let fileInfo = fileInfoList[i]
                checkedFileInfoList.append(fileInfo)
            }
        }

        return checkedFileInfoList
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
        searchBar = UISearchBar(frame: searchBarFrame)
        searchBar!.delegate = self
        searchBar!.showsCancelButton = true

        let searchDisplayController = UISearchDisplayController(searchBar: searchBar!, contentsController: self)
        searchDisplayController.delegate = self;
        searchDisplayController.searchResultsDelegate = self;
        searchDisplayController.searchResultsDataSource = self;
        tableView.tableHeaderView = searchBar;
    }


    // MARK: - ActionSheet

    /**
     ローカルファイル操作アクションシートを表示する。

     - Parameter fileInfo: ファイル情報
     - Parameter index: ファイル情報の位置
     - Parameter cell: テーブルビューセル
    */
    private func showOperateLocalFileActionSheet(fileInfo: FileInfo, index: Int, cell: UITableViewCell) {
        // ローカルファイル操作アクションシートを生成する。
        let alertTitle = LocalizableUtils.getString(LocalizableConst.kActionSheetTitleLocalFile)
        let alert = UIAlertController(title: alertTitle, message: "", preferredStyle: .ActionSheet)
        // iPadでクラッシュする対応
        alert.popoverPresentationController?.sourceView = view
        alert.popoverPresentationController?.sourceRect = cell.frame

        // キャンセルボタンを生成する。
        let cancelButtonTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleCancel)
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .Cancel, handler: nil)
        alert.addAction(cancelAction)

        let name = fileInfo.name
        let isDir = fileInfo.isDir
        if !isDir {
            // 文字エンコーディングを指定して開くボタンを生成する。
            let openCharButtonTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleOpenChar)
            let openCharAction = UIAlertAction(title: openCharButtonTitle, style: .Default, handler: {(action: UIAlertAction) -> Void in
                // 文字エンコーディング選択画面に遷移する。
                let vc = SelectEncodingViewController(sourceClassName: self.dynamicType.description(), pathName: self.pathName, fileName: name)
                self.navigationController?.pushViewController(vc, animated: true)
            })
            alert.addAction(openCharAction)
        }

        // 削除ボタンを生成する。
        let deleteButtonTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleDelete)
        let deleteAction = UIAlertAction(title: deleteButtonTitle, style: .Default, handler: {(action: UIAlertAction) -> Void in
            // ファイル削除確認アラートを表示する。
            self.showDeleteFileConfirmAlert(name, index: index)
        })
        alert.addAction(deleteAction)

        // アラートを表示する。
        self.presentViewController(alert, animated: true, completion: nil)
    }

    /**
     ファイル削除確認アラートを表示する。

     - Parameter name: ファイル名またはディレクトリ名
     - Parameter index: ファイル情報の位置
     */
    private func showDeleteFileConfirmAlert(name: String, index: Int) {
        // ファイル削除確認アラートを生成する。
        let alertTitle = LocalizableUtils.getString(LocalizableConst.kAlertTitleConfirm)
        let alertMessage = LocalizableUtils.getStringWithArgs(LocalizableConst.kAlertMessageDeleteConfirm, "\(name)")
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .Alert)

        // キャンセルボタンを生成する。
        let cancelButtonTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleCancel)
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .Cancel, handler: nil)

        // 削除ボタンを生成する。
        let deleteButtonTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleDelete)
        let okAction = UIAlertAction(title: deleteButtonTitle, style: .Default, handler: {(action: UIAlertAction) -> Void in
            // 削除する。
            self.deleteFile(name, index: index)
        })

        // 各ボタンをアラートに設定する。
        alert.addAction(cancelAction)
        alert.addAction(okAction)

        // アラートを表示する。
        self.presentViewController(alert, animated: true, completion: nil)
    }

    /**
     ファイルまたはディレクトリを削除する。

     - Parameter name: ファイル名またはディレクトリ名
     - Parameter index: ファイル情報の位置
     */
    func deleteFile(name: String, index: Int) {
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
            self.fileInfoList.removeAtIndex(index)
            self.tableView.reloadData()
        }
    }
}
