//
//  BaseViewController.swift
//  PWEditor
//
//  Created by 二俣征嗣 on 2016/02/19.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import UIKit
import GoogleMobileAds
import SwiftyDropbox

/**
 基底ビューコントローラクラス

 - Version: 1.0 新規作成
 - Author: paveway.info@gmail.com
 */
class BaseViewController: UIViewController, GADBannerViewDelegate {

    // MARK: - Constants

    /// 行番号最大値
    let kListNumberMax = 4

    /// 拡張キーリスト1
    let kExtendKeyList1 = [";", ":", ".", ",", "_", "\"", "'", "@"]

    /// 拡張キーリスト2
    let kExtendKeyList2 = ["(", ")", "{", "}", "[", "]", "<", ">"]

    /// 拡張キーリスト3
    let kExtendKeyList3 = ["=", "+", "-", "*", "/", "%"]

    /// 拡張キーリスト4
    let kExtendKeyList4 = ["&", "|", "!", "?", "#", "$", "~", "^"]

    /// Undoボタンタイトル
    let kUndoButtonTitle = "U"

    /// Redoボタンタイトル
    let kRedoButtonTitle = "R"

    /// 前へボタンタイトル
    let kPrevButtonTitle = "▲"

    /// 次へボタンタイトル
    let kNextButtonTitle = "▼"

    /// 閉じるボタンタイトル
    let kCloseButtonTitle = "↓"

    // MARK: - Variables

    /// 対象のビュー
    var targetView: UIView?

    /// 行番号
    var listNumber: Int!

    var undoButton: UIBarButtonItem?

    var redoButton: UIBarButtonItem?

