//
//  ICloudDocument.swift
//  PWEditor
//
//  Created by 二俣征嗣 on 2016/02/26.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import Foundation

class ICloudDOcument: UIDocument {
    var contents: NSData {
        get {
            return self.contents
        }

        set(newData) {
            let oldData = self.contents
            setContentsData(newData)

            self.undoManager.setActionName("Data Change")
            let selector = #selector(setContentsData)
            self.undoManager.registerUndoWithTarget(self, selector: selector, object: oldData)
        }
    }
    func setContentsData(newData: NSData) {
        self.contents = newData.copy() as! NSData
    }

    /**
     イニシャライザ

     - Parameter pathName: パス名
     */
    override init(fileURL url: NSURL) {
        super.init(fileURL: url)
        contents = NSData()
    }

    override func contentsForType(typeName: String) throws -> AnyObject {
        return contents
    }

    override func loadFromContents(fileContents: AnyObject, ofType typeName: String?) throws {
        if fileContents.length > 0 {
            contents = NSData(data: fileContents as! NSData)
        } else {
            contents = NSData()
        }
    }
}