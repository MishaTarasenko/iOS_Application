//
//  PostView.swift
//  iOS_App
//
//  Created by Михаил Тарасенко on 18.03.2025.
//

import UIKit
import SDWebImage

class PostView: UIView {
    let kCONTENT_XIB_NAME = "PostView"
    
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var selftextLabel: UILabel?
    @IBOutlet private weak var bookmarkButton: UIButton!
    @IBOutlet private weak var postImage: UIImageView!
    @IBOutlet private weak var ratingButton: UIButton!
    @IBOutlet private weak var commentsButton: UIButton!
    @IBOutlet private weak var shareButton: UIButton!
    
    @IBOutlet private weak var postImageTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var ratingButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var messageButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var shareButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var imageHeightConstraint: NSLayoutConstraint!
    
    weak var shareDelegate: ShareDelegate?
    weak var redrowCellDelegate: RedrowCellDelegate?
    weak var savePostDelegate: SavePostDelegate?
    private weak var post: Post?
    private var layoutStyle: LayoutStyleEnum?
    
    private var compactViewWithoutImageConstraints: [NSLayoutConstraint] = []
    
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
    
    func setPropertiesForView(post: Post, layoutStyle: LayoutStyleEnum) {
        self.post = post
        self.layoutStyle = layoutStyle
        
        if layoutStyle == .full {
            titleLabel.numberOfLines = 0
            initComponents()
        } else {
            selftextLabel?.removeFromSuperview()
            let newConstraint = postImage.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6)
            postImageTopConstraint = newConstraint
            postImageTopConstraint.isActive = true
            initComponents()
        }
    }
    
    private func initComponents() {
        guard let postData = post?.post.data else { return }
        guard let isSaved = post?.saved else { return }
        
        let thumbnailURLString = postData.thumbnail.replacingOccurrences(of: "&amp;", with: "&")
        //TO DO: переробити цей if else
        if thumbnailURLString.hasPrefix("http") {
                postImage.sd_setImage(
                    with: URL(string: thumbnailURLString),
                    placeholderImage: UIImage(named: "white.jpeg"),
                    options: [.retryFailed],
                    completed: { [weak self] (image, error, cacheType, url) in
                        guard let self = self else { return }
                        if error != nil {
                            if layoutStyle == .compact {
                                self.setUpCompactViewWithoutImage()
                            } else {
                                self.setUpFullViewWithoutImage()
                            }
                        }
                    }
                )
        } else {
            if layoutStyle == .compact {
                self.setUpCompactViewWithoutImage()
            } else {
                self.setUpFullViewWithoutImage()
            }
        }
        
        usernameLabel.text = "\(postData.author) • \(timeAgo(from: Date(timeIntervalSince1970: TimeInterval(postData.created_utc)))) • \(postData.domain)"
        titleLabel.text = postData.title
        if layoutStyle == .full {
            selftextLabel!.text = postData.selftext
        }
        ratingButton.setTitle(formatRating(rating: postData.score), for: .normal)
        commentsButton.setTitle(String(postData.num_comments), for: .normal)
        if isSaved {
            bookmarkButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
        }
    }
    
    private func setUpCompactViewWithoutImage() {
        postImage.isHidden = true
        titleLabel.numberOfLines = 5
        
        imageHeightConstraint?.isActive = false

        let ratingConstraint = ratingButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 14)
        let commentsConstraint = commentsButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 14)
        let shareConstraint = shareButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 14)
        let heightConstraint = postImage.heightAnchor.constraint(equalToConstant: 0)
        compactViewWithoutImageConstraints = [ratingConstraint, commentsConstraint, shareConstraint, heightConstraint]

        NSLayoutConstraint.activate(compactViewWithoutImageConstraints)
    }

    private func revertCompactViewChanges() {
        self.post = nil
        postImage.isHidden = false
        titleLabel.numberOfLines = 3
        
        imageHeightConstraint?.isActive = true
        
        NSLayoutConstraint.deactivate(compactViewWithoutImageConstraints)
        compactViewWithoutImageConstraints.removeAll()
        bookmarkButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
    }
    
    private func setUpFullViewWithoutImage() {
        postImage.isHidden = true
        titleLabel.numberOfLines = 0
        
        ratingButtonTopConstraint.isActive = false
        messageButtonTopConstraint.isActive = false
        shareButtonTopConstraint.isActive = false
    }
    
    @IBAction func shareButtonWasClicked(_ sender: Any) {
        if let postUrl = post?.post.data.permalink {
            guard let url = URL(string: "https://www.reddit.com" + postUrl) else {
                return
            }
            let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            shareDelegate?.shareButtonWasPressed(self, viewController: activityViewController)
        }
    }
    
    @IBAction func bookmarkButtonWasClicked(_ sender: UIButton) {
        if let isSaved = self.post?.saved, isSaved == true {
            self.post?.saved = false
            bookmarkButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
            redrowCellDelegate?.redrowCell(for: post!)
            savePostDelegate?.savePost(for: post!, isSave: false)
        } else {
            self.post?.saved = true
            bookmarkButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
            redrowCellDelegate?.redrowCell(for: post!)
            savePostDelegate?.savePost(for: post!, isSave: true)
        }
    }
    
    func resetState() {
        postImage.sd_cancelCurrentImageLoad()
        revertCompactViewChanges()
        postImage.image = nil
        usernameLabel.text = nil
        titleLabel.text = nil
        selftextLabel?.text = nil
        ratingButton.setTitle(nil, for: .normal)
        commentsButton.setTitle(nil, for: .normal)
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
