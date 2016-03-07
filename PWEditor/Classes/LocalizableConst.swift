//
//  LocalizeConst.swift
//  PWEditor
//
//  Created by 二俣征嗣 on 2016/02/19.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import Foundation

struct LocalizableConst {
    // ボタンタイトル
    static let kButtonTitleOk = "ButtonTitleOk"
    static let kButtonTitleCancel = "ButtonTitleCancel"
    static let kButtonTitleClose = "ButtonTitleClose"
    static let kButtonTitleClear = "ButtonTitleClear"
    static let kButtonTitleDelete = "ButtonTitleDelete"
    static let kButtonTitleMenu = "ButtonTitleMenu"
    static let kButtonTitleOpenChar = "ButtonTitleOpenChar"

    // アラートタイトル
    static let kAlertTitleError = "AlertTitleError"
    static let kAlertTitleAbout = "AlertTitleAbout"
    static let kAlertTitleConfirm = "AlertTitleConfirm"

    // アラートメッセージ
    static let kAlertMessageAbout = "AlertMessageAbout"
    static let kAlertMessageDeleteConfirm = "AlertMessageDeleteConfirm"
    static let kAlertMessageSignOutDropbox = "AlertMessageSignOutDropbox"
    static let kAlertMessageDropboxInvalid = "AlertMessageDropboxInvalid"
    static let kAlertMessageOpenFileError = "AlertMessageOpenFileError"
    static let kAlertMessageGetFileDataError = "AlertMessageGetFileDataError"
    static let kAlertMessageNotTextFileError = "AlertMessageNotTextFileError"
    static let kAlertMessageCovertCharCodeError = "AlertMessageCovertCharCodeError"

    // アクションシートタイトル
    static let kActionSheetTitleDropbox = "ActionSheetTitleDropbox"

    // その他
    static let kFontSize = "FontSize"
    static let kSignIn = "SignIn"
    static let kSignOut = "SignOut"
    static let kUpdate = "Update"

    // フォント選択画面
    static let kSelectFontScreenTitle = "SelectFontScreenTitle"

    // 文字コード選択画面
    static let kSelectCharCodeScreenTitle = "SelectCharCodeScreenTitle"
    static let kSelectCharCodeSectionTitleCharCode = "SelectCharCodeSectionTitleCharCode"
    static let kSelectCharCodeSectionTitleReturnCode = "SelectCharCodeSectionTitleReturnCode"

    // メニュー画面
    static let kMenuScreenTitle = "MenuScreenTitle"
    // セクションタイトル
    static let kMenuSectionTitleLocal = "MenuSectionTitleLocal"
    static let kMenuSectionTitleCloud = "MenuSectionTitleCloud"
    static let kMenuSectionTitleHelp = "MenuSectionTitleHelp"
    // セルタイトル
    static let kMenuCellTitleLocalFileList = "MenuCellTitleLocalFileList"
    static let kMenuCellTitleRecentFileList = "MenuCellTitleRecentFileList"
    static let kMenuCellTitleICloud = "MenuCellTitleICloud"
    static let kMenuCellTitleDropbox = "MenuCellTitleDropbox"
    static let kMenuCellTitleGoogleDrive = "MenuCellTitleGoogleDrive"
    static let kMenuCellTitleOneDrive = "MenuCellTitleOneDrive"
    static let kMenuCellTitleSettings = "MenuCellTitleSettings"
    static let kMenuCellTitleAbout = "MenuCellTitleAbout"
    static let kMenuCellTitleHistory = "MenuCellTitleHistory"
    static let kMenuCellTitleOpenSourceLicense = "MenuCellTitleOpenSourceLicense"

    // ローカルファイル一覧画面
    static let kLocalFileListScreenTitle = "LocalFileListScreenTitle"
    static let kLocalFileListScreenTitleSearch = "LocalFileListScreenTitleSearch"

    // ファイル追加画面
    static let kAddFileScreenTitle = "AddFileScreenTitle"
    static let kAddFileSectionTitleFileName = "AddFileSectionTitleFileName"
    static let kAddFileSectionTitleFileType = "AddFileSectionTitleFileType"
    static let kAddFileCellTitleFile = "AddFileCellTitleFile"
    static let kAddFileCellTitleDir = "AddFileCellTitleDir"
    static let kAddFileEnterNameError = "AddFileEnterNameError"
    static let kAddFileSameNameError = "AddFileSameNameError"
    static let kAddFileCreateError = "AddFileCreateError"
    
