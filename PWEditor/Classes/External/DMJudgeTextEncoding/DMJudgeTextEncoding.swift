//
//  DMJudgeTextEncoding.swift
//
//  Created by Takeshi Yamane on 2016/02/01.
//  DOBON!さん（http://dobon.net/index.html）がC#へ移植されたものをSwiftへ移植したものです。
//  Jcode.pmのgetcodeメソッドを移植したものです。
//  Jcode.pm(http://openlab.ring.gr.jp/Jcode/index-j.html)
//  Jcode.pmのCopyright: Copyright 1999-2005 Dan Kogai
//

import Foundation

// Constants
private let bEscape: UInt8 = 0x1B
private let bAt: UInt8 = 0x40
private let bDollar: UInt8 = 0x24
private let bAnd: UInt8 = 0x26
private let bOpen: UInt8 = 0x28	//'('
private let bB: UInt8 = 0x42
private let bD: UInt8 = 0x44
private let bJ: UInt8 = 0x4A
private let bI: UInt8 = 0x49

// Unknown encoding
let UNKNOWN_ENCODING = NSStringEncoding.max

//
// Judge text encoding
//
func DMJudgeTextEncodingOfData(rawData: NSData) -> NSStringEncoding {
    var b1: UInt8
    var b2: UInt8
    var b3: UInt8
    var b4: UInt8

    // NSDataからバイト配列へ
    var bytes = [UInt8](count: rawData.length, repeatedValue: 0)
    rawData.getBytes(&bytes, length: rawData.length)

    let len: Int = rawData.length

    var isBinary: Bool = false
    for i in 0..<len {
        b1 = bytes[i]
        if b1 <= 0x06 || b1 == 0x7F || b1 == 0xFF {
            // 'binary'
            isBinary = true
            if b1 == 0x00 && i < len - 1 && bytes[i + 1] <= 0x7F {
                // smells like raw unicode
                return NSUnicodeStringEncoding
            }
        }
    }
    if isBinary {
        return UNKNOWN_ENCODING
    }

    // not Japanese
    var notJapanese: Bool = true
    for i in 0..<len {
        b1 = bytes[i]
        if b1 == bEscape || 0x80 <= b1 {
            notJapanese = false
            break
        }
    }
    if notJapanese {
        return NSASCIIStringEncoding
    }

    for i in 0..<len - 2 {
        b1 = bytes[i]
        b2 = bytes[i + 1]
        b3 = bytes[i + 2]

        if b1 == bEscape {
            if b2 == bDollar && b3 == bAt {
                // JIS_0208 1978
                // JIS
                return NSISO2022JPStringEncoding
            } else if b2 == bDollar && b3 == bB {
                // JIS_0208 1983
                // JIS
                return NSISO2022JPStringEncoding

            } else if b2 == bOpen && (b3 == bB || b3 == bJ) {
                // JIS_ASC
                // JIS
                return NSISO2022JPStringEncoding
            } else if b2 == bOpen && b3 == bI {
                // JIS_KANA
                // JIS
                return NSISO2022JPStringEncoding
            }
            if i < len - 3 {
                b4 = bytes[i + 3]
                if b2 == bDollar && b3 == bOpen && b4 == bD {
                    // JIS_0212
                    // JIS
                    return NSISO2022JPStringEncoding
                }
                if i < len - 5 && b2 == bAnd && b3 == bAt && b4 == bEscape && bytes[i + 4] == bDollar && bytes[i + 5] == bB {
                    // JIS_0208 1990
                    // JIS
                    return NSISO2022JPStringEncoding
                }
            }
        }
    }

    // should be euc|sjis|utf8
    // use of (?:) by Hiroki Ohzaki <ohzaki@iod.ricoh.co.jp>
    var sjis: Int = 0
    var euc: Int = 0
    var utf8: Int = 0
    for var i = 0; i < len - 1; i++ {
        b1 = bytes[i]
        b2 = bytes[i + 1]
        if ((0x81 <= b1 && b1 <= 0x9F) || (0xE0 <= b1 && b1 <= 0xFC)) && ((0x40 <= b2 && b2 <= 0x7E) || (0x80 <= b2 && b2 <= 0xFC)) {
            // SJIS_C
            sjis += 2
            i++
        }
    }
    for var i = 0; i < len - 1; i++ {
        b1 = bytes[i]
        b2 = bytes[i + 1]
        if ((0xA1 <= b1 && b1 <= 0xFE) && (0xA1 <= b2 && b2 <= 0xFE)) || (b1 == 0x8E && (0xA1 <= b2 && b2 <= 0xDF)) {
            // EUC_C
            // EUC_KANA
            euc += 2
            i++
        } else if i < len - 2 {
            b3 = bytes[i + 2]
            if b1 == 0x8F && (0xA1 <= b2 && b2 <= 0xFE) && (0xA1 <= b3 && b3 <= 0xFE) {
                // EUC_0212
                euc += 3
                i += 2
            }
        }
    }
    for var i = 0; i < len - 1; i++ {
        b1 = bytes[i]
        b2 = bytes[i + 1]
        if (0xC0 <= b1 && b1 <= 0xDF) && (0x80 <= b2 && b2 <= 0xBF) {
            // UTF8
            utf8 += 2
            i++
        } else if i < len - 2 {
            b3 = bytes[i + 2]
            if (0xE0 <= b1 && b1 <= 0xEF) && (0x80 <= b2 && b2 <= 0xBF) && (0x80 <= b3 && b3 <= 0xBF) {
                // UTF8
                utf8 += 3
                i += 2
            }
        }
    }

    // M. Takahashi's suggestion
    // utf8 += utf8 / 2

    NSLog("sjis = %ld, euc = %ld, utf8 = %ld", sjis, euc, utf8)

    if euc > sjis && euc > utf8 {
        // EUC
        return NSJapaneseEUCStringEncoding
    } else if sjis > euc && sjis > utf8 {
        // SJIS
        return NSShiftJISStringEncoding
    } else if utf8 > euc && utf8 > sjis {
        // UTF-8
        return NSUTF8StringEncoding
    }

    return UNKNOWN_ENCODING
}

