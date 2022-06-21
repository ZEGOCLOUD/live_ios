//
//  RoomListRequest.swift
//  ZEGOLiveDemo
//
//  Created by Larry on 2021/12/27.
//

import Foundation
import UIKit


struct RoomListRequest: Request {
    var host = ""
    var path = "/describe_room_list"
    
    var method: HTTPMethod = .GET
    typealias Response = RoomInfoList
    var parameter = Dictionary<String, AnyObject>()
    
    var pageNum = 100 {
        willSet {
            parameter["PageSize"] = newValue as AnyObject
        }
    }
    var from = 1 {
        willSet {
            parameter["PageIndex"] = newValue as AnyObject
        }
    }
    init() {
        parameter["PageSize"] = 100 as AnyObject
        parameter["PageIndex"] = 1 as AnyObject
        parameter["host"] = host as AnyObject
        assert(host.isEmpty==false, "you need set your room list host url, see https://github.com/ZEGOCLOUD/room_list_server_nodejs")
        
    
    }
}
