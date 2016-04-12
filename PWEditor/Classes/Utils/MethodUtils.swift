//
//  MethodUtils.swift
//  pwhub
//
//  Created by mfuta1971 on 2016/03/25.
//  Copyright © 2016年 Paveway.info. All rights reserved.
//

import Foundation

class MethodUtils: NSObject {

    /**
     UITextViewのメソッドを変更する。
     */
    class func changeTextViewMethod() {
        let kClass = UITextView.self
        let replaceRangeMethod = class_getInstanceMethod(kClass, #selector(UITextView.replaceRange(_:withText:)))
        let hookReplaceRangeMethod = class_getInstanceMethod(kClass, #selector(UITextView.hookReplaceRange(_:withText:)))
        method_exchangeImplementations(replaceRangeMethod, hookReplaceRangeMethod)

        let setMarkedTextMethod = class_getInstanceMethod(kClass, #selector(UITextView.setMarkedText(_:selectedRange:)))
        let hookSetMarkedTextMethod = class_getInstanceMethod(kClass, #selector(UITextView.hookSetMarkedText(_:selectedRange:)))
        method_exchangeImplementations(setMarkedTextMethod, hookSetMarkedTextMethod)

        let insertTextMethod = class_getInstanceMethod(kClass, #selector(UITextView.insertText(_:)))
        let hookInsertTextMethod = class_getInstanceMethod(kClass, #selector(UITextView.hookInsertText(_:)))
        method_exchangeImplementations(insertTextMethod, hookInsertTextMethod)

        let deleteBackwardMethod = class_getInstanceMethod(kClass, #selector(UITextView.deleteBackward))
        let hookDeleteBackwardMethod = class_getInstanceMethod(kClass, #selector(UITextView.hookDeleteBackward))
        method_exchangeImplementations(deleteBackwardMethod, hookDeleteBackwardMethod)
    }
}