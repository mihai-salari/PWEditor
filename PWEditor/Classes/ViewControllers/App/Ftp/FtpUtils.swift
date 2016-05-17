//
//  FtpUtils.swift
//  PWEditor
//
//  Created by mfuta1971 on 2016/05/18.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import Foundation

class FtpUtils: NSObject {

    class func getPath(pathName: String, name: String) -> String {
        let path: String
        if pathName == "/" {
            path = "/\(name)"
        } else {
            path = "\(pathName)/\(name)"
        }

        return path
    }

    class func getDirPath(pathName: String, name: String) -> String {
        let path = getPath(pathName, name: name)
        let dirPath = "\(path)/"
        return dirPath
    }
}