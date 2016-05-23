//
//  BaseEditViewController.swift
//  PWEditor
//
//  Created by mfuta1971 on 2016/05/23.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import UIKit

/**
 基底編集画面クラス

 - Version: 1.0 新規作成
 - Author: paveway.info@gmail.com
 */
class BaseEditViewController: BaseViewController, UITextViewDelegate {

    // MARK: - Constants

    /// シンタックスハイライト
    struct SyntaxHighigth {
        static let nameKey = "name"
        static let foregroundColorKey = "foregroundColor"
        static let fontKey = "font"
        static let expressionKey = "expression"

        struct Font {
            static let defaultName = "default"
            static let italicName = "italic"
            static let boldName = "bold"
            static let boldItalicName = "boldItalic"
        }
    }

    // MARK: - Variables

    /// テキストビュー
    var textView: CYRTextView!

    /// プレオフセット
    var preOffset: CGPoint?

    // MARK: - UIViewController

    /**
     画面が表示される前に呼び出される。

     - Parameter animated: アニメーション指定
     */
    override func viewWillAppear(animated: Bool) {
        // スーパークラスのメソッドを呼び出す。
        super.viewWillAppear(animated)

        preOffset = textView.contentOffset
    }

    /**
     画面が閉じた後に呼び出される。
     */
    override func viewDidDisappear(animated: Bool) {
        // 通知設定をクリアする。
        clearNotification()

        // スーパークラスのメソッドを呼び出す。
        super.viewDidDisappear(animated)
    }

    // MARK: - Common method

    /**
     テキストビューを生成する。
 
     - Parameter editView: 編集ビュー
     - Parameter fileName: ファイル名
     - Parameter heightOffset: 高さオフセット
     */
    func createTextView(editView: UIView, fileName: String, heightOffset: CGFloat) {
        var tokens = [CYRToken]()

        // 共通のシンタックスハイライトトークンを取得する。
        setSyntaxHighlightTokens("Syntax_common", tokens: &tokens)

        // ファイル拡張子により使用するシンタックスハイライトトークンを選択する。
        let fileExtention = FileUtils.getFileExtention(fileName)
        if fileExtention == "htm" ||
            fileExtention == "html" {
            // HTMLの場合
            setSyntaxHighlightTokens("Syntax_html", tokens: &tokens)
            setSyntaxHighlightTokens("Syntax_css", tokens: &tokens)
            setSyntaxHighlightTokens("Syntax_javascript", tokens: &tokens)

        } else if fileExtention == "css" {
            // CSSの場合
            setSyntaxHighlightTokens("Syntax_css", tokens: &tokens)

        } else if fileExtention == "js" {
            // JavaScriptの場合
            setSyntaxHighlightTokens("Syntax_javascript", tokens: &tokens)

        } else if fileExtention == "xml" {
            // XMLの場合

        } else if fileExtention == "c" ||
            fileExtention == "h" {
            // C言語の場合
            setSyntaxHighlightTokens("Syntax_c", tokens: &tokens)

        } else if fileExtention == "cc" ||
            fileExtention == "cp" ||
            fileExtention == "cpp" ||
            fileExtention == "c++" {
            // C++言語の場合
            setSyntaxHighlightTokens("Syntax_cpp", tokens: &tokens)

        } else if fileExtention == "java" {
            // Java言語の場合
            setSyntaxHighlightTokens("Syntax_java", tokens: &tokens)

        } else if fileExtention == "swift" {
            // Swift言語の場合
            setSyntaxHighlightTokens("Syntax_swift", tokens: &tokens)
        }

        let frame = CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height - heightOffset)
        textView = CYRTextView(frame: frame)
        textView.delegate = self
        textView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        if tokens.count > 0 {
            textView.tokens = tokens
        }
        editView.addSubview(textView)

        // フォントを設定する。
        let fontName = EnvUtils.getEnterDataFontName()
        let fontSize = EnvUtils.getEnterDataFontSize()
        textView.font = UIFont(name: fontName, size: fontSize)

