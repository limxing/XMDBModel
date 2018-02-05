//
//  XMDBModel.swift
//  leefeng.me
//
//  Created by 李利锋 on 2018/1/31.
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

import SQLite

@objcMembers
class XMDBModel:NSObject {
    
    private var mirror:Mirror.Children?{
        get{
            return Mirror.init(reflecting: self).children
        }
    }
    
    required override public init() {
        super.init()
       
        
    }
//    获取子类属性名称集合
    private func getKeys(exceptPriK:Bool) -> [String]{
        var keys = [String]()
        let exceptions = exceptionKeys()
        
        for (name,_) in mirror! {
            if (exceptPriK && name! == primaryKey() || exceptions.contains(name!)){
                continue
            }
            
            keys.append(name!)
        }
        
        return keys
    }
//    override func setValue(_ value: Any?, forUndefinedKey key: String) {
//        print(value)
//    }
    
   
        
//        for (name,_) in Mirror.init(reflecting: self).customMirror.children{
//            mVars.append(name ?? "")
//        }
//    }
    
   
    public class func getTable() -> Table{
        return Table(nameOfTable)
    }
    
    public func getTable() -> Table{
        return type(of: self).getTable()
    }
    public class var nameOfTable: String{
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
    public var nameOfTable:String{
        get{
            return type(of: self).nameOfTable
        }
    }
    
     var _id:NSNumber?
    //主键名称
    func primaryKey() -> String {
        return "_id"
    }
    //唯一的键名称数组
    func uniqueKeys() -> [String] {
        return [String]()
    }
    //不保存哪个字段
    func exceptionKeys() -> [String] {
        return [String]()
    }
    //双精度字段
    func doubleKeys() -> [String] {
        return [String]()
    }
    
    
//    新建表格
    private func getTableWithColume() -> String {
     
        return getTable().create(ifNotExists: true) { (table) in
            let keys = getKeys(exceptPriK: true)
            let uniques = uniqueKeys()
            let doubles = doubleKeys()
            table.column(Expression<Int64>(primaryKey()),primaryKey:PrimaryKey.autoincrement)
            
//            let mirror = Mirror.init(reflecting: self).children
            if let mirror = mirror{
                for (name,value) in mirror {
                    if keys.contains(name ?? ""){
                        let type = Mirror(reflecting: value).subjectType
                        switch type{
                        case is String.Type, is ImplicitlyUnwrappedOptional<String>.Type:
                            table.column(Expression<String>(name!),unique:uniques.contains(name!))
                        case is Optional<String>.Type:
                            table.column(Expression<String?>(name!),unique:uniques.contains(name!))
                        case is NSNumber.Type, is  ImplicitlyUnwrappedOptional<NSNumber>.Type:
                            if doubles.contains(name!){
                                table.column(Expression<Double>(name!),unique:uniques.contains(name!))
                            }else{
                                table.column(Expression<Int64>(name!),unique:uniques.contains(name!))
                            }
                        case  is Optional<NSNumber>.Type:
                            if doubles.contains(name!){
                                table.column(Expression<Double?>(name!),unique:uniques.contains(name!))
                            }else{
                                table.column(Expression<Int64?>(name!),unique:uniques.contains(name!))
                            }
                        case is Data.Type, is ImplicitlyUnwrappedOptional<Data>.Type:
                            table.column(Expression<Blob>(name!),unique:uniques.contains(name!))
                        case is Optional<Data>.Type:
                            table.column(Expression<Blob?>(name!),unique:uniques.contains(name!))
                        case is Date.Type, is ImplicitlyUnwrappedOptional<Date>.Type:
                            table.column(Expression<Date>(name!),unique:uniques.contains(name!))
                        case is Optional<Date>.Type:
                            table.column(Expression<Date?>(name!),unique:uniques.contains(name!))
                        default:
                            break
                        }
                    }
                }
            }
        }
    }