//
// Encode type list
//
private let encodeTypeList: [NSStringEncoding: String] = [
    NSASCIIStringEncoding: "NSASCIIStringEncoding",
    NSNEXTSTEPStringEncoding: "NSNEXTSTEPStringEncoding",
    NSJapaneseEUCStringEncoding: "NSJapaneseEUCStringEncoding",
    NSUTF8StringEncoding: "NSUTF8StringEncoding",
    NSISOLatin1StringEncoding: "NSISOLatin1StringEncoding",
    NSSymbolStringEncoding: "NSSymbolStringEncoding",
    NSNonLossyASCIIStringEncoding: "NSNonLossyASCIIStringEncoding",
    NSShiftJISStringEncoding: "NSShiftJISStringEncoding",
    NSISOLatin2StringEncoding: "NSISOLatin2StringEncoding",
    NSUnicodeStringEncoding: "NSUnicodeStringEncoding",
    NSWindowsCP1251StringEncoding: "NSWindowsCP1251StringEncoding",
    NSWindowsCP1252StringEncoding: "NSWindowsCP1252StringEncoding",
    NSWindowsCP1253StringEncoding: "NSWindowsCP1253StringEncoding",
    NSWindowsCP1254StringEncoding: "NSWindowsCP1254StringEncoding",
    NSWindowsCP1250StringEncoding: "NSWindowsCP1250StringEncoding",
    NSISO2022JPStringEncoding: "NSISO2022JPStringEncoding",
    NSMacOSRomanStringEncoding: "NSMacOSRomanStringEncoding",
    //NSUTF16StringEncoding: "NSUTF16StringEncoding",	// Duplicate
    NSUTF16BigEndianStringEncoding: "NSUTF16BigEndianStringEncoding",
    NSUTF16LittleEndianStringEncoding: "NSUTF16LittleEndianStringEncoding",
    NSUTF32StringEncoding: "NSUTF32StringEncoding",
    NSUTF32BigEndianStringEncoding: "NSUTF32BigEndianStringEncoding",
    NSUTF32LittleEndianStringEncoding: "NSUTF32LittleEndianStringEncoding",
    NSProprietaryStringEncoding: "NSProprietaryStringEncoding"
]

func DMGetNameOfEncoding(encoding: NSStringEncoding) -> String {
    if let encName = encodeTypeList[encoding] {
        return encName
    } else {
        return "Unknown encoding"
    }
}
