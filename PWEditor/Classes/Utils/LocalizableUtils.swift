//
//  LocalizeUtils.swift
//  pwhub
//
//  Created by 二俣征嗣 on 2015/11/13.
//  Copyright © 2015年 Masatsugu Futamata. All rights reserved.
//

import Foundation

class LocalizableUtils: NSObject {

    class func getString(key: String) -> String {
        let value = NSLocalizedString(key, comment: "")
        return value
    }

    class func getStringWithArgs(key: String, _ args: CVarArgType...) -> String {
        let format = getString(key)
        let values = getVaList(args)
        let string = NSString(format: format, arguments: values) as String
        return string
    }
}