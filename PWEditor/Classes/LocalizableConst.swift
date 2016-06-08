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
    static let kButtonTitleEdit = "ButtonTitleEdit"
    static let kButtonTitleDownload = "ButtonTitleDownload"
    static let kButtonTitleFtpUpload = "ButtonTitleFtpUpload"
    static let kButtonTitleSearch = "ButtonTitleSearch"
    static let kButtonTitleReplace = "ButtonTitleReplace"
    static let kButtonTitleRename = "ButtonTitleRename"
    static let kButtonTitleCopy = "ButtonTitleCopy"
    static let kButtonTitleMove = "ButtonTitleMove"

    // アラートタイトル
    static let kAlertTitleError = "AlertTitleError"
    static let kAlertTitleAbout = "AlertTitleAbout"
    static let kAlertTitleConfirm = "AlertTitleConfirm"
    static let kAlertTitleProcessing = "AlertTitleProcessing"

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
    static let kAlertMessageOneDriveInvalid = "AlertMessageOneDriveInvalid"
    static let kAlertMessageSignOutOneDrive = "AlertMessageSignOutOneDrive"
    static let kAlertMessageFileDataNotFound = "AlertMessageFileDataNotFound"
    static let kAlertMessageGetFileListError = "AlertMessageGetFileListError"
    static let kAlertMessageGetFileListFailed = "AlertMessageGetFileListFailed"
    static let kAlertMessageProcessing = "AlertMessageProcessing"

    static let kAlertMessageUrlError = "AlertMessageUrlError"
    static let kAlertMessageUrlParamsError = "AlertMessageUrlParamsError"
    static let kAlertMessageHttpRequestError = "AlertMessageHttpRequestError"
    static let kAlertMessageHttpStatusError = "AlertMessageHttpStatusError"
    static let kAlertMessageFileUploadError = "AlertMessageFileUploadError"

    // アラートメッセージ：FTP関連
    static let kAlertMessageStartFtpError = "AlertMessageStartFtpError"
    static let kAlertMessageFtpDeleteError = "AlertMessageFtpDeleteError"
    static let kAlertMessageFtpCreateError = "AlertMessageFtpCreateError"

    static let kAlertMessageNoDirectoryError = "AlertMessageNoDirectoryErorr"
    static let kAlertMessageCreateFileError = "AlertMessageCreateFileError"
    static let kAlertMessageFileDownloadError = "AlertMessageFileDownloadError"
        static let kAlertMessageSameFileName = "AlertMessageSameFileName"

    static let kAlertMessageEnterNameError = "AlertMessageEnterNameError";
    static let kAlertMessageSameNameError = "AlertMessageSameNameError";
    static let kAlertMessageRenameError = "AlertMessageRenameError";

    // アクションシートタイトル
    static let kActionSheetTitleLocalFile = "ActionSheetTitleLocalFile"
    static let kActionSheetTitleICloudFile = "ActionSheetTitleICloudFile"
    static let kActionSheetTitleDropboxFile = "ActionSheetTitleDropboxFile"
    static let kActionSheetTitleGoogleDriveFile = "ActionSheetTitleGoogleDriveFile"
    static let kActionSheetTitleOneDriveFile = "ActionSheetTitleOneDriveFile"
    static let kActionSheetTitleFtpHostInfo = "ActionSheetTitleFtpHostInfo"
    static let kActionSheetTitleFtpFile = "ActionSheetTitleFtpFile"

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
    static let kMenuSectionTitleApp = "MenuSectionTitleApp"
    static let kMenuSectionTitleHelp = "MenuSectionTitleHelp"
    // セルタイトル
    static let kMenuCellTitleLocalFileList = "MenuCellTitleLocalFileList"
    static let kMenuCellTitleRecentFileList = "MenuCellTitleRecentFileList"
    static let kMenuCellTitleICloud = "MenuCellTitleICloud"
    static let kMenuCellTitleDropbox = "MenuCellTitleDropbox"
    static let kMenuCellTitleGoogleDrive = "MenuCellTitleGoogleDrive"
    static let kMenuCellTitleOneDrive = "MenuCellTitleOneDrive"
    static let kMenuCellTitleBox = "MenuCellTitleBox"
    static let kMenuCellTitleFtp = "MenuCellTitleFtp"
    static let kMenuCellTitleSettings = "MenuCellTitleSettings"
    static let kMenuCellTitleAbout = "MenuCellTitleAbout"
    static let kMenuCellTitleHistory = "MenuCellTitleHistory"
    static let kMenuCellTitleOpenSourceLicense = "MenuCellTitleOpenSourceLicense"

    // 単語検索画面
    static let kSearchWordScreenTitle = "SearchWordScreenTitle"

    // 検索・置換画面
    static let kSearchAndReplaceSegmentedTitleSearch = "SearchAndReplaceSegmentedTitleSearch"
    static let kSearchAndReplaceSegmentedTitleReplace = "SearchAndReplaceSegmentedTitleReplace"
    static let kSearchAndReplaceSectionTitleInput = "SearchAndReplaceSectionTitleInput"
    static let kSearchAndReplaceSectionTitleResult = "SearchAndReplaceSectionTitleResult"
    static let kSearchAndReplaceCellTitleSearch = "SearchAndReplaceCellTitleSearch"
    static let kSearchAndReplaceCellTitleReplace = "SearchAndReplaceCellTitleReplace"

    // ローカルファイル一覧画面
    static let kLocalFileListScreenTitle = "LocalFileListScreenTitle"
    static let kLocalFileListScreenTitleSearch = "LocalFileListScreenTitleSearch"

    // ローカルファイル作成画面
    static let kCreateLocalFileScreenTitle = "CreateLocalFileScreenTitle"
    static let kCreateLocalFileSectionTitleFileName = "CreateLocalFileSectionTitleFileName"
    static let kCreateLocalFileSectionTitleFileType = "CreateLocalFileSectionTitleFileType"
    static let kCreateLocalFileCellTitleFile = "CreateLocalFileCellTitleFile"
    static let kCreateLocalFileCellTitleDir = "CreateLocalFileCellTitleDir"
    static let kCreateLocalFileEnterNameError = "CreateLocalFileEnterNameError"
    static let kCreateLocalFileSameNameError = "CreateLocalFileSameNameError"
    static let kCreateLocalFileCreateError = "CreateLocalFileCreateError"
    
    // ローカルファイル編集画面
    static let kEditLocalFileWriteFileDataError = "EditLocalFileWriteFileDataError"

    // ローカルファイル詳細画面
    static let kLocalFileDetailScreenTitle = "LocalFileDetailScreenTitle"
    static let kLocalFileDetailCellTitlePathName = "LocalFileDetailCellTitlePathName"
    static let kLocalFileDetailCellTitleFileName = "LocalFileDetailCellTitleFileName"
    static let kLocalFileDetailCellTitleSize = "LocalFileDetailCellTitleSize"
    static let kLocalFileDetailCellTitleCharNum = "LocalFileDetailCellTitleCharNum"
    static let kLocalFileDetailCellTitleLineNum = "LocalFileDetailCellTitleLineNum"
    static let kLocalFileDetailCellTitleRetCodeType = "LocalFileDetailCellTitleRetCodeType"
    static let kLocalFileDetailCellTitleCreateDate = "LocalFileDetailCellTitleCreateDate"
    static let kLocalFileDetailCellTitleUpdateDate = "LocalFileDetailCellTitleUpdateDate"

    // ローカルファイルgrep一覧画面
    static let kGrepLocalFileListScreenTitle = "GrepLocalFileListScreenTitle"

    // ローカルファイル名前変更画面
    static let kRenameLocalFileScreenTitle = "RenameLocalFileScreenTitle"

    // ディレクトリ選択画面
    static let kSelectDirScreenTitle = "SelectDirScreenTitle"

    // iCloudファイル一覧画面
    static let kICloudFileListScreenTitle = "ICloudFileListScreenTitle"

    // iCloudファイル作成
    static let kCreateICloudFileScreenTitle = "CreateICloudFileScreenTitle"
    static let kCreateICloudFileSectionTitleDirName = "CreateICloudFileSectionTitleDirName"
    static let kCreateICloudFileSectionTitleFileName = "CreateICloudFileSectionTitleFileName"

    // iCloudファイル詳細画面
    static let kICloudFileDatailScreenTitle = "ICloudFileDatailScreenTitle"
    static let kICloudFileDetailCellTitleName = "ICloudFileDetailCellTitleName"
    static let kICloudFileDetailCellTitleDisplayName = "ICloudFileDetailCellTitleDisplayName"
    static let kICloudFileDetailCellTitleUrl = "ICloudFileDetailCellTitleUrl"
    static let kICloudFileDetailCellTitlePath = "ICloudFileDetailCellTitlePath"
    static let kICloudFileDetailCellTitleSize = "ICloudFileDetailCellTitleSize"
    static let kICloudFileDetailCellTitleCreationDate = "ICloudFileDetailCellTitleCreationDate"
    static let kICloudFileDetailCellTitleContentChangeDate = "ICloudFileDetailCellTitleContentChangeDate"

    // Dropboxファイル一覧画面
    static let kDropboxFileListScreenTitle = "DropboxFileListScreenTitle"
    static let kDropboxFileListGetFileInfoListError = "DropboxFileListGetFileInfoListError"

    // Dropboxファイル詳細画面
    static let kDropboxFileDetailScreenTitle = "DropboxFileDetailScreenTitle"
    static let kDropboxFileDetailCellTitleId = "DropboxFileDetailCellTitleId"
    static let kDropboxFileDetailCellTitleName = "DropboxFileDetailCellTitleName"
    static let kDropboxFileDetailCellTitlePathLower = "DropboxFileDetailCellTitlePathLower"
    static let kDropboxFileDetailCellTitleSize = "DropboxFileDetailCellTitleSize"
    static let kDropboxFileDetailCellTitleRev = "DropboxFileDetailCellTitleRev"
    static let kDropboxFileDetailCellTitleServerModified = "DropboxFileDetailCellTitleServerModified"
    static let kDropboxFileDetailCellTitleClientModified = "DropboxFileDetailCellTitleClientModified"

    // Dropboxファイル作成画面
    static let kCreateDropboxFileScreenTitle = "CreateDropboxFileScreenTitle"
    static let kCreateDropboxFileSectionTitleFileName = "CreateDropboxFileSectionTitleFileName"
    static let kCreateDropboxFileSectionTitleFileType = "CreateDropboxFileSectionTitleFileType"
    static let kCreateDropboxFileCellTitleFile = "CreateDropboxFileCellTitleFile"
    static let kCreateDropboxFileCellTitleDir = "CreateDropboxFileCellTitleDir"
    static let kCreateDropboxFileEnterNameError = "CreateDropboxFileEnterNameError"
    static let kCreateDropboxFileGetMetaDataError = "CreateDropboxFileGetMetaDataError"
    static let kCreateDropboxFileSameNameError = "CreateDropboxFileSameNameError"
    static let kCreateDropboxFileCreateError = "CreateDropboxFileCreateError"

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
    static let kEditGoogleDriveFileDownloadDataError = "EditGoogleDriveFileDownloadDataError"

    // OneDriveファイル一覧画面
    static let kOneDriveFileListScreenTitle = "OneDriveFileListScreenTitle"

    // OneDriveファイル詳細画面
    static let kOneDriveFileDetailScreenTitle = "OneDriveFileDetailScreenTitle"
    static let kOneDriveFileDetailCellTitleName = "OneDriveFileDetailCellTitleName"
    static let kOneDriveFileDetailCellTitleSize = "OneDriveFileDetailCellTitleSize"
    static let kOneDriveFileDetailCellTitleCreatedDateTime = "OneDriveFileDetailCellTitleCreatedDateTime"
    static let kOneDriveFileDetailCellTitleLastModifiedDateTime = "OneDriveFileDetailCellTitleLastModifiedDateTime"

    // OneDriveファイル作成画面
    static let kCreateOneDriveFileScreenTitle = "CreateOneDriveFileScreenTitle"
    static let kCreateOneDriveFileSectionTitleFileName = "CreateOneDriveFileSectionTitleFileName"
    static let kCreateOneDriveFileSectionTitleFileType = "CreateOneDriveFileSectionTitleFileType"
    static let kCreateOneDriveFileCellTitleFile = "CreateOneDriveFileCellTitleFile"
    static let kCreateOneDriveFileCellTitleDir = "CreateOneDriveFileCellTitleDir"
    static let kCreateOneDriveFileEnterNameError = "CreateOneDriveFileEnterNameError"

    // OneDrive編集画面
    static let kEditOneDriveFileDownloadError = "EditOneDriveFileDownloadError";
    static let kEditOneDriveFileFilePathInvalid = "EditOneDriveFileFilePathInvalid";
    static let kEditOneDriveFileDownloadDataError = "EditOneDriveFileDownloadDataError";

    // FTPホスト一覧画面
    static let kFtpHostListScreenTitle = "FtpHostListScreenTitle"

    // FTPホスト作成画面
    static let kCreateFtpHostScreenTitle = "CreateFtpHostScreenTitle"
    static let kCreateFtpHostSectionTitleDisplayName = "CreateFtpHostSectionTitleDisplayName"
    static let kCreateFtpHostSectionTitleHostName = "CreateFtpHostSectionTitleHostName"
    static let kCreateFtpHostSectionTitleUserName = "CreateFtpHostSectionTitleUserName"
    static let kCreateFtpHostSectionTitlePassword = "CreateFtpHostSectionTitlePassword"
    static let kCreateFtpHostEnterDisplayNameError = "CreateFtpHostEnterDisplayNameError"
    static let kCreateFtpHostEnterHostNameError = "CreateFtpHostEnterHostNameError"

    // FTPファイル一覧画面
    static let kFtpFileListScreenTitle = "FtpFileListScreenTitle"

    // FTPファイル詳細画面
    static let kFtpFileDetailScreenTitle = "FtpFileDetailScreenTitle"
    static let kFtpFileDetailCellTitleName = "FtpFileDetailCellTitleName"
    static let kFtpFileDetailCellTitleLink = "FtpFileDetailCellTitleLink"
    static let kFtpFileDetailCellTitleSize = "FtpFileDetailCellTitleSize"
    static let kFtpFileDetailCellTitleType = "FtpFileDetailCellTitleType"
    static let kFtpFileDetailCellTitleMode = "FtpFileDetailCellTitleMode"
    static let kFtpFileDetailCellTitleOwner = "FtpFileDetailCellTitleOwner"
    static let kFtpFileDetailCellTitleGroup = "FtpFileDetailCellTitleGroup"
    static let kFtpFileDetailCellTitleModDate = "FtpFileDetailCellTitleModDate"

    // FTPファイル作成画面
    static let kCreateFtpFileScreenTitle = "CreateFtpFileScreenTitle"
    static let kCreateFtpFileSectionTitleFileName = "CreateFtpFileSectionTitleFileName"
    static let kCreateFtpFileSectionTitleFileType = "CreateFtpFileSectionTitleFileType"
    static let kCreateFtpFileCellTitleFile = "CreateFtpFileCellTitleFile"
    static let kCreateFtpFileCellTitleDir = "CreateFtpFileCellTitleDir"

    // FTPダウンロード先選択画面
    static let kSelectFtpDownloadTargetScreenTitle = "SelectFtpDownloadTargetScreenTitle"
    static let kSelectFtpDownloadTargetCellTitleLocal = "SelectFtpDownloadTargetCellTitleLocal"
    static let kSelectFtpDownloadTargetCellTitleICloud = "SelectFtpDownloadTargetCellTitleICloud"
    static let kSelectFtpDownloadTargetCellTitleDropbox = "SelectFtpDownloadTargetCellTitleDropbox"
    static let kSelectFtpDownloadTargetCellTitleGoogleDrive = "SelectFtpDownloadTargetCellTitleGoogleDrive"
    static let kSelectFtpDownloadTargetCellTitleOneDrive = "SelectFtpDownloadTargetCellTitleOneDrive"
    static let kSelectFtpDownloadTargetCellTitleBox = "SelectFtpDownloadTargetCellTitleBox"

    // ローカルディレクトリ選択画面
    static let kSelectLocalDirectoryNotSelectError = "SelectLocalDirectoryNotSelectError";

    // FTPアップロード先ホスト一覧選択画面
    static let kSelectFtpUploadHostListScreenTitle = "SelectFtpUploadHostListScreenTitle";

    // FTPアップロードディレクトリ一覧選択画面
    static let kSelectFtpUploadDirectoryListScreenTitle = "SelectFtpUploadDirectoryListScreenTitle";

    // 設定画面
    static let kSettingsScreenTitle = "SettingsScreenTitle"
    static let kSettingsSectionTitleFont = "SettingsSectionTitleFont"
    static let kSettingsSectionTitleCloud = "SettingsSectionTitleCloud"
    static let kSettingsCellTitleEnterDataFontName = "SettingsCellTitleEnterDataFontName"
    static let kSettingsCellTitleEnterDataFontSize = "SettingsCellTitleEnterDataFontSize"
    static let kSettingsCellTitleDropbox = "SettingsCellTitleDropbox"
    static let kSettingsCellTitleGoogleDrive = "SettingsCellTitleGoogleDrive"
    static let kSettingsCellTitleOneDrive = "SettingsCellTitleOneDrive"
    static let kSettingsCellTitleBox = "SettingsCellTitleBox"
    static let kSettingsSignInOneDriveError = "SettingsSignInOneDriveError"
    static let kSettingsSignOutOneDriveError = "SettingsSignOutOneDriveError"

    // 更新履歴画面
    static let kHistoryScreenTitle = "HistoryScreenTitle"

    // オープンソースライセンス一覧画面
    static let kOpenSourceLicenseListScreenTitle = "OpenSourceLicenseListScreenTitle"
}
