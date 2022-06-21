//
//  RoomListVC.swift
//  ZEGOLiveDemo
//
//  Created by Larry on 2021/12/27.
//

import UIKit
import ZIM

class RoomListVC: UIViewController {
    
    var roomInfoList: Array<RoomInfo> {
        return RoomManager.shared.roomListService.roomList
    }
    @IBOutlet weak var roomListCollectionView: UICollectionView! {
        didSet {
            roomListCollectionView.backgroundColor = UIColor.clear
            roomListCollectionView.delegate = self
            roomListCollectionView.dataSource = self
            roomListCollectionView.alwaysBounceVertical = true
            roomListCollectionView.contentInsetAdjustmentBehavior = .never
            roomListCollectionView.refreshControl = refreshControl
        }
    }
    lazy var refreshControl: UIRefreshControl = {
        var refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: ZGLocalizedString("room_list_page_refresh"))
        refreshControl.addTarget(self, action: #selector(refreshRoomList), for: .valueChanged)
        return refreshControl
    }()
    
    @IBOutlet weak var creatButton: UIButton! {
        didSet {
            creatButton.setTitle(ZGLocalizedString("room_list_page_create"), for: .normal)
            creatButton.layer.cornerRadius = 22
            creatButton.clipsToBounds = true
            let layer = CAGradientLayer()
            layer.startPoint = CGPoint(x: 0, y: 0)
            layer.endPoint = CGPoint(x: 1, y: 0)
            layer.locations = [NSNumber(value: 0.5), NSNumber(value: 1.0)]
            let startColor = ZegoColor("A754FF")
            let endColor = ZegoColor("510DF1")
            layer.colors = [startColor.cgColor, endColor.cgColor]
            layer.frame = creatButton.bounds
            // need call this method to load imageView, then inser sublayer
            // or this sublayer will above the imageView's layer
            _ = creatButton.imageView
            creatButton.layer.insertSublayer(layer, at: 0)
        }
    }
    
    @IBOutlet weak var emptyLabel: UILabel! {
        didSet {
            emptyLabel.text = ZGLocalizedString("room_list_page_none")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        RoomManager.shared.userService.addUserServiceDelegate(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        self.refreshRoomList()
    }
    
    // MARK: action
    @objc func refreshRoomList() {
        RoomManager.shared.roomListService.getRoomList(nil) { result in
            switch result {
            case .success(_):
                self.emptyLabel.isHidden = self.roomInfoList.count > 0
                self.roomListCollectionView.reloadData()
            case .failure(_):
                break
            }
            self.refreshControl.endRefreshing()
        }
    }
    
    
    @IBAction func backItemClick(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
        RoomManager.shared.userService.logout()
    }
    
    // MARK: private method
    func joinLiveRoom() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LiveRoomVC") as! LiveRoomVC
        vc.isLiving = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // reset the device data before create room.
        RoomManager.shared.deviceService.reset()
    }
}

extension RoomListVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let num = Int(ceil(Double(self.roomInfoList.count) / 2.0))
        return num
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section > self.roomInfoList.count / 2 - 1 {
            return 2 - self.roomInfoList.count % 2;
        }
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RoomListViewCell", for: indexPath) as? RoomListViewCell else {
            return RoomListViewCell()
        }
        let index = indexPath.section * 2 + indexPath.row
        if roomInfoList.count > index {
            let roomInfo = roomInfoList[index]
            cell.updateCellWithRoomInfo(roomInfo)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? RoomListViewCell  else { return }
        guard let roomInfo = cell.roomInfo else { return }
        guard let roomID = roomInfo.roomID else { return }
        
        guard let userID = RoomManager.shared.userService.localUserInfo?.userID else { return }
        TokenManager.shared.getToken(userID) { result in
            if result.isSuccess {
                let rtcToken: String? = result.success
                guard let rtcToken = rtcToken else {
                    print("token is nil")
                    HUDHelper.hideNetworkLoading()
                    return
                }
                RoomManager.shared.roomService.joinRoom(roomID, rtcToken) { result in
                    switch result {
                    case .success:
                        self.joinLiveRoom()
                    case .failure(let error):
                        let message = String(format: ZGLocalizedString("toast_join_room_fail"), error.code)
                        TipView.showWarn(message)
                    }
                }
            } else {
                HUDHelper.showMessage(message: "get token fail")
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 13
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 13, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 16 * 2 - 13) / 2.0
        return CGSize(width: width, height: width)
    }
}

extension RoomListVC : UserServiceDelegate {    
    func connectionStateChanged(_ state: ZIMConnectionState, _ event: ZIMConnectionEvent) {
        guard let nav = self.navigationController else { return }
        for vc in nav.children {
            if vc is LiveRoomVC { return }
        }
        if (state == .disconnected) {
            let message: String = event == .kickedOut ? ZGLocalizedString("toast_kickout_error") : ZGLocalizedString("toast_disconnect_tips")
            TipView.showTip(message)
            logout()
        }
    }
    
    
    private func logout() {
        RoomManager.shared.userService.logout()
        guard let nav = self.navigationController else {
            self.navigationController?.popToRootViewController(animated: true)
            return
        }
        for vc in nav.children {
            if vc is LoginVC {
                self.navigationController?.popToViewController(vc, animated: true)
                return
            }
        }
        self.navigationController?.popToRootViewController(animated: true)
    }
}
