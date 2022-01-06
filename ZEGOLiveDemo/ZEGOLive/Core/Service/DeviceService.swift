//
//  DeviceService.swift
//  ZEGOLiveDemo
//
//  Created by zego on 2022/1/6.
//

import UIKit
import ZegoExpressEngine


enum RTCVideoPreset: Int {
    case p1080
    case p720
    case p540
    case p360
    case p270
    case p180
}

enum RTCAudioBitrate: Int {
    case b16
    case b48
    case b56
    case b128
    case b192
}

enum RTCVideoCode: Int {
    case h264
    case h265
}

class DeviceService: NSObject {

    var videoPreset: RTCVideoPreset = .p720
    var audioBitrate: RTCAudioBitrate = .b48
    var videoCodeID: RTCVideoCode = .h264
    var layerCoding: Bool = false
    var hardwareCoding: Bool = false
    var hardwareDecoding: Bool = false
    var noiseRedution: Bool = false
    var echo: Bool = false
    var micVolume: Bool = false
    
    func setVideoPreset(_ preset: RTCVideoPreset) -> Void {
        videoPreset = preset
        var expressVideoPreset: ZegoVideoConfigPreset = .preset720P
        switch preset {
        case .p1080:
            expressVideoPreset = .preset1080P
        case .p720:
            expressVideoPreset = .preset720P
        case .p540:
            expressVideoPreset = .preset540P
        case .p360:
            expressVideoPreset = .preset360P
        case .p270:
            expressVideoPreset = .preset270P
        case .p180:
            expressVideoPreset = .preset180P
        }
        let videoConfig: ZegoVideoConfig = ZegoVideoConfig.init(preset: expressVideoPreset)
        ZegoExpressEngine.shared().setVideoConfig(videoConfig)
    }
    
    func setAudioBitrate(_ bitrate: RTCAudioBitrate) -> Void {
        audioBitrate = bitrate
        var expressAudioPreset: ZegoAudioConfigPreset = .standardQuality
        switch bitrate {
        case .b16:
            expressAudioPreset = .basicQuality
        case .b48:
            expressAudioPreset = .standardQuality
        case .b56:
            expressAudioPreset = .standardQualityStereo
        case .b128:
            expressAudioPreset = .highQuality
        case .b192:
            expressAudioPreset = .highQualityStereo
        }
        let audioConfig: ZegoAudioConfig = ZegoAudioConfig.init(preset: expressAudioPreset)
        ZegoExpressEngine.shared().setAudioConfig(audioConfig)
    }
    
    func setVideoCodeID(_ ID: RTCVideoCode) -> Void {
        videoCodeID = ID
        var expressCodeID: ZegoVideoCodecID = .idDefault
        switch ID {
        case .h264:
            expressCodeID = .idDefault
        case .h265:
            expressCodeID = .IDH265
        }
        ZegoExpressEngine.shared().isVideoDecoderSupported(expressCodeID)
    }
    
    func setLiveDeviceStatus(_ statusType: SettingSelectionType, enable: Bool) {
        switch statusType {
        case .encoding:
            return
        case .layered:
            return
        case .hardware:
            return
        case .decoding:
            return
        case .noise:
            return
        case .echo:
            return
        case .volume:
            return
        case .resolution:
            return
        case .bitrate:
            return
        }
    }
    
}