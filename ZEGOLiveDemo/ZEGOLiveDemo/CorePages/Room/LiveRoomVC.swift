//
//  LiveRoomVC.swift
//  ZEGOLiveDemo
//
//  Created by Kael Ding on 2021/12/28.
//

import UIKit
import ZegoExpressEngine
import ZIM

class LiveRoomVC: UIViewController {

    @IBOutlet weak var streamView: UIView!
    
    @IBOutlet weak var backgroundView: UIView! {
        didSet {
            backgroundView.isHidden = true
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var blurHeadImageView: UIImageView!
    @IBOutlet weak var headImageView: UIImageView! {
        didSet {
            headImageView.layer.cornerRadius = 50.0
        }
    }
    
    var readyView: LiveReadyView?
    @IBOutlet weak var readyContainer: UIView! {
        didSet {
            if let readyView = UINib(nibName: "LiveReadyView", bundle: nil).instantiate(withOwner: nil, options: nil).first as? LiveReadyView {
                readyView.frame = readyContainer.bounds
                readyContainer.addSubview(readyView)
                self.readyView = readyView
                readyView.delegate = self
            }
        }
    }
    
    var bottomView: LiveBottomView?
    @IBOutlet weak var bottomContainer: UIView! {
        didSet {
            bottomContainer?.backgroundColor = UIColor.clear
            if let bottomView = UINib(nibName: "LiveBottomView", bundle: nil).instantiate(withOwner: nil, options: nil).first as? LiveBottomView {
                bottomView.frame = bottomContainer.bounds
                bottomContainer.addSubview(bottomView)
                self.bottomView = bottomView
                bottomView.delegate = self
            }
        }
    }
    
    var topView: LiveTopView?
    @IBOutlet weak var topContainer: UIView! {
        didSet {
            topContainer.backgroundColor = UIColor.clear
            if let topView = UINib(nibName: "LiveTopView", bundle: nil).instantiate(withOwner: nil, options: nil).first as? LiveTopView {
                topView.frame = topContainer.bounds
                topContainer.addSubview(topView)
                self.topView = topView
                topView.delegate = self
            }
        }
    }
    
    lazy var faceBeautifyView: FaceBeautifyView = {
        let beautifyView = UINib(nibName: "FaceBeaytifyView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! FaceBeautifyView
        beautifyView.frame = self.view.bounds
        beautifyView.isHidden = true
        beautifyView.delegate = self
        self.view.addSubview(beautifyView)
        return beautifyView
    }()
    
    lazy var musicEffectsVC : MusicEffectsVC = {
        let vc: MusicEffectsVC = MusicEffectsVC(nibName :"MusicEffectsVC",bundle : nil)
        vc.view.frame = CGRect.init(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
        vc.view.isHidden = true
        self.addChild(vc)
        self.view.addSubview(vc.view)
        return vc
    }()
    
    lazy var liveSettingView : LiveSettingView? = {
        if let view: LiveSettingView = UINib.init(nibName: "LiveSettingView", bundle: nil).instantiate(withOwner: nil, options: nil).first as? LiveSettingView {
            view.setViewType(.nomal)
            view.frame = CGRect.init(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
            view.isHidden = true
            view.delegate = self
            self.view.addSubview(view)
            return view
        }
        return nil
    }()
    
    lazy var LivingSettingView : LiveSettingView? = {
        if let view: LiveSettingView = UINib.init(nibName: "LiveSettingView", bundle: nil).instantiate(withOwner: nil, options: nil).first as? LiveSettingView {
            view.setViewType(.less)
            view.frame = CGRect.init(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
            view.isHidden = true
            view.delegate = self
            self.view.addSubview(view)
            return view
        }
        return nil
    }()
    
    lazy var resolutionView: LiveSettingSecondView? = {
        if let view: LiveSettingSecondView = UINib(nibName: "LiveSettingSecondView", bundle: nil).instantiate(withOwner: nil, options: nil).first as? LiveSettingSecondView {
            view.setShowDataSourceType(.resolution)
            view.frame = self.view.bounds
            view.isHidden = true
            view.delegate = self
            self.view.addSubview(view)
            return view
        }
        return nil
    }()
    
    lazy var bitrateView: LiveSettingSecondView? = {
        if let view: LiveSettingSecondView = UINib(nibName: "LiveSettingSecondView", bundle: nil).instantiate(withOwner: nil, options: nil).first as? LiveSettingSecondView {
            view.setShowDataSourceType(.audio)
            view.frame = self.view.bounds
            view.isHidden = true
            view.delegate = self
            self.view.addSubview(view)
            return view
        }
        return nil
    }()
    
    lazy var encodingView: LiveSettingSecondView? = {
        if let view: LiveSettingSecondView = UINib(nibName: "LiveSettingSecondView", bundle: nil).instantiate(withOwner: nil, options: nil).first as? LiveSettingSecondView {
            view.setShowDataSourceType(.encoding)
            view.frame = self.view.bounds
            view.isHidden = true
            view.delegate = self
            self.view.addSubview(view)
            return view
        }
        return nil
    }()
    
    lazy var participantListView: ParticipantListView = {
        guard let participantListView = UINib(nibName: "ParticipantListView", bundle: nil).instantiate(withOwner: nil, options: nil).first as? ParticipantListView else {
            return ParticipantListView()
        }
        participantListView.frame = self.view.bounds
        participantListView.isHidden = true
        self.view.addSubview(participantListView)
        participantListView.delegate = self
        return participantListView
    }()
    
    lazy var moreSettingView: MoreSettingView = {
        let view: MoreSettingView = UINib(nibName: "MoreSettingView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! MoreSettingView
        view.frame = self.view.bounds
        view.isHidden = true
        view.delegate = self
        self.view.addSubview(view)
        return view
    }()
    
    var isLiving: Bool = false
    
    @IBOutlet weak var messageView: MessageView!
    
    @IBOutlet weak var messageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var coHostViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var coHostCollectionView: UICollectionView! {
        didSet {
            coHostCollectionView.backgroundColor = UIColor.clear
            coHostCollectionView.register(UINib(nibName: "CoHostCell", bundle: nil), forCellWithReuseIdentifier: "CoHostCell")
        }
    }
    
    
    var messageList: [MessageModel] = []
    var isFrontCamera: Bool = true
    
    lazy var inputTextView: InputTextView = {
        let textView: InputTextView = UINib(nibName: "InputTextView", bundle: nil).instantiate(withOwner: self, options: nil).last as! InputTextView
        textView.frame = CGRect(x: 0, y: self.view.bounds.size.height, width: self.view.bounds.size.width, height: 55)
        textView.delegate = self
        return textView
    }()
    
    let micCameraTimer: ZegoTimer = ZegoTimer(500)
    let requestTimer: ZegoTimer = ZegoTimer(30 * 1000, startNow: false)
    
    let coHostTask: CoHostTaskQueue = CoHostTaskQueue()
    
    deinit {
        
    }
    
    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addDelegates()
        addObserver()

        // Do any additional setup after loading the view.
        configUI()
        configVideoStream()
        configFaceBeautify()
        updateHostBackgroundView()
                
        // update room attributes
        if isLiving {
            addLocalJoinMessage()
            reloadCoHost()
            updateBottomView()
            reloadParticipantListView()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.presentedViewController != nil {
            self.dismiss(animated: true, completion: nil)
        }
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let window : UIWindow = UIApplication.shared.windows.first!
        window.endEditing(true)
    }
    
    // MARK: - private method
    func addObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardDidShow(node:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardDidHide(node:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func addDelegates() {
        RoomManager.shared.messageService.delegate = self
        RoomManager.shared.roomService.delegate = self
        RoomManager.shared.userService.addUserServiceDelegate(self)
    }
    
    func configUI() {
        self.view.addSubview(inputTextView)
        navigationController?.navigationBar.isHidden = true
        readyContainer.isHidden = isLiving
        topContainer.isHidden = !isLiving
        bottomContainer.isHidden = !isLiving
        messageView.isHidden = !isLiving
        coHostCollectionView.isHidden = !isLiving
        self.updateTopView()
    }
     
    func configVideoStream() {
        if !isLiving {
            RoomManager.shared.deviceService.playVideoStream(localUserID, view: streamView)
            RoomManager.shared.deviceService.useFrontCamera(isFrontCamera)
            RoomManager.shared.deviceService.enableCamera(true)
        }
    }
        
    func updateHostBackgroundView() {
        if !isLiving { return }
        let hostID = getHostID()
        guard let coHost = getCoHost(hostID) else {
            self.backgroundView.isHidden = false
            return
        }
        self.backgroundView.isHidden = coHost.camera
        
        let host = getUser(hostID)
        if let userName = host?.userName {
            self.nameLabel.text = userName
            let image = UIImage(named: String.getHeadImageName(userName: userName))
            self.headImageView.image = image
            self.blurHeadImageView.image = UIImage.getBlurImage(image)
        }
    }
}

extension LiveRoomVC : RoomServiceDelegate {
    func receiveRoomInfoUpdate(_ info: RoomInfo?) {
        
        if info == nil {
            receiveRoomEnded()
        }
    }
    
    func receiveRoomEnded() {
        leaveRoom(false)
        let alert = UIAlertController(title: ZGLocalizedString("dialog_attetion_title"),
                                      message: ZGLocalizedString("toast_room_has_destroyed"),
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: ZGLocalizedString("dialog_close"), style: .default) { action in
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func onRoomTokenWillExpire(_ remainTimeInSecond: Int32, roomID: String?) {
        TokenManager.shared.getToken(localUserID, isForceUpdate: true) { result in
            if result.isSuccess {
                let token: String? = result.success
                guard let token = token else { return }
                RoomManager.shared.roomService.renewToken(token, roomID: roomID)
            } else {
                HUDHelper.showMessage(message: "renew token fail")
            }
        }
    }
}
