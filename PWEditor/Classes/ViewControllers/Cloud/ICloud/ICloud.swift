//
//  ICloud.swift
//  PWEditor
//
//  Created by mfuta1971 on 2016/05/09.
//  Copyright © 2016年 Masatsugu Futamata. All rights reserved.
//

import Foundation

@objc protocol ICloudDelegate: NSObjectProtocol {

    optional func iCloudAvailabilityDidChangeToState(cloudIsAvailable: Bool, ubiquityToken: AnyObject?, ubiquityContainer: NSURL)
    optional func iCloudDidFinishInitializingWitUbiquityToken(cloudToken: AnyObject, ubiquityContainer: NSURL)
    optional func iCloudQueryLimitedToFileExtension() -> String
    optional func iCloudFileStartUpdate()
    optional func iCloudFileEndUpdate()
    optional func iCloudFilesDidChange(files: [AnyObject], fileNames: [String])
    optional func iCloudFileConflictBetweenCloudFile(cloudFile: NSDictionary, localFile: NSDictionary)
}

class ICloud: NSObject {

    // MARK: Constants

    let kDocumentsDirectory = "Documents"

    let kDefaultFileExtention = "*"

    // MARK: - Variables

    var fileManager: NSFileManager?

    var notificationCenter: NSNotificationCenter?

    var query: NSMetadataQuery?

    var ubiquityContainer: NSURL?

    var fileExtension: String?

    var delegate: ICloudDelegate?

    class var sharedManager: ICloud
    {
        struct Singleton {
            static let instance = ICloud()
        }
        return Singleton.instance
    }

    func setupiCloudDocumentSyncWithUbiquityContainer(containerID: String?) {
        if fileManager == nil {
            fileManager = NSFileManager.defaultManager()
        }

        if notificationCenter == nil {
            notificationCenter = NSNotificationCenter.defaultCenter()
        }

        if query ==  nil {
            query = NSMetadataQuery()
        }

        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(queue) {
            let fileManager = NSFileManager.defaultManager()
            self.ubiquityContainer = fileManager.URLForUbiquityContainerIdentifier(containerID)
            if self.ubiquityContainer != nil {
                let mainQueue = dispatch_get_main_queue()
                dispatch_async(mainQueue) {
                    let cloudToken = self.fileManager!.ubiquityIdentityToken

                    self.enumerateCloudDocuments()

                    let selector = #selector(ICloudDelegate.iCloudDidFinishInitializingWitUbiquityToken)
                    let name = NSUbiquityIdentityDidChangeNotification
                    self.notificationCenter!.addObserver(self, selector: selector, name: name, object: nil)

                    if self.delegate != nil {
                        let delegateSelector = #selector(ICloudDelegate.iCloudDidFinishInitializingWitUbiquityToken)
                        if self.delegate!.respondsToSelector(delegateSelector) {
                            self.delegate?.iCloudDidFinishInitializingWitUbiquityToken!(cloudToken!, ubiquityContainer: self.ubiquityContainer!)
                        }
                    }
                }

            } else {
                if self.delegate != nil {
                    let selector = #selector(ICloudDelegate.iCloudAvailabilityDidChangeToState(_:ubiquityToken:ubiquityContainer:))
                    if self.delegate!.respondsToSelector(selector) {
                        self.delegate?.iCloudAvailabilityDidChangeToState!(false, ubiquityToken: nil, ubiquityContainer: self.ubiquityContainer!)
                    }
                }
            }
        }
    }

    func checkCloudAvailability() -> Bool {
        let cloudToken = fileManager?.ubiquityIdentityToken
        if delegate != nil {
            let selector = #selector(ICloudDelegate.iCloudAvailabilityDidChangeToState(_:ubiquityToken:ubiquityContainer:))
            if delegate!.respondsToSelector(selector) {
                delegate!.iCloudAvailabilityDidChangeToState!(true, ubiquityToken: cloudToken, ubiquityContainer: ubiquityContainer!)

            }
        }

        if cloudToken != nil {
            return true
        } else {
            return false
        }
    }

    func checkCloudUbiquityContainer() -> Bool {
        if ubiquityContainer != nil {
            return true
        } else {
            return false
        }
    }

    func quickCloudCheck() -> Bool {
        if fileManager?.ubiquityIdentityToken != nil {
            return true
        } else {
            return false
        }
    }

    func ubiquitousContainerURL() -> NSURL? {
        return ubiquityContainer
    }

