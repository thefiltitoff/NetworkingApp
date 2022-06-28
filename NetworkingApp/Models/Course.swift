//
//  Course.swift
//  NetworkingApp
//
//  Created by Felix Titov on 6/28/22.
//  Copyright © 2022 by Felix Titov. All rights reserved.
//  


import Foundation

struct Course: Codable {
    let id: Int
    let name: String?
    let link: String?
    let imageUrl: String?
    let number_of_lessons: Int?
    let number_of_tests: Int?
}
