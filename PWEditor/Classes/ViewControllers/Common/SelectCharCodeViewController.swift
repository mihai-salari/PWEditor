//
//  SelectEncodeViewController.swift
//  PWEditor
//
//  Created by 二俣征嗣 on 2016/03/04.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import UIKit
import GoogleMobileAds

class SelectCharCodeViewController: BaseTableViewController {

    // MARK: - Constants

    /// 画面タイトル
    let kScreenTitle = LocalizableUtils.getString(LocalizableConst.kSelectCharCodeScreenTitle)

    /// セクションタイトルリスト
    let kSectionTitleList = [
        LocalizableUtils.getString(LocalizableConst.kSelectCharCodeSectionTitleCharCode),
        LocalizableUtils.getString(LocalizableConst.kSelectCharCodeSectionTitleReturnCode)
    ]

    /// 文字コードセルタイトルリスト
    let kCharCodeCellTitleList = [
        "UTF-8",
        "Shift-JIS",
        "EUC"
    ]

    /// 改行コードセルタイトルリスト
    let kReturnCodeCellTitleList = [
        "Unix(LF)",
        "Windows(CR/LF)",
        "Mac(CR)"
    ]

    enum SectionIndex: Int {
        case CharCode = 0
        case ReturnCode = 1
    }

    /// 文字コードセルインデックス
    enum StringEncodingCellIndex: Int {
        case Utf8 = 0
        case ShiftJis = 1
        case Euc = 2
    }

    /// 改行コードセルインデックス
    enum ReturnCodeIndex: Int {
        case Unix = 0
        case Windows = 1
        case Mac = 2
    }

    // MARK: - Variables

    /// テーブルビュー
    @IBOutlet weak var tableView: UITableView!

    /// バナービュー
    @IBOutlet weak var bannerView: GADBannerView!

    /// 遷移元クラス名
    var sourceClassName: String!

    /// パス名
    var pathName: String!

    /// ファイル名
    var fileName: String!

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

     - Parameter sourceClassName: 遷移元クラス名
     - Parameter pathName: パス名
     - Parameter fileName: ファイル名
     */
    init(sourceClassName: String, pathName: String, fileName: String) {
        // 引数のデータを保存する。
        self.sourceClassName = sourceClassName
        self.pathName = pathName
        self.fileName = fileName

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

        // 右バーボタンを作成する。
        createRightBarButton()

        // テーブルビューを設定する。
        setupTableView(tableView)

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
     セクション数を返却する。

     - Parameter tableView: テーブルビュー
     */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return kSectionTitleList.count
    }

    /**
     セクションのタイトルを返却する。

     - Parameter tableView: テーブルビュー
     - Parameter section: セクション
     - Returns: セクションのタイトル
     */
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return kSectionTitleList[section] as String
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SectionIndex.CharCode.rawValue:
            return CommonConst.CharCodeNameList.count

        case SectionIndex.ReturnCode.rawValue:
            return CommonConst.RetCodeNameList.count
        default:
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = getTableViewCell(tableView)

        let section = indexPath.section
        let row = indexPath.row

        switch section {
        case SectionIndex.CharCode.rawValue:
            // 文字コードセクションの場合
            cell.textLabel?.text = kCharCodeCellTitleList[row]
            if row == 0 {
                cell.accessoryType = .Checkmark

            } else {
                cell.accessoryType = .None
            }
            break

        case SectionIndex.ReturnCode.rawValue:
            // 改行コードセクションの場合
            cell.textLabel?.text = kReturnCodeCellTitleList[row]
            if row == 0 {
                cell.accessoryType = .Checkmark

            } else {
                cell.accessoryType = .None
            }
            break

        default:
            break
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
        // 選択状態を解除する。
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        let section = indexPath.section
        let row = indexPath.row

        switch section {
        case SectionIndex.CharCode.rawValue:
            // セル位置のセルを取得する。
            let cell = tableView.cellForRowAtIndexPath(indexPath)

            // チェックマークを設定する
            cell?.accessoryType = .Checkmark

            // 選択されていないセルのチェックマークを外す。
            let valuesNum = kCharCodeCellTitleList.count
            for var i = 0; i < valuesNum; i++ {
                if i != row {
                    let unselectedIndexPath = NSIndexPath(forRow: i, inSection: section)
                    let unselectedCell = tableView.cellForRowAtIndexPath(unselectedIndexPath)
                    unselectedCell?.accessoryType = .None
                }
            }
            break

        case SectionIndex.ReturnCode.rawValue:
            // セル位置のセルを取得する。
            let cell = tableView.cellForRowAtIndexPath(indexPath)

            // チェックマークを設定する
            cell?.accessoryType = .Checkmark

            // 選択されていないセルのチェックマークを外す。
            let valuesNum = kReturnCodeCellTitleList.count
            for var i = 0; i < valuesNum; i++ {
                if i != row {
                    let unselectedIndexPath = NSIndexPath(forRow: i, inSection: section)
                    let unselectedCell = tableView.cellForRowAtIndexPath(unselectedIndexPath)
                    unselectedCell?.accessoryType = .None
                }
            }
            break

        default:
            // 上記以外、何もしない。
            break
        }
    }

    // MARK: - Button Handler

    /**
    右バーボタン押下時に呼び出される。

    - Parameter sender: 右バーボタン
    */
    override func rightBarButtonPressed(sender: UIButton) {
        // 選択された文字コードを取得する。
        var charCodeType = -1
        let charCodeSection = SectionIndex.CharCode.rawValue
        let charCodeRowNum = tableView?.numberOfRowsInSection(charCodeSection)
        for (var i = 0; i < charCodeRowNum; i++) {
            let indexPath = NSIndexPath(forItem: i, inSection: charCodeSection)
            let cell = tableView?.cellForRowAtIndexPath(indexPath)
            let check = cell?.accessoryType

            if check == UITableViewCellAccessoryType.Checkmark {
                charCodeType = indexPath.row
                break
            }
        }
        if charCodeType == -1 {
            // 文字コードが取得できない場合、処理終了
            return
        }

        // 選択された改行コードを取得する。
        var returnCodeType = -1
        let returnCodeSection = SectionIndex.CharCode.rawValue
        let returnCodeRowNum = tableView?.numberOfRowsInSection(returnCodeSection)
        for (var i = 0; i < returnCodeRowNum; i++) {
            let indexPath = NSIndexPath(forItem: i, inSection: returnCodeSection)
            let cell = tableView?.cellForRowAtIndexPath(indexPath)
            let check = cell?.accessoryType

            if check == UITableViewCellAccessoryType.Checkmark {
                returnCodeType = indexPath.row
                break
            }
        }
        if returnCodeType == -1 {
            // 改行コードが取得できない場合、処理終了
            return
        }

        if sourceClassName == DropboxFileListViewController.self.description() {
            // 遷移元画面がDropboxファイル一覧画面の場合
            // Dropboxファイル編集画面に遷移する。
            let vc = EditDropboxFileViewController(pathName: pathName, fileName: fileName, charCodeType: charCodeType, retCodeType: returnCodeType)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
