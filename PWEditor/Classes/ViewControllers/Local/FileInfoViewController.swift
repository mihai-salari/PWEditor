//
//  FileInfoViewController.swift
//  PWEditor
//
//  Created by 二俣征嗣 on 2016/02/23.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import UIKit
import GoogleMobileAds

/**
 ファイル情報画面クラス

 - Version: 1.0 新規作成
 - Author: paveway.info@gmail.com
 */
class FileInfoViewController: BaseTableViewController {

    // MARK: - Constants

    /// 画面タイトル
    let kScreenTitle = LocalizableUtils.getString(LocalizableConst.kFileInfoScreenTitle)

    /// セルインデックス
    enum CellIndex: Int {
        case PathName = 0
        case FileName = 1
        case Size = 2
        case CharNum = 3
        case LineNum = 4
        case RetCodeType = 5
        case UpdateDate = 6
        case FileAttrMax = 7
    }

    // MARK: - Variables

    /// テーブルビュー
    @IBOutlet weak var tableView: UITableView!

    /// バナービュー
    @IBOutlet weak var bannerView: GADBannerView!

    /// パス名
    var pathName: String!

    /// ファイル名
    var fileName: String!

    /// 文字エンコーディング
    var encoding: UInt!

    /// ファイル属性情報
    var fileAttrInfo: NSDictionary?

    /// 文字数
    var charNum = 0

    /// 行数
    var lineNum = 0

    /// 改行コードタイプ
    var retCodeType = CommonConst.RetCodeType.LF.rawValue

    // MARK: - Initializer

    /**
    イニシャライザ

    - parameter coder: デコーダー
    */
    required init?(coder aDecoder: NSCoder) {
        // スーパークラスのイニシャライザを呼び出す。
        super.init(coder: aDecoder)
    }

    /**
     イニシャライザ
     コンテンツ作成時呼び出される。
     */
    init(pathName: String, fileName: String, encoding: UInt) {
        // 引数を保存する。
        self.pathName = pathName
        self.fileName = fileName
        self.encoding = encoding

        // スーパークラスのイニシャライザを呼び出す。
        super.init(nibName: nil, bundle: nil)
    }

    // MARK: - UIViewDelegate

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

        // バナービューを設定する。
        setupBannerView(bannerView)

        // ファイル属性情報を取得する。
        let localFilePathName = FileUtils.getLocalPath(pathName, name: fileName)
        let fileManager = NSFileManager.defaultManager()
        do {
            fileAttrInfo = try fileManager.attributesOfItemAtPath(localFilePathName)
        } catch {
            fileAttrInfo = nil
        }

        if fileAttrInfo != nil {
            // ファイル属性情報が取得できた場合
            // ファイルデータを取得する。
            let returns = FileUtils.getFileData(localFilePathName, encoding: encoding)

            let result = returns.0
            if result {
                return
            }
            let fileData = returns.1

            // 文字数を取得する。
            charNum = fileData.characters.count

            // 行数を取得する。
            fileData.enumerateLines { line, stop in
                self.lineNum++
            }

            // 改行コードタイプを取得する。
            retCodeType = StringUtils.getRetCodeType(fileData, encoding: encoding)
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
        if fileAttrInfo == nil {
            return 0
        } else {
            return CellIndex.FileAttrMax.rawValue
        }
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
            cell = UITableViewCell(style: .Value1, reuseIdentifier: kCellName)
        }

        // セル番号を取得する。
        let row = indexPath.row

        switch row {
        case CellIndex.PathName.rawValue:
            cell?.textLabel?.text = LocalizableUtils.getString(LocalizableConst.kFileInfoCellTitlePathName)
            cell?.detailTextLabel?.text = "/\(pathName)"
            break

        case CellIndex.FileName.rawValue:
            cell?.textLabel?.text = LocalizableUtils.getString(LocalizableConst.kFileInfoCellTitleFileName)
            cell?.detailTextLabel?.text = fileName
            break

        case CellIndex.Size.rawValue:
            cell?.textLabel?.text = LocalizableUtils.getString(LocalizableConst.kFileInfoCellTitleSize)
            let fileSize = Int(fileAttrInfo!.fileSize())
            cell?.detailTextLabel?.text = StringUtils.numberWithComma(fileSize)
            break

        case CellIndex.CharNum.rawValue:
            cell?.textLabel?.text = LocalizableUtils.getString(LocalizableConst.kFileInfoCellTitleCharNum)
            cell?.detailTextLabel?.text = StringUtils.numberWithComma(charNum)
            break

        case CellIndex.LineNum.rawValue:
            cell?.textLabel?.text = LocalizableUtils.getString(LocalizableConst.kFileInfoCellTitleLineNum)
            cell?.detailTextLabel?.text = StringUtils.numberWithComma(lineNum)
            break

        case CellIndex.RetCodeType.rawValue:
            cell?.textLabel?.text = LocalizableUtils.getString(LocalizableConst.kFileInfoCellTitleRetCodeType)
            let text = CommonConst.RetCodeNameList[retCodeType]
            cell?.detailTextLabel?.text = text
            break

        case CellIndex.UpdateDate.rawValue:
            cell?.textLabel?.text = LocalizableUtils.getString(LocalizableConst.kFileInfoCellTitleUpdateDate)
            let updateDate = fileAttrInfo!.fileModificationDate()!
            let updateDateString = DateUtils.getDateString(updateDate)
            cell?.detailTextLabel?.text = String(updateDateString)
            break

        default:
            break
        }

        return cell!
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
    }
}
