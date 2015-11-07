//
//  Comment.swift
//  MappaCore
//
//  Created by 秋元　健太 on 2015/11/08.
//  Copyright © 2015年 KentaAkimoto. All rights reserved.
//

import UIKit

class Comment: NSObject {
    var author:String
    var comment:String
    var createDate:NSDate
    
    override init() {
        self.author = ""
        self.comment = ""
        self.createDate = NSDate.init(timeIntervalSince1970: 0)
    }
}
