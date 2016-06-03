//
//  AppDelegate.swift
//  PWEditor
//
//  Created by 二俣征嗣 on 2016/02/18.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import UIKit
import SwiftyDropbox
import OneDriveSDK
//import BoxContentSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    /// ウィンドウ
    var window: UIWindow?

    /// スライディングビューコントローラー
    var slidingViewController: ECSlidingViewController?

    /// デフォルトフォント名
    var defaultFontName = CommonConst.FontName.kCourierNew

    /// デフォルトフォントサイズ
    var defaultFontSize = CommonConst.FontSize.kDefault

    /// 入力用フォント名
    var enterDataFontName = CommonConst.FontName.kCourierNew

    /// 入力用フォントサイズ
    var enterDataFontSize = CommonConst.FontSize.kEnterData

    /// メソッド変更フラグ
    var isChangedMethod = false

    /// GoogleDriveクライアントID
    var googleDriveClientId: String!

    /// スコープ
    private let scopes = [kGTLAuthScopeDrive]

    /// GoogleDriveサービスドライブ
    let googleDriveServiceDrive = GTLServiceDrive()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        if !isChangedMethod {
            // メソッドが変更されていない場合、メソッドを変更する。
            isChangedMethod = true
            MethodUtils.changeTextViewMethod()
        }

        // iCloudの初期化を行う。
        // TODO: ライブラリを使用するためとりあえず不要
        //initializeiCloudAccess()

        // Dropboxの初期化を行う。
        let appKey = ConfigUtils.getConfigValue(CommonConst.ConfigKey.kDropBoxAppKey)
        Dropbox.setupWithAppKey(appKey)

        // GoogleDriveクライアントIDを取得する。
        googleDriveClientId = ConfigUtils.getConfigValue(CommonConst.ConfigKey.kGoogleDriveClientId)

        // 認証オブジェクトを取得する。
        let keyChainItemName = CommonConst.GoogleDrive.kKeychainItemName
        let auth = GTMOAuth2ViewControllerTouch.authForGoogleFromKeychainForName(keyChainItemName, clientID: googleDriveClientId, clientSecret: nil)
        if auth != nil {
            // 認証情報が取得できた場合
            googleDriveServiceDrive.authorizer = auth
        }

        // OneDriveクライアントIDを取得する。
        let oneDriveClientId = ConfigUtils.getConfigValue(CommonConst.ConfigKey.kOneDriveClientId)
        let scopes = CommonConst.OneDrive.kScopes
        ODClient.setMicrosoftAccountAppId(oneDriveClientId, scopes: scopes)

//        let boxClientId = ConfigUtils.getConfigValue(CommonConst.ConfigKey.kBoxClientId)
//        let boxSecret = ConfigUtils.getConfigValue(CommonConst.ConfigKey.kBoxSecret)
//        BOXContentClient.setClientID(boxClientId, clientSecret: boxSecret)

        // トップ画面を作成する。
        let topVc = LocalFileListViewController(pathName: "")
        let topNc = UINavigationController(rootViewController: topVc)
        topNc.view.layer.shadowOpacity = CommonConst.SlidingViewSetting.kShadowOpacity
        topNc.view.layer.shadowRadius = CommonConst.SlidingViewSetting.kShadowRadius
        topNc.view.layer.shadowColor = UIColor.blackColor().CGColor

        // スライディングビューコントローラーを作成し、トップ画面を設定する。
        slidingViewController = ECSlidingViewController()
        slidingViewController?.topViewController = topNc

        // メニュー画面を作成する。
        let menuVc = MenuViewController()
        let menuNc = UINavigationController(rootViewController: menuVc)

        // スライディングビューコントローラーの右画面にメニュー画面を設定する。
        slidingViewController?.underLeftViewController = menuNc
        slidingViewController?.anchorRightRevealAmount = CommonConst.SlidingViewSetting.kRightRevealAmount

        // ウィンドウを作成し、スライディングビューコントローラーを設定する。
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.rootViewController = slidingViewController
        window?.makeKeyAndVisible()
        return true
    }

    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {

        if let authResult = Dropbox.handleRedirectURL(url) {
            switch authResult {
            case .Success(let token):
                // 成功の場合
                // トップ画面が設定画面として画面構成を再設定する。
                let topVc = SettingsViewController()
                let topNc = UINavigationController(rootViewController: topVc)
                topNc.view.layer.shadowOpacity = CommonConst.SlidingViewSetting.kShadowOpacity
                topNc.view.layer.shadowRadius = CommonConst.SlidingViewSetting.kShadowRadius
                topNc.view.layer.shadowColor = UIColor.blackColor().CGColor
                slidingViewController?.topViewController = topNc

                let menuVc = MenuViewController()
                let menuNc = UINavigationController(rootViewController: menuVc)
                slidingViewController?.underLeftViewController = menuNc

                window?.rootViewController = slidingViewController

            case .Error(let error, let description):
                print("Error \(error): \(description)")
            }
        }
        
        return false
    }

    func initializeiCloudAccess() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let fileManager = NSFileManager.defaultManager()
            let ubiquityContainerIdentifier = fileManager.URLForUbiquityContainerIdentifier(nil)
            if ubiquityContainerIdentifier != nil {
                LogUtils.d("iCloud available.")
            } else {
                LogUtils.d("iCloud not available.")
            }
        })
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self)
    }
}

