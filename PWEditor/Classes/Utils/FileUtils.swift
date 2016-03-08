//
//  FileUtils.swift
//  PWhub
//
//  Created by 二俣征嗣 on 2015/08/31.
//  Copyright (c) 2015年 Masatsugu Futamata. All rights reserved.
//

import Foundation

/**
 ファイルユーティリティ

 - Version: 1.0 新規作成
 - Author: paveway.info@gmail.com
*/
class FileUtils: NSObject {

    static let kEncodings = [
        NSNonLossyASCIIStringEncoding,
        NSShiftJISStringEncoding,
        NSJapaneseEUCStringEncoding,
        NSMacOSRomanStringEncoding,
        NSWindowsCP1251StringEncoding,
        NSWindowsCP1252StringEncoding,
        NSWindowsCP1253StringEncoding,
        NSWindowsCP1254StringEncoding,
        NSWindowsCP1250StringEncoding,
        NSISOLatin1StringEncoding,
        NSUnicodeStringEncoding,
        NSUTF8StringEncoding,
    ]

    /**
     ドキュメントパスを取得する。

     - Returns: ドキュメントパス
     */
    class func getDocumentsPath() -> String {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        return documentsPath
    }

    /**
     ディレクトリ/ファイルのローカルパスを取得する。

     - Parameter pathName: パス名付きディレクトリ名、またはパス名付きファイル名
     - Returns: ローカルパス
     */
    class func getLocalPath(pathName: String) -> String {
        let documentsPath = getDocumentsPath()
        let localPath = "\(documentsPath)/\(pathName)"
        return localPath
    }

    /**
     ディレクトリ/ファイルのローカルパスを取得する。

     - Parameter pathName: パス名
     - Parameter name: ディレクトリ名、またはファイル名
     - Returns: ローカルパス
     */
    class func getLocalPath(pathName: String, name: String) -> String {
        let documentsPath = getDocumentsPath()
        let localPath: String
        if pathName.isEmpty {
            localPath = "\(documentsPath)/\(name)"
        } else {
            localPath = "\(documentsPath)/\(pathName)/\(name)"
        }
        return localPath
    }

    /**
     拡張子をチェックする。

     - Parameter path: パス名
     - Parameter extention: 対象の拡張子
     - Returns: チェック結果 true:対象の拡張子 / false:対象の拡張子ではない。
     */
    class func checkExtention(path: String, extention: String) -> Bool {
        // 拡張子を切り出すため"."で分割する。
        let paths = path.componentsSeparatedByString(".")

        // 分割数を取得する。
        let count = paths.count

        // 分割された末尾の文字列を取得する。
        let target = paths[count - 1]
        if target == extention {
            // 取得した文字列が対象の拡張子と同じ場合
            return true

        } else {
            // 取得した文字列が対象の拡張子と異なる場合
            return false
        }
    }


    /**
     ディレクトリ/ファイルが存在するかチェックする。

     - Parameter name: ディレクトリ名、またはファイル名
     - Returns: チェック結果 true:存在する。 / false:存在しない。
     */
    class func isExist(name: String) -> Bool {
        let fileManager = NSFileManager.defaultManager()
        var isDir: ObjCBool = false
        let isFile = fileManager.fileExistsAtPath(name, isDirectory: &isDir)
        if isDir {
            return true
        }
        return isFile
    }

    /**
     ディレクトリかチェックする。

     - Parameter dirName: ディレクトリ名
     - Returns: チェック結果 true:ディレクトリ / false:ディレクトリではない
     */
    class func isDirectory(dirName: String) -> Bool {
        let fileManager = NSFileManager.defaultManager()
        var isDir: ObjCBool = false
        if fileManager.fileExistsAtPath(dirName, isDirectory: &isDir) {
            if isDir {
                return true
            }
        }
        return false
    }

    /**
     ディレクトリ内のファイル情報リストを取得する。

     - Parameter dirName: ディレクトリ名
     - Returns: ファイル情報リスト
     */
    class func getFileInfoListInDir(dirName: String) -> [FileInfo] {
        var fileInfoList: [FileInfo] = []
        let fileManager = NSFileManager.defaultManager()

