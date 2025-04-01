//
//  PostServiceExtensions.swift
//  iOS_App
//
//  Created by Михаил Тарасенко on 01.04.2025.
//

extension PostService: SavePostDelegate {
    func savePost(for post: Post, isSave: Bool) {
        if isSave {
            savePost(post)
        } else {
            removePost(post)
        }
    }
}

extension Array where Element == Post {
    func customContains(post: Post) -> Bool {
        for element in self {
            if element == post {
                return true
            }
        }
        return false
    }

    @discardableResult
    mutating func customRemove(post: Post) -> Post? {
        for (index, element) in self.enumerated() {
            if element == post {
                return self.remove(at: index)
            }
        }
        return nil
    }
}