    // MARK: - UIViewControllerDelegate

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if ((self as? MenuViewController) == nil) {
            setupSlidingViewController()
            navigationController?.interactivePopGestureRecognizer?.enabled = false
        }
    }

    // MARK: - Common method

    /**
     バナービューを作成する。

     - Parameter bannerView: バナービュー
     */
    func setupBannerView(bannerView: GADBannerView) {
        let adUnitId = ConfigUtils.getConfigValue(CommonConst.ConfigKey.kAdmobAdUnitId)
        bannerView.adUnitID = adUnitId

        var deviceIds = ConfigUtils.getConfigValues(CommonConst.ConfigKey.kAdmobTestDeviceId)
        deviceIds.append(kGADSimulatorID as! String)

        bannerView.delegate = self
        bannerView.rootViewController = self
        let request = GADRequest()
        request.testDevices = deviceIds

        //dispatch_async(dispatch_get_main_queue(), {
            bannerView.loadRequest(request)
        //})
    }

    /**
     スライディングビューコントローラを作成する。
     */
    func setupSlidingViewController() {
        let appDelegate = EnvUtils.getAppDelegate()
        view.addGestureRecognizer(appDelegate.slidingViewController!.panGesture)
        appDelegate.slidingViewController!.topViewController.view.layer.shadowOpacity = CommonConst.SlidingViewSetting.kShadowOpacity
        appDelegate.slidingViewController!.topViewController.view.layer.shadowRadius = CommonConst.SlidingViewSetting.kShadowRadius
        appDelegate.slidingViewController!.topViewController.view.layer.shadowColor = UIColor.blackColor().CGColor
    }

    /**
     左バーボタンを作成する。
     */
    func createLeftBarButton() {
        let action = Selector("leftBarButtonPressed:")
        let title = LocalizableUtils.getString(LocalizableConst.kButtonTitleMenu)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: title, style: .Plain, target: self, action: action)
    }

    /**
     右バーボタンを作成する。

     - Parameter title: タイトル
     */
    func createRightBarButton(title title: String) {
        let action = Selector("rightBarButtonPressed:")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: title, style: .Plain, target: self, action: action)
    }

    /**
     右バーボタンを作成する。

     - Parameter style: スタイル(デフォルトDone)
     */
    func createRightBarButton(style: UIBarButtonItemStyle = .Done) {
        let action = Selector("rightBarButtonPressed:")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: action)
    }

    /**
     トップビューをリセットする。

     - Parameter vc: ビューコントローラ
     */
    func resetTopView(vc: UIViewController) {
        let appDelegate = EnvUtils.getAppDelegate()
        let slidingViewController = appDelegate.slidingViewController!
        let nc = UINavigationController(rootViewController: vc)
        slidingViewController.topViewController = nc
        slidingViewController.resetTopViewAnimated(true)
        appDelegate.slidingViewController = slidingViewController
    }

    // MARK: - Button handler

    /**
     左バーボタンが押下された時に呼び出される。

     - Parameter sender: 左バーボタン
     */
    func leftBarButtonPressed(sender: UIBarButtonItem) {
        let appDelegate = EnvUtils.getAppDelegate()
        if (appDelegate.slidingViewController?.currentTopViewPosition == ECSlidingViewControllerTopViewPosition.AnchoredRight) {
            appDelegate.slidingViewController?.resetTopViewAnimated(true)

        } else {
            appDelegate.slidingViewController?.anchorTopViewToRightAnimated(true)
        }
    }

    /**
     右バーボタンが押下された時に呼び出される。

     - Parameter sender: 右バーボタン
     */
    func rightBarButtonPressed(sender: UIButton) {
        // サブクラスで実装する。
    }

    // MARK: - Alert

    /**
     アラートを表示する(アラート表示のみ)

     - Parameter title: タイトル
     - Parameter message: メッセージ
     - Parameter okButtonTitle: OKボタンタイトル(デフォルト"OK")
     - Parameter handler: OKボタン押下時の処理
     */
    func showAlert(title: String, message: String, okButtonTitle: String = LocalizableUtils.getString(LocalizableConst.kButtonTitleOk), handler: (() -> Void)? = nil) {
        // アラートを表示する。
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: okButtonTitle, style: .Default, handler: {(action: UIAlertAction!) -> Void in
            handler?()
        })
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: nil)
    }

    /**
     アラートを表示する(アラート表示のみ)

     - Parameter title: タイトル
     - Parameter message: メッセージ
     - Parameter okButtonTitle: OKボタンタイトル(デフォルト"OK")
     - Parameter cancelButtonTitle: キャンセルボタンタイトル(デフォルト"キャンセル")
     - Parameter handler: OKボタン押下時の処理
     */
    func showAlertWithCancel(title: String, message: String, okButtonTitle: String = LocalizableUtils.getString(LocalizableConst.kButtonTitleOk), cancelButtonTitle: String = LocalizableUtils.getString(LocalizableConst.kButtonTitleCancel), handler: (() -> Void)? = nil) {
        // アラートを表示する。
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: okButtonTitle, style: .Default, handler: {(action: UIAlertAction!) -> Void in
            handler?()
        })
        alert.addAction(okAction)

        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .Cancel, handler: nil)
        alert.addAction(cancelAction)

        presentViewController(alert, animated: true, completion: nil)
    }

    /**
     アラートを表示する(遷移元画面に戻る)

     - Parameter title: タイトル
     - Parameter message: メッセージ
     - Parameter okButtonTItle: OKボタンタイトル
     */
    func showAlertBack(title: String, message: String, okButtonTitle: String) {
        // アラートを表示する。
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)

        let okAction = UIAlertAction(title: okButtonTitle, style: .Default, handler: {(action: UIAlertAction!) -> Void in
            // 元の画面に戻る。
            self.navigationController?.popViewControllerAnimated(true)
        })
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: nil)
    }

    /**
     画面構成をリセットする。
     エラーアラートを表示し、ローカルファイル一覧画面に遷移する。

     */
    func resetScreen() {
        // エラーアラートを表示する。
        let title = LocalizableUtils.getString(LocalizableConst.kAlertTitleError)
        let message = LocalizableUtils.getString(LocalizableConst.kAlertMessageDropboxInvalid)
        showAlert(title, message: message, handler: { () -> Void in
            // トップ画面をローカルファイル一覧画面として画面構成を再設定する。
            let appDelegate = EnvUtils.getAppDelegate()
            let topVc = LocalFileListViewController(pathName: "")
            let topNc = UINavigationController(rootViewController: topVc)
            topNc.view.layer.shadowOpacity = CommonConst.SlidingViewSetting.kShadowOpacity
            topNc.view.layer.shadowRadius = CommonConst.SlidingViewSetting.kShadowRadius
            topNc.view.layer.shadowColor = UIColor.blackColor().CGColor
            appDelegate.slidingViewController?.topViewController = topNc

            let menuVc = MenuViewController()
            let menuNc = UINavigationController(rootViewController: menuVc)
            appDelegate.slidingViewController?.underLeftViewController = menuNc

            appDelegate.window?.rootViewController = appDelegate.slidingViewController
        })
    }

    // MARK: - Internal Method

    /**
    拡張キーボードボタン押下時の処理

    - Parameter sender: 押下されたボタン
    */
    func onClickExtendKeyboardButton(sender: UIBarButtonItem) {
        let title = sender.title
        switch title! {
        case kUndoButtonTitle:
            // Undoボタンの場合
            if targetView != nil {
                let undoManager = targetView!.undoManager
                if undoManager != nil {
                    if undoManager!.canUndo {
                        undoManager!.undo()
                        if !undoManager!.canUndo {
                            undoButton?.enabled = false
                        }
                        redoButton?.enabled = true
                    } else {
                        undoButton?.enabled = false
                        if undoManager!.canRedo {
                            redoButton?.enabled = true
                        } else {
                            redoButton?.enabled = false
                        }
                    }
                }
            }
            break

        case kRedoButtonTitle:
            // Redoボタンの場合
            break

        case kNextButtonTitle:
            // 次の行へボタンの場合
            if listNumber < kListNumberMax {
                listNumber = listNumber + 1
            } else {
                listNumber = 0
            }
            setExtendKeyboardItems(listNumber)
            break

        case kPrevButtonTitle:
            // 前の行へボタンの場合
            if listNumber > 0 {
                listNumber = listNumber - 1
            } else {
                listNumber = kListNumberMax - 1
            }
            setExtendKeyboardItems(listNumber)
            break

        case kCloseButtonTitle:
            // キーボードを閉じるボタンの場合
            targetView?.resignFirstResponder()
            break

        default:
            // その他の場合
            // 入力された文字をビューに反映する。
            if let targetView = targetView as? UITextView {
                targetView.text = targetView.text + title!

            } else if let targetView = targetView as? UITextView {
                targetView.text = targetView.text + title!
            }
            break
        }
    }

    // MARK: - Extend Keyboard

    /**
    拡張キーボードのボタンを生成する。

    - Parameter lineNumber: 行番号
    - Returns: 拡張キーボードのボタン
    */
    func createExtendKeyboardItems(lineNumber: Int) -> [UIBarButtonItem] {
        let action = Selector("onClickExtendKeyboardButton:")
        let barButtonArray = NSMutableArray()

        // TODO: Undo/Redo対応は保留
        // Undoボタン
        undoButton = UIBarButtonItem(title: kUndoButtonTitle, style: .Plain, target: self, action: action)
//        barButtonArray.addObject(undoButton!)

        // Redoボタン
        redoButton = UIBarButtonItem(title: kRedoButtonTitle, style: .Plain, target: self, action: action)
//        barButtonArray.addObject(redoButton!)

        // スペース
        let space = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)

        // 拡張キーのリストを決定する。
        let extendKeyList: [String]!
        if lineNumber == 0 {
            extendKeyList = kExtendKeyList1

        } else if lineNumber == 1 {
            extendKeyList = kExtendKeyList2

        } else if lineNumber == 2 {
            extendKeyList = kExtendKeyList3

        } else {
            extendKeyList = kExtendKeyList4
        }

        // 各拡張キーリストのキー数分繰り返す。
        let count = extendKeyList.count
        for var i = 0; i < count; i++ {
            let title = extendKeyList[i]
            let button = UIBarButtonItem(title: title, style: .Plain, target: self, action: action)
            barButtonArray.addObject(button)
            barButtonArray.addObject(space)
        }

        // 次の行ボタン
        let nextButton = UIBarButtonItem(title: kNextButtonTitle, style: .Plain, target: self, action: action)
        barButtonArray.addObject(nextButton)

        // 前の行ボタン
        let prevButton = UIBarButtonItem(title: kPrevButtonTitle, style: .Plain, target: self, action: action)
        barButtonArray.addObject(prevButton)

        // キーボードを閉じるボタン
        let closeButton = UIBarButtonItem(title: kCloseButtonTitle, style: .Plain, target: self, action: action)
        barButtonArray.addObject(closeButton)

        return barButtonArray as NSArray as! [UIBarButtonItem]
    }

    /**
     拡張キーボードを生成する。

     - Returns: 拡張キーボード
     */
    func createExtendKeyboard() -> UIToolbar {
        let frame = CGRectMake(0, 0, view.frame.width, 0)
        let accessoryView = UIToolbar(frame: frame)
        accessoryView.sizeToFit()
        return accessoryView
    }

    /**
     拡張キーボードのボタンを設定する。

     - Parameter listNumber: 行番号
     */
    func setExtendKeyboardItems(listNumber: Int) {
        if targetView != nil {
            let extendKeyboard = targetView!.inputAccessoryView as! UIToolbar
            let extendKeyboardItems = createExtendKeyboardItems(listNumber)
            extendKeyboard.setItems(extendKeyboardItems, animated: false)
        }
    }
}
