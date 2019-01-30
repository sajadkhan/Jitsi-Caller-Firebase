//
//  User.swift
//  JitsiSample
//
//  Created by Muhammad Sajad on 25/01/2019.
//  Copyright © 2019 Muhammad Sajad. All rights reserved.
//

import Foundation
import Firebase

struct JSUser {
    let id: String
    let name: String
    
    init?(snapshot: DataSnapshot) {
        id = snapshot.key 
        guard let dict = snapshot.value as? [String:Any] else { return nil }
        guard let username = dict["username"]  as? String else { return nil }
        
        self.name = username
    }
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
    
    static var loggedInUser: JSUser? {
        guard let name = UserDefaults.standard.string(forKey: AppConstants.USER_NAME_DEFAULTS_KEY)  else { return nil }
        guard let id = UserDefaults.standard.string(forKey: AppConstants.USER_UID_DEFAULTS_KEY)  else { return nil }
        return JSUser(id: id, name: name)
    }
}
