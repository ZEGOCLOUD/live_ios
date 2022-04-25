//
//  ZegoZIMManager.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by Kael Ding on 2021/12/13.
//

import Foundation
import ZIM

/// Class ZIM SDK management
///
/// Description: This class contains and manages the ZIM SDK instance objects, so that
class ZIMManager {
    
    /// Get the ZegoZIMManager singleton instance
    ///
    /// Description: This method can be used to get the ZegoZIMManager singleton instance.
    ///
    /// Call this method at: When you need to use the ZegoZIMManager singleton instance
    ///
    /// @return ZegoZIMManager singleton instance
    static let shared = ZIMManager()
    private init() {}
    
    /// ZIM SDK instance objects
    fileprivate(set) var zim: ZIM?
    
    /// Description: You need to call this method to initialize the ZIM SDK first before you log in, create a room, join a room, send messages and other operations with ZIM SDK. This method need to be used in conjunction with the [destroyZIM] method, which is to make sure that the current process is running only one ZIM SDK instance.
    ///
    /// Call this method at: Before you calling the ZIM SDK methods. We recommend you call this method when the application starts.
    ///
    /// @param appID refers to the ID of your project. To get this, go to ZEGOCLOUD Admin Console: https://console.zegocloud.com/dashboard?lang=en
    func createZIM(appID: UInt32) {
        zim = ZIM.create(withAppID: appID)
    }
    
    /// Destroy the ZIM SDK instance
    ///
    /// Description: This method can be used to destroy the ZIM SDK instance and release the resources it occupies.
    ///
    /// Call this method at: When the ZIM SDK is no longer be used. We recommend you call this method when the application exits.
    func destoryZIM() {
        zim?.destroy()
        zim = nil
    }
}
