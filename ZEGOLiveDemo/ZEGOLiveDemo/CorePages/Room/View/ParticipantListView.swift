//
//  ParticipantListView.swift
//  ZEGOLiveDemo
//
//  Created by Larry on 2022/1/5.
//

import UIKit

protocol ParticipantListViewDelegate: AnyObject {
    func invitedUserAddCoHost(userInfo:UserInfo)
}

class ParticipantListView: UIView {
    weak var delegate: ParticipantListViewDelegate?
    @IBOutlet weak var backgroudView: UIView!
    
    @IBOutlet weak var lineView: UIView! {
        didSet {
            lineView.layer.cornerRadius = 2.5
        }
    }
    
    @IBOutlet weak var onlineLabel: UILabel!
    @IBOutlet weak var paticipantTableView: UITableView! {
        didSet {
            paticipantTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
            paticipantTableView.delegate = self
            paticipantTableView.dataSource = self
            paticipantTableView.backgroundColor = UIColor.clear
            paticipantTableView.register(UINib(nibName: "ParticipantTableViewCell", bundle: nil), forCellReuseIdentifier: "ParticipantTableViewCell")
        }
    }
    
    @IBOutlet weak var inviteMaskView: UIView! {
        didSet {
            let inviteMaskTap:UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(inviteMaskTapClick))
            inviteMaskView.addGestureRecognizer(inviteMaskTap)
        }
    }
    
    @IBOutlet weak var inviteButton: UIButton! {
        didSet {
            inviteButton.layer.cornerRadius = 24.5
            inviteButton.clipsToBounds = true
            let layer = CAGradientLayer()
            layer.startPoint = CGPoint(x: 0, y: 0)
            layer.endPoint = CGPoint(x: 1, y: 0)
            layer.locations = [NSNumber(value: 0.5), NSNumber(value: 1.0)]
            let startColor = ZegoColor("A754FF")
            let endColor = ZegoColor("510DF1")
            layer.colors = [startColor.cgColor, endColor.cgColor]
            layer.frame = inviteButton.bounds
            inviteButton.layer.insertSublayer(layer, at: 0)
            inviteButton.setTitle(ZGLocalizedString("user_list_page_invite_to_speak"), for: .normal)
        }
    }
    
    var inviteUserInfo: UserInfo?
    
    var dataSource: [UserInfo] = []
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard let touch = touches.first else { return }
        let point = touch.location(in: backgroudView)
        if backgroudView.point(inside: point, with: event) { return }
        self.isHidden = true
    }
    
    func reloadListView(_ dataSource: [UserInfo]) {
        self.dataSource = dataSource
        self.onlineLabel.text = String(format: ZGLocalizedString("user_list_page_participants_num"), dataSource.count)
        paticipantTableView.reloadData()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @objc func inviteMaskTapClick() {
        self.inviteMaskView.isHidden = true
    }
        
    // MARK: -action
    @IBAction func pressInviteButton(_ sender: UIButton) {
        guard let inviteUserInfo = inviteUserInfo else { return }
        delegate?.invitedUserAddCoHost(userInfo: inviteUserInfo)
    }
}

extension ParticipantListView: ParticipantTableViewCellDelegate {
    func ParticipantTableViewCellDidSelectedMoreAction(cell: ParticipantTableViewCell) {
        guard let userInfo = cell.userInfo else { return }
        inviteUserInfo = userInfo
        inviteMaskView.isHidden = false
    }
}

extension ParticipantListView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:ParticipantTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "ParticipantTableViewCell", for: indexPath) as? ParticipantTableViewCell
        if cell == nil {
            cell = ParticipantTableViewCell(style: .default, reuseIdentifier: "ParticipantTableViewCell")
        }
        cell?.delegate = self
        if indexPath.row < dataSource.count {
            let roomUser = dataSource[indexPath.row]
            let isHost = RoomManager.shared.userService.localUserInfo?.userID == RoomManager.shared.roomService.roomInfo.hostID
            cell?.setRoomUser(user: roomUser, isHost: isHost)
        }
        return cell ?? ParticipantTableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 56.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
}
