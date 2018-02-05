//
//  XMDataBase.swift
//  leefeng.me
//
//  Created by 李利锋 on 2018/1/31.
//  Copyright © 2018年 leefeng. All rights reserved.
//

import Foundation
import SQLite

struct XMDataBase {
   
    var sqlName:String = "db.sqlite3"
    
    
    let dbVersion = 0
    static let conn = XMDataBase.init().connDatabase()
    private init() {}
    
    
     func connDatabase(filePath:String="/Documents") -> Connection?{
        let sqlFilePath = NSHomeDirectory() + filePath + "/\(sqlName)"
        
        do { // 与数据库建立连接
            let db = try Connection(sqlFilePath)
            print("与数据库建立连接 成功")
            return db
        } catch {
            print("与数据库建立连接 失败：\(error)")
            return nil
        }
    }

    
}
public extension Connection {
    
    public var userVersion: Int32 {
        get { return Int32(try! scalar("PRAGMA user_version") as! Int64)}
        set { try! run("PRAGMA user_version = \(newValue)") }
    }
}
