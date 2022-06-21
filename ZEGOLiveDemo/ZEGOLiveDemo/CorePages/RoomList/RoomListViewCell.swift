//
//  RoomListViewCell.swift
//  ZEGOLiveDemo
//
//  Created by Larry on 2021/12/28.
//

import UIKit

class RoomListViewCell: UICollectionViewCell {
    
    @IBOutlet weak var backgroudImage: UIImageView!
    
    @IBOutlet weak var participantNumLabel: UILabel!
    
    @IBOutlet weak var roomNameLabel: UILabel!
    
    var roomInfo: RoomInfo?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 12.0
    }
    
    func updateCellWithRoomInfo(_ roomInfo: RoomInfo) {
        self.roomInfo = roomInfo
        roomNameLabel.text = roomInfo.roomID
        participantNumLabel.text = String(roomInfo.userNum ?? 0)
        let imageName = String.getRoomCoverImageName(roomName: roomInfo.roomID ?? "")
        backgroudImage.image = UIImage(named: imageName)
    }
}
