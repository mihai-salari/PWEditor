//
//  CreateICloudFileViewController.swift
//  PWEditor
//
//  Created by mfuta1971 on 2016/05/10.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import UIKit
import GoogleMobileAds

class CreateICloudFileViewController: BaseTableViewController, UIGestureRecognizerDelegate, UITextFieldDelegate {

    // MARK: - Constants

    let kScreenTitle = "iCloudファイル一覧"

    let kSectionTitleList = [
        "名前",
        "タイプ"
    ]

    let kFileTypeCellTitleList = [
        "ファイル",
//        "ディレクトリ"
    ]

    enum SectionIndex: Int {
        case FileName
        case FileType
    }

    enum FileTypeCellIndex: Int {
        case File
        case Dir
    }

    // MARK: - Variables

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var bannerView: GADBannerView!

    /// パス名
    var pathName: String!

    /// スクリーンタップジェスチャ
    var screenTapGesture: UITapGestureRecognizer!

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

        // 右バーボタンを作成する。
        createRightBarButton()

        // テーブルビューを設定する。
        setupTableView(tableView)

        // カスタムテーブルビューセルを設定する。
        let nib  = UINib(nibName: kLineDataTableViewCellNibName, bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: kLineDataCellName)

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
        case SectionIndex.FileName.rawValue:
            // ファイル名セクションの場合
            return 1

        case SectionIndex.FileType.rawValue:
            // ファイルタイプセクションの場合
            return kFileTypeCellTitleList.count

        default:
            // 上記以外
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
        var title = ""
        switch section {
        case SectionIndex.FileName.rawValue:
            // ファイル名セクションの場合
            var lineDataCell = tableView.dequeueReusableCellWithIdentifier(kLineDataCellName) as? EnterLineDataTableViewCell
            if (lineDataCell == nil) {
                // セルを生成する。
                lineDataCell = EnterLineDataTableViewCell()
            }

            let textField = lineDataCell?.textField
            textField?.delegate = self
            textField?.keyboardType = .ASCIICapable
            textField?.returnKeyType = .Done
            cell = lineDataCell! as UITableViewCell
            break

        case SectionIndex.FileType.rawValue:
            // ファイルタイプセクションの場合
            cell = getTableViewCell(tableView)
            title = kFileTypeCellTitleList[row]
            cell!.textLabel?.text = title

            if row == FileTypeCellIndex.File.rawValue {
                // ファイルタイプがファイルの場合
                cell?.accessoryType = UITableViewCellAccessoryType.Checkmark

            } else {
                // ファイルタイプがディレクトリの場合
                cell?.accessoryType = UITableViewCellAccessoryType.None
            }
            break

        default:
            // 上記以外、何もしない。
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
        // 選択状態を解除する。
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        let section = indexPath.section
        let row = indexPath.row

        switch section {
        case SectionIndex.FileType.rawValue:
            // セル位置のセルを取得する。
            let cell = tableView.cellForRowAtIndexPath(indexPath)

            // チェックマークを設定する
            cell?.accessoryType = .Checkmark

            // 選択されていないセルのチェックマークを外す。
            let valuesNum = kFileTypeCellTitleList.count
            for i in 0 ..< valuesNum {
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

    // MARK: - UIGestureRecognizerDelegate

    func screenTapped(sender: AnyObject) {
        view.endEditing(true)
    }

    // MARK: - UITextFieldDelegate

    /**
     リターンキーが押下された時に呼び出される。

     - Parameter textField: テキストフィールド
     - Returns: 処理結果
     */
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        // キーボードを閉じる。
        let result = textField.resignFirstResponder()
        return result
    }

    // MARK: - Button Handler

    /**
     右バーボタン押下時に呼び出される。

     - Parameter sender: 右バーボタン
     */
    override func rightBarButtonPressed(sender: UIButton) {
        let section = SectionIndex.FileName.rawValue
        let indexPath = NSIndexPath(forItem: 0, inSection: section)
        let cell = tableView?.cellForRowAtIndexPath(indexPath) as! EnterLineDataTableViewCell
        let textField = cell.textField
        textField.resignFirstResponder()

        // 入力された名前を取得する。
        let name = textField.text!
        if name.isEmpty {
            // 名前が未入力の場合
            // エラーアラートを表示して、処理終了
            let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
            let message = LocalizableUtils.getString(LocalizableConst.kCreateDropboxFileEnterNameError)
            let okButtonTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleClose)
            showAlert(title, message: message, okButtonTitle: okButtonTitle, handler: nil)
            return
        }

        // 選択されたファイルタイプを取得する。
        var fileType = -1
        let fileTypeSection = SectionIndex.FileType.rawValue
        let fileTypeRowNum = tableView?.numberOfRowsInSection(fileTypeSection)
        for (var i = 0; i < fileTypeRowNum; i++) {
            let indexPath = NSIndexPath(forItem: i, inSection: fileTypeSection)
            let cell = tableView?.cellForRowAtIndexPath(indexPath)
            let check = cell?.accessoryType

            if check == UITableViewCellAccessoryType.Checkmark {
                fileType = indexPath.row
                break
            }
        }
        if fileType == -1 {
            // ファイルタイプが取得できない場合、処理終了
            return
        }

        // ファイルタイプにより処理を振り分ける。
        switch fileType {
        case FileTypeCellIndex.File.rawValue:
            // ファイルタイプがファイルの場合
            // ファイルを作成する。
            self.createFile(pathName, fileName: name)
            break

        case FileTypeCellIndex.Dir.rawValue:
            // ファイルタイプがディレクトリの場合
            // ディレクトリを作成する。
            self.createDirectory(pathName, dirName: name)
            break

        default:
            // 上記以外、処理終了
            return
        }
    }

    // MARK: - iCloud

    /**
     ファイルを作成する。

     - Parameter pathName: パス名
     - Parameter fileName: ファイル名
     */
    func createFile(pathName: String, fileName: String) {
        // ファイルデータを空で生成する。
        let content = NSData()

        // ファイルをiCloudに保存する。
        let cloud = iCloud.sharedCloud()
        cloud.saveAndCloseDocumentWithName(fileName, withContent: content, completion: { (cloudDocument: UIDocument!, documentData: NSData!, error: NSError!) -> Void in
            if error != nil {
                // エラーの場合
                let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
                let message = "ファイルが作成できませんでした。"
                self.showAlert(title, message: message, handler: { () -> Void in
                    // 遷移元画面に戻る。
                    self.navigationController?.popViewControllerAnimated(true)
                })
            }

            // 遷移元画面に戻る。
            self.navigationController?.popViewControllerAnimated(true)
        })
    }

    /**
     ディレクトリを作成する。

     - Parameter pathName: パス名
     - Parameter dirName: ディレクトリ名
     */
    func createDirectory(pathName: String, dirName: String) {
    }
}
