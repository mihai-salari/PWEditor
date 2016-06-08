//
//  SearchAndReplaceViewController.swift
//  PWEditor
//
//  Created by mfuta1971 on 2016/06/07.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import UIKit
import GoogleMobileAds

@objc protocol SearchAndReplaceDelegate {

    func receiveData(searchword: String)
    func receiveData(searchWord: String, replaceWord: String)
    func receiveData(searchWord: String, replaceWord: String, fileData: String)
}

/**
 検索・置換画面クラス

 - Version: 1.0 新規作成
 - Author: paveway.info@gmail.com
 */
class SearchAndReplaceViewController: BaseTableViewController, UITextFieldDelegate {

    // MARK: - Constants

    /// セグメントタイトルリスト
    let kSegmentTitleList = [
        LocalizableUtils.getString(LocalizableConst.kSearchAndReplaceSegmentedTitleSearch),
        LocalizableUtils.getString(LocalizableConst.kSearchAndReplaceSegmentedTitleReplace)
    ]

    // セグメントインデックス
    enum SegmentedIndex: Int {
        // 検索
        case Search

        // 置換
        case Replace
    }

    /// セクションタイトルリスト
    let kSectionTitleList = [
        LocalizableUtils.getString(LocalizableConst.kSearchAndReplaceSectionTitleInput),
        LocalizableUtils.getString(LocalizableConst.kSearchAndReplaceSectionTitleResult),
    ]

    /// セクションインデックス
    enum SectionIndex: Int {
        case Input
        case Result
    }

    /// 入力セルタイトルリスト
    let kInputCellTitleList = [
        LocalizableUtils.getString(LocalizableConst.kSearchAndReplaceCellTitleSearch),
        LocalizableUtils.getString(LocalizableConst.kSearchAndReplaceCellTitleReplace),
    ]

    /// 入力セルインデックス
    enum InputCellIndex: Int {
        case Search
        case Replace
    }

    // MARK: - Variables

    /// テーブルビュー
    @IBOutlet weak var tableView: UITableView!

    /// バナービュー
    @IBOutlet weak var bannerView: GADBannerView!

    /// セグメントコントロール
    private var segmentedControl: UISegmentedControl!

    /// セグメントインデックス
    private var segmentedIndex = SegmentedIndex.Search.rawValue

    /// 検索結果情報リスト
    private var searchResultInfoList = [SearchResultInfo]()

    /// ファイル名
    private var fileName: String!

    /// ファイルデータ
    private var fileData: String!

    /// 検索単語
    private var searchWord: String!

    /// 置換単語
    private var replaceWord: String!

    /// 検索・置換デリゲート
    var delegate: SearchAndReplaceDelegate?

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

