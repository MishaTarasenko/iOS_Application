//
//  PostTableViewCell.swift
//  iOS_App
//
//  Created by Михаил Тарасенко on 16.03.2025.
//

import UIKit
import SDWebImage

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var bookMarkButton: UIButton!
    @IBOutlet private weak var titleLable: UILabel!
    @IBOutlet private weak var postImage: UIImageView!
    @IBOutlet private weak var ratingButton: UIButton!
    @IBOutlet private weak var commentsButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func setProperties(post: Children, isSaved: Bool) {
        usernameLabel.text = "\(post.data.author) • \(timeAgo(from: Date(timeIntervalSince1970: TimeInterval(post.data.created_utc)))) • \(post.data.domain)"
        titleLable.text = post.data.title

        let thumbnailURLString = post.data.thumbnail.replacingOccurrences(of: "&amp;", with: "&")
        postImage.sd_setImage(with: URL(string: thumbnailURLString), placeholderImage: UIImage(named: "white.jpeg"))


        ratingButton.setTitle(formatRating(rating: post.data.score), for: .normal)
        commentsButton.setTitle(String(post.data.num_comments), for: .normal)

        if isSaved {
            bookMarkButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
        }
    }

}
