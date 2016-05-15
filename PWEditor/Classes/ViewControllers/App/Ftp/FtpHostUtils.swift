//
//  FtpHostUtils.swift
//  PWEditor
//
//  Created by mfuta1971 on 2016/05/13.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import Foundation

class FtpConst: NSObject {
    struct FtpHostKey {
        static let kDisplayName = "displayName"
        static let kHostName = "HostName"
        static let kUserName = "userName"
        static let kPassword = "password"
    }

    struct FtpFileType {
        static let Diretory = 4
        static let File = 8
        static let Link = 10
    }
}

class FtpHostUtils: NSObject {

    /**
     表示名を設定する。
 
     - Parameter value: 表示名
     */
    class func setDisplayName(value: String) {
        let key = FtpConst.FtpHostKey.kDisplayName
        setValue(key, value: value)
    }

    /**
     表示名を取得する。

     - Returns: 表示名
     */
    class func getDisplayName() -> String {
        let value = getValue(FtpConst.FtpHostKey.kDisplayName)
        return value
    }

    /**
     ホスト名を設定する。

     - Parameter value: ホスト名
     */
    class func setHostName(value: String) {
        let key = FtpConst.FtpHostKey.kHostName
        setValue(key, value: value)
    }

    /**
     ホスト名を取得する。

     - Returns: ホスト名
     */
    class func getHostName() -> String {
        let value = getValue(FtpConst.FtpHostKey.kHostName)
        return value
    }

    /**
     ユーザ名を設定する。

     - Parameter value: ユーザ名
     */
    class func setUserName(value: String) {
        let key = FtpConst.FtpHostKey.kUserName
        setValue(key, value: value)
    }

    /**
     ユーザ名を取得する。

     - Returns: ユーザ名
     */
    class func getUserName() -> String {
        let value = getValue(FtpConst.FtpHostKey.kUserName)
        return value
    }

    /**
     パスワードを設定する。

     - Parameter value: パスワード
     */
    class func setPassword(value: String) {
        let key = FtpConst.FtpHostKey.kPassword
        setValue(key, value: value)
    }

    /**
     パスワードを取得する。

     - Returns: パスワード
     */
    class func getPassword() -> String {
        let value = getValue(FtpConst.FtpHostKey.kPassword)
        return value
    }

    class func clear() {
        let ud = NSUserDefaults.standardUserDefaults()
        ud.setObject("", forKey: FtpConst.FtpHostKey.kDisplayName)
        ud.setObject("", forKey: FtpConst.FtpHostKey.kHostName)
        ud.setObject("", forKey: FtpConst.FtpHostKey.kUserName)
        ud.setObject("", forKey: FtpConst.FtpHostKey.kPassword)
    }

    // MARK: - Private

    private class func getValue(key: String) -> String {
        let ud = NSUserDefaults.standardUserDefaults()
        let result: String
        let value = ud.objectForKey(key)
        if value != nil {
            result = value as! String
        } else {
            result = ""
        }
        return result
    }

    private class func setValue(key: String, value: String) {
        let ud = NSUserDefaults.standardUserDefaults()
        ud.setObject(value, forKey: key)
    }
}