//
//  ICloudFileInfo.swift
//  PWEditor
//
//  Created by mfuta1971 on 2016/06/04.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import Foundation

class ICloudFileInfo: NSObject {

    enum FileType: Int {
        case Unknown = -1
        case File
        case Dir
    }

    var parent = ""
    var name = ""
    var type = FileType.Unknown.rawValue
    var file: NSMetadataItem!
}
