//
//  SoundChangeCell.swift
//  ZEGOLiveDemo
//
//  Created by zego on 2021/12/31.
//

import UIKit

class SoundChangeCell: UICollectionViewCell {
    
    @IBOutlet weak var VoiceImageView: UIImageView!
    @IBOutlet weak var voiceNameLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var soundModel: MusicEffectsModel?
    
    func updateCellWithModel(_ model: MusicEffectsModel) {
        soundModel = model
        voiceNameLabel.text = model.name
        if model.isSelected {
            VoiceImageView.image = UIImage.init(named: model.selectedImageName ?? "")
            voiceNameLabel.textColor = ZegoColor("A653FF")
        } else {
            VoiceImageView.image = UIImage.init(named: model.imageName ?? "")
            voiceNameLabel.textColor = ZegoColor("CCCCCC")
        }
    }

}
