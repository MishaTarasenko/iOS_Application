//
//  PostListViewControllerXIB.swift
//  iOS_App
//
//  Created by Михаил Тарасенко on 18.03.2025.
//

import UIKit
import Foundation

class PostListViewControllerXIB: UITableViewController {
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var bookmarkButton: UIButton!
    
    let subreddit = "ios"
    var posts: [Post] = []
    var after: String?
    var isFetching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = subreddit
        
        fetchData(subreddit: subreddit)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCellXIB", for: indexPath) as! PostTableViewCellXIB
        let post = posts[indexPath.row]
        
        cell.setProperties(post: post.post, isSaved: post.saved)
        
        return cell
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height

        if offsetY > contentHeight - frameHeight - 950 {
            fetchData(subreddit: subreddit)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let cell = sender as? UITableViewCell,
               let indexPath = tableView.indexPath(for: cell),
               let detailVC = segue.destination as? PostDetailsViewControllerXIB {
                detailVC.post = posts[indexPath.row]
            }
        }
    }

    
    private func fetchData(subreddit: String) {
        guard !isFetching else { return }
        isFetching = true
        
        Task {
            let redditPostsResponse = try await RedditAPIClient.shared.fetchPosts(
                subreddit: subreddit,
        limit: 10,
                after: after)
            after = redditPostsResponse.data.after
            
            var fetchedPosts: [Post] = []
            for post in redditPostsResponse.data.children {
                fetchedPosts.append(Post(post: post, saved: isPostSaved()))
            }
            
            DispatchQueue.main.async {
                self.posts.append(contentsOf: fetchedPosts)
                self.tableView.reloadData()
                self.isFetching = false
            }
        }
    }
}
