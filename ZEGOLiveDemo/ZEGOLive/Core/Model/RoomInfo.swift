//
//  RoomInfo.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by Kael Ding on 2021/12/13.
//

import Foundation

class RoomInfo: NSObject, Codable {
    /// room ID
    var roomID: String?
    var hostID: String?
    var userNum: Int?
    
    enum CodingKeys: String, CodingKey {
        case roomID = "RoomId"
        case userNum = "UserCount"
        case hostID = "HostId"
    }
}

extension RoomInfo: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = RoomInfo()
        copy.roomID = roomID
        copy.userNum = userNum
        return copy
    }
}