    func enumerateCloudDocuments() {
        query!.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
        let filePattern = "*"
        let predicate = NSPredicate(format: "%K.pathExtension LIKE '*'", NSMetadataItemFSNameKey)
        query!.predicate = predicate

        let startSelector = #selector(startUpdate(_:))
        let startName = NSMetadataQueryDidStartGatheringNotification
        notificationCenter!.addObserver(self, selector: startSelector, name: startName, object: query)

        let updateSelector = #selector(receiveUpdate(_:))
        let updateName = NSMetadataQueryDidUpdateNotification
        notificationCenter!.addObserver(self, selector: updateSelector, name: updateName, object: query)

        let finishSelector = #selector(finishUpdate(_:))
        let finishName = NSMetadataQueryDidFinishGatheringNotification
        notificationCenter!.addObserver(self, selector: finishSelector, name: finishName, object: query)

        let queue = dispatch_get_main_queue()
        dispatch_async(queue) {
            self.query!.startQuery()
        }
    }

    func startUpdate(notification: NSNotification) {
        let queue = dispatch_get_main_queue()
        dispatch_async(queue) {
            if self.delegate != nil {
                let selector = #selector(ICloudDelegate.iCloudFileStartUpdate)
                if self.delegate!.respondsToSelector(selector) {
                    self.delegate!.iCloudFileStartUpdate!()
                }
            }
        }
    }

    func receiveUpdate(notification: NSNotification) {
        updateFiles()
    }

    func finishUpdate(notificaiton: NSNotification) {
        updateFiles()

        let queue = dispatch_get_main_queue()
        dispatch_async(queue) {
            if self.delegate != nil {
                let selector = #selector(ICloudDelegate.iCloudFileEndUpdate)
                if self.delegate!.respondsToSelector(selector) {
                    self.delegate!.iCloudFileEndUpdate!()
                }
            }
        }
    }


    func updateFiles() {
        if !quickCloudCheck() {
            return
        }

        var files = [AnyObject]()
        var fileNames = [String]()

        if query != nil {
            let selector = #selector(NSMetadataQuery.enumerateResultsUsingBlock(_:))
            if query!.respondsToSelector(selector) {
                query!.enumerateResultsUsingBlock( { (result: AnyObject, idx: Int, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                    let fileUrl = result.valueForAttribute(NSMetadataItemURLKey) as! NSURL
                    var fileStatus: AnyObject? = nil
                    do {
                        try fileUrl.getResourceValue(&fileStatus, forKey: NSURLUbiquitousItemDownloadingStatusKey)
                    } catch {

                    }
                    let fileStatusString = fileStatus as! String
                    if fileStatusString == NSURLUbiquitousItemDownloadingStatusDownloaded {

                    }

                    if fileStatusString == NSURLUbiquitousItemDownloadingStatusCurrent {
                        files.append(result)
                        let fileName = result.valueForAttribute(NSMetadataItemFSNameKey) as! String
                        fileNames.append(fileName)

                        if self.query!.resultCount - 1 >= idx {
                            let queue = dispatch_get_main_queue()
                            dispatch_async(queue) {
                                if self.delegate != nil {
                                    let selector = #selector(ICloudDelegate.iCloudFilesDidChange(_:fileNames:))
                                    if self.delegate!.respondsToSelector(selector) {
                                        self.delegate!.iCloudFilesDidChange!(files, fileNames: fileNames)
                                    }
                                }
                            }
                        }
                    } else if fileStatusString == NSURLUbiquitousItemDownloadingStatusNotDownloaded {
                        do {
                            try self.fileManager?.startDownloadingUbiquitousItemAtURL(fileUrl as! NSURL)
                        } catch {

                        }
                    }
                })

            } else {
                // iOS6.1以下の場合
                query!.disableUpdates()

                let queryResults = query!.results
                for result in queryResults {
                    files.append(result)
                    let fileName = result.valueForAttribute(NSMetadataItemFSNameKey)
                    fileNames.append(fileName as! String)
                }

                let queue = dispatch_get_main_queue()
                dispatch_async(queue) {
                    if self.delegate != nil {
                        let selector = #selector(ICloudDelegate.iCloudFilesDidChange(_:fileNames:))
                        if self.delegate!.respondsToSelector(selector) {
                            self.delegate!.iCloudFilesDidChange!(files, fileNames: fileNames)
                        }
                    }
                }

                query!.enableUpdates()
            }
        }
    }
}