    // MARK:  执行所指定字段更新，（默认除了id的全部字段）
    func update(needUpdateKeys:[String]? = nil) -> Bool  {
        do {
            if let id = value(forKey: primaryKey()){
                let table = getTable().where(Expression<Int64>(primaryKey()) == (id as! NSNumber).int64Value)
                let rowid = try XMDataBase.conn?.run(table.update(getSetters(needUpdateKeys)))
                if (rowid! > 0) {
                   
                } else {
                   return false
                }
            }else{
               return false
            }
        } catch  {
           
            return false
        }
        return true
    }
    
   
    private func getSetters(_ needUpdateKeys:[String]? = nil) -> [Setter] {
//        let mirror =
        var setters = [Setter]()
        let keys = needUpdateKeys == nil ? getKeys(exceptPriK: true) : needUpdateKeys!
        let doubles = doubleKeys()
        if let mirror = mirror{
            for (name,value) in mirror {
                if keys.contains(name ?? ""){
                    let type = Mirror(reflecting: value).subjectType
                    switch type {
                    case is String.Type, is ImplicitlyUnwrappedOptional<String>.Type:
                        setters.append(Expression<String>(name!) <- value as! String)
                    case is Optional<String>.Type:
                        if let v = value as? String{
                            setters.append(Expression<String>(name!) <- v )
                        }else{
                            setters.append(Expression<String?>(name!) <- nil)
                        }
                    case is NSNumber.Type, is  ImplicitlyUnwrappedOptional<NSNumber>.Type:
                        if doubles.contains(name!){
                            setters.append(Expression<Double>(name!) <- (value as! NSNumber).doubleValue)
                        }else{
                            setters.append(Expression<Int64>(name!) <- (value as! NSNumber).int64Value)
                        }
                    case is Optional<NSNumber>.Type:
                        if let v = value as? NSNumber{
                            if doubles.contains(name!){
                                setters.append(Expression<Double>(name!) <- v.doubleValue)
                            }else{
                                setters.append(Expression<Int64>(name!) <- v.int64Value)
                            }
                        }else{
                             if doubles.contains(name!){
                                setters.append(Expression<Double>(name!) <- 0.0)
                             }else{
                                setters.append(Expression<Int64>(name!) <- 0)
                            }
                        }
                    case is Data.Type, is ImplicitlyUnwrappedOptional<Data>.Type:
                        setters.append(Expression<Blob>(name!) <- Blob(bytes: [UInt8](value as! Data)))
                    case is Optional<Data>.Type:
                        if let v = value as? Data{
                            setters.append(Expression<Blob>(name!) <- Blob(bytes: [UInt8](v)))
                        }else{
                            setters.append(Expression<Blob?>(name!) <- nil)
                        }
                    case is Date.Type, is ImplicitlyUnwrappedOptional<Date>.Type:
                        setters.append(Expression<Date>(name!) <- value as! Date)
                    case is Optional<Date>.Type:
                        if let v = value as? Date{
                            setters.append(Expression<Date>(name!) <- v)
                        }else{
                            setters.append(Expression<Date?>(name!) <- nil)
                        }
                    default:
                        break
                    }
                }
            }
        }
        return setters
    }
    
    //MARK: 添加一条记录
    func add() -> Bool {
        do {
            try XMDataBase.conn?.run(getTableWithColume())
        } catch let e {
             print("XMDBModel --> 创建表失败\(e)")
        }
        
        do {
            try XMDataBase.conn?.run(getTable().insert(getSetters()))
            print("XMDBModel --> 存消息成功")
        } catch  let e {
            
            print("XMDBModel --> 存消息失败\(e)")
            if "\(e)".contains("has no column named"){
                    let column = "\(e)".split(separator: " ")[6]
                let addString = getAddColume(column: column)
                do {
                    if addString.count > 0 {
                        try XMDataBase.conn?.run(addString)
                         print("XMDBModel -->添加字段完成\(column)")
                        _ = add()
                    }
                } catch  {
                     print("XMDBModel -->添加字段失败\(column)")
                }
            }
            return false
        }
        return true
    }
    
