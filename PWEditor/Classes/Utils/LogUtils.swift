//
//  LogUtils.swift
//
//  Created by 二俣征嗣 on 2015/08/26.
//  Copyright (c) 2015年 Masatsugu Futamata. All rights reserved.
//
import Foundation
/**
ログ出力ユーティリティ
:version: 1.0 新規作成
- Author: paveway.info@gmail.com
*/
class LogUtils: NSObject {
    /** ログレベル */
    enum LogLevel: Int {
        /** 詳細 */
        case v = 0
        /** デバッグ */
        case d = 1
        /** 情報 */
        case i = 2
        /** 警告 */
        case w = 3
        /** エラー */
        case e = 4
    }
    /** ログ出力制御 */
    private struct ClassProperty {
        // TODO: ログレベルで出力を抑制する場合、levelの設定値を変更する。
        static let Level = LogLevel.v.rawValue
    }
    class var Level: Int {
        get {
            return ClassProperty.Level
        }
    }
    /**
    詳細レベルのログを出力する。
    - parameter obj: ログメッセージ
    - parameter file: ファイル名
    - parameter function: メソッド名
    - parameter line: 行番号
    */
    class func v(obj: AnyObject?, file: String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
        log(LogLevel.v, obj: obj, file: file, function: function, line: line)
    }
    /**
    デバッグレベルのログを出力する。
    - parameter obj: ログメッセージ
    - parameter file: ファイル名
    - parameter function: メソッド名
    - parameter line: 行番号
    */
    class func d(obj: AnyObject?, file: String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
        log(LogLevel.d, obj: obj, file: file, function: function, line: line)
    }
    /**
    情報レベルのログを出力する。
    - parameter obj: ログメッセージ
    - parameter file: ファイル名
    - parameter function: メソッド名
    - parameter line: 行番号
    */
    class func i(obj: AnyObject?, file: String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
        log(LogLevel.i, obj: obj, file: file, function: function, line: line)
    }
    /**
    警告レベルのログを出力する。
    - parameter obj: ログメッセージ
    - parameter file: ファイル名
    - parameter function: メソッド名
    - parameter line: 行番号
    */
    class func w(obj: AnyObject?, file: String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
        log(LogLevel.w, obj: obj, file: file, function: function, line: line)
    }
    /**
    エラーレベルのログを出力する。
    - parameter obj: ログメッセージ
    - parameter file: ファイル名
    - parameter function: メソッド名
    - parameter line: 行番号
    */
    class func e(obj: AnyObject?, file: String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__) {
        log(LogLevel.e, obj: obj, file: file, function: function, line: line)
    }
    // MARK: - Private
    /**
    ログ出力した時間の文字列を返却する。
    ログクラス単体で切り出せるように、日付ユーティリティではなくログクラスに実装する。
    :return: ログ出力した時間の文字列
    */
    private class func getDateString() -> String {
        let now = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "ja_JP")
        dateFormatter.timeStyle = .MediumStyle
        dateFormatter.dateStyle = .MediumStyle
        let dateString = dateFormatter.stringFromDate(now)
        return dateString
    }
    /**
    フルパスのファイル名からファイル名のみ取り出す。
    拡張子も削除する。
    - parameter file: フルパスのファイル名
    :return: パス名と拡張子が削除されたファイル名
    */
    private class func getFileName(file: String) -> String {
        // パス区切り文字で分割する。
        let files = file.componentsSeparatedByString("/")
        // 分割された文字列で最後の文字列を取り出す。
        let index = files.count - 1
        let fileName = files[index]
        // 拡張子の区切り文字で分割する。
        let fileNames = fileName.componentsSeparatedByString(".")
        // ファイル名のみを取り出す。
        let fileNameBody = fileNames[0]
        return fileNameBody
    }
    /**
    ログ出力する。
    - parameter logLevel: ログレベル
    - parameter obj: ログメッセージ
    - parameter file: ファイル名
    - parameter function: メソッド名
    - parameter line: 行番号
    */
    private class func log(logLevel: LogLevel, obj: AnyObject?, file: String, function: String, line: Int) {
        #if DEBUG
            // デバッグの場合のみ出力する。
            if Level.self <= logLevel.rawValue {
                // 出力許可されたログレベルの場合
                let date = getDateString()
                let fileName = getFileName(file)
                // 出力フォーマット YYYY/MM/DD HH:mm <ファイル名>.<メソッド名>(<行番号>) <メッセージ>
                print("\(date) \(fileName).\(function)(\(line)) \(obj)")
            }
        #endif
    }
}