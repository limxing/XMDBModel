# XMDBModel
基于SQLite.swift的数据库orm增删改查

```
/*
XMDBModel Type         SQLite.swift Type      SQLite Type
NSNumber                 Int64(Int,Bool)         INTEGER
NSNumber                    Double                  REAL
String                      String                  TEXT
nil                         nil                     NULL
Data                      SQLite.Blob               BLOB
Date                      Int64 (Date)             INTEGER
*/
```
### How To Use
1、copy Source to your project

2、add depend library：pod 'SQLite.swift', '~> 0.11.4'

3、creat Model imp：XMDBModel

4、API ：demo中XMBean中有属性方法介绍，ViewController中有增删改查使用方法


### 参考：
    <a src="https://github.com/KevinZhouRafael/ActiveSQLite">ActiveSQLite</a>
### License
    XMDBModel is available under the MIT license.



