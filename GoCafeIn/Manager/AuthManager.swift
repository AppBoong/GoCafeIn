//
//  AuthManager.swift
//  GoCafeIn
//
//  Created by RedMac on 2020/09/10.
//  Copyright © 2020 AppBoong. All rights reserved.
//

import Foundation
import FirebaseAuth
public class AuthManager {
    
    static let shared = AuthManager()

    
    public func registerNewUser(username : String, email : String, password : String, completion : @escaping (Bool) -> Void) {
        DatabaseManager.shared.canCreateNewUser(with: email, username: username) { canCreate in
            if canCreate {
                
                Auth.auth().createUser(withEmail: email, password: password) { result, error in
                    guard error == nil, result != nil else {
                        completion(false)

                        return
                    }
                    completion(true)
                    //insert into database
                    DatabaseManager.shared.insertNewUser(with: email, username: username, uid: result!.user.uid) { inserted in
                        if inserted {
                            completion(true)
                            return
                        }
                        else {
                            completion(false)
                            return
                        }
                    }
                }
            }
            else {
                completion(false)
            }
        }
    }
    public func loginUser(email : String? , password : String, completion: @escaping(Bool) -> Void) {
        if let email = email {
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                guard authResult != nil, error == nil else {
                    completion(false)
                    return
                }
                completion(true)
            }
        }

        
    }
    
    public func logOut(completion : (Bool) -> Void) {
        
        do {
            try Auth.auth().signOut()
            completion(true)
            return
        } catch  {
            print(error)
            completion(false)
            return
        }
    }
}
