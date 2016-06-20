//
//  SelectLocalDirViewController.swift
//  PWEditor
//
//  Created by 二俣征嗣 on 2016/03/11.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import UIKit
import GoogleMobileAds

/**
 ローカルディレクトリ選択画面

 - Version: 1.0 新規作成
 - Authoer: paveway.info@gmail.com
 */
class SelectLocalDirViewController: BaseTableViewController, UIGestureRecognizerDelegate {

    // MARK: - Constants

    /// 画面タイトル
    let kScreenTitle = LocalizableUtils.getString(LocalizableConst.kSelectLocalDirScreenTitle)

    // MARK: - Variables

    // テーブルビュー
    @IBOutlet weak var tableView: UITableView!

    // バナービュー
    @IBOutlet weak var bannerView: GADBannerView!

    /// パス名
    private var pathName: String!

    /// 名前
    private var name: String!

    /// 元のパス名
    private var srcPathName: String!

    /// 元の名前
    private var srcName: String!

    /// 操作タイプ
    private var operateType: Int!

    /// ディレクトリ情報リスト
    private var dirInfoList = [FileInfo]()

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
     - Parameter name: 名前
     - Parameter srcPathName: 元のパス名
     - Parameter srcName: 元の名前
     - Parameter operateType: 操作タイプ
     */
    init(pathName: String, name: String, srcPathName: String, srcName: String, operateType: Int) {
        // 引数のデータを保存する。
        self.pathName = pathName
        self.name = name
        self.srcPathName = srcPathName
        self.srcName = srcName
        self.operateType = operateType

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

        // セルロングタップを設定する。
        createCellLogPressed(tableView, delegate: self)

        // バナービューを設定する。
        setupBannerView(bannerView)

        if pathName == "/" {
            // ルートディレクトリの場合
            let fileInfo = FileInfo()
            fileInfo.name = pathName
            fileInfo.isDir = true
            dirInfoList.append(fileInfo)

        } else {
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
        let count = dirInfoList.count
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

        let row = indexPath.row
        let dirInfo = dirInfoList[row]
        let name = dirInfo.name
        cell.textLabel!.text = name
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

        // 次のサブディレクトリパス名を取得する。
        let row = indexPath.row
        let dirInfo = dirInfoList[row]
        let name = dirInfo.name
        let path: String
        if pathName == "/" {
            // ルートディレクトリの場合
            path = ""

        } else {
            if pathName == "" {
                // 1階層目の場合
                path = "\(name)"

            } else {
                // 2階層目以降の場合
                path = "\(pathName)/\(name)"
            }
        }

        // サブディレクトリ内にディレクトリが存在するか確認する。
        let localPath = FileUtils.getLocalPath(path)
        let tmpdirInfoList = FileUtils.getDirInfoListInDir(localPath)
        let dirNum = tmpdirInfoList.count
        if dirNum == 0 {
            // ディレクトリが存在しない場合
            // アラートを表示して処理終了
            let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
            let message = LocalizableUtils.getString(LocalizableConst.kAlertMessageNoDirectoryError)
            showAlert(title, message: message)
            return
        }

        // ローカルディレクトリ選択画面に遷移する。
        let vc = SelectLocalDirViewController(pathName: path, name: name, srcPathName: srcPathName, srcName: srcName, operateType: operateType)
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
            // チェックマークを設定する。
            let cell = tableView.cellForRowAtIndexPath(indexPath!)
            if cell == nil {
                return
            }

            if cell!.accessoryType == .Checkmark {
                // チェックマークが設定されている場合
                cell!.accessoryType = .DisclosureIndicator

            } else {
                // チェックマークが設定されていない場合
                cell!.accessoryType = .Checkmark
            }

            // 選択されていないセルのチェックマークを外す。
            let count = dirInfoList.count
            let row = indexPath!.row
            for i in 0 ..< count {
                if i != row {
                    let unselectedIndexPath = NSIndexPath(forRow: i, inSection: 0)
                    let unselectedCell = tableView.cellForRowAtIndexPath(unselectedIndexPath)
                    unselectedCell?.accessoryType = .DisclosureIndicator
                }
            }
        }
    }

