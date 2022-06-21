//
//  RoomListService.swift
//  ZEGOLiveDemo
//
//  Created by Kael Ding on 2021/12/23.
//

import UIKit
import ZegoExpressEngine

class RoomListService: NSObject {
    
    var roomList = Array<RoomInfo>()
    let timer = ZegoTimer(15 * 1000)
    
    // MARK: - Public
    // get room list
    func getRoomList(_ fromRoomID: String?, callback: RoomListCallback?) {
        let request = RoomListRequest()
        RequestManager.shared.getRoomListRequest(request: request) { roomInfoList in
            guard let roomInfoList = roomInfoList else { return }
            self.roomList = roomInfoList.roomInfoArray
            guard let callback = callback else { return }
            callback(.success(roomInfoList.roomInfoArray))
        } failure: { roomInfoList in
            guard let callback = callback else { return }
            callback(.failure(.failed))
        }
    }

}

