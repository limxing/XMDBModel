//
//  ViewController.swift
//  XMDBModel
//
//  Created by 李利锋 on 2018/2/5.
//  Copyright © 2018年 leefeng. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
//        let xmbean = XMBean()
//        xmbean.payload = "save payload"
//        xmbean.isSend = false
//        xmbean.timestamp = 111111111
//        xmbean.toAccount = "aaaaaaaa"
//        
//        print(xmbean.add())//增
        XMBean.query().forEach { (model) in//全部查询
            let xm = model as! XMBean
            print(xm.toJSONString(prettyPrint: true)!)
        }
        print("条件查询===========")//whereAttAndValue:条件查询，orders：排序条件，limit：个数限制，offSet：跳过前几个，一般用于分页
        XMBean.query(whereAttAndValue: ["toAccount":"aaaaaaaa"], orders: ["_id":false], limit: 2, offSet: 0).forEach { (model) in
            let xm = model as! XMBean
            print(xm.toJSONString(prettyPrint: true)!)
            //删除需要删查出来的model
            if (xm._id == 2){
                xm.delete()
            }
            //修改
            if (xm._id == 3){
                xm.payload = "这是修改了的，默认都是aaaaaa"
//                xm.update()//会全字段修改
                xm.update(needUpdateKeys: ["payload"])//指定字段修改
            }
        }
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

