//
//  UITextViewExtention.swift
//  pwhub
//
//  Created by 二俣征嗣 on 2016/03/25.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import Foundation

extension UITextView {

    func hookReplaceRange(range: UITextRange, withText: NSString) {
        undoManager!.beginUndoGrouping()
        hookReplaceRange(range, withText: withText)
        undoManager!.endUndoGrouping()
    }

    func hookSetMarkedText(text: NSString, selectedRange: NSRange) {
        undoManager!.beginUndoGrouping()
        hookSetMarkedText(text, selectedRange: selectedRange)
        undoManager!.endUndoGrouping()
    }

    func hookInsertText(text: NSString) {
        undoManager!.beginUndoGrouping()
        hookInsertText(text)
        undoManager!.endUndoGrouping()
    }

    func hookDeleteBackward() {
        undoManager!.beginUndoGrouping()
        hookDeleteBackward()
        undoManager!.endUndoGrouping()
    }
}
