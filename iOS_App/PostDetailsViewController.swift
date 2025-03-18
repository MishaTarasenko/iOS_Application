//
//  PostDetailsViewController.swift
//  iOS_App
//
//  Created by Михаил Тарасенко on 17.03.2025.
//

import Foundation
import UIKit
import SDWebImage

class PostDetailsViewController: UIViewController {
    
    @IBOutlet private weak var userNameLabel: UILabel!
    @IBOutlet private weak var bookMarkButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var postImage: UIImageView!
    @IBOutlet private weak var ratingButton: UIButton!
    @IBOutlet private weak var commentsButton: UIButton!
    @IBOutlet private weak var shareButton: UIButton!
    
    var post: Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let currentPost = post else { return }
        
        userNameLabel.text = "\(currentPost.post.data.author) • \(timeAgo(from: Date(timeIntervalSince1970: TimeInterval(currentPost.post.data.created_utc)))) • \(currentPost.post.data.domain)"
        titleLabel.text = currentPost.post.data.title
        textLabel.text = currentPost.post.data.selftext

        let thumbnailURLString = currentPost.post.data.thumbnail.replacingOccurrences(of: "&amp;", with: "&")
        postImage.sd_setImage(with: URL(string: thumbnailURLString), placeholderImage: UIImage(named: "white.jpeg"))

        ratingButton.setTitle(formatRating(rating: currentPost.post.data.score), for: .normal)
        commentsButton.setTitle(String(currentPost.post.data.num_comments), for: .normal)

        if currentPost.saved {
            bookMarkButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
        }
    }
}
