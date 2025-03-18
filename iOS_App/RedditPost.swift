//
//  RedditPost.swift
//  Tarasenko02
//
//  Created by Михаил Тарасенко on 10.03.2025.
//

import Foundation

struct Post {
    let post: Children
    var saved: Bool = false
}

struct RedditPost: Codable {
    let kind: String
    let data: Data
}

struct Data: Codable {
    let children: [Children]
    let after: String?
}

struct Children: Codable {
    let kind: String
    let data: ChildrenData
}

struct ChildrenData: Codable {
    let author: String
    let created_utc: Int
    let domain: String
    let title: String
    let thumbnail: String
    let selftext: String
    let score: Int
    let num_comments: Int
}
