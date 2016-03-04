//
//  DropboxFileInfo.swift
//  PWEditor
//
//  Created by 二俣征嗣 on 2016/03/01.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import Foundation

class DropboxFileInfo: NSObject {
    var id = ""
    var name = ""
    var pathLower = "" //
    var size = ""
    var rev = ""
    var serverModified: NSDate! //
    var clientModified: NSDate! //
    var isDir = false
}