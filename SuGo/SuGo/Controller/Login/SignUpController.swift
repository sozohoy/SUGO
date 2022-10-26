//
//  SignUpController.swift
//  SuGo
//
//  Created by 한지석 on 2022/10/10.
//

import UIKit

import Alamofire
import SwiftyJSON

// 회원가입 로직
// 1. 아이디 형식 확인 및 중복확인
// 2. 비밀번호 형식 확인
// 3. 2차 비밀번호 일치 판별
// 4. 이메일 중복 확인
// 5. 완료와 동시에 인증메일 전송
// 텍스트 변경을 실시간으로 확인해주어야 함. 예를 들어 이메일 중복확인 이후 텍스트가 변경되는 경우를 캐치 해야 함.


class SignUpController: UIViewController {

    //MARK: IBOutlets
    
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var idBox: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordBox: UIView!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordBox: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailBox: UIView!
    @IBOutlet weak var idWarningLabel: UILabel!
    @IBOutlet weak var passwordWarningLabel: UILabel!
    @IBOutlet weak var confirmPasswordWarningLabel: UILabel!
    @IBOutlet weak var emailWarningLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    //MARK: Properties
    
    let loginModel = LoginModel()
    var loginIsValid = false
    var keyboardTouchCheck = false
    var emailTouch = false
    let colorLiteralGreen = #colorLiteral(red: 0.2208407819, green: 0.6479891539, blue: 0.4334517121, alpha: 1)
    let userInfo = UserInfo.shared
    
    //MARK: Functions
    