    //获取添加字段的语句
    private func getAddColume(column:String.SubSequence)->String{
        var addString = ""
        mirror?.forEach({ (child) in
            if let name = child.label {
                if (name == column) {
                    let type = Mirror(reflecting: child.value).subjectType
                    switch type{
                    case is String.Type, is ImplicitlyUnwrappedOptional<String>.Type,is String?.Type:
                        addString = getTable().addColumn(Expression<String?>(name))
                    case is NSNumber?.Type,is NSNumber.Type, is  ImplicitlyUnwrappedOptional<NSNumber>.Type:
                        if doubleKeys().contains(child.label!){
                            addString = getTable().addColumn(Expression<Double?>(name))
                        }else{
                            addString = getTable().addColumn(Expression<Int64?>(name))
                        }
                    case is Data?.Type,is Data.Type, is ImplicitlyUnwrappedOptional<Data>.Type:
                        addString = getTable().addColumn(Expression<Blob?>(name))
                    case is Date?.Type, is Date.Type, is ImplicitlyUnwrappedOptional<Date>.Type:
                        addString = getTable().addColumn(Expression<Date?>(name))
                    default:
                        print("XMDBModel 未知的字段类型--> \(type)")
                        break
                    }
                }
            }
        })
        return addString
    }
    
    
    //返回排序用到的参数
    private class func orderExpressibles(orders:[String:Bool],mi:Mirror.Children?,doubleKeys:[String]) -> [Expressible] {
//        let model = self.init()
        
//        let mi = model.mirror
//        let doubleKeys = model.doubleKeys()
        
        var expressibles = [Expressible]()
        
        for (key,isAsc) in orders{

            for (name,value) in mi!{
                if (key == name){
                    switch Mirror(reflecting: value).subjectType{
                    case is String.Type,is ImplicitlyUnwrappedOptional<String>.Type:
                        expressibles.append((isAsc ? Expression<String>(key).asc : Expression<String>(key).desc))
                    case is String?.Type:
                        expressibles.append((isAsc ? Expression<String?>(key).asc : Expression<String?>(key).desc))
                        
                    case is NSNumber.Type,is ImplicitlyUnwrappedOptional<NSNumber>.Type:
                        if doubleKeys.contains(key){
                            expressibles.append((isAsc ? Expression<Double>(key).asc : Expression<Double>(key).desc))
                        }else{
                            expressibles.append((isAsc ? Expression<Int64>(key).asc : Expression<Int64>(key).desc))
                        }
                    case is NSNumber?.Type:
                        if doubleKeys.contains(key){
                            expressibles.append((isAsc ? Expression<Double?>(key).asc : Expression<Double?>(key).desc))
                        }else{
                            expressibles.append((isAsc ? Expression<Int64?>(key).asc : Expression<Int64?>(key).desc))
                        }
                    case is Date.Type,is ImplicitlyUnwrappedOptional<Date>.Type:
                        expressibles.append((isAsc ? Expression<Date>(key).asc : Expression<Date>(key).desc))
                    case is Date?.Type:
                        expressibles.append((isAsc ? Expression<Date?>(key).asc : Expression<Date?>(key).desc))
                    default:
                        break
                    }
                }
            }
        }
        return expressibles
    }
    
    
    //MARK: 根据条件查询，Dictionary,根据条件是否 正 排序,limit限制多少，offSet 跳过多少，分页查询使用
    class func query(whereAttAndValue:[String:Any]? = nil, orders:[String:Bool]? = nil,limit:Int = 0, offSet:Int = 0) ->Array<XMDBModel>  {
        
        var results:Array<XMDBModel> = Array<XMDBModel>()
        var table = getTable()
        let m = self.init()
        let doubles = m.doubleKeys()
        
