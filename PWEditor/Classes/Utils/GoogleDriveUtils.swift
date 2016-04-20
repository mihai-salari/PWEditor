//
//  GoogleDriveUtils.swift
//  PWEditor
//
//  Created by mfuta1971 on 2016/04/21.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import Foundation

class GoogleDriveUtils: NSObject {

    /**
     ディレクトリか判定する。

     - Parameter file: ファイルオブジェクト
     - Returns: true:ディレクトリ / false:ファイル
     */
    class func isDir(file: GTLDriveFile) -> Bool {
        let mimeType = file.mimeType
        let mimeTypes = mimeType.componentsSeparatedByString(".")
        let lastIndex = mimeTypes.count - 1
        let type = mimeTypes[lastIndex]

        let result: Bool
        if type == "folder" {
            result = true
        } else {
            result = false
        }
        return result
    }
}