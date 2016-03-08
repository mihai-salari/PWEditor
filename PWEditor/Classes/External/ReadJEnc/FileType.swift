//
//  FileType.swift
//  PWEditor
//
//  Created by 二俣征嗣 on 2016/03/07.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import Foundation

class FileType: NSObject {

}

/*
#region 継承クラス定義--------------------------------------------------
private FileType(string Name) : base(Name, 0, null) { }

/// <summary>ファイル文字コード種類：バイナリ
/// </summary>
public class Bin : CharCode
{
internal Bin(string Name, params byte[] bytes) : base(Name, 0, bytes) { }
internal Bin(int Encoding, string Name, params byte[] bytes) : base(Name, Encoding, bytes) { }
}
*/
class Bin: CharCode {

}

/*
/// <summary>ファイル文字コード種類：Zipバイナリ
/// </summary>
public class ZipBinary : Bin
{
internal ZipBinary(string Name, params byte[] bytes) : base(Name, bytes) { }
}
*/
class ZipBinary: Bin {

}

/*
/// <summary>ファイル文字コード種類：画像
/// </summary>
public class Image : CharCode
{
internal Image(string Name, params byte[] bytes) : base(Name, 0, bytes) { }
}
#endregion
}
}
*/
class Image: CharCode {

}