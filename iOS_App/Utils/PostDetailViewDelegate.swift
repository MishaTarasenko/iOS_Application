//
//  PostDetailViewDelegate.swift
//  iOS_App
//
//  Created by Михаил Тарасенко on 01.04.2025.
//


protocol PostDetailOpenerDelegate: AnyObject {
    func didRequestPostDetail(for postView: PostView)
}
