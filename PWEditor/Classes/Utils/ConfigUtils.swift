//
//  ConfigUtils.swift
//  pwhub
//
//  Created by 二俣征嗣 on 2015/11/10.
//  Copyright © 2015年 Masatsugu Futamata. All rights reserved.
//

import Foundation

class ConfigUtils: NSObject {

    class func getConfigValue(key: String) -> String! {
        let fileData = FileUtils.getFileData("Config", type: "txt")
        let fileDatas = fileData.componentsSeparatedByString("\n")
        for line in fileDatas {
            let lines = line.componentsSeparatedByString("=")
            if key == lines[0] {
                return lines[1]
            }
        }
        return ""
    }

    class func getConfigValues(key: String) -> [String]! {
        let value = getConfigValue(key)
        if value.isEmpty {
            return [] as [String]
        } else {
            return value.componentsSeparatedByString(",")
        }
    }
}