    // ファイル編集画面
    static let kEditFileWriteFileDataError = "EditFileWriteFileDataError"

    // ファイル情報画面
    static let kFileInfoScreenTitle = "FileInfoScreenTitle"
    static let kFileInfoCellTitlePathName = "FileInfoCellTitlePathName"
    static let kFileInfoCellTitleFileName = "FileInfoCellTitleFileName"
    static let kFileInfoCellTitleSize = "FileInfoCellTitleSize"
    static let kFileInfoCellTitleCharNum = "FileInfoCellTitleCharNum"
    static let kFileInfoCellTitleLineNum = "FileInfoCellTitleLineNum"
    static let kFileInfoCellTitleRetCodeType = "FileInfoCellTitleRetCodeType"
    static let kFileInfoCellTitleCreateDate = "FileInfoCellTitleCreateDate"
    static let kFileInfoCellTitleUpdateDate = "FileInfoCellTitleUpdateDate"

    // grep一覧画面
    static let kGrepListScreenTitle = "GrepListScreenTitle"

    // iCloudファイル一覧画面
    static let kICloudFileListScreenTitle = "ICloudFileListScreenTitle"

    // Dropboxファイル一覧画面
    static let kDropboxFileListScreenTitle = "DropboxFileListScreenTitle"
    static let kDropboxFileListGetFileInfoListError = "DropboxFileListGetFileInfoListError"

    // Dropboxファイル情報画面
    static let kDropboxFileInfoScreenTitle = "DropboxFileInfoScreenTitle"
    static let kDropboxFileInfoCellTitleId = "DropboxFileInfoCellTitleId"
    static let kDropboxFileInfoCellTitleName = "DropboxFileInfoCellTitleName"
    static let kDropboxFileInfoCellTitlePathLower = "DropboxFileInfoCellTitlePathLower"
    static let kDropboxFileInfoCellTitleSize = "DropboxFileInfoCellTitleSize"
    static let kDropboxFileInfoCellTitleRev = "DropboxFileInfoCellTitleRev"
    static let kDropboxFileInfoCellTitleServerModified = "DropboxFileInfoCellTitleServerModified"
    static let kDropboxFileInfoCellTitleClientModified = "DropboxFileInfoCellTitleClientModified"

    // Dropboxファイル追加画面
    static let kAddDropboxFileScreenTitle = "AddDropboxFileScreenTitle"
    static let kAddDropboxFileSectionTitleFileName = "AddDropboxFileSectionTitleFileName"
    static let kAddDropboxFileSectionTitleFileType = "AddDropboxFileSectionTitleFileType"
    static let kAddDropboxFileCellTitleFile = "AddDropboxFileCellTitleFile"
    static let kAddDropboxFileCellTitleDir = "AddDropboxFileCellTitleDir"
    static let kAddDropboxFileEnterNameError = "AddDropboxFileEnterNameError"
    static let kAddDropboxFileSameNameError = "AddDropboxFileSameNameError"
    static let kAddDropboxFileCreateError = "AddDropboxFileCreateError"

    // Dropboxファイル編集画面
    static let kEditDropboxFileDownloadError = "EditDropboxFileDownloadError"
    static let kEditDropboxFileUpdloadError = "EditDropboxFileUpdloadError"

    // 設定画面
    static let kSettingsScreenTitle = "SettingsScreenTitle"
    static let kSettingsSectionTitleFont = "SettingsSectionTitleFont"
    static let kSettingsSectionTitleCloud = "SettingsSectionTitleCloud"
    static let kSettingsCellTitleEnterDataFontName = "SettingsCellTitleEnterDataFontName"
    static let kSettingsCellTitleEnterDataFontSize = "SettingsCellTitleEnterDataFontSize"
    static let kSettingsCellTitleDropbox = "SettingsCellTitleDropbox"
    static let kSettingsCellTitleGoogleDrive = "SettingsCellTitleGoogleDrive"
    static let kSettingsCellTitleOneDrive = "SettingsCellTitleOneDrive"

    // 更新履歴画面
    static let kHistoryScreenTitle = "HistoryScreenTitle"

    // オープンソースライセンス一覧画面
    static let kOpenSourceLicenseListScreenTitle = "OpenSourceLicenseListScreenTitle"
}
