//
//  PostView.swift
//  iOS_App
//
//  Created by Михаил Тарасенко on 18.03.2025.
//

import UIKit

class PostView: UIView {
    let kCONTENT_XIB_NAME = "PostView"
    
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var bookmarkButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var postImage: UIImageView!
    @IBOutlet private weak var ratingButton: UIButton!
    @IBOutlet private weak var commentsButton: UIButton!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
       
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
       
    func commonInit() {
        Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
        contentView.fixInView(self)
    }
    
    func setProperties(post: Children, isSaved: Bool) {
        usernameLabel.text = "\(post.data.author) • \(timeAgo(from: Date(timeIntervalSince1970: TimeInterval(post.data.created_utc)))) • \(post.data.domain)"
        titleLabel.text = post.data.title

        let thumbnailURLString = post.data.thumbnail.replacingOccurrences(of: "&amp;", with: "&")
        postImage.sd_setImage(with: URL(string: thumbnailURLString), placeholderImage: UIImage(named: "white.jpeg"))


        ratingButton.setTitle(formatRating(rating: post.data.score), for: .normal)
        commentsButton.setTitle(String(post.data.num_comments), for: .normal)

        if isSaved {
            bookmarkButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
        }
    }
}

extension UIView
{
    func fixInView(_ container: UIView!) -> Void{
        self.translatesAutoresizingMaskIntoConstraints = false;
        self.frame = container.frame;
        container.addSubview(self);
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
    }
}
