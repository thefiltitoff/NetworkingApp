//
//  CurrentUser.swift
//  NetworkingApp
//
//  Created by Felix Titov on 6/30/22.
//  Copyright © 2022 by Felix Titov. All rights reserved.
//  


import Foundation

struct CurrentUser {
    let uid: String
    let name: String
    let email: String
    
    init?(uid: String, data: [String: Any]) {
        guard
            let name = data["name"] as? String,
              let email = data["email"] as? String else { return nil }
        
        self.uid = uid
        self.name = name
        self.email = email
    }
}
