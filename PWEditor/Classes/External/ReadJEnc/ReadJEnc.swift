//
//  ReadJEnc.swift
//  PWEditor
//
//  Created by 二俣征嗣 on 2016/03/07.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import Foundation

class ReadJEnc: NSObject {

    static let JP = SJis()

    func getEncoding(bytes: [UInt8], len: Int) -> (CharCode, String) {
        let charCode = CharCode(name: "", encoding: NSUTF8StringEncoding, bytes: [0x00])
        let str = String()
        return (charCode, str)
    }

    func getEncoding(bytes: [UInt8], pos: Int, len: Int) -> Int {
        return 0
    }

    class func seemsUTF16N(bytes: [UInt8], len: Int) -> CharCode {
        let charCode = CharCode(name: "", encoding: NSUTF8StringEncoding, bytes: [0x00])
        return charCode
    }

    static let DEL = 0x7F

    static let BINARY = 0x03

    var charCode: CharCode
    var euc: CharCode
    var euctw = false

    init(charCode: CharCode, euc: CharCode) {
        self.charCode = charCode
        self.euc = euc
    }

    func toString() -> String {
        return charCode.name
    }

    class Jis: NSObject {

        func hasSOSI(bytes: [UInt8], len: Int) -> Bool {
            return false
        }

        var bytes: [UInt8]
        var len: Int
        var jish = false
        var isokr = false
        var c = 0

        init(bytes: [UInt8], len: Int, pos: Int) {
            self.bytes = bytes
            self.len = len
            self.isokr = pos >= 0 && pos < len - 4 && String(bytes[pos + 1]) == "$" && String(bytes[pos + 2]) == ")" && String(bytes[pos + 3]) == "C";
        }

        func getEncoding(pos: Int) -> Int {
            return 0
        }

        func getEncoding() -> (CharCode, String) {
            let charCode = CharCode(name: "", encoding: NSUTF8StringEncoding, bytes: [0x00])
            let str = String()
            return (charCode, str)
        }

//        func getEncoding(pos: Int) -> Int {
//            if pos + 2 < len {
//                c++;
//                switch bytes[pos + 1] {
//                case 0x24:
//                    switch bytes[pos + 2] {
//                    case 0x40:
//                        return 2
//
//                    case 0x42:
//                        return 2
//
//                    case 0x28:
//                        if pos + 3 < len && bytes[pos + 3] == 0x44 {
//                            jish = true
//                            return 3
//                        }
//                        break
//
//                    default:
//                        break
//                    }
//                    break
//
//                case 0x28:
//                    // ESC(
//                    switch bytes[pos + 2] {
//                    case 0x42:
//                        return 2
//                    case 0x48:
//                        return 2
//                    case 0x49:
//                        return 2
//                    case 0x4A:
//                        return 2
//                    default:
//                        break
//                    }
//
//                default:
//                    break
//                }
//            }
//            c -= 4
//            return 0
//        }
//
//        func getEncoding() -> (CharCode, String) {
//            let bytes = self.bytes
//            let len = self.len
//        }
    }

    class SJis: ReadJEnc {
        init() {
            super.init(charCode: CharCode.SJIS, euc: CharCode.EUC)
        }
    }
}