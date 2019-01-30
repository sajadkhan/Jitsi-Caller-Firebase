//
//  UsersTableViewController.swift
//  JitsiSample
//
//  Created by Muhammad Sajad on 25/01/2019.
//  Copyright © 2019 Muhammad Sajad. All rights reserved.
//

import UIKit
import Firebase
import Toast_Swift

class UsersTableViewController: UITableViewController {
    
    lazy var ref: DatabaseReference = {
        return Database.database().reference()
    }()
    
    var users: [JSUser] = []
    
    private var callCleanUpBlock: (()->Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        title = "Call Someone"
        
        self.navigationController?.view.makeToastActivity(.center)
        
        //Get and Observe users.
        ref.child("users").observe(.childAdded) { [weak self] (snapshot) in
            self?.navigationController?.view.hideToastActivity()
            guard let strongSelf = self else {
                return
            }
            let jsUser = JSUser(snapshot: snapshot)!
            
            strongSelf.users.append(jsUser)
            strongSelf.tableView.insertRows(at: [IndexPath(row: strongSelf.users.count-1, section: 0)], with: .automatic)
        }
        
        
        //Observe for in comming call
        ref.child("users").child(JSUser.loggedInUser!.id).child("incommingCalls").observe(.childAdded) { [weak self] (snapshot) in
            
            let callAlert = UIAlertController(title: "Incomming Call", message: "You have a call, please respond.", preferredStyle: .alert)
            
            //If user rejects the call we remove it from DB.
            callAlert.addAction(UIAlertAction(title: "Reject", style: .cancel, handler: { [weak self] action in
                self?.ref.child("users").child(JSUser.loggedInUser!.id).child("incommingCalls").child(snapshot.key).removeValue()
            }))
            
            callAlert.addAction(UIAlertAction(title: "Accept", style: .default, handler: { (action) in
                let callRoomName = snapshot.value as! String
                self?.callCleanUpBlock = {
                    self?.ref.child("users").child(JSUser.loggedInUser!.id).child("incommingCalls").child(snapshot.key).removeValue()
                }
                self?.performSegue(withIdentifier: "makeCall", sender: callRoomName)
            }))
            
            self?.present(callAlert, animated: true, completion: nil)
        }

    }

    @IBAction func logoutUserTap(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            UserDefaults.standard.removeObject(forKey: AppConstants.USER_NAME_DEFAULTS_KEY)
            UserDefaults.standard.removeObject(forKey: AppConstants.USER_UID_DEFAULTS_KEY)
            navigationController?.popViewController(animated: true)
        } catch let signOutError {
            self.showAlert(with: "Failure", message: signOutError.localizedDescription)
        }
        
        
    }
    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "user cell", for: indexPath)
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        if user.id == JSUser.loggedInUser!.id {
            cell.textLabel?.textColor = UIColor.gray
            cell.isUserInteractionEnabled = false
        } else {
            cell.textLabel?.textColor = UIColor.black
            cell.isUserInteractionEnabled = true
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        let callRoomName = "\(JSUser.loggedInUser!.name)-\(user.name)".replacingOccurrences(of: " ", with: "")
        
        //Create a new call to the user we are calling
        ref.child("users").child(user.id).child("incommingCalls").setValue(["room-id":callRoomName])
        self.callCleanUpBlock = { [weak self] in 
            self?.ref.child("users").child(user.id).child("incommingCalls").child("room-id").removeValue()
        }
        self.performSegue(withIdentifier: "makeCall", sender: callRoomName);
    }
  
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "makeCall",
            let callRoomName = sender as? String {
            let callVC = segue.destination as! CallViewController
            callVC.didEndCall = {
                self.callCleanUpBlock!()
            }
            callVC.callRoomName = callRoomName
        }
    }

}
