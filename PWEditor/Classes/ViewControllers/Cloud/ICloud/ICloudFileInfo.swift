//
//  ICloudFileInfo.swift
//  PWEditor
//
//  Created by mfuta1971 on 2016/06/04.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import Foundation

/**
 iCloudファイル情報クラス

 - Version: 1.0 新規作成
 - Author: paveway.info@gmail.com
 */
class ICloudFileInfo: NSObject {

    /// ファイルタイプ
    enum FileType: Int {
        case Unknown = -1
        case File
        case Dir
    }

    var name = ""
    var type = FileType.Unknown.rawValue
    var file: NSMetadataItem!
}
