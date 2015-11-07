//
//  CloudKitStorageManager.swift
//  MappaCore
//
//  Created by 秋元　健太 on 2015/11/07.
//  Copyright © 2015年 KentaAkimoto. All rights reserved.
//

import UIKit
import CloudKit

class CloudKitStorageManager: NSObject {

    func saveRecord(){

        let recordID:CKRecordID = CKRecordID(recordName: "116")
        let record:CKRecord = CKRecord(recordType: "Comment", recordID: recordID)
        record["comment"] = "wwww"
        record["author"] = "hoge2"
        
        let container:CKContainer = CKContainer.defaultContainer()
        let publicDatabase:CKDatabase = container.publicCloudDatabase
        
        publicDatabase.saveRecord(record) { (targetRecord, error) -> Void in
            if (error == nil) {
                print("saved!")
            } else {
                print("save error!")
            }
        }
    }
    
    /// レコードの取得
    /// 同期的に処理する
    ///
    func fetchRecord(currentDate:NSDate) -> [Comment]{
        
        var resultComments:[Comment] = []
        
        let container:CKContainer = CKContainer.defaultContainer()
        let publicDatabase:CKDatabase = container.publicCloudDatabase
        
        let predicate:NSPredicate = NSPredicate(format: "createDate > %@", currentDate)
        let query:CKQuery = CKQuery(recordType: "Comment", predicate: predicate)
        
        let semaphore:dispatch_semaphore_t = dispatch_semaphore_create(0)
        
        publicDatabase.performQuery(query, inZoneWithID: nil) { (results, error) -> Void in
            
            if (error == nil) {
                
                let records:[CKRecord]? = results as [CKRecord]?
                print(records!.count)
                for result in records! {
                    let comment:Comment = Comment()
                    comment.author = result["author"] as! String
                    comment.comment = result["comment"] as! String
                    comment.createDate = result["createDate"] as! NSDate
                    resultComments.append(comment)
                }
                
                dispatch_semaphore_signal(semaphore)

            } else {
                dispatch_semaphore_signal(semaphore)

            }
        }

        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        return resultComments
    }
}
