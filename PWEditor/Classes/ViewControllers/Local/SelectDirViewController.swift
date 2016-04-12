//
//  SelectDirViewController.swift
//  PWEditor
//
//  Created by 二俣征嗣 on 2016/03/11.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import UIKit
import GoogleMobileAds

/**
 ディレクトリ選択画面

 - Version: 1.0 新規作成
 - Authoer: paveway.info@gmail.com
 */
class SelectDirViewController: BaseTableViewController, UIGestureRecognizerDelegate {

    // MARK: - Constants

    /// 画面タイトル
    let kScreenTitle = LocalizableUtils.getString(LocalizableConst.kSelectDirScreenTitle)

    // MARK: - Variables

    // テーブルビュー
    @IBOutlet weak var tableView: UITableView!

    // バナービュー
    @IBOutlet weak var bannerView: GADBannerView!

    /// パス名
    var pathName: String!

    /// ファイル情報リスト
    var fileInfoList: [FileInfo]!

    /// ディレクトリ情報リスト
    var dirInfoList: [FileInfo]?

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
     - Parameter fileInfoList: ファイル情報リスト
     */
    init(pathName: String, fileInfoList: [FileInfo]) {
        // 引数のデータを保存する。
        self.pathName = pathName
        self.fileInfoList = fileInfoList

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

        // テーブルビューを設定する。
        setupTableView(tableView)

        // セルロングタップを設定する。
        createCellLogPressed(tableView, delegate: self)

        // バナービューを設定する。
        setupBannerView(bannerView)

        if pathName != "/" {
            // ルートディレクトリ以外の場合
            // ディレクトリ情報リストを取得する。
            let localPathName = FileUtils.getLocalPath(pathName)
            dirInfoList = FileUtils.getDirInfoListInDir(localPathName)
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

    // MARK: - UITableViewDataSource

    /**
    セクション内のセル数を返却する。

    - Parameter tableView: テーブルビュー
    - Parameter section: セクション番号
    - Returns: セクション内のセル数
    */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // ディレクトリ情報リストの件数を返却する。
        let count: Int
        if pathName == "/" {
            // ルートディレクトリの場合
            count = 1
        } else {
            // ルートディレクトリ以外の場合
            count = dirInfoList!.count
        }
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

        if pathName == "/" {
            // ルートディレクトリの場合
            cell.textLabel!.text = pathName

        } else {
            // ルートディレクトリ以外の場合
            let row = indexPath.row
            let dirInfo = dirInfoList![row]
            cell.textLabel!.text = dirInfo.name
        }
        cell.accessoryType = .DisclosureIndicator

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

        // ディレクトリ選択画面に遷移する。
        let localPathName: String
        if pathName == "/" {
            // ルートディレクトの場合
            localPathName = ""
        } else {
            // ルートディレクトリ以外の場合
            let row = indexPath.row
            let dirInfo = dirInfoList![row]
            if pathName.isEmpty {
                // 1階層目の場合
                localPathName = dirInfo.name
            } else {
                // 2階層目以降の場合
                localPathName = "\(pathName)/\(dirInfo.name)"
            }
        }
        let vc = SelectDirViewController(pathName: localPathName, fileInfoList: fileInfoList)
        navigationController?.pushViewController(vc, animated: true)
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
            // ディレクトリパス名を取得する。
            let driPathName: String
            if pathName == "/" {
                // ルートディレクトの場合
                driPathName = ""
            } else {
                // ルートディレクトリ以外の場合
                let row = indexPath!.row
                let dirInfo = dirInfoList![row]
                if pathName.isEmpty {
                    // 1階層目の場合
                    driPathName = dirInfo.name
                } else {
                    // 2階層目以降の場合
                    driPathName = "\(pathName)/\(dirInfo.name)"
                }
            }
            let localPathName = FileUtils.getLocalPath(driPathName)

        }
    }
}
