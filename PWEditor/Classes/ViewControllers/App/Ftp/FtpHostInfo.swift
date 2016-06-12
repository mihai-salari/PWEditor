//
//  FtpHostInfo.swift
//  PWEditor
//
//  Created by mfuta1971 on 2016/05/12.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import Foundation

class FtpHostInfo: RLMObject {

    dynamic var displayName = ""

    dynamic var hostName = ""

    dynamic var portNo = 0

    dynamic var userName: String? = nil

    dynamic var password: String? = nil

    override class func primaryKey() -> String {
        return "displayName"
    }
}
