//
//  DateUtils.swift
//  PWhub
//
//  Created by Masatsugu Futamata on 2015/06/27.
//  Copyright (c) 2015年 Paveway. All rights reserved.
//

import Foundation

/**
 日付ユーティリティ

 - Version: 1.0 新規作成
 - Author: paveway.info@gmail.com
 */
class DateUtils: NSObject {

    /**
     日付フォーマットを変換する。

     - Parameter src: 変換前日付文字列
     - Returns: 変換された日付文字列
     */
    class func changeDateFormat(src: String) -> String {
        var dst = src.stringByReplacingOccurrencesOfString("T", withString: " ", options: [], range: nil)
        dst = dst.stringByReplacingOccurrencesOfString("Z", withString: "", options: [], range: nil)
        dst = dst.stringByReplacingOccurrencesOfString("-", withString: "/", options: [], range: nil)
        return dst
    }

    /**
     文字列からNSDateオブジェクトを生成し、返却する。
     文字列は"yyyy/MM/dd"のフォーマットであること。

     - Parameter dateString: yyyy/MM/ddフォーマットの文字列
     - Returns: NSDateオブジェクト
     */
    class func dateFromDateString(dateString: String) -> NSDate {
        if dateString.isEmpty {
            return NSDate()
        }

        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "ja_JP")
        dateFormatter.dateFormat = "yyyy/MM/dd"

        let date = dateFormatter.dateFromString(dateString)!
        return date
    }

    /**
     時間文字列からDateオブジェクトを生成する。

     - Parameter timeString: 時間文字列
     - Returns: Dateオブジェクト
     */
    class func dateFromTimeString(timeString: String) -> NSDate {
        if timeString.isEmpty {
            return NSDate()
        }

        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "ja_JP")
        dateFormatter.dateFormat = "HH:mm"

        let date = dateFormatter.dateFromString(timeString)!
        return date
    }

    /**
     日時フォーマットから日時文字列を返却する。

     - Parameter date: Dateオブジェクト
     - Parameter dateFormat: 日時フォーマット文字列(デフォルトyyyy/MM/dd HH:mm:ss)
     - Returns: 日時文字列
     */
    class func getDateString(date: NSDate, dateFormat: String = "yyyy/MM/dd HH:mm:ss") -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "ja_JP")
        dateFormatter.dateFormat = dateFormat
        let dateString = dateFormatter.stringFromDate(date)
        return dateString
    }
}
