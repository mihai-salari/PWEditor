//
//  SelectNumberViewController.swift
//  pwhub
//
//  Created by 二俣征嗣 on 2015/10/22.
//  Copyright © 2015年 Masatsugu Futamata. All rights reserved.
//

import UIKit
import GoogleMobileAds

/**
 数値データ受信デリゲート
 */
@objc protocol ReceiveNumberDelegate {

    /**
     数値データを受信する。

     - Parameter receiverNo: 受信者番号
     - Parameter number: 数値データ
     */
    func receiveNumber(receiverNo: Int, number: String)
}

/**
 数値選択画面

 - Version: 1.0 新規作成
 - Author: paveway.info@gmail.com
 */
class SelectNumberViewController: BaseViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    // MARK: - Constants

    // MARK: - Variables

    /// 数値ピッカー
    @IBOutlet weak var numberPicker: UIPickerView!

    /// バナービュー
    @IBOutlet weak var bannerView: GADBannerView!

    /// 受信者番号
    let receiverNo: Int!

    /// 数値
    var number: String!

    /// 範囲最小値
    let rangeMin: Int!

    /// 範囲最大値
    let rangeMax: Int!

    /// 画面タイトル
    let displayTitle: String!

    /// 番号リスト
    var numberList = [String]()

    /// デリゲート
    var delegate: ReceiveNumberDelegate?

    // MARK: - Initializer

    /**
     イニシャライザ

     - Parameter coder: デコーダー
     */
    required init?(coder aDecoder: NSCoder) {
        self.receiverNo = 0
        self.number = "0"
        self.rangeMin = 0
        self.rangeMax = 0
        self.displayTitle = ""

        // スーパークラスのイニシャライザを呼び出す。
        super.init(coder: aDecoder)
    }

    /**
     イニシャライザ

     - Parameter receiverNo: 受信者番号
     - Parameter displayTitle: 画面タイトル
     */
    init(receiverNo: Int, displayTitle: String) {
        self.receiverNo = receiverNo
        self.number = "0"
        self.rangeMin = 0
        self.rangeMax = 0
        self.displayTitle = displayTitle

        for var i = 1; i <= 30; i++ {
            numberList.append(i.description)
        }

        // スーパークラスのイニシャライザを呼び出す。
        super.init(nibName: nil, bundle: nil)
    }

    /**
     イニシャライザ

     - Parameter receiverNo: 受信者番号
     - Parameter number: 数値データ
     - Parameter rangeMin: 範囲最小値
     - Parameter rangeMax: 範囲最大値
     - Parameter displayTitle: 画面タイトル
     */
    init(receiverNo: Int, number: String, rangeMin: Int, rangeMax: Int, displayTitle: String) {
        self.receiverNo = receiverNo
        self.number = number
        self.rangeMin = rangeMin
        self.rangeMax = rangeMax
        self.displayTitle = displayTitle

        for var i = rangeMin; i <= rangeMax; i++ {
            numberList.append(i.description)
        }

        // スーパークラスのイニシャライザを呼び出す。
        super.init(nibName: nil, bundle: nil)
    }


    // MARK: - UIViewControllerDelegate

    /**
     インスタンスが生成された時に呼び出される。
     */
    override func viewDidLoad() {
        // スーパークラスのメソッドを呼び出す。
        super.viewDidLoad()

        // 画面タイトルを設定する。
        navigationItem.title = displayTitle

        // 右上ボタンを設定する。
        createRightBarButton()

        // 数値ピッカーを設定する。
        setupNumberPicker()

        // バナービューを設定する。
        setupBannerView(bannerView)
    }

    /**
     メモリ不足の時に呼び出される。
     */
    override func didReceiveMemoryWarning() {
        LogUtils.w("memory error.")

        // スーパークラスのメソッドを呼び出す。
        super.didReceiveMemoryWarning()
    }

    // MARK: - UIPickerViewDataSource

    /**
     pickerに表示する列数を返すデータソースメソッド.
    
     (実装必須)
     */
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    /**
     pickerに表示する行数を返すデータソースメソッド.
    
     (実装必須)
     */
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return numberList.count
    }

    // MARK: - UIPicerViewDelegate

    /**
     pickerに表示する値を返すデリゲートメソッド.
     */
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return numberList[row]
    }

    /**
     pickerが選択された際に呼ばれるデリゲートメソッド.
     */
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        number = numberList[row]
    }

    // MARK: - Button Handler

    /**
     右上バーボタンを押下した時に呼び出される。

     - Parameter sender: 右上バーボタン
     */
    override func rightBarButtonPressed(sender: UIButton) {
        // デリゲートメソッドを呼び出す。
        delegate?.receiveNumber(receiverNo, number: number)

        // 呼び出し元画面に戻る。
        navigationController?.popViewControllerAnimated(true)
    }

    // MARK: - Private

    /**
     数値ピッカーを設定する。
     */
    private func setupNumberPicker() {
        numberPicker.dataSource = self
        numberPicker.delegate = self

        var index = 0
        for var i = 0; i < numberList.count; i++ {
            if number == numberList[i] {
                break
            }
            index++
        }
        numberPicker.selectRow(index, inComponent: 0, animated: false)

        view.addSubview(numberPicker)
    }
}