     - Parameter fileName: ファイル名
     - Parameter fileData: ファイルデータ
     - Parameter searchWord: 検索単語
     - Parameter replaceWord: 置換単語
     */
    init(fileName: String, fileData: String, searchWord: String, replaceWord: String) {
        // 引数を保存する。
        self.fileName = fileName
        self.fileData = fileData
        self.searchWord = searchWord
        self.replaceWord = replaceWord

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
        navigationItem.title = fileName

        // 右バーボタンを作成する。
        let title = LocalizableUtils.getString(LocalizableConst.kButtonTitleReplace)
        createRightBarButton(title: title)
        navigationItem.rightBarButtonItem!.enabled = false

        // テーブルビューを設定する。
        setupTableView(tableView)

        // カスタムテーブルビューセルを設定する。
        let nib  = UINib(nibName: kLineDataTableViewCellNibName, bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: kLineDataCellName)

        // セグメントコントロールを設定する。
        segmentedControl = UISegmentedControl(items: kSegmentTitleList)
        segmentedControl.selectedSegmentIndex = segmentedIndex
        let action = #selector(segmentedControlChanged(_:))
        segmentedControl.addTarget(self, action: action, forControlEvents: .ValueChanged)
        tableView.tableHeaderView = segmentedControl

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

    /**
     画面が表示される前に呼び出される。
 
     - Parameter animated: アニメーション指定
     */
    override func viewWillAppear(animated: Bool) {
        // スーパークラスのメソッドを呼び出す。
        super.viewWillAppear(animated)

        // 単語検索を行う。
        search()
    }

    // MARK: - UISegmentedControl

    /**
     セグメントコントロールが変更された時に呼び出される。

     - Parameter sender: セグメントコントロール
     */
    func segmentedControlChanged(sender: UISegmentedControl) {
        // セグメントインデックスを更新する。
        segmentedIndex = sender.selectedSegmentIndex

        switch segmentedIndex {
        case SegmentedIndex.Search.rawValue:
            // 検索の場合
            navigationItem.rightBarButtonItem!.enabled = false

            searchWord = getSearchWord()
            if searchWord.isEmpty {
                searchResultInfoList.removeAll(keepCapacity: false)

            } else {
                search()
            }
            delegate?.receiveData(searchWord)

            // テーブルビューを更新する。
            tableView.reloadData()
            break

        case SegmentedIndex.Replace.rawValue:
            // 置換の場合
            searchWord = getSearchWord()
            if searchWord.isEmpty {
                searchResultInfoList.removeAll(keepCapacity: false)

            } else {
                search()
            }

            // テーブルビューを更新する。
            tableView.reloadData()

            replaceWord = getReplaceWord()

            let count = searchResultInfoList.count
            if count > 0 {
                navigationItem.rightBarButtonItem!.enabled = true

            } else {
                navigationItem.rightBarButtonItem!.enabled = false
            }

            delegate?.receiveData(searchWord, replaceWord: replaceWord)
            break

        default:
            // 上記以外、何もしない。
            break
        }
    }

    // MARK: - UITableViewDataSource

    /**
     セクション数を返却する。

     - Parameter tableView: テーブルビュー
     - Returns: セクション数
     */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return kSectionTitleList.count
    }

