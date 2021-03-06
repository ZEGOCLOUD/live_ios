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
        var request = RoomListRequest()
        if let roomID = fromRoomID {
            request.from = roomID
        }
        RequestManager.shared.getRoomListRequest(request: request) { roomInfoList in
            guard let roomInfoList = roomInfoList else { return }
            if request.from.count > 0 {
                self.roomList.append(contentsOf: roomInfoList.roomInfoArray)
            } else {
                self.roomList = roomInfoList.roomInfoArray
            }
            guard let callback = callback else { return }
            callback(.success(roomInfoList.roomInfoArray))
        } failure: { roomInfoList in
            guard let callback = callback else { return }
            callback(.failure(.failed))
        }
    }
    
    func createRoom(_ roomName: String, callback: CreateRoomCallback?) {
        var request = CreateRoomRequest()
        request.name = roomName
        request.hostID = RoomManager.shared.userService.localUserInfo?.userID ?? ""
        
        RequestManager.shared.createRoomRequest(request: request) { status in
            guard let dataDic = status?.data else { return }
            guard let roominfo = ZegoJsonTool.dictionaryToModel(type: RoomInfo.self, dict: dataDic) else { return }
            
            guard let callback = callback else { return }
            callback(.success(roominfo))
        } failure: { requestStatus in
            guard let callback = callback else { return }
            callback(.failure(.failed))
        }
    }
    
    func joinServerRoom(_ roomID: String, callback: RoomCallback?) {
        var request = JoinRoomRequest()
        request.roomID = roomID
        request.userID = RoomManager.shared.userService.localUserInfo?.userID ?? ""
        
        RequestManager.shared.joinRoomRequest(request: request) { requestStatus in
            self.timer.setEventHandler { [weak self] in
                self?.heartBeatRequest()
            }
            self.timer.start()
            guard let callback = callback else { return }
            callback(.success(()))
        } failure: { requestStatus in
            guard let callback = callback else { return }
            callback(.failure(.failed))
        }
    }
    
    func leaveServerRoom(_ roomID: String, callback: RoomCallback?) {
        var request = LeaveRoomRequest()
        request.roomID = roomID
        request.userID = RoomManager.shared.userService.localUserInfo?.userID ?? ""
        RequestManager.shared.leaveRoomRequest(request: request) { requestStatus in
            self.timer.stop()
            guard let callback = callback else { return }
            callback(.success(()))
        } failure: { requestStatus in
            self.timer.stop()
            guard let callback = callback else { return }
            callback(.failure(.failed))
        }
    }
    
    func endServerRoom(_ roomID: String, callback: RoomCallback?) {
        var request = EndRoomRequest()
        request.roomID = roomID
        RequestManager.shared.endRoomRequest(request: request) { status in
            self.timer.stop()
            guard let callback = callback else { return }
            callback(.success(()))
        } failure: { status in
            self.timer.stop()
            guard let callback = callback else { return }
            callback(.failure(.failed))
        }

    }
    
    // MARK: private method
    func heartBeatRequest() {
        var request = HeartBeatRequest()
        request.roomID = RoomManager.shared.roomService.roomInfo.roomID ?? ""
        request.userID = RoomManager.shared.userService.localUserInfo?.userID ?? ""
        request.keepRoom = RoomManager.shared.userService.isMyselfHost
        RequestManager.shared.heartBeatRequest(request: request) { requestStatus in
        } failure: { requestStatus in
        }
    }
}

