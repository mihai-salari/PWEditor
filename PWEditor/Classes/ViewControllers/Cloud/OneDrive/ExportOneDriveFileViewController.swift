//
//  ExportOneDriveFileViewController.swift
//  PWEditor
//
//  Created by mfuta1971 on 2016/06/21.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import UIKit
import GoogleMobileAds
import OneDriveSDK

/**
 OneDriveファイルエクスポート画面

 - Version: 1.0 新規作成
 - Author: paveway.info@gmail.com
 */
class ExportOneDriveFileViewController: BaseTableViewController, UIGestureRecognizerDelegate {

    // MARK: - Constants

    /// 画面タイトル
    let kScreenTitle = LocalizableUtils.getString(LocalizableConst.kExportOneDriveFileScreenTitle)

    // MARK: - Variables

    /// テーブルビュー
    @IBOutlet weak var tableView: UITableView!

    /// バナービュー
    @IBOutlet weak var bannerView: GADBannerView!

    /// 遷移元クラス名
    private var sourceClassName: String!

    /// 親アイテムID
    private var parentItemId: String!

    /// ファイル名
    private var fileName: String!

    /// ファイルデータ
    private var fileData: NSData!

    /// ディレクトリアイテムリスト
    private var dirItemList = [ODItem]()

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
     - Parameter parentItemId: 親アイテムID
     - Parameter fileName: ファイル名
     - Parameter fileData: ファイルデータ
     */
    init(sourceClassName: String, parentItemId: String, fileName: String, fileData: NSData) {
        // 引数のデータを保存する。
        self.sourceClassName = sourceClassName
        self.parentItemId = parentItemId
        self.fileName = fileName
        self.fileData = fileData

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

        if parentItemId.isEmpty {
            let dirItem = ODItem()
            dirItem.id = "root"
            dirItem.name = "/"
            dirItemList.append(dirItem)

        } else {
            // ディレクトリアイテムリストを取得する。
            getDirItemList()
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
        // ディレクトリアイテムリストの件数を返却する。
        let count = dirItemList.count
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

        // ディレクトリアイテムリストが未取得の場合、処理を終了する。
        let row = indexPath.row
        let count = dirItemList.count
        if row + 1 > count {
            return cell
        }

        let dirItem = dirItemList[row]
        let name = dirItem.name
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

        // ディレクトリアイテムリストが未取得の場合、処理を終了する。
        let row = indexPath.row
        let count = dirItemList.count
        if row + 1 > count {
            return
        }

        // 次のサブディレクトリパス名を取得する。
        let dirInfo = dirItemList[row]
        if parentItemId.isEmpty {
            // ルートディレクトリの場合
            parentItemId = "root"

        } else {
            parentItemId = dirInfo.id
        }

        // OneDriveファイルエクスポート画面に遷移する。
        let vc = ExportOneDriveFileViewController(sourceClassName: sourceClassName, parentItemId: parentItemId, fileName: fileName, fileData: fileData)
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
            let count = dirItemList.count
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
        var dirItem: ODItem? = nil
        let rowNum = tableView?.numberOfRowsInSection(0)
        for var i = 0; i < rowNum; i += 1 {
            let indexPath = NSIndexPath(forItem: i, inSection: 0)
            let cell = tableView?.cellForRowAtIndexPath(indexPath)
            let check = cell?.accessoryType

            if check == UITableViewCellAccessoryType.Checkmark {
                let row = indexPath.row
                dirItem = dirItemList[row]
                break
            }
        }

        if dirItem == nil {
            // 選択されたディレクトリアイテムが取得できない場合
            // エラーアラートを表示して終了する。
            let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
            let message = LocalizableUtils.getString(LocalizableConst.kAlertMessageDirNotSelectError)
            showAlert(title, message: message)
            return
        }

        // ファイルをエクスポートする。
        let parentId = dirItem!.id
        exportFile(parentId)
    }

    // MARK: - OneDrive API

    /**
     ファイル情報リストを取得する。
     */
    func getDirItemList() {
        let client = ODClient.loadCurrentClient()
        if client == nil {
            // OneDriveが無効な場合
            let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
            let message = LocalizableUtils.getString(LocalizableConst.kAlertMessageOneDriveInvalid)
            self.showAlert(title, message: message)
            return
        }

        // ネットワークアクセス通知を表示する。
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

        // OneDriveファイルリストを取得する。
        client.drive().items(self.parentItemId).children().request().getWithCompletion( { (children: ODCollection?, nextRequest: ODChildrenCollectionRequest?, error: NSError?) -> Void in
            // ネットワークアクセス通知を消す。
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false

            if error != nil {
                // エラーの場合
                let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
                let errorCode = error!.code
                let errorMessage = error!.localizedDescription
                let message = LocalizableUtils.getStringWithArgs(LocalizableConst.kAlertMessageGetFileListError, errorCode, errorMessage)
                let queue = dispatch_get_main_queue()
                dispatch_async(queue) {
                    self.showAlert(title, message: message) {
                        // 遷移元画面に戻る。
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                }
                return
            }

            if children == nil {
                // OneDriveファイルリストが取得できない場合
                let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
                let message = LocalizableUtils.getString(LocalizableConst.kAlertMessageGetFileListFailed)
                let queue = dispatch_get_main_queue()
                dispatch_async(queue) {
                    self.showAlert(title, message: message) {
                        // 遷移元画面に戻る。
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                }
                return
            }

            self.dirItemList.removeAll(keepCapacity: false)
            for item in children!.value as! [ODItem] {
                if item.folder != nil {
                    self.dirItemList.append(item)
                }
            }

            let count = self.dirItemList.count
            if count == 0 {
                // サブディレクトリが無い場合
                // エラーアラートを表示する。
                let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
                let message = LocalizableUtils.getString(LocalizableConst.kAlertMessageNoDirectoryError)
                let okButtonTitle = LocalizableUtils.getString(LocalizableConst.kButtonTitleClose)
                self.showAlert(title, message: message, okButtonTitle: okButtonTitle) {
                    // 遷移元画面に戻る。
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }

            // UI操作はメインスレッドで行う。
            let queue = dispatch_get_main_queue()
            dispatch_sync(queue) {
                // テーブルビューを更新する。
                self.tableView.reloadData()
            }
        })
    }

    /**
     ファイルをエクスポートする。

     - Parameter parentId: 親ID
     */
    private func exportFile(parentId: String) {
        let client = ODClient.loadCurrentClient()
        if client == nil {
            // OneDriveが無効な場合
            let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
            let message = LocalizableUtils.getString(LocalizableConst.kAlertMessageOneDriveInvalid)
            showAlert(title, message: message)
            return
        }

        // ネットワークアクセス通知を表示する。
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

        // ベースURLを取得する。
        let baseURL = client.baseURL

        // アクセストークンを取得する。
        let accountSession = client.authProvider.accountSession!()
        let accessToken = accountSession.accessToken

        // URL文字列を生成する。
        let urlString = "\(baseURL)/drive/items/\(parentId)/children/\(fileName)/content"
        // URLを生成する。
        let url = NSURL(string: urlString)
        if url == nil {
            // URLが生成できない場合
            // ネットワークアクセス通知を消す。
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false

            // エラーアラートを表示して終了する。
            let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
            let message = LocalizableUtils.getString(LocalizableConst.kAlertMessageUrlError)
            showAlert(title, message: message)
            return
        }

        // HTTPリクエストを生成する。
        let request = NSMutableURLRequest(URL: url!)

        // キャッシュをオフにする。
        request.cachePolicy = .ReloadIgnoringLocalCacheData

        // HTTPメソッドを設定する。
        request.HTTPMethod = CommonConst.Http.Method.kPUT

        // Content-Typeを設定する。
        let contentType = CommonConst.Http.HTTPHeaderField.Key.kContentType
        let kTextPlain = CommonConst.Http.HTTPHeaderField.Value.kTextPlain
        request.setValue(kTextPlain, forHTTPHeaderField: contentType)

        // Authorizationを設定する。
        let authorization = CommonConst.Http.HTTPHeaderField.Key.kAuthorization
        let bearer = String(format: CommonConst.Http.HTTPHeaderField.Value.kBearer, accessToken)
        request.setValue(bearer, forHTTPHeaderField: authorization)

        // ファイルデータを設定する。
        request.HTTPBody = fileData

        // 通信タスクを生成する。
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            // ネットワークアクセス通知を消す。
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false

            if error != nil {
                // エラーの場合
                // エラーアラートを表示して終了する。
                let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
                let message = LocalizableUtils.getString(LocalizableConst.kAlertMessageHttpRequestError)
                self.showAlertAsync(title, message: message)
                return
            }

            var message = ""
            if data != nil {
                message = String(data: data!, encoding: NSUTF8StringEncoding)!
            }

            // HTTPステータスコードを取得する。
            let statusCode = (response as! NSHTTPURLResponse).statusCode
            // HTTPステータスコード別に処理を振り分ける。
            switch statusCode {
            case 200, 201:
                // 正常終了の場合
                // 遷移元画面に戻る。
                self.popViewController()
                break

            default:
                // エラーの場合
                // エラーアラートを表示して終了する。
                let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
                let message = LocalizableUtils.getStringWithArgs(LocalizableConst.kAlertMessageHttpStatusError, statusCode, message)
                self.showAlertAsync(title, message: message)
                break
            }
        })
        // HTTP通信タスクを実行する。
        task.resume()
    }

    /**
     遷移元画面に戻る。
     */
    func popViewController(thread: Bool = true) {
        // 画面遷移数を取得する。
        let count = navigationController?.viewControllers.count
        // 最後に表示した画面から画面遷移数確認する。
        for var i = count! - 1; i >= 0; i-- {
            let vc = navigationController?.viewControllers[i]
            if vc!.dynamicType.description() == sourceClassName {
                // 表示した画面が遷移元画面の場合
                // 画面を戻す。
                if thread {
                    let queue = dispatch_get_main_queue()
                    dispatch_sync(queue) {
                        self.navigationController?.popToViewController(vc!, animated: true)
                    }
                } else {
                    navigationController?.popToViewController(vc!, animated: true)
                }
                break
            }
        }
    }
}
