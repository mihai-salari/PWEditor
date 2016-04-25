//
//  ReserveWordUtils.swift
//  PWEditor
//
//  Created by mfuta1971 on 2016/04/22.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import Foundation

class ReserveWordUtils: NSObject {

    static let kLanguageDic: Dictionary = [
        "java": "Java",
        "swift": "Swift",
        "c": "C",
        "cpp": "CPP"
    ]

    class func getPattern(fileExtension: String) -> String {
        if fileExtension.isEmpty {
            return ""
        }

        let reserveWordList = getReserveWordList(fileExtension)
        let count = reserveWordList.count
        if count == 0 {
            return ""
        }

        var searchWord = ""
        for i in 0 ..< count {
            let reserveWord = reserveWordList[i]
            searchWord = "\(searchWord)(\(reserveWord))"
            if i != count - 1 {
                searchWord = searchWord + "|"
            }
        }

        return searchWord
    }

    class private func getReserveWordList(fileExtension: String) -> [String] {
        var reserveWordList = [String]()

        let fileName = getFileName(fileExtension)
        if fileName.isEmpty {
            return reserveWordList
        }

        let fileData = FileUtils.getFileData(fileName, type: "txt")
        let reserveWords = fileData.componentsSeparatedByString("\n")
        for reserveWord in reserveWords {
            if !reserveWord.isEmpty {
                reserveWordList.append(reserveWord)
            }
        }

        return reserveWordList
    }

    class private func getFileName(language: String) -> String {
        var fileName = ""
        for (key, value) in kLanguageDic {
            if key == language {
                fileName = value
                break
            }
        }
        return fileName
    }
}