    /**
     セクションのタイトルを返却する。

     - Parameter tableView: テーブルビュー
     - Parameter section: セクション番号
     - Returns: セクションのタイトル
     */
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return kSectionTitleList[section] as String
    }

    /**
     セクション内のセル数を返却する。

     - Parameter tableView: テーブルビュー
     - Parameter section: セクション番号
     - Returns: セクション内のセル数
     */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SectionIndex.Input.rawValue:
            // 入力セクションの場合
            let count: Int
            if segmentedIndex == SegmentedIndex.Search.rawValue {
                // 検索の場合
                count = 1

            } else {
                // 置換の場合
                count = 2
            }
            return count

        case SectionIndex.Result.rawValue:
            // 結果セクションの場合
            let count = searchResultInfoList.count
            return count

        default:
            // 上記以外、無効値を返却する。
            return 0;
        }
    }

    /**
     セルを返却する。

     - Parameter tableView: テーブルビュー
     - Parameter indexPath: インデックスパス
     - Returns: セル
     */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row

        var cell: UITableViewCell?

        // セクションにより処理を振り分ける。
        switch section {
        case SectionIndex.Input.rawValue:
            // 入力セクションの場合
            // セルにより処理を振り分ける。
            switch row {
            case InputCellIndex.Search.rawValue:
                // 検索セルの場合
                // 1行データ入力セルを取得する。
                cell = getLineDataCell(tableView, tag: row, text: searchWord)
                break

            case InputCellIndex.Replace.rawValue:
                // 置換セルの場合
                // 1行データ入力セルを取得する。
                cell = getLineDataCell(tableView, tag: row, text: replaceWord)
                break

            default:
                // 上記以外、何もしない。
                break
            }
            break

        case SectionIndex.Result.rawValue:
            // 結果セクションの場合
            cell = getTableViewDetailCell(tableView)

            // セルのラベルにファイル名+行番号を設定する。
            let searchResultInfo = searchResultInfoList[row]
            let line = searchResultInfo.line
            cell!.textLabel!.text = "(\(line))"

            // セルの詳細ラベルにファイルデータを設定する。
            let data = searchResultInfo.data
            cell!.detailTextLabel!.text = data
            cell!.detailTextLabel!.lineBreakMode = .ByTruncatingMiddle
            break

        default:
            // 上記以外、何もしない。
            break
        }
        
        return cell!
    }

    /**
     1行データセルを返却する。
 
     - Parameter tableView: テーブルテーブルビュー
     */
    private func getLineDataCell(tableView: UITableView, tag: Int, text: String) -> UITableViewCell {
        let lineDataCell = getTableViewLineDataCell(tableView)

        let textField = lineDataCell.textField
        textField?.delegate = self
        textField?.keyboardType = .ASCIICapable
        textField?.returnKeyType = .Done
        textField?.placeholder = kInputCellTitleList[tag]
        textField?.clearButtonMode = .WhileEditing
        textField.tag = tag
        textField.text = text
        let cell = lineDataCell as UITableViewCell
        return cell
    }

    // MARK: - UITableViewDelegate

    /**
     セルが選択された時に呼び出される。

     - Parameter tableView: テーブルビュー
     - Parameter indexPath: インデックスパス
     */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // 選択状態を解除する。
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        // セクションにより処理を振り分ける。
        let section = indexPath.section
        switch section {
        case SectionIndex.Result.rawValue:
            // 結果セクションの場合
            // 検索結果情報リストが未取得の場合、処理を終了する。
            let row = indexPath.row
            let count = searchResultInfoList.count
            if row + 1 > count {
                return
            }
            break

        default:
            // 上記以外、何もしない。
            break
        }
    }

    // MARK: - UIGestureRecognizerDelegate

    /**
     画面がタップされた場合に呼び出される。
 
 　  - Parameter sender: 画面
     */
    func screenTapped(sender: AnyObject) {
        // キーボードを閉じる。
        view.endEditing(true)
    }

    // MARK: - UITextFieldDelegate

    /**
     キーボードのリターンキーが押下された時に呼び出される。
 
     - Parameter textField: テキストフィールド
     - Returns: 処理結果
     */
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        // キーボードを閉じる。
        let result = textField.resignFirstResponder()

        let text = textField.text

        // 選択されたセグメントにより処理を振り分ける。
        switch segmentedIndex {
        case SegmentedIndex.Search.rawValue:
            // 検索の場合
            if text == nil {
                searchWord = ""
            } else {
                searchWord = text
            }

            // 検索単語を取得する。
            if searchWord.isEmpty {
                // 検索単語が空の場合
                // 検索結果情報リストをクリアする。
                searchResultInfoList.removeAll(keepCapacity: false)

                // テーブルビューを更新する。
                tableView.reloadData()

            } else {
                // 検索単語が空ではない場合
                // 単語検索を行う。
                search()
            }

            delegate?.receiveData(searchWord)
            break

        case SegmentedIndex.Replace.rawValue:
            // 置換の場合
            delegate?.receiveData(searchWord, replaceWord: replaceWord)

            // 置換単語を取得する。
            replaceWord = getReplaceWord()

            // 検索結果情報数を取得する。
            let count = searchResultInfoList.count
            if count == 0 {
                // 検索結果情報がない場合
                // 右上バーボタンを無効にする。
                navigationItem.rightBarButtonItem!.enabled = false

            } else {
                // 検索結果除法がある場合
                // 右上バーボタンを有効にする。
                navigationItem.rightBarButtonItem!.enabled = true
            }
            break

        default:
            // 上記以外、何もしない。
            break
        }

        return result
    }

    /**
     テキストフィールドのクリアボタン押下時に呼び出される。
 
     - Parameter textField: テキストフィールド
     - Returns: 処理結果 常にtrue
     */
    func textFieldShouldClear(textField: UITextField) -> Bool {
        // キーボードを閉じる。
        textField.resignFirstResponder()

        let tag = textField.tag
        switch tag {
        case InputCellIndex.Search.rawValue:
            // 検索の場合
            searchWord = ""
            // 検索結果をクリアする。
            searchResultInfoList.removeAll(keepCapacity: false)
            tableView.reloadData()

            navigationItem.rightBarButtonItem!.enabled = false
            break

        case InputCellIndex.Replace.rawValue:
            // 置換の場合
            replaceWord = ""
            break

        default:
            // 上記以外、何もしない。
            break
        }

        return true
    }

    // MARK: - Button Handler

    /**
     右バーボタン押下時に呼び出される。

     - Parameter sender: 右バーボタン
     */
    override func rightBarButtonPressed(sender: UIButton) {
        // 単語置換を行う。
        replace()
    }

    /**
     検索単語を取得する。
 
     - Returns: 検索単語
     */
    private func getSearchWord() -> String {
        let section = SectionIndex.Input.rawValue
        let item = InputCellIndex.Search.rawValue
        let textField = getTextField(section, item: item)
        let text = textField.text
        if text == nil {
            // テキストが取得できない場合
            return ""

        } else {
            // テキストが取得できた場合
            return text!
        }
    }

    /**
     置換単語を取得する。
 
     - Parameter 置換単語
     */
    private func getReplaceWord() -> String {
        let section = SectionIndex.Input.rawValue
        let item = InputCellIndex.Replace.rawValue
        let textField = getTextField(section, item: item)
        let text = textField.text
        if text == nil {
            // テキストが取得できない場合
            return ""

        } else {
            // テキストが取得できた場合
            return text!
        }
    }

    /**
     テキストフィールドを取得する。
 
     - Parameter section: セクション
     - Parameter cell: セル
     - Returns: テキストフィールド
     */
    private func getTextField(section: Int, item: Int) -> UITextField {
        let indexPath = NSIndexPath(forItem: item, inSection: section)
        let cell = tableView?.cellForRowAtIndexPath(indexPath) as! EnterLineDataTableViewCell
        let textField = cell.textField
        return textField
    }

    /**
     単語検索を行う。
     */
    private func search() {
        // 検索結果情報リストをクリアする。
        searchResultInfoList.removeAll(keepCapacity: false)

        // 1行ごとに分割する。
        let lines = fileData.componentsSeparatedByString("\n")
        let count = lines.count
        for i in 0 ..< count {
            // 行数分繰り返す。
            let line = lines[i]
            let range = line.rangeOfString(searchWord)
            if range != nil {
                // 行に検索単語が含まれる場合
                let searchResultInfo = SearchResultInfo()
                searchResultInfo.line = String(i + 1)

                let deleteTarget = NSCharacterSet.whitespaceCharacterSet
                let trimedLine = line.stringByTrimmingCharactersInSet(deleteTarget())
                searchResultInfo.data = trimedLine

                // 検索結果情報リストに追加する。
                searchResultInfoList.append(searchResultInfo)
            }
        }

        // テーブルビューを更新する。
        tableView.reloadData()
    }

    /**
     単語置換を行う。
     */
    private func replace() {
        // 1行ごとに分割する。
        var lines = fileData.componentsSeparatedByString("\n")
        let resultCount = searchResultInfoList.count
        for i in 0 ..< resultCount {
            // 行数分繰り返す。
            let searchResultInfo = searchResultInfoList[i]
            let srcData = searchResultInfo.data
            let dstData = srcData.stringByReplacingOccurrencesOfString(searchWord, withString: replaceWord)
            let index = Int(searchResultInfo.line)! - 1
            lines[index] = dstData
        }

        fileData = ""
        let lineCount = lines.count
        for i in 0 ..< lineCount {
            fileData = fileData.stringByAppendingString(lines[i]) + "\n"
        }

        delegate?.receiveData(searchWord, replaceWord: replaceWord, fileData: fileData)

        // 再度検索を行う。
        search()
    }
}