        if let dic = whereAttAndValue{
            for (key,value) in dic{
                switch value {
                case is NSNumber:
                    if doubles.contains(key){
                        table = table.where(Expression<Double>(key) == value as! Double)
                    }else{
                        table = table.where(Expression<Int64>(key) == value as! Int64)
                    }
                case is String:
                    table = table.where(Expression<String>(key) == value as! String)
                case is Date:
                    table = table.where(Expression<Date>(key) == value as! Date)
                default:
                    break
                }
            }
        }
        if let os = orders{
            for ex in orderExpressibles(orders: os, mi: m.mirror, doubleKeys: doubles) {
                table = table.order(ex)
            }
        }
        if (limit != 0) {
            table = table.limit(limit,offset: offSet)
        }
        do {
            if let rows = try XMDataBase.conn?.prepare(table){
                for row in rows{
                    results.append(try rowToModel(row: row))
                }
            }
        } catch let e {
            let error = "\(e)"
            
            if (error.contains("No such column")){
                let column =  error.split(separator: " ")[3].split(separator: "\"")[1]
                let addString = m.getAddColume(column: column)
                
                do {
                    if addString.count > 0 {
                        try XMDataBase.conn?.run(addString)
                        print("XMDBModel -->添加字段完成\(column)")
                        _ = query()
                    }
                } catch  {
                    print("XMDBModel -->添加字段失败\(column)")
                }
            }
            
            
        }
        
        return results
    }
    
    //根据查询的列，返回对象
    private class func rowToModel(row:Row) throws ->XMDBModel{
        let model = self.init()
        let keys = model.getKeys(exceptPriK: false)
        let doubles = model.doubleKeys()
        for (name,value) in model.mirror!{
            if let n = name{
                if keys.contains(n){
                    let type = Mirror(reflecting: value).subjectType
                    switch type{
                    case is String.Type, is ImplicitlyUnwrappedOptional<String>.Type:
            
                        model.setValue(try row.get(Expression<String>(n)), forKey: n)
                    case is String?.Type:
                        if let v = try row.get(Expression<String?>(n)) {
                            model.setValue(v, forKey: n)
                        }else{
                            model.setValue(nil, forKey: n)
                        }
                    case is NSNumber.Type, is  ImplicitlyUnwrappedOptional<NSNumber>.Type:
                        if doubles.contains(n){
                            model.setValue(try row.get(Expression<Double>(n)), forKey: n)
                        }else{
                            model.setValue(try row.get(Expression<Int64>(n)), forKey: n)
                        }
                        
                    case is NSNumber?.Type:
                        if doubles.contains(n){
                            if let v = try row.get(Expression<Double?>(n)) {
                                model.setValue(v, forKey: n)
                            }else{
                                model.setValue(nil, forKey: n)
                            }
                        }else{
                            if let v = try row.get(Expression<Int64?>(n)) {
                                model.setValue(v, forKey: n)
                            }else{
                                model.setValue(nil, forKey: n)
                            }
                        }
                    case is Data.Type, is ImplicitlyUnwrappedOptional<Data>.Type:
                        model.setValue(Data(bytes: (try row.get(Expression<Blob>(n)).bytes)), forKey: n)
                    case is Data?.Type:
                        if let v = try row.get(Expression<Blob?>(n)){
                            model.setValue(Data(bytes: v.bytes), forKey: n)
                        }else{
                            model.setValue(nil, forKey: n)
                        }
                        
                    case is Date.Type,is ImplicitlyUnwrappedOptional<Date>.Type:
                        model.setValue(try row.get(Expression<Date>(n)), forKey: n)
                    case is Date?.Type:
                        if let v = try row.get(Expression<Date?>(n)){
                            model.setValue(v, forKey: n)
                        }else{
                            model.setValue(nil, forKey: n)
                        }
                    default:
                        break
                    }
                }
            }
            
        }
        if (model.primaryKey() == "_id") {
            model.setValue(row[Expression<Int64>("_id")], forKey: "_id")
        }
        return model
    }

    
    
    //MARK: 删除自己
    func delete()  {
        if let id = value(forKey: primaryKey()) {
            do {
               
                if id is NSNumber{
                    try XMDataBase.conn?.run(getTable().where(Expression<Int64>(primaryKey()) == (id as! NSNumber).int64Value).delete())
                }else{
                    try XMDataBase.conn?.run(getTable().where(Expression<Int64>(primaryKey()) == id as! Int64).delete())
                }
            } catch{
                
            }
        }  
    }
}

