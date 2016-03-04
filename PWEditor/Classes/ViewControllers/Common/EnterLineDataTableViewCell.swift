//
//  EnterLineDataTableViewCell.swift
//  PWEditor
//
//  Created by 二俣征嗣 on 2016/02/19.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import UIKit

/**
 一行データ入力テーブルビューセルクラス

 - Version: 1.0 新規作成
 - Author: paveway.info@gmail.com
 */
class EnterLineDataTableViewCell: UITableViewCell {

    // MARK: - Variabales

    @IBOutlet weak var textField: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
