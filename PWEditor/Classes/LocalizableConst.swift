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
    static let kAlertMessageCovertEncodingError = "AlertMessageCovertEncodingError"
    static let kAlertMessageSignOutGoogleDrive = "AlertMessageSignOutGoogleDrive"
    static let kAlertMessageDeleteFileError = "AlertMessageDeleteFileError"
    static let kAlertMessageSignOutOneDrive = "AlertMessageSignOutOneDrive"

    // アクションシートタイトル
    static let kActionSheetTitleLocalFile = "ActionSheetTitleLocalFile"
    static let kActionSheetTitleDropboxFile = "ActionSheetTitleDropboxFile"
    static let kActionSheetTitleGoogleDriveFile = "ActionSheetTitleGoogleDriveFile"

    // その他
    static let kFontSize = "FontSize"
    static let kSignIn = "SignIn"
    static let kSignOut = "SignOut"
    static let kUpdate = "Update"

    // フォント選択画面
    static let kSelectFontScreenTitle = "SelectFontScreenTitle"

    // 文字コード選択画面
    static let kSelectEncodingScreenTitle = "SelectEncodingScreenTitle"
    static let kSelectEncodingSectionTitleEncoding = "SelectEncodingSectionTitleEncoding"
    static let kSelectEncodingSectionTitleReturnCode = "SelectEncodingSectionTitleReturnCode"

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
    static let kMenuCellTitleBox = "MenuCellTitleBox"
    static let kMenuCellTitleSettings = "MenuCellTitleSettings"
    static let kMenuCellTitleAbout = "MenuCellTitleAbout"
    static let kMenuCellTitleHistory = "MenuCellTitleHistory"
    static let kMenuCellTitleOpenSourceLicense = "MenuCellTitleOpenSourceLicense"

    // ローカルファイル一覧画面
    static let kLocalFileListScreenTitle = "LocalFileListScreenTitle"
    static let kLocalFileListScreenTitleSearch = "LocalFileListScreenTitleSearch"

    // ローカルファイル追加画面
    static let kAddLocalFileScreenTitle = "AddLocalFileScreenTitle"
    static let kAddLocalFileSectionTitleFileName = "AddLocalFileSectionTitleFileName"
    static let kAddLocalFileSectionTitleFileType = "AddLocalFileSectionTitleFileType"
    static let kAddLocalFileCellTitleFile = "AddLocalFileCellTitleFile"
    static let kAddLocalFileCellTitleDir = "AddLocalFileCellTitleDir"
    static let kAddLocalFileEnterNameError = "AddLocalFileEnterNameError"
    static let kAddLocalFileSameNameError = "AddLocalFileSameNameError"
    static let kAddLocalFileCreateError = "AddLocalFileCreateError"
    
    // ローカルファイル編集画面
    static let kEditLocalFileWriteFileDataError = "EditLocalFileWriteFileDataError"

    // ローカルファイル情報画面
    static let kLocalFileInfoScreenTitle = "LocalFileInfoScreenTitle"
    static let kLocalFileInfoCellTitlePathName = "LocalFileInfoCellTitlePathName"
    static let kLocalFileInfoCellTitleFileName = "LocalFileInfoCellTitleFileName"
    static let kLocalFileInfoCellTitleSize = "LocalFileInfoCellTitleSize"
    static let kLocalFileInfoCellTitleCharNum = "LocalFileInfoCellTitleCharNum"
    static let kLocalFileInfoCellTitleLineNum = "LocalFileInfoCellTitleLineNum"
    static let kLocalFileInfoCellTitleRetCodeType = "LocalFileInfoCellTitleRetCodeType"
    static let kLocalFileInfoCellTitleCreateDate = "LocalFileInfoCellTitleCreateDate"
    static let kLocalFileInfoCellTitleUpdateDate = "LocalFileInfoCellTitleUpdateDate"

    // ローカルファイルgrep一覧画面
    static let kGrepLocalFileListScreenTitle = "GrepLocalFileListScreenTitle"

    // ディレクトリ選択画面
    static let kSelectDirScreenTitle = "SelectDirScreenTitle"

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
    static let kAddDropboxGetMetaDataError = "AddDropboxGetMetaDataError"
    static let kAddDropboxFileSameNameError = "AddDropboxFileSameNameError"
    static let kAddDropboxFileCreateError = "AddDropboxFileCreateError"

    // Dropboxファイル編集画面
    static let kEditDropboxFileDownloadError = "EditDropboxFileDownloadError"
    static let kEditDropboxFileUpdloadError = "EditDropboxFileUpdloadError"

    // GoogleDriveファイル一覧画面
    static let kGoogleDriveFileListScreenTitle = "GoogleDriveFileListScreenTitle"

    // GoogleDriveファイル詳細画面
    static let kGoogleDriveFileDetailScreenTitle = "GoogleDriveFileDetailScreenTitle"
    static let kGoogleDriveFileDetailCellName = "GoogleDriveFileDetailCellName"
    static let kGoogleDriveFileDetailCellSize = "GoogleDriveFileDetailCellSize"
    static let kGoogleDriveFileDetailCellMimeType = "GoogleDriveFileDetailCellMimeType"
    static let kGoogleDriveFileDetailCellFileExtention = "GoogleDriveFileDetailCellFileExtention"
    static let kGoogleDriveFileDetailCellCreatedTime = "GoogleDriveFileDetailCellCreatedTime"
    static let kGoogleDriveFileDetailCellModifiedTime = "GoogleDriveFileDetailCellModifiedTime"
    static let kGoogleDriveFileDetailCellStarred = "GoogleDriveFileDetailCellStarred"

    // GoogleDriveファイル作成画面
    static let kCreateGoogleDriveFileScreenTitle = "CreateGoogleDriveFileScreenTitle"
    static let kCreateGoogleDriveFileSectionTitleFileName = "CreateGoogleDriveFileSectionTitleFileName"
    static let kCreateGoogleDriveFileSectionTitleFileType = "CreateGoogleDriveFileSectionTitleFileType"
    static let kCreateGoogleDriveFileCellTitleFile = "CreateGoogleDriveFileCellTitleFile"
    static let kCreateGoogleDriveFileCellTitleDir = "CreateGoogleDriveFileCellTitleDir"
    static let kCreateGoogleDriveFileEnterNameError = "CreateGoogleDriveFileEnterNameError"
    static let kCreateGoogleDriveFileFileCreateError = "CreateGoogleDriveFileFileCreateError"

    // GoogleDriveファイル編集画面
    static let kEditGoogleDriveFileDownloadError = "EditGoogleDriveFileDownloadError";
    static let kEditGoogleDriveFileDownloadDataError = "EditGoogleDriveFileDownloadDataError";

    // OneDriveファイル一覧画面
    static let kOneDriveFileListScreenTitle = "OneDriveFileListScreenTitle"

    // 設定画面
    static let kSettingsScreenTitle = "SettingsScreenTitle"
    static let kSettingsSectionTitleFont = "SettingsSectionTitleFont"
    static let kSettingsSectionTitleCloud = "SettingsSectionTitleCloud"
    static let kSettingsCellTitleEnterDataFontName = "SettingsCellTitleEnterDataFontName"
    static let kSettingsCellTitleEnterDataFontSize = "SettingsCellTitleEnterDataFontSize"
    static let kSettingsCellTitleDropbox = "SettingsCellTitleDropbox"
    static let kSettingsCellTitleGoogleDrive = "SettingsCellTitleGoogleDrive"
    static let kSettingsCellTitleOneDrive = "SettingsCellTitleOneDrive"
    static let kSettingsSignInOneDriveError = "SettingsSignInOneDriveError"
    static let kSettingsSignOutOneDriveError = "SettingsSignOutOneDriveError"

    // 更新履歴画面
    static let kHistoryScreenTitle = "HistoryScreenTitle"

    // オープンソースライセンス一覧画面
    static let kOpenSourceLicenseListScreenTitle = "OpenSourceLicenseListScreenTitle"
}