        // 拡張キーボードを生成する。
        listNumber = 0
        targetView = textView
        let extendKeyboardItems = createExtendKeyboardItems(listNumber)
        let extendKeyboard = createExtendKeyboard()
        extendKeyboard.setItems(extendKeyboardItems, animated: false)
        textView.inputAccessoryView = extendKeyboard
    }

    /**
     シンタックスハイライトトークンを設定する。
 
     - Parameter fileName: ファイル名
     - Parameter tokens: シンタックスハイライトトークン配列
     */
    private func setSyntaxHighlightTokens(fileName: String, inout tokens: [CYRToken]) {
        let syntaxCommonData = FileUtils.getFileData(fileName, type: "txt")
        let syntaxCommonDataLines = syntaxCommonData.componentsSeparatedByString("\n")
        let items = NSMutableDictionary()
        for line in syntaxCommonDataLines {
            if line.isEmpty {
                continue
            }
            let lines = line.componentsSeparatedByString("=")
            if lines.count != 2 {
                continue
            }
            if lines[0] == "name" ||
                lines[0] == "foregroundColor" ||
                lines[0] == "font" {
                items.setValue(lines[1], forKey: lines[0])

            } else if lines[0] == "expression" {
                items.setValue(lines[1], forKey: lines[0])

                if items.count != 4 {
                    items.removeAllObjects()
                    continue
                }

                let name = items.objectForKey("name") as! String
                let foregroundColor = items.objectForKey("foregroundColor") as! String
                let font = items.objectForKey("font") as! String
                let expression = items.objectForKey("expression") as! String
                let foregroundColors = foregroundColor.componentsSeparatedByString(",")
                if foregroundColors.count != 3 {
                    items.removeAllObjects()
                    continue
                }

                let redFloat = stringToCGFloat(foregroundColors[0])
                if !redFloat.0 {
                    items.removeAllObjects()
                    continue
                }
                let red = redFloat.1

                let greenFloat = stringToCGFloat(foregroundColors[1])
                if !greenFloat.0 {
                    items.removeAllObjects()
                    continue
                }
                let green = greenFloat.1

                let blueFloat = stringToCGFloat(foregroundColors[2])
                if !blueFloat.0 {
                    items.removeAllObjects()
                    continue
                }
                let blue = blueFloat.1

                let foregroundColorValue = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
                let attributes: NSDictionary
                let defaultFontName = EnvUtils.getDefaultFontName()
                let fontSize = EnvUtils.getDefaultFontSize()
                if font == "italic" {
                    let fontName: String
                    if defaultFontName == CommonConst.FontName.kArial {
                        fontName = CommonConst.FontName.kArialItalic

                    } else if defaultFontName == CommonConst.FontName.kCourierNew {
                        fontName = CommonConst.FontName.kCourierNewItalic

                    } else if defaultFontName == CommonConst.FontName.kSourceHanCodeJpNormal {
                        fontName = CommonConst.FontName.kSourceHanCodeJpNormalItalic

                    } else {
                        fontName = defaultFontName
                    }
                    let fontSize = EnvUtils.getEnterDataFontSize()
                    let font = UIFont(name: fontName, size: fontSize)
                    attributes = [
                        NSForegroundColorAttributeName: foregroundColorValue,
                        NSFontAttributeName: font!
                    ]

                } else if font == "bold" {
                    let fontName: String
                    if defaultFontName == CommonConst.FontName.kArial {
                        fontName = CommonConst.FontName.kArialBold

                    } else if defaultFontName == CommonConst.FontName.kCourierNew {
                        fontName = CommonConst.FontName.kCourierNewBold

                    } else if defaultFontName == CommonConst.FontName.kSourceHanCodeJpNormal {
                        fontName = CommonConst.FontName.kSourceHanCodeJpBold

                    } else {
                        fontName = defaultFontName
                    }
                    let font = UIFont(name: fontName, size: fontSize)
                    attributes = [
                        NSForegroundColorAttributeName: foregroundColorValue,
                        NSFontAttributeName: font!
                    ]

                } else if font == "boldItalic" {
                    let fontName: String
                    if defaultFontName == CommonConst.FontName.kArial {
                        fontName = CommonConst.FontName.kArialBoldItalic

                    } else if defaultFontName == CommonConst.FontName.kCourierNew {
                        fontName = CommonConst.FontName.kCourierNewBoldItalic

                    } else if defaultFontName == CommonConst.FontName.kSourceHanCodeJpNormal {
                        fontName = CommonConst.FontName.kSourceHanCodeJpBoldItalic

                    } else {
                        fontName = defaultFontName
                    }
                    let font = UIFont(name: fontName, size: fontSize)
                    attributes = [
                        NSForegroundColorAttributeName: foregroundColorValue,
                        NSFontAttributeName: font!
                    ]

                } else if font == "default" {
                    let fontName = EnvUtils.getDefaultFontName()
                    let font = UIFont(name: fontName, size: fontSize)
                    attributes = [
                        NSForegroundColorAttributeName: foregroundColorValue,
                        NSFontAttributeName: font!
                    ]

                } else {
                    let fontColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
                    let fontName = EnvUtils.getDefaultFontName()
                    let font = UIFont(name: fontName, size: fontSize)
                    attributes = [
                        NSForegroundColorAttributeName: fontColor,
                        NSFontAttributeName: font!
                    ]
                }

                let token = CYRToken(name: name, expression: expression, attributes: attributes as! [String : AnyObject])
                tokens.append(token)
                
                items.removeAllObjects()
            }
        }
    }

    /**
     数値文字列をCGFloat型に変換する。
     UIFont用に255で除算した結果を返却する。
 
     - Parameter src: 変換元数値文字列
     - Returns: 変換結果 true:成功 / false:失敗
 　　　　　　　　　変換されたCGFloat型の数値
     */
    private func stringToCGFloat(src: String) -> (Bool, CGFloat) {
        let formatter = NSNumberFormatter()
        let number = formatter.numberFromString(src)
        if number == nil {
            return (false, 0.0)
        } else {
            let result = CGFloat(number!) / 255.0
            return (true, result)
        }
    }

    /**
     通知設定を行う。
     */
    func setNotification() {
        // テキストビューがキーボードに隠れないための処理
        // 参考 : https://teratail.com/questions/2915
        let notificationCenter = NSNotificationCenter.defaultCenter()

        let keyboardWillShow = #selector(keyboardWillShow(_:))
        notificationCenter.addObserver(self, selector: keyboardWillShow, name: UIKeyboardWillShowNotification, object: nil)

        let keyboardWillHide = #selector(keyboardWillHide(_:))
        notificationCenter.addObserver(self, selector: keyboardWillHide, name: UIKeyboardWillHideNotification, object: nil)

        let keyboardDidHide = #selector(keyboardDidHide(_:))
        notificationCenter.addObserver(self, selector: keyboardDidHide, name: UIKeyboardDidHideNotification, object: nil)
    }

    /**
     通知設定をクリアする。
     */
    func clearNotification() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }

    // MARK: - Notification handler

    /**
     キーボードが表示される時に呼び出される。

     - Parameter notification: 通知
     */
    func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let size = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue().size

        var contentInsets = UIEdgeInsetsMake(0.0, 0.0, size.height, 0.0)
        contentInsets = textView.contentInset
        contentInsets.bottom = size.height + 44.0

        textView.contentInset = contentInsets
        textView.scrollIndicatorInsets = contentInsets
    }

    /**
     キーボードが閉じる時に呼び出される。

     - Parameter notification: 通知
     */
    func keyboardWillHide(notification: NSNotification) {
        var contentsInsets = textView.contentInset
        contentsInsets.bottom = 0
        textView.contentInset = contentsInsets
        textView.contentInset.bottom = 0
        preOffset = textView.contentOffset
    }

    /**
     キーボードが閉じた後に呼び出される。

     - Parameter notification: 通知
     */
    func keyboardDidHide(notification: NSNotification) {
        textView.setContentOffset(preOffset!, animated: true)
    }
}