//
//  RequestMananger.swift
//  ZEGOLiveDemo
//
//  Created by Larry on 2021/12/27.
//

import Foundation
struct RequestManager {
    static let shared: RequestManager = RequestManager()
    
    //  get room list
    func getRoomListRequest(request: RoomListRequest, success:@escaping(RoomInfoList?)->(), failure:@escaping(_ roomInfoList: RoomInfoList?)->()){
        NetworkManager.shareManage.send(request){ roomInfoList in
            if roomInfoList?.requestStatus.code == 0 {
                success(roomInfoList)
            } else {
                failure(roomInfoList)
            }
        }
    }

}








