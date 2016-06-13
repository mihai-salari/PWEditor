//
//  CreateICloudFileViewController.swift
//  PWEditor
//
//  Created by mfuta1971 on 2016/05/10.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import UIKit
import GoogleMobileAds

/**
 iCloudファイル作成画面クラス

 - Version: 1.0 新規作成
 - Author: paveway.info@gmail.com
 */
class CreateICloudFileViewController: BaseTableViewController, UIGestureRecognizerDelegate, UITextFieldDelegate {

    // MARK: - Constants

    /// 画面タイトル
    let kScreenTitle = LocalizableUtils.getString(LocalizableConst.kCreateICloudFileScreenTitle)

    /// セクションタイトル
    let kSectionTitleList = [
        LocalizableUtils.getString(LocalizableConst.kCreateICloudFileSectionTitleDirName),
        LocalizableUtils.getString(LocalizableConst.kCreateICloudFileSectionTitleFileName),
    ]

    /// セクションインデックス
    enum SectionIndex: Int {
        case DirName
        case FileName
    }

    // MARK: - Variables

    /// テーブルビュー
    @IBOutlet weak var tableView: UITableView!

    /// バナービュー
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
        // 区切り線を非表示にする。
        tableView.tableFooterView = UIView()

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
        case SectionIndex.DirName.rawValue:
            // ディレクトリ名セクションの場合
            return 1

        case SectionIndex.FileName.rawValue:
            // ファイル名セクションの場合
            return 1

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
        var cell: UITableViewCell?

        // セクションにより処理を振り分ける。
        switch section {
        case SectionIndex.DirName.rawValue:
            // ディレクトリ名セクションの場合
            var lineDataCell = tableView.dequeueReusableCellWithIdentifier(kLineDataCellName) as? EnterLineDataTableViewCell
            if (lineDataCell == nil) {
                // セルを生成する。
                lineDataCell = EnterLineDataTableViewCell()
            }

            let textField = lineDataCell!.textField
            textField?.delegate = self
            textField?.keyboardType = .ASCIICapable
            textField?.returnKeyType = .Done
            cell = lineDataCell! as UITableViewCell
            break

        case SectionIndex.FileName.rawValue:
            // ファイル名セクションの場合
            var lineDataCell = tableView.dequeueReusableCellWithIdentifier(kLineDataCellName) as? EnterLineDataTableViewCell
            if (lineDataCell == nil) {
                // セルを生成する。
                lineDataCell = EnterLineDataTableViewCell()
            }

            let textField = lineDataCell!.textField
            textField?.delegate = self
            textField?.keyboardType = .ASCIICapable
            textField?.returnKeyType = .Done
            cell = lineDataCell! as UITableViewCell
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
        let fileNameSection = SectionIndex.FileName.rawValue
        let fileNameTextField = getTextField(fileNameSection)
        fileNameTextField.resignFirstResponder()

        // 入力された名前を取得する。
        let fileName = fileNameTextField.text!
        if fileName.isEmpty {
            // ファイル名が未入力の場合
            // エラーアラートを表示して、処理終了
            let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
            let message = LocalizableUtils.getString(LocalizableConst.kCreateDropboxFileEnterNameError)
            let okButtonTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleClose)
            showAlert(title, message: message, okButtonTitle: okButtonTitle, handler: nil)
            return
        }

        let dirNameSection = SectionIndex.DirName.rawValue
        let dirNameTextField = getTextField(dirNameSection)
        dirNameTextField.resignFirstResponder()
        let dirName = dirNameTextField.text
        if dirName != nil && !dirName!.isEmpty {
            let result = createDirectory(dirName!)
            if !result {
                return
            }
        }

        createFile(dirName!, fileName: fileName)
    }

    private func getTextField(section: Int) -> UITextField {
        let indexPath = NSIndexPath(forItem: 0, inSection: section)
        let cell = tableView?.cellForRowAtIndexPath(indexPath) as! EnterLineDataTableViewCell
        let textField = cell.textField
        return textField
    }

    // MARK: - iCloud

    /**
     ディレクトリを作成する。

     - Parameter pathName: パス名
     - Parameter dirName: ディレクトリ名
     */
    func createDirectory(dirName: String) -> Bool {
        let cloud = iCloud.sharedCloud()
        let fileManager = NSFileManager.defaultManager()
        if !dirName.isEmpty {
            var targetUrl = cloud.ubiquitousDocumentsDirectoryURL()
            if !pathName.isEmpty {
                targetUrl = targetUrl.URLByAppendingPathComponent(pathName)
            }
            targetUrl = targetUrl.URLByAppendingPathComponent(dirName)
            var isDirectory: ObjCBool = false
            let result = fileManager.fileExistsAtPath(targetUrl.path!, isDirectory: &isDirectory)
            if !result || (result && !isDirectory) {
                do {
                    try fileManager.createDirectoryAtURL(targetUrl, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
                    let message = LocalizableUtils.getStringWithArgs(LocalizableConst.kAlertMessageCreateFileError, dirName)
                    showAlert(title, message: message)
                    return false
                }
            }
        }
        return true
    }

    /**
     ファイルを作成する。

     - Parameter dirName: ディレクトリ名
     - Parameter fileName: ファイル名
     */
    func createFile(dirName: String, fileName: String) {
        // ファイルデータを空で生成する。
        let content = NSData()

        // ファイルをiCloudに保存する。
        var targetName = ""
        if !pathName.isEmpty {
            targetName = pathName
        }
        if !dirName.isEmpty {
            if targetName.isEmpty {
                targetName = dirName
            } else {
                targetName = "\(targetName)/\(dirName)"
            }
        }
        if targetName.isEmpty {
            targetName = fileName
        } else {
            targetName = "\(targetName)/\(fileName)"
        }
        let cloud = iCloud.sharedCloud()
        cloud.saveAndCloseDocumentWithName(targetName, withContent: content, completion: { (cloudDocument: UIDocument!, documentData: NSData!, error: NSError!) -> Void in
            if error != nil {
                // エラーの場合
                let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
                let message = LocalizableUtils.getStringWithArgs(LocalizableConst.kAlertMessageCreateFileError, dirName)
                self.showAlert(title, message: message)
            }

            // 遷移元画面に戻る。
            self.navigationController?.popViewControllerAnimated(true)
        })
    }
}
