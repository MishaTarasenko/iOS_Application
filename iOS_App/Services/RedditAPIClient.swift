//
//  RedditAPIClient.swift
//  Tarasenko02
//
//  Created by Михаил Тарасенко on 10.03.2025.
//
import UIKit
import Foundation

final class RedditAPIClient {
    static let shared = RedditAPIClient()
    
    private init() {}
    
    func fetchPosts(subreddit: String, limit: Int, after: String?) async throws -> RedditPost {
        var urlComponents = URLComponents(string: "https://www.reddit.com/r/\(subreddit)/top.json")!
        
        var parameters: [String: String] = [
            "limit": "\(limit)"
        ]
        
        if let after = after, !after.isEmpty {
            parameters["after"] = after
        }
        
        urlComponents.queryItems = parameters.map {key, value in
            URLQueryItem(name: key, value: value)
        }
        
        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        return try JSONDecoder().decode(RedditPost.self, from: data)
    }
}
