//
//  RedditPost.swift
//  Tarasenko02
//
//  Created by Михаил Тарасенко on 10.03.2025.
//

import Foundation

class Post: Hashable, Equatable, Codable {
    let post: Children
    var saved: Bool = false
    
    init(post: Children, saved: Bool) {
        self.post = post
        self.saved = saved
    }
    
    static func == (lhs: Post, rhs: Post) -> Bool {
        return lhs.post == rhs.post
    }
        
    func hash(into hasher: inout Hasher) {
        hasher.combine(post)
        hasher.combine(saved)
    }
}

struct RedditPost: Codable {
    let kind: String
    let data: Data
}

struct Data: Codable {
    let children: [Children]
    let after: String?
}

struct Children: Codable, Equatable, Hashable {
    let kind: String
    let data: ChildrenData
}

struct ChildrenData: Codable, Equatable, Hashable {
    let author: String
    let created_utc: Int
    let domain: String
    let title: String
    let thumbnail: String
    let selftext: String
    let score: Int
    let num_comments: Int
    let permalink: String
    
    static func == (lhs: ChildrenData, rhs: ChildrenData) -> Bool {
        return lhs.author == rhs.author &&
        lhs.created_utc == rhs.created_utc &&
        lhs.domain == rhs.domain &&
        lhs.title == rhs.title &&
        lhs.thumbnail == rhs.thumbnail &&
        lhs.selftext == rhs.selftext &&
        lhs.permalink == rhs.permalink;
    }
}
