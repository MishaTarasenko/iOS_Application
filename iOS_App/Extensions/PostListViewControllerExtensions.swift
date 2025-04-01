//
//  PostListViewControllerExtensions.swift
//  iOS_App
//
//  Created by Михаил Тарасенко on 01.04.2025.
//

import UIKit

extension PostListViewController: ShareDelegate {
    func shareButtonWasPressed(_ view: PostView, viewController: UIActivityViewController) {
        present(viewController, animated: true, completion: nil)
    }
}

extension PostListViewController: RedrowCellDelegate {
    func redrowCell(for post: Post) {
        if isSavedPosts {
            self.redrowTable()
        } else {
            if let index = postService!.posts.firstIndex(where: { $0.post == post.post }) {
                let indexPath = IndexPath(row: index, section: 0)
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
}

extension PostListViewController: LoadNewPostsDelegate {
    func redrowTable() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension PostListViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension PostListViewController: PostDetailOpenerDelegate {
    func didRequestPostDetail(for postView: PostView) {
        if let cell = postView.findSuperview(of: PostTableViewCell.self) {
            performSegue(withIdentifier: "showDetail", sender: cell)
        }
    }
}
