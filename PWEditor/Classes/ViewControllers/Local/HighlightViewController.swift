//
//  HighlightViewController.swift
//  PWEditor
//
//  Created by 二俣征嗣 on 2016/03/10.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import UIKit

class HighlightViewController: BaseViewController, UITextViewDelegate {

    @IBOutlet weak var textView: ICTextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        textView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textViewDidChange(textView: UITextView) {
        LogUtils.d("textViewDidChange")
        self.textView.resetSearch()
        let result = self.textView.scrollToString("main", searchDirection: ICTextViewSearchDirectionForward)
        if result {
            LogUtils.d("match")
        } else {
            LogUtils.d("not match")
        }
    }

/*
    - (NSAttributedString *)getHighlightedString:(NSString *)str
    {
    NSMutableAttributedString *attributedString;
    attributedString = [[NSMutableAttributedString alloc] initWithString:str];

    for(NSString *keyWord in keyWords) {

    // 文字列を先頭から順に見つからなくなるまで検索する
    // 大文字・小文字は区別しない
    NSRange textSearchRange = NSMakeRange(0, [str length]);
    NSRange range;
    do {
    range = [str rangeOfString: keyWord
    options: NSCaseInsensitiveSearch
    range: textSearchRange];

    if(range.location != NSNotFound) {
    [attributedString addAttribute:NSForegroundColorAttributeName
    value:[UIColor blueColor]
    range:NSMakeRange(range.location, range.length)];

    textSearchRange.location = range.location + range.length;
    textSearchRange.length = str.length - textSearchRange.location;

    }
    } while (range.location != NSNotFound);
    }
    return attributedString;
    }
    func getHightlightedString(str: String) -> NSAttributedString {
        var attributedString = NSMutableAttributedString()
        //let textSearchRange = NSMakeRange(0, str.characters.count)
        var range: Range<String.Index>?
        do {
            range = str.rangeOfString("main", options: NSStringCompareOptions.CaseInsensitiveSearch)
            if range != nil {
                attributedString.addAttribute(NSForegroundColorAttributeName, value: [UIColor.blueColor()], range: NSMakeRange(0, range!.count))
            }
        }

    }
*/
}
