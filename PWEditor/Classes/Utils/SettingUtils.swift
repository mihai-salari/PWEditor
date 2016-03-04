//
//  SettingUtils.swift
//  PWhub
//
//  Created by Masatsugu Futamata on 2015/06/27.
//  Copyright (c) 2015年 Paveway. All rights reserved.
//

import Foundation

/**
設定ユーティリティ

- Version: 1.0 新規作成
- Author: paveway.info@gmail.com
*/
class SettingUtils: NSObject {

    /**
    フォントサイズを取得する。

    - Parameter name: キー名
    - Returns: フォントサイズ
    */
    class func getFontSize(key: String) -> CGFloat {
        var fontSize: CGFloat = 0.0
        if !key.isEmpty {
            // キー名が指定されている場合
            let ud = NSUserDefaults.standardUserDefaults()
            let value = ud.objectForKey(key)
            if value != nil {
                let floatValue = value as! CGFloat
                fontSize = floatValue
            }
        }
        return fontSize
    }

    /**
    フォントサイズを設定する。

    - Parameter key: キー名
　  - Parameter fontSize: フォントサイズ
    */
    class func setFontSize(key: String, fontSize: CGFloat) {
        if !key.isEmpty && fontSize > 0 {
            // キー名が指定されているかつフォントサイズが0より大きい場合
            let ud = NSUserDefaults.standardUserDefaults()
            ud.setFloat(Float(fontSize), forKey: key)
        }
    }
}
