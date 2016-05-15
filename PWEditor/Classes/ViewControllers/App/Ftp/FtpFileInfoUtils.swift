//
//  FtpFileInfoUtils.swift
//  PWEditor
//
//  Created by mfuta1971 on 2016/05/13.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import Foundation

class FtpFileInfoUtils: NSObject {

    class func getName(ftpFileInfo: NSDictionary) -> String {
        let result = getString(ftpFileInfo, key: kCFFTPResourceName)
        return result
    }

    class func getLink(ftpFileInfo: NSDictionary) -> String {
        let result = getString(ftpFileInfo, key: kCFFTPResourceLink)
        return result
    }

    class func getGroup(ftpFileInfo: NSDictionary) -> String {
        let result = getString(ftpFileInfo, key: kCFFTPResourceGroup)
        return result
    }

    class func getSize(ftpFileInfo: NSDictionary) -> Int {
        let result = getInt(ftpFileInfo, key: kCFFTPResourceSize)
        return result
    }

    class func getOwner(ftpFileInfo: NSDictionary) -> String {
        let result = getString(ftpFileInfo, key: kCFFTPResourceOwner)
        return result
    }

    class func getType(ftpFileInfo: NSDictionary) -> Int {
        let result = getInt(ftpFileInfo, key: kCFFTPResourceType)
        return result
    }

    class func getModDate(ftpFileInfo: NSDictionary) -> String {
        let result = getDate(ftpFileInfo, key: kCFFTPResourceModDate)
        return result
    }

    class func getMode(ftpFileInfo: NSDictionary) -> Int {
        let result = getInt(ftpFileInfo, key: kCFFTPResourceMode)
        return result
    }

    // MARK: - Private

    private class func getString(ftpFileInfo: NSDictionary, key: CFString) -> String {
        let keyString = key as String
        let value = ftpFileInfo.valueForKey(keyString)
        let result: String
        if value == nil {
            result = ""
        } else {
            result = value as! String
        }
        return result
    }

    private class func getInt(ftpFileInfo: NSDictionary, key: CFString) -> Int {
        let keyString = key as String
        let value = ftpFileInfo.valueForKey(keyString)
        let result: Int
        if value == nil {
            result = 0
        } else {
            result = value as! Int
        }
        return result
    }

    private class func getDate(ftpFileInfo: NSDictionary, key: CFString) -> String {
        let keyString = key as String
        let value = ftpFileInfo.valueForKey(keyString)
        let result: String
        if value == nil {
            result = ""
        } else {
            result = DateUtils.getDateString(value as! NSDate)
        }
        return result
    }
}
