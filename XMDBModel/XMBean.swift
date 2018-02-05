//
//  XMBean.swift
//  基于SQLite.swift 数据库orm存储操作
//
//  Created by 李利锋 on 2018/1/30.
//  Copyright © 2018年 leefeng. All rights reserved.
//

/*
 XMDBModel Type            SQLite.swift Type      SQLite Type
 NSNumber                   Int64(Int,Bool)         INTEGER
 NSNumber（内部转Double）     Double                  REAL
 String                     String                  TEXT
 nil                        nil                     NULL
 Data                       SQLite.Blob†             BLOB
 Date                       Int64 (Date)             INTEGER
 */
//可与HandJSON一起使用，HandJSON是alibaba Group的JSON convert to Model的库
import Foundation
import HandyJSON
class XMBean:XMDBModel,HandyJSON{
    required init() {}
    
    
    //表主键
//    var row_id:NSNumber?
    
    //内容，被HandJSON映射对象使用，一般是网络传输过来的，也用于存储
    var mid:String?
    var msgType:String?
    var payload:String?
    var timestamp:NSNumber?
    
    //另外的消息内容，由映射后设置值，用于存储
    var isSend:NSNumber?//是否是发送出去的消息，1 是 0 否
    var mfrom:String?
    var toAccount:String?
    
    var isRead:NSNumber?// 当前消息是否被阅读了，1 是 0 否
    var test:String?
    var test3:String?
    
    //不会被SQL创建，也可以被网上的内容映射赋值（NSNumber，String,Data,Date，'Double', 为数据库创建字段支持的类型，否者不予创建，其中Double定义时还是使用NSNumber，在doubleKeys中声明）
    var isChecked:Bool? //是否被选中， 

    // 1、自定义主键，需将row_id定义在以上的属性
//    override func primaryKey() -> String {
//        return "row_id"
//    }
    //2、NSNumber中哪个是Double值
//    override func doubleKeys() -> [String] {
//        return ["other"]
//    }
    
    //3、不创建哪个属性为数据库的字段
//    override func exceptionKeys() -> [String] {
//        return ["row_id"]
//    }
    
}