    // MARK: - Bar button

    /**
     右バーボタン押下時に呼び出される。

     - Parameter sender: 右バーボタン
     */
    override func rightBarButtonPressed(sender: UIButton) {
        // 選択されたディレクトリ情報を取得する。
        var fileInfo: FileInfo? = nil
        let rowNum = tableView?.numberOfRowsInSection(0)
        for var i = 0; i < rowNum; i += 1 {
            let indexPath = NSIndexPath(forItem: i, inSection: 0)
            let cell = tableView?.cellForRowAtIndexPath(indexPath)
            let check = cell?.accessoryType

            if check == UITableViewCellAccessoryType.Checkmark {
                let row = indexPath.row
                fileInfo = dirInfoList[row]
                break
            }
        }

        if fileInfo == nil {
            // 選択されたディレクトリ情報が取得できない場合
            // エラーアラートを表示して終了する。
            let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
            let message = LocalizableUtils.getString(LocalizableConst.kAlertMessageDirNotSelectError)
            showAlert(title, message: message)
            return
        }

        // コピー・移動先パス名を取得する。
        let dirName = fileInfo!.name
        let toPathName: String
        if pathName == "/" {
            // ルートディレクトリの場合
            toPathName = ""

        } else {
            // ルートディレクトリ以外の場合
            if pathName.isEmpty {
                // 1階層目の場合
                toPathName = "\(dirName)"

            } else {
                // 2階層目以降の場合
                toPathName = "\(pathName)/\(dirName)"
            }
        }

        // 存在確認用の名前を取得する。
        let toName: String
        if toPathName.isEmpty {
            // コピー・移動先パス名が空の場合
            toName = srcName

        } else {
            // 上記以外
            toName = "\(toPathName)/\(srcName)"
        }

        // コピー・移動先に同名のファイル・ディレクトリが存在するか確認する。
        let toPath = FileUtils.getLocalPath(toName)
        var result = FileUtils.isExist(toPath)
        if result {
            // コピー先に同名のファイルまたはディレクトリが存在する場合
            // エラーアラートを表示して終了する。
            let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
            let message = LocalizableUtils.getString(LocalizableConst.kAlertMessageSameFileName)
            showAlert(title, message: message)
            return
        }

        // 操作タイプにより処理を振り分ける。
        switch operateType {
        case CommonConst.OperateType.Copy.rawValue:
            // コピーを行う。
            result = FileUtils.copy(srcPathName, name: srcName, toPathName: toPathName)
            if !result {
                // コピーできない場合
                // エラーアラートを表示して終了する。
                let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
                let message = LocalizableUtils.getString(LocalizableConst.kAlertMessageCopyError)
                showAlert(title, message: message)
                return
            }
            break

        case CommonConst.OperateType.Move.rawValue:
            // 移動を行う。
            result = FileUtils.move(srcPathName, name: srcName, toPathName: toPathName)
            if !result {
                // 移動できない場合
                // エラーアラートを表示して終了する。
                let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
                let message = LocalizableUtils.getString(LocalizableConst.kAlertMessageMoveError)
                showAlert(title, message: message)
                return
            }
            break

        default:
            // 上記以外、何もしない。
            break
        }

        // 遷移元画面に戻る。
        popViewController()
    }

    // MARK: - Private method

    /**
     遷移元画面に戻る。
     */
    func popViewController() {
        // 画面遷移数を取得する。
        let count = navigationController?.viewControllers.count
        // 最後に表示した画面から画面遷移数確認する。
        for var i = count! - 1; i >= 0; i-- {
            let vc = navigationController?.viewControllers[i]
            if vc!.dynamicType == LocalFileListViewController.self {
                // 表示した画面がローカルファイル一覧画面の場合
                // 画面を戻す。
                navigationController?.popToViewController(vc!, animated: true)
                break
            }
        }
    }
}
