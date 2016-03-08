//
//  CharCode.swift
//  PWEditor
//
//  Created by 二俣征嗣 on 2016/03/07.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import Foundation

class CharCode: NSObject {

    static let UTF8 = Text(name: "UTF-8", encoding: NSUTF8StringEncoding)
    static let EUC = Text(name: "EUCJP", encoding: NSJapaneseEUCStringEncoding)
    static let SJIS = Text(name: "SJIS", encoding: NSShiftJISStringEncoding)

    class func getPreamble(bytes: [UInt8], read: Int) -> CharCode {
        return CharCode(name: "", encoding: NSUTF8StringEncoding, bytes: [0])
    }

    var name: String
    var bytes: [UInt8]?
    var encoding: UInt?
    var enc: Int = 0

    init(name: String, enc: Int, bytes: [UInt8]) {
        self.name = name
        self.enc = enc
        self.bytes = bytes
    }

    init(name: String, encoding: UInt, bytes: [UInt8]) {
        self.name = name
        self.encoding = encoding
        self.bytes = bytes
    }

    func getEncoding() -> UInt? {
        if encoding == nil {
            encoding = enc > 0 ? 0 : enc < 0 ? 0 : nil
        }
        return encoding
    }

    func getString(bytes: [UInt8], len: Int) -> String? {
        let enc = getEncoding()
        if enc == nil {
            return nil
        }
        return nil
    }

    func toString() -> String {
        return name
    }

    static func getPreamble(bytes: [UInt8], rd: Int, params: [CharCode]) -> CharCode {
        for charCode in params {

        }
        return CharCode(name: "", encoding: NSUTF8StringEncoding, bytes: [0])
    }
}

class Text: CharCode {

    init(name: String, encoding: UInt) {
        super.init(name: name, encoding: encoding, bytes: [0])
    }

    init(name: String, enc: Int) {
        super.init(name: name, enc: enc, bytes: [])
    }
}

/**
 JIS補助漢字対応デコーダ
 */
class Euch: Text {
    /**
     イニシャライザ

     - Parameter name: 文字コード名
     */
    init(name: String) {
        super.init(name: name, enc: 20932)
    }

    /**
     イニシャライザ

     - Parameter bytes: 先頭バイト識別データ
     - Parameter len: 長さ
     */
    override func getString(bytes: [UInt8], len: Int) -> String {
        var bytesForCP20932 = [UInt8]()
        var cp20932Len = 0
        var shiftPos = Int.min
        var b: UInt8
        for var i = 0; i < len; i++ {
            b = bytes[i]
            let start: UInt8 = 0x8F
            if b == start {
                shiftPos = i + 2
            } else {
                bytesForCP20932[cp20932Len] = i == shiftPos ? b & 0x7F : b
                cp20932Len++
            }
        }
        return ""
    }
}
