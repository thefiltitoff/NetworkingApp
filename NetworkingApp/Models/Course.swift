//
//  Course.swift
//  NetworkingApp
//
//  Created by Felix Titov on 6/28/22.
//  Copyright © 2022 by Felix Titov. All rights reserved.
//  


import Foundation

/*
struct Course: Codable {
    let id: Int
    let name: String?
    let link: String?
    let imageUrl: String?
    let numberOfLessons: Int?
    let numberOfTests: Int?
}
*/

struct Course: Decodable {
    let id: Int
    let name: String?
    let link: String?
    let imageUrl: String?
    let numberOfLessons: String?
    let numberOfTests: String?
    
    init?(json: [String: Any]) {
        let id = json["id"] as! Int
        let name = json["name"] as? String
        let link = json["link"] as? String
        let imageUrl = json["imageUrl"] as? String
        let numberOfLessons = json["numberOfLessons"] as? String
        let numberOfTests = json["numberOfTests"] as? String
        
        self.id = id
        self.name = name
        self.link = link
        self.imageUrl = imageUrl
        self.numberOfLessons = numberOfLessons
        self.numberOfTests = numberOfTests
    }
    
    static func getItems(from json: Any) -> [Course]? {
        guard let json = json as? Array<[String: Any]> else { return nil}
        
        var courses: [Course] = []
        for item in json {
            if let course = Course(json: item) {
                courses.append(course)
            }
        }
        
        return json.compactMap { Course(json: $0) }
    }
}