        let files: [String]
        do {
            files = try fileManager.contentsOfDirectoryAtPath(dirName)
        } catch {
            return fileInfoList
        }

        for file in files {
            let fileInfo = FileInfo()

            let name = file as String
            fileInfo.name = name

            let fullPath = "\(dirName)/\(name)"
            let isDir = isDirectory(fullPath)
            fileInfo.isDir = isDir

            fileInfoList.append(fileInfo)
        }
        
        return fileInfoList
    }

    /**
    ファイルデータを取得する。
    取得できない場合、空文字列を返却する。

    - parameter fileName: ファイル名(拡張子抜き)
    - parameter type: 拡張子
    - Returns: ファイルデータ
    */
    class func getFileData(fileName: String, type: String) -> String {
        var fileData = ""
        if let filePath = NSBundle.mainBundle().pathForResource(fileName, ofType: type){
            fileData = try! String(contentsOfFile: filePath, encoding: NSUTF8StringEncoding)
            if fileData.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) <= 0 {
                fileData = ""
            }
        }
        return fileData
    }

    /**
     ファイルデータを取得する。

     - Parameter filePathName: ファイルパス名
     - Parameter encoding: 文字エンコーディング
     - Returns: 取得結果(true:成功/false:エラー)、ファイルデータ
     */
    class func getFileData(filePathName: String, encoding: UInt) -> (Bool, String) {
        if filePathName.isEmpty {
            return (false, "")
        }

        let fileData: String
        do {
            fileData = try NSString(contentsOfFile: filePathName, encoding: encoding) as String
        } catch {
            return (false, "")
        }

        return (true, fileData)
    }

    class func writeFileData(filePathName: String, fileData: String)  -> Bool {
        if filePathName.isEmpty {
            return false
        }

        do {
            try fileData.writeToFile(filePathName, atomically: true, encoding: NSUTF8StringEncoding)
        } catch {
            return false
        }
        return true
    }

    /**
     ディレクトリ/ファイルを削除する。
     nameにディレクトリ名を指定した場合、サブディレクトリを含め削除する。

     - Parameter name: ディレクトリ名、またはファイル名
     - Returns: 処理結果 true:削除成功、または引数nameが存在しない。 / false:削除失敗
     */
    class func remove(name: String) -> Bool {
        if isExist(name) {
            let fileManager = NSFileManager.defaultManager()
            do {
                try fileManager.removeItemAtPath(name)
            } catch {
                return false
            }
        }

        return true
    }

    /**
     テキストデータか判定する。

     - Parameter data: 元データ
     - Returns: 判定結果 true:テキストデータ / false:非テキストデータ
     */
    class func isTextData(data: NSData) -> Bool {
        // バイナリデータか判定する。
        let count = data.length / sizeof(UInt8)
        var array = [UInt8](count: count, repeatedValue: 0)
        data.getBytes(&array, length:count * sizeof(UInt8))
        var convert = true
        for b in array {
            // デコードデータのバイト数分繰り返す。
            if b <= 0x08 {
                // バイナリデータの場合
                convert = false
                break
            }
        }

        return convert
    }





    
    class func getFileEncoding(filePathName: String) -> NSStringEncoding {
        if filePathName.isEmpty {
            return 0
        }

        let fileManager = NSFileManager.defaultManager()
        let fileData = fileManager.contentsAtPath(filePathName)
        if fileData == nil {
            return 0
        }
        let encoding = detectEncoding(fileData!)
        return encoding
    }

    class func detectEncoding(data: NSData) -> NSStringEncoding {
        var buffer = Array<Int8>(count: data.length, repeatedValue: 0)
        data.getBytes(&buffer, length: data.length)
        for c in buffer {
            if c == 0x1b {
                let str = String(data: data, encoding: NSISO2022JPStringEncoding)
                if str != nil {
                    return NSISO2022JPStringEncoding
                }
            }
        }

        for encoding in kEncodings {
            let str = NSString(data: data, encoding: encoding)
            if str != nil {
                return encoding
            }
        }

        return 0
    }
}
