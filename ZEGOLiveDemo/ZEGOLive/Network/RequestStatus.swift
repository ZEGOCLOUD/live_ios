//
//  RequestStatus.swift
//  ZEGOLiveDemo
//
//  Created by Larry on 2021/12/27.
//

import Foundation

struct RequestStatus {
    var code = 0
    var message = ""
    var data = Dictionary<String, AnyObject>()
    
    init(json: Dictionary<String, Any>) {
        code = json["Code"] as? Int ?? 0
        message = json["Message"] as? String ?? ""
        data = json["data"] as? Dictionary<String, AnyObject> ?? Dictionary<String, AnyObject>()
    }
}

extension RequestStatus: Decodable {
    static func parse(_ json: Dictionary<String, Any>) -> RequestStatus? {
        return RequestStatus(json: json)
    }
}