    override func viewDidLoad() {
        
        designBox()
        designLabel()
        
        super.viewDidLoad()
        
        textFieldAddTargets()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillAppear),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
        
    }
    
    private func textFieldAddTargets() {
        
        // email add targets
        emailTextField.addTarget(self,
                                 action: #selector(emailTextFieldEditingChanged),
                                 for: .touchDown)
        emailTextField.addTarget(self,
                                 action: #selector(emailTextFieldEditingChanged),
                                 for: .editingChanged)
        emailTextField.addTarget(self,
                                 action: #selector(emailTextFieldisValid),
                                 for: .editingDidEnd)
        
        // id add targets
        idTextField.addTarget(self,
                              action: #selector(idTextFieldEditingChanged),
                              for: .touchDown)
        idTextField.addTarget(self,
                              action: #selector(idTextFieldEditingChanged),
                              for: .editingChanged)
        idTextField.addTarget(self,
                              action: #selector(idTextFieldisValid),
                              for: .editingDidEnd)
        
        // password add targets
        passwordTextField.addTarget(self,
                                    action: #selector(passwordTextFieldEditingChanged),
                                    for: .touchDown)
        passwordTextField.addTarget(self,
                                    action: #selector(passwordTextFieldEditingChanged),
                                    for: .editingChanged)
        passwordTextField.addTarget(self,
                                    action: #selector(passwordTextFieldisValid),
                                    for: .editingDidEnd)
        
        // confirm add targets
        confirmPasswordTextField.addTarget(self,
                                           action: #selector(confirmPasswordTextFieldEditingChanged),
                                           for: .touchDown)
        confirmPasswordTextField.addTarget(self,
                                           action: #selector(confirmPasswordTextFieldEditingChanged),
                                           for: .editingChanged)
        confirmPasswordTextField.addTarget(self,
                                           action: #selector(confirmPasswordTextFieldisValid),
                                           for: .editingDidEnd)
    }
    
    // 기존 입력마다 형식 알려주던 방식 대신, endEditing 이후 유효성 검사하는 방식으로 전환
    
    @objc func emailTextFieldEditingChanged(_ sender: UITextField) {
        
        emailTouch = true
        
        emailBox.layer.borderColor = colorLiteralGreen.cgColor
        idBox.layer.borderColor = UIColor.lightGray.cgColor
        passwordBox.layer.borderColor = UIColor.lightGray.cgColor
        confirmPasswordBox.layer.borderColor = UIColor.lightGray.cgColor
        
    }
    

    @objc func emailTextFieldisValid(_ sender: UITextField) {
        
        emailTouch = false
        emailWarningLabel.isHidden = false
        
        guard let email = emailTextField.text, !email.isEmpty else { return }
        
        if loginModel.isValidEmail(email: email) {
            
            emailOverlapCheck(email: email + "@suwon.ac.kr")
            
        } else {
            
            warningText(label: emailWarningLabel,
                        box: emailBox,
                        text: "이메일 형식이 올바르지 않아요.",
                        textColor: UIColor.red,
                        borderColor: UIColor.red.cgColor)
            
        }
        
}
    
    @objc func idTextFieldEditingChanged(_ sender: UITextField) {
        
        emailBox.layer.borderColor = UIColor.lightGray.cgColor
        idBox.layer.borderColor = colorLiteralGreen.cgColor
        passwordBox.layer.borderColor = UIColor.lightGray.cgColor
        confirmPasswordBox.layer.borderColor = UIColor.lightGray.cgColor
        
    }
    
    @objc func idTextFieldisValid(_ sender: UITextField) { // id 정규표현식 확인
        
        idWarningLabel.isHidden = false
        
        guard let id = idTextField.text, !id.isEmpty else { return }
        
        //1. 아이디 형식 체크 후 일치하지 않을 경우 경고문 ON
        if loginModel.isValidId(id: id) {
            
            idOverlapCheck(id: id)
            
        } else {
            
            warningText(label: idWarningLabel,
                        box: idBox,
                        text: "영문/숫자를 사용한 5~20자 아이디를 사용해주세요.",
                        textColor: UIColor.red,
                        borderColor: UIColor.red.cgColor)
            
        }
    }
    
    @objc func test(_ sender: UITextField) {
        print("입력 완료")
    }
    
    @objc func passwordTextFieldEditingChanged(_ sender: UITextField) {
        
        emailBox.layer.borderColor = UIColor.lightGray.cgColor
        idBox.layer.borderColor = UIColor.lightGray.cgColor
        passwordBox.layer.borderColor = colorLiteralGreen.cgColor
        confirmPasswordBox.layer.borderColor = UIColor.lightGray.cgColor
        
    }
    
    @objc func passwordTextFieldisValid(_ sender: UITextField) { // password 정규표현식
        
        passwordWarningLabel.isHidden = false
        
        guard let password = passwordTextField.text, !password.isEmpty else { return }
        
        // 정규표현식
        
        if loginModel.isValidPassword(pwd: password) {
            
            warningText(label: passwordWarningLabel,
                        box: passwordBox,
                        text: "사용 가능한 비밀번호에요!",
                        textColor: colorLiteralGreen,
                        borderColor: colorLiteralGreen.cgColor)
            
        } else {
            
//            passwordBox.layer.borderColor = UIColor.red.cgColor
            warningText(label: passwordWarningLabel,
                        box: passwordBox,
                        text: "영문/숫자/특수문자를 조합한 8~20자 비밀번호를 사용해주세요.",
                        textColor: UIColor.red,
                        borderColor: UIColor.red.cgColor)
        
        }
        
        if confirmPasswordTextField.text?.count ?? 0 > 0 && password != confirmPasswordTextField.text {
            // 2차 비밀번호 불일치 출력
            warningText(label: confirmPasswordWarningLabel,
                        box: confirmPasswordBox,
                        text: "비밀번호가 일치하지 않아요.",
                        textColor: UIColor.red,
                        borderColor: UIColor.red.cgColor)
            print("print : 2차 비밀번호까지 입력 후 1차 비밀번호 변경 시 불일치")
            
        }
        
    }
    
    @objc func confirmPasswordTextFieldEditingChanged(_ sender: UITextField) {
        
        emailBox.layer.borderColor = UIColor.lightGray.cgColor
        idBox.layer.borderColor = UIColor.lightGray.cgColor
        passwordBox.layer.borderColor = UIColor.lightGray.cgColor
        confirmPasswordBox.layer.borderColor = colorLiteralGreen.cgColor
        
    }
    
    @objc func confirmPasswordTextFieldisValid(_ sender: UITextField) {
        
        confirmPasswordWarningLabel.isHidden = false
        
        guard let password = confirmPasswordTextField.text, !password.isEmpty else { return }

        if password == passwordTextField.text { // 비밀번호 일치
            
            warningText(label: confirmPasswordWarningLabel,
                        box: confirmPasswordBox,
                        text: "비밀번호가 일치해요!",
                        textColor: colorLiteralGreen,
                        borderColor: colorLiteralGreen.cgColor)
            print("비밀번호 일치")
            
        } else { // 비밀번호 불일치
            
            warningText(label: confirmPasswordWarningLabel,
                        box: confirmPasswordBox,
                        text: "비밀번호가 일치하지 않아요.",
                        textColor: UIColor.red,
                        borderColor: UIColor.red.cgColor)
            print("print : 정규표현식 불일치, 비밀번호 불일치")
            
        }
        
    }
    
   
    
    @objc func keyboardWillAppear(_ notification: NSNotification){
        
        if keyboardTouchCheck == false && emailTouch == false{
            
            keyboardTouchCheck = true
            if let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                UIView.animate(withDuration: 0.7){
                    self.view.frame.origin.y -= 180
                    print(keyboardFrame.height)
                }
            }
            
        }
    }
    
    @objc func keyboardWillDisappear(_ notification: Notification){
        
        if keyboardTouchCheck == true{
            
            keyboardTouchCheck = false
            UIView.animate(withDuration: 0.8){
                self.view.frame.origin.y = 0
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){

          self.view.endEditing(true)

    }
    
    //MARK: API Functions
    
    func emailOverlapCheck(email: String) {
        AlamofireManager
            .shared
            .session
            .request(LoginRouter.checkEmail(email: email))
            .responseJSON { response in
                print(JSON(response.data))
                if JSON(response.data)["exist"].boolValue == false {
                    
                    self.warningText(label: self.emailWarningLabel,
                                box: self.emailBox,
                                text: "사용 가능한 이메일이에요!",
                                textColor: self.colorLiteralGreen,
                                borderColor: self.colorLiteralGreen.cgColor)
                    
                } else {
                    
                    self.warningText(label: self.emailWarningLabel,
                                box: self.emailBox,
                                text: "이미 사용중이거나, 사용할 수 없는 이메일이에요.",
                                textColor: UIColor.red,
                                borderColor: UIColor.red.cgColor)
                    
                }
            }

    }
    
    func idOverlapCheck(id: String) {
        AlamofireManager
            .shared
            .session
            .request(LoginRouter.checkLoginId(id: id))
            .responseJSON { response in
                
                if response.response?.statusCode == 200 {
                    
                    self.warningText(label: self.idWarningLabel,
                                box: self.idBox,
                                text: "사용 가능한 아이디에요!",
                                textColor: self.colorLiteralGreen,
                                borderColor: self.colorLiteralGreen.cgColor)
                  
                } else {
                    
                    self.warningText(label: self.idWarningLabel,
                                     box: self.idBox,
                                     text: "이미 사용중인 아이디에요!",
                                     textColor: UIColor.red,
                                     borderColor: UIColor.red.cgColor)
                    
                }
                
            }
    }
    
    
    //MARK: Button Actions
     
    @IBAction func nextButtonClicked(_ sender: Any) {
        
        userInfo.loginId = idTextField.text
        userInfo.password = passwordTextField.text
        userInfo.email = emailTextField.text
        
        let departmentViewStoryboard = UIStoryboard(name: "DepartmentView", bundle: nil)
        let nextViewController =
        departmentViewStoryboard.instantiateViewController(withIdentifier: "departmentVC") as! DepartmentController
        self.navigationController?.pushViewController(nextViewController, animated: true)

    }
    
    @IBAction func idOverlapButonClicked(_ sender: Any) {
        
        let id = idTextField.text ?? ""
        
    }
    
    // 이메일 중복 확인 로직을 다음 버튼에서 진행
    
    @IBAction func testJoin(_ sender: Any) {
        let id = idTextField.text ?? ""
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        let department = "정보보호학과"
        
        AlamofireManager
            .shared
            .session
            .request(LoginRouter.join(loginId: id, email: email, password: password, department: department))
            .responseJSON { response in
                print(JSON(response.data))

            }
    }
    
    //MARK: Design Funtions
    
    @objc func emailBoxClicked(_ sender: UITextField) {
        
    }
    
    func warningText(label: UILabel,
                     box: UIView,
                     text: String,
                     textColor: UIColor,
                     borderColor: CGColor) {
        
        label.text = text
        label.textColor = textColor
        box.layer.borderColor = borderColor
        
    }

    func designBox() {
        
        emailBox.layer.borderWidth = 0.7
        emailBox.layer.borderColor = UIColor.lightGray.cgColor
        emailBox.layer.cornerRadius = 3.0
        
        idBox.layer.borderWidth = 0.7
        idBox.layer.borderColor = UIColor.lightGray.cgColor
        idBox.layer.cornerRadius = 3.0
        
        passwordBox.layer.borderWidth = 0.7
        passwordBox.layer.borderColor = UIColor.lightGray.cgColor
        passwordBox.layer.cornerRadius = 3.0
        
        confirmPasswordBox.layer.borderWidth = 0.7
        confirmPasswordBox.layer.borderColor = UIColor.lightGray.cgColor
        confirmPasswordBox.layer.cornerRadius = 3.0
        
        nextButton.layer.cornerRadius = 6.0

        
        
    }
    
    func designLabel() {
        
        emailWarningLabel.isHidden = true
        idWarningLabel.isHidden = true
        passwordWarningLabel.isHidden = true
        confirmPasswordWarningLabel.isHidden = true
        
    }
    
    
}
