//
//  BaseTableViewController.swift
//  PWEditor
//
//  Created by 二俣征嗣 on 2016/02/19.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import UIKit

/**
 基底テーブルビューコントローラクラス

 - Version: 1.0 新規作成
 - Author: paveway.info@gmail.com
 */
class BaseTableViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: - Constants

    /// セル名
    let kCellName = "Cell"

    /// 1行データ入力用セル名
    let kLineDataCellName = "LineDataCell"

    /// 1行データ入力用セルNIB名
    let kLineDataTableViewCellNibName = "EnterLineDataTableViewCell"

    // MARK: - Variables

    /// リフレッシュコントロール
    var refreshControl: UIRefreshControl?

    // MARK: - UITableViewDataSource

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = getTableViewCell(tableView)
        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }

    func setupTableView(tableView: UITableView) {
        tableView.dataSource = self
        tableView.delegate = self
    }

    func getTableViewCell(tableView: UITableView) -> UITableViewCell {
        // セルを取得する。
        var cell = tableView.dequeueReusableCellWithIdentifier(kCellName) as UITableViewCell?
        if (cell == nil) {
            // セルが取得できない場合
            // セルを生成する。
            cell = UITableViewCell()
        }

        cell!.textLabel?.text = ""
        cell!.accessoryType = .None

        return cell!
    }

    func getTableViewDetailCell(tableView: UITableView) -> UITableViewCell {
        // セルを取得する。
        var cell = tableView.dequeueReusableCellWithIdentifier(kCellName) as UITableViewCell?
        if (cell == nil || cell?.detailTextLabel == nil) {
            // セルが取得できない場合
            // セルを生成する。
            cell = UITableViewCell(style: .Value1, reuseIdentifier: kCellName)
        }

        cell!.textLabel?.text = ""
        cell!.detailTextLabel?.text = ""
        cell!.accessoryType = .None

        return cell!
    }

    func getTableViewLineDataCell(tableView: UITableView) -> EnterLineDataTableViewCell {
        var lineDataCell = tableView.dequeueReusableCellWithIdentifier(kLineDataCellName) as? EnterLineDataTableViewCell
        if (lineDataCell == nil) {
            // セルを生成する。
            lineDataCell = EnterLineDataTableViewCell()
        }
        return lineDataCell!
    }

    // MARK: - Common method

    /**
     セルロングタップを生成する。

     - Parameter tableView: テーブルビュー
     - Parameter delegate: デリゲート
     - Parameter selector: セレクター
     */
    func createCellLogPressed(tableView: UITableView, delegate: UIGestureRecognizerDelegate, selector: Selector = #selector(BaseTableViewController.cellLongPressed(_:))) {
        let cellLongPressedAction = selector
        let longPressRecognizer = UILongPressGestureRecognizer(target: delegate, action: cellLongPressedAction)
        longPressRecognizer.delegate = delegate
        tableView.addGestureRecognizer(longPressRecognizer)
    }

    /**
     セルがロングタップされた時に呼び出される。
     デフォルトのハンドラで何もしない。
     サブクラスでオーバーライドすること。

     - Parameter recognizer: セルロングタップジェスチャーオブジェクト
     */
    func cellLongPressed(recognizer: UILongPressGestureRecognizer) {
        // 何もしない。
    }

    /**
     リフレッシュコントロールを生成する。
     */
    func createRefreshControl(title: String = LocalizableUtils.getString(LocalizableConst.kUpdate), tableView: UITableView) {
        // リフレッシュコントロールを生成する。
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: title)
        let action = #selector(BaseTableViewController.pullRefresh)
        refreshControl?.addTarget(self, action: action, forControlEvents: .ValueChanged)

        // テーブルビューにリフレッシュコントロールを追加する。
        tableView.addSubview(refreshControl!)
    }

    // MARK: - Override

    /**
    引っ張って更新する。
    サブクラスで実装する。
    */
    func pullRefresh() {
        // 何もしない。
    }
}
