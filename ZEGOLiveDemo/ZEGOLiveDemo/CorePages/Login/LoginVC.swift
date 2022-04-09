//
//  LoginVC.swift
//  ZEGOLiveDemo
//
//  Created by Kael Ding on 2021/12/23.
//

import UIKit

class LoginVC: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userIDTextField: UITextField! {
        didSet {
            let userIDLeftView = UIView(frame: CGRect(x: 0, y: 0, width: 24, height: 49))
            let userIDRightView = UIView(frame: CGRect(x: 0, y: 0, width: 24, height: 49))
            userIDTextField.leftView = userIDLeftView
            userIDTextField.leftViewMode = .always
            userIDTextField.rightView = userIDRightView
            userIDTextField.rightViewMode = .always
            userIDTextField.layer.cornerRadius = 24.5
            let attributed: [NSAttributedString.Key: Any] = [.foregroundColor: ZegoColor("FFFFFF_40")]
            userIDTextField.attributedPlaceholder = NSAttributedString(string: ZGLocalizedString("login_page_user_id"),
                                                                       attributes: attributed)
        }
    }
    @IBOutlet weak var userNameTextField: UITextField! {
        didSet {
            let userNameLeftView = UIView(frame: CGRect(x: 0, y: 0, width: 24, height: 49))
            let userNameRightView = UIView(frame: CGRect(x: 0, y: 0, width: 24, height: 49))
            userNameTextField.leftView = userNameLeftView
            userNameTextField.leftViewMode = .always
            userNameTextField.rightView = userNameRightView
            userNameTextField.rightViewMode = .always
            userNameTextField.layer.cornerRadius = 24.5
            let attributed: [NSAttributedString.Key: Any] = [.foregroundColor: ZegoColor("FFFFFF_40")]
            userNameTextField.attributedPlaceholder = NSAttributedString(string: ZGLocalizedString("login_page_user_name"),
                                                                         attributes: attributed)
            userNameTextField.delegate = self
        }
    }
    @IBOutlet weak var loginButton: UIButton! {
        didSet {
            loginButton.layer.cornerRadius = 24.5
            loginButton.setTitle(ZGLocalizedString("login_page_login"), for: .normal)
            let layer = CAGradientLayer()
            layer.startPoint = CGPoint(x: 0, y: 0)
            layer.endPoint = CGPoint(x: 1, y: 0)
            layer.locations = [NSNumber(value: 0.5), NSNumber(value: 1.0)]
            let startColor = ZegoColor("A754FF")
            let endColor = ZegoColor("510DF1")
            layer.colors = [startColor.cgColor, endColor.cgColor]
            layer.frame = loginButton.bounds
            loginButton.layer.addSublayer(layer)
        }
    }
    
    var myUserID: String = ""
    var myUserName: String = ""
    
    
    // MARK: - lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let a = arc4random_uniform(1000) + 1
        let userId: String = "Apple\(a)"
        myUserID = userId
        myUserName = userId
        userIDTextField.text = userId
        
        configUI()
    }
    
    func configUI() {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let window : UIWindow = UIApplication.shared.windows.first!
        window.endEditing(true)
    }
    
    // MARK: - action
    @IBAction func backItemClick(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func userIDTextFieldDidChanged(_ sender: UITextField) {
        var userId : String = sender.text! as String
        if userId.count > 20 {
            let startIndex = userId.index(userId.startIndex, offsetBy: 0)
            let index = userId.index(userId.startIndex, offsetBy: 19)
            userId = String(userId[startIndex...index])
            sender.text = userId;
        }
        myUserID = userId;
        if userNameTextField.text?.count == 0 {
            myUserName = myUserID
        }
        let buttonColor = myUserID.count > 0 ? UIColor.white : ZegoColor("FFFFFF_40")
        loginButton.setTitleColor(buttonColor, for: .normal)
    }
    
    @IBAction func userNameTextFieldDidChanged(_ sender: UITextField) {
        var userName = sender.text! as String
        if userName.count > 16 {
            let startIndex = userName.index(userName.startIndex, offsetBy: 0)
            let index = userName.index(userName.startIndex, offsetBy: 15)
            userName = String(userName[startIndex...index])
            sender.text = userName
        }
        myUserName = userName
    }
    
    @IBAction func loginButtonClick(_ sender: UIButton) {
        let userInfo = UserInfo(myUserID, myUserName, .participant)
        if userInfo.userName == nil || userInfo.userName?.count == 0 {
            userInfo.userName = userInfo.userID
        }
        
        var errMsg : String = ""
        if userInfo.userID == "" || userInfo.userID == nil {
            errMsg = ZGLocalizedString("toast_userid_login_fail")
        } else if (userInfo.userID?.isUserIdValidated() == false) {
            errMsg = ZGLocalizedString("toast_user_id_error")
        }
        
        if errMsg.count > 0 {
            TipView.showTip(errMsg)
            return
        }
                
        HUDHelper.showNetworkLoading()
        TokenManager.shared.getToken(myUserID, isForceUpdate: true) { result in
            if result.isSuccess {
                let token: String? = result.success
                guard let token = token else {
                    HUDHelper.hideNetworkLoading()
                    print("token is nil")
                    return
                }
                self.startLogin(userInfo, token)
            } else {
                HUDHelper.showMessage(message: "get token fail")
            }
        }
    }
    
    
    @IBAction func popFromSettingsVC(_ segue: UIStoryboardSegue) {
        print("pop from settings vc.")
    }
    
    func startLogin(_ userInfo: UserInfo, _ token: String) {
        RoomManager.shared.userService.login(userInfo, token) { result in
            HUDHelper.hideNetworkLoading()
            switch result {
            case .success:
                let roomListVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RoomListVC")
                self.navigationController?.pushViewController(roomListVC, animated: true)
                break
            case .failure(let error):
                let message = String(format: ZGLocalizedString("toast_login_fail"), error.code)
                TipView.showWarn(message)
                break
            }
        }
    }
    
    
    // MARK: - private method
    func getKeyWindow() -> UIWindow {
        let window: UIWindow = UIApplication.shared.windows.filter({ $0.isKeyWindow }).last!
        return window
    }
}

extension LoginVC : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let proposeLength = (textField.text?.lengthOfBytes(using: .utf8))! - range.length + string.lengthOfBytes(using: .utf8)
        if proposeLength > 32 {
            return false
        }
        return true
    }
}
