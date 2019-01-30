//
//  LoginViewController.swift
//  JitsiSample
//
//  Created by Muhammad Sajad on 25/01/2019.
//  Copyright © 2019 Muhammad Sajad. All rights reserved.
//

import UIKit
import Firebase
import Toast_Swift

struct AppConstants {
    static let USER_NAME_DEFAULTS_KEY = "user-name"
    static let USER_UID_DEFAULTS_KEY = "user-uid"
}


class LoginViewController: UIViewController {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    
    lazy var ref: DatabaseReference = {
        return Database.database().reference()
    }()
    
    var handle: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UserDefaults.standard.string(forKey: AppConstants.USER_NAME_DEFAULTS_KEY) != nil {
            performSegue(withIdentifier: "show users", sender: nil)
        }
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    private func saveUserInfo(uid: String, name: String) {
        UserDefaults.standard.set(uid, forKey: AppConstants.USER_UID_DEFAULTS_KEY)
        UserDefaults.standard.set(name, forKey: AppConstants.USER_NAME_DEFAULTS_KEY)
    }

    @IBAction func signInTap(_ sender: UIButton) {
        guard !((emailTextField.text?.isEmpty)!), !((passwordTextField.text?.isEmpty)!) else {
            showAlert(with: LoginViewController.missingInfoAlertTitleText, message: LoginViewController.missingInfoAlertText)
            return
        }
        
        self.view.makeToastActivity(.center)
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (authResult, error) in
            self.view.hideToastActivity()
            guard let user = authResult?.user, error == nil else {
                self.showAlert(with: LoginViewController.networkErrorAlertTitle, message: error!.localizedDescription)
                return
            }
            
            self.ref.child("users").child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                guard let userSnapshot = snapshot.value as? [String: String] else { return }
                self.saveUserInfo(uid: user.uid , name: userSnapshot["username"]!)
                self.performSegue(withIdentifier: "show users", sender: nil)
            })
        
        }
    }
    
    
    
    @IBAction func signUpTap(_ sender: UIButton) {
        
        let signUpAlertContrller = UIAlertController(title: "Details", message: "Please fill in the details.", preferredStyle: .alert)
        signUpAlertContrller.addTextField { (textfield) in
            textfield.placeholder = "User Name"
        }
        
        signUpAlertContrller.addTextField { (textfield) in
            textfield.placeholder = "Email"
        }
        
        signUpAlertContrller.addTextField { (textfield) in
            textfield.placeholder = "Password"
            textfield.isSecureTextEntry = true
        }
        
        signUpAlertContrller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        signUpAlertContrller.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak signUpAlertContrller](action) in
            if signUpAlertContrller != nil {
                if let fields = signUpAlertContrller!.textFields {
                    for field in fields {
                        if field.text!.isEmpty {
                            self.showAlert(with: LoginViewController.missingInfoAlertTitleText, message: LoginViewController.missingInfoAlertText)
                            signUpAlertContrller?.dismiss(animated: true, completion: nil)
                            return
                        }
                    }
                    
                    let userName = fields[0].text!
                    let email = fields[1].text!
                    let password = fields[2].text!
                    
                
                    self.view.makeToastActivity(.center)
                    Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
                        
                        guard error == nil else {
                            self.view.hideToastActivity()
                            self.showAlert(with: LoginViewController.networkErrorAlertTitle, message: error!.localizedDescription)
                            return
                        }
                        if let authResult = authResult {
                            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                            changeRequest?.displayName = userName
                            
                            changeRequest?.commitChanges(completion: { (error) in
                                self.view.hideToastActivity()
                                guard error == nil else {
                                    self.showAlert(with: "Failure", message: error!.localizedDescription)
                                    return
                                }
                                self.ref.child("users").child(authResult.user.uid).setValue(["username": userName])
                                self.saveUserInfo(uid: authResult.user.uid , name: userName)
                                self.performSegue(withIdentifier: "show users", sender: nil)
                            })
                            
                        }
                    }
                    
                }
                
            }
            
        }))
        
        present(signUpAlertContrller, animated: true, completion: nil)
        
        
    }
}


extension LoginViewController {
    static let missingInfoAlertTitleText = "Missing Fields"
    static let missingInfoAlertText = "Please fill in the required Info."
    static let networkErrorAlertTitle = "Error"
}


extension UIViewController {
    func showAlert(with title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let alertOkAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(alertOkAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}
