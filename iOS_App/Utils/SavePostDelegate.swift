//
//  SavePostDelegate.swift
//  iOS_App
//
//  Created by Михаил Тарасенко on 30.03.2025.
//

protocol SavePostDelegate: AnyObject {
    func savePost(for post: Post, isSave: Bool)
}
