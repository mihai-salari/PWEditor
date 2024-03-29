//
//  CommonConst.swift
//  PWEditor
//
//  Created by 二俣征嗣 on 2016/02/19.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import Foundation
import UIKit

struct CommonConst {

    struct ConfigKey {
        static let kAdmobAdUnitId = "admobAdUnitId"
        static let kAdmobTestDeviceId = "admobTestDeviceId"
        static let kDropBoxAppKey = "dropboxAppKey"
        static let kDropBoxAppSecret = "dropboxAppSecret"
        static let kGoogleDriveClientId = "googleDriveClientId"
        static let kOneDriveClientId = "oneDriveClientId"
        static let kBoxClientId = "boxClientId"
        static let kBoxSecret = "boxSecret"
    }

    struct SlidingViewSetting {
        static let kShadowOpacity: Float = 0.75
        static let kShadowRadius: CGFloat = 5.0
        static let kRightRevealAmount: CGFloat = 250.0
    }

    /**
     フォントファミリー名情報
     */
    struct FontFamilyName {
        static let KCourierNew = "CourierNew"
        static let kArial = "Arial"
        static let kSourceHanCodeJp = "SourceHanCodeJP"
    }
    /**
     フォントファミリー名インデックス
     */
    struct FontFamilyNameIndex {
        static let kCourierNew = 0
        static let kArial = 1
        static let kSourceHanCodeJp = 2
    }
    /// フォントファミリー名リスト
    static let FontFamilyNameList = [FontFamilyName.KCourierNew, FontFamilyName.kArial, FontFamilyName.kSourceHanCodeJp]

    /**
     フォント名情報
     */
    struct FontName {
        /// CourierNew(Normal)
        static let kCourierNew = "CourierNewPSMT"

        /// CourierNew(Italic)
        static let kCourierNewItalic = "CourierNewPS-ItalicMT"

        /// CourierNew(Bold)
        static let kCourierNewBold = "CourierNewPS-BoldMT"

        /// CourierNew(Bold Italic)
        static let kCourierNewBoldItalic = "CourierNewPS-BoldItalicMT"

        /// Arial(Normal)
        static let kArial = "ArialMT"

        /// Arial(Italic)
        static let kArialItalic = "Arial-ItalicMT"

        /// Arial(Bold)
        static let kArialBold = "Arial-BoldMT"

        /// Arial(Bold Italic)
        static let kArialBoldItalic = "Arial-BoldItalicMT"

        /// Source Han Code JP(Normal)
        static let kSourceHanCodeJpNormal = "SourceHanCodeJP-Normal"

        /// Source Han Code JP(Normal Italic)
        static let kSourceHanCodeJpNormalItalic = "SourceHanCodeJP-NormalIt"

        /// Source Han Code JP(Bold)
        static let kSourceHanCodeJpBold = "SourceHanCodeJP-Bold"

        /// Source Han Code JP(Bold Italic)
        static let kSourceHanCodeJpBoldItalic = "SourceHanCodeJP-BoldIt"
    }
    struct FontNameIndex {
        static let kCourierNew = 0
        static let kArial = 1
        static let kSourceHanCodeJpNormal = 2
    }
    static let FontNameList = [FontName.kCourierNew, FontName.kArial, FontName.kSourceHanCodeJpNormal]

    /**
     フォントサイズ
     */
    struct FontSize {
        /// デフォルト
        static let kDefault: CGFloat = UIFont.systemFontSize()

        /// 入力用
        static let kEnterData: CGFloat = 12.0
    }

    enum EncodingType: Int {
        case Undefine = -1
        case Utf8 = 0
        case ShiftJis = 1
        case Euc = 2
    }

    static let EncodingNameList = [
        "UTF-8",
        "Shift_JIS",
        "EUC"
    ]

    static let EncodingList = [
        NSUTF8StringEncoding,
        NSShiftJISStringEncoding,
        NSJapaneseEUCStringEncoding
    ]

    enum RetCodeType: Int {
        case LF = 0
        case CRLF = 1
        case CR = 2
    }

    static let RetCodeNameList = [
        "UNIX(LF)",
        "Windows(CR/LF)",
        "Mac(CR)"
    ]

    struct Http {
        struct Method {
            static let kGET = "GET"
            static let kPOST = "POST"
            static let kPUT = "PUT"
            static let kDELETE = "DELETE"
        }

        struct HTTPHeaderField {
            struct Key {
                static let kContentType = "Content-Type"
                static let kAuthorization = "Authorization"
                static let kPrefer = "Prefer"
            }

            struct Value {
                static let kApplicationJson = "application/json"
                static let kTextPlain = "text/plain"
                static let kBearer = "Bearer %@"
                static let kRespondAsync = "respond-async"
            }
        }
    }

    struct GoogleDrive {
        static let kKeychainItemName = "GoogleDrive"
        static let kRootParentId = "root"

        /// スコープリスト
        static let kScopeList = [kGTLAuthScopeDrive, kGTLAuthScopeDriveFile]
    }

    struct MimeType {
        static let kText = "text/plain"
        static let kFolder = "application/vnd.google-apps.folder"
    }

    struct OneDrive {
        static let kScopes = [
            "wl.signin",
            "wl.offline_access",
            "onedrive.readwrite"
        ]
    }

    struct FileExtention {
        static let kHTML = "html"
        static let kHTM = "htm"
        static let kMarkdown = "md"
        static let kPdf = "pdf"
    }

    enum PreviewFileType: Int {
        case HTML
        case Markdown
        case Other
    }

    /// 操作タイプ
    enum OperateType: Int {
        case Copy
        case Move
    }
}
