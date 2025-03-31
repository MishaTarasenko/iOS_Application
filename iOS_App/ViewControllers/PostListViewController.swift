//
//  PostListViewControllerXIB.swift
//  iOS_App
//
//  Created by Михаил Тарасенко on 18.03.2025.
//

import UIKit
import Foundation

class PostListViewController: UITableViewController {
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var titleFilterText: UITextField!
    @IBOutlet private weak var bookmarkButton: UIButton!
    private var postService: PostService?
    private var isSavedPosts: Bool = false
    private var titleFilter: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleFilterText.isHidden = true
        titleFilterText.delegate = self
        postService = PostService(delegate: self)
        nameLabel.text = postService!.subreddit
        postService!.loadInitialPosts()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tapGesture)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getPostsCount()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell", for: indexPath) as! PostTableViewCell
        let post = getPostByIndex(indexPath.row)
        
        cell.setProperties(post: post, shareDelegate: self, redrowCellDelegate: self, savePostDelegate: postService)
        return cell
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !isSavedPosts else { return }
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height

        if offsetY > contentHeight - frameHeight - 950 {
            postService?.fetchData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let cell = sender as? UITableViewCell,
               let indexPath = tableView.indexPath(for: cell),
               let detailVC = segue.destination as? PostDetailsViewController {
                detailVC.post = getPostByIndex(indexPath.row)
                detailVC.redrowCellDelegate = self
                detailVC.savePostDelegate = postService
            }
        }
    }
    
    @IBAction func showSavedPosts(_ sender: Any) {
        if isSavedPosts {
            isSavedPosts = false
            self.titleFilterText.isHidden = true
            self.titleFilterText.text = ""
            self.titleFilter = ""
            self.bookmarkButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
            self.redrowTable()
        } else {
            isSavedPosts = true
            self.titleFilterText.isHidden = false
            self.bookmarkButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
            self.redrowTable()
        }
    }
    
    @IBAction func filterPostByTitle(_ sender: Any) {
        guard let filterText = titleFilterText.text else {
            return
        }
            
        titleFilter = filterText
        self.redrowTable()
    }
    private func getPostByIndex(_ index: Int) -> Post {
        if isSavedPosts {
            return postService!.getFilteredSavedPosts(title: titleFilter)[index]
        } else {
            return postService!.posts[index]
        }
    }
    
    private func getPostsCount() -> Int {
        if isSavedPosts {
            return postService!.getFilteredSavedPosts(title: titleFilter).count
        } else {
            return postService!.posts.count
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

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
