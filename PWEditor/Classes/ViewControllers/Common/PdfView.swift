//
//  PdfView.swift
//  PWEditor
//
//  Created by mfuta1971 on 2016/05/05.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import Foundation
import UIKit

class PdfView: UIView {

    var pdfPage: CGPDFPageRef?

    override func drawRect(rect: CGRect) {
        let context:CGContextRef = UIGraphicsGetCurrentContext()!;

        //上下を反転させる
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextTranslateCTM(context, 0, -CGRectGetHeight(rect));

        // PDFページのサイズを取得
        let pdfRect: CGRect = CGPDFPageGetBoxRect(pdfPage, CGPDFBox.ArtBox)
        let width = rect.size.width / pdfRect.size.width
        let height = rect.size.height / pdfRect.size.height
        CGContextScaleCTM(context, width, height)
        CGContextDrawPDFPage(context, pdfPage)
    }
}
