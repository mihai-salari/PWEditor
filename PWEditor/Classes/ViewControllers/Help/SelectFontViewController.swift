
//
//  SelectFontViewController.swift
//  pwhub
//
//  Created by 二俣征嗣 on 2015/10/22.
//  Copyright © 2015年 Masatsugu Futamata. All rights reserved.
//

import UIKit
import GoogleMobileAds

/**
フォント選択画面

- Version: 1.0 新規作成
- Author: paveway.info@gmail.com
*/
class SelectFontViewController: BaseTableViewController {

    // MARK: - Constants

    /// 画面タイトル
    let kScreenTitle = LocalizableUtils.getString(LocalizableConst.kSelectFontScreenTitle)

    // MARK: - Variables

    /// テーブルビュー
    @IBOutlet weak var tableView: UITableView!

    /// バナービュー
    @IBOutlet weak var bannerView: GADBannerView!

    /// 受信者番号
    var receiverNo: Int!

    /// フォント名
    var fontName: String!

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

     - Parameter receiverNo: 受信者番号
     */
    init(receiverNo: Int) {
        // 引数のデータを保存する。
        self.receiverNo = receiverNo
        self.fontName = EnvUtils.getEnterDataFontName()

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

        // 右上ボタンを設定する。
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
     セクション内のセル数を返却する。

     - Parameter tableView: テーブルビュー
     - Parameter section: セクション番号
     - Returns: セクション内のセル数
     */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CommonConst.FontFamilyNameList.count
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
        if (cell == nil) {
            // セルを生成する。
            cell = UITableViewCell()
        }

        // セル番号を取得する。
        let row = indexPath.row

        // フォントファミリー名を取得する。
        let fontFamilyName = CommonConst.FontFamilyNameList[row]

        // フォント名を取得する。
        let fontName = CommonConst.FontNameList[row]

        // セルにタイトルを設定する。
        cell?.textLabel!.text = fontFamilyName
        let fontSize = UIFont.systemFontSize()
        cell?.textLabel!.font = UIFont(name: fontName, size: fontSize)

        cell?.accessoryType = .None
        let selectedFontName = EnvUtils.getEnterDataFontName()
        if selectedFontName == fontName {
            cell?.accessoryType = .Checkmark
        }

        // セルを返却する。
        return cell!
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

        // セル位置のセルを取得する。
        let cell = tableView.cellForRowAtIndexPath(indexPath)

        // チェックマークを設定する
        cell?.accessoryType = .Checkmark

        // 選択されていないセルのチェックマークを外す。
        let section = indexPath.section
        let row = indexPath.row
        let fontFamilyNameNum = CommonConst.FontFamilyNameList.count
        for i in 0 ..< fontFamilyNameNum {
            if i != row {
                let unselectedIndexPath = NSIndexPath(forRow: i, inSection: section)
                let unselectedCell = tableView.cellForRowAtIndexPath(unselectedIndexPath)
                unselectedCell?.accessoryType = .None
            }
        }
    }

    // MARK: - Button Handler

    /**
     右上バーボタンが押下された時に呼び出される。

     - Parameter sender: 右上バーボタン
     */
    override func rightBarButtonPressed(sender: UIButton) {
        // チェックされたセルを検索する。
        let rowNum = tableView?.numberOfRowsInSection(0)
        for var i = 0; i < rowNum; i++ {
            let indexPath = NSIndexPath(forItem: i, inSection: 0)
            let cell = tableView?.cellForRowAtIndexPath(indexPath)
            let check = cell?.accessoryType
            if check == UITableViewCellAccessoryType.Checkmark {
                // 選択したフォント名を取得する。
                let fontName = CommonConst.FontNameList[i]

                // フォント名を保存する。
                EnvUtils.setEnterDataFontName(fontName)

                // 遷移元画面に戻る。
                navigationController?.popViewControllerAnimated(true)
            }
        }
    }
}
