//
//  StringUtils.swift
//  PWhub
//
//  Created by 二俣征嗣 on 2015/09/11.
//  Copyright (c) 2015年 Masatsugu Futamata. All rights reserved.
//

import Foundation

class StringUtils: NSObject {
    
    class func escapeUrlString(urlString: String) -> String? {
        let escapeUrlString = urlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        //let escapeUrlString = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.alphanumericCharacterSet())
        return escapeUrlString

        //var allowedCharacterSet = NSMutableCharacterSet.alphanumericCharacterSet()
        //allowedCharacterSet.addCharactersInString("-._~")
        //return urlString.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacterSet)!
    }

    /**
     数値をカンマ区切り文字列に変換する。

     - Parameter num: 数値
     - Returns: カンマ区切りされた数字文字列
     */
    class func numberWithComma(num: Int) -> String {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3

        let result = formatter.stringFromNumber(num)
        return result!
    }

    static let encodingList = [
        NSNonLossyASCIIStringEncoding,
        NSShiftJISStringEncoding,
        NSJapaneseEUCStringEncoding,
        NSMacOSRomanStringEncoding,
        NSWindowsCP1251StringEncoding,
        NSWindowsCP1252StringEncoding,
        NSWindowsCP1253StringEncoding,
        NSWindowsCP1254StringEncoding,
        NSWindowsCP1250StringEncoding,
        NSISOLatin1StringEncoding,
        NSUnicodeStringEncoding,
        NSISO2022JPStringEncoding,
        NSUTF8StringEncoding,
        0
    ]

    class func getCharEncoding(dataString: String) -> NSStringEncoding {
        for encoding in encodingList {
            let result = dataString.canBeConvertedToEncoding(encoding)
            if result {
//                return encoding
            }
        }

        return 0
    }

    /**
     改行コードタイプを返却する。

     - Parameter dataString: データ文字列
     - Parameter encodig: 文字エンコーディング
     - Returns: 改行コードタイプ
     */
    class func getRetCodeType(dataString: String, encoding: UInt) -> Int {
        let data = dataString.dataUsingEncoding(encoding)
        let count = data!.length
        var buffer = Array<Int8>(count: count, repeatedValue: 0)
        data!.getBytes(&buffer, length: count)
        var crFlag = false
        var lfFlag = false
        for var i = 0; i < count; i++ {
            if buffer[i] == 13 {
                // CRの場合
                crFlag = true
                let j = i + 1
                if j < count {
                    if buffer[j] == 10 {
                        // LFの場合
                        lfFlag = true
                        break
                    }
                }
                break

            } else if buffer[i] == 10 {
                // LFの場合
                lfFlag = true
                break
            }
        }
        let retCodeType: Int
        if crFlag {
            if lfFlag {
                retCodeType = CommonConst.RetCodeType.CRLF.rawValue
            } else {
                retCodeType = CommonConst.RetCodeType.CR.rawValue
            }
        } else {
            retCodeType = CommonConst.RetCodeType.LF.rawValue
        }
        return retCodeType
    }
}