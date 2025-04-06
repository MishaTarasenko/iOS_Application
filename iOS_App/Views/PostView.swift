//
//  PostView.swift
//  iOS_App
//
//  Created by Михаил Тарасенко on 18.03.2025.
//

import UIKit
import SDWebImage

class PostView: UIView, UIGestureRecognizerDelegate {
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
    weak var postDetailOpenerDelegate: PostDetailOpenerDelegate?
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
        
        self.isUserInteractionEnabled = true
        postImage.isUserInteractionEnabled = true
                
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap))
        self.addGestureRecognizer(singleTapGesture)
                
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTapGesture.numberOfTapsRequired = 2
        postImage.addGestureRecognizer(doubleTapGesture)
        singleTapGesture.require(toFail: doubleTapGesture)
        
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
        postImage.sd_setImage(
                    with: URL(string: thumbnailURLString),
                    placeholderImage: UIImage(named: "white.jpeg")
                )
        
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

    private func revertCompactViewChanges() {
        self.post = nil
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
        savePost()
        redrowCellDelegate?.redrowCell(for: post!)
    }
    
    @objc private func handleDoubleTap() {
        self.savePost()
        showBookmarkAnimation {
            self.redrowCellDelegate?.redrowCell(for: self.post!)
        }
    }
    
    @objc private func handleSingleTap() {
        postDetailOpenerDelegate?.didRequestPostDetail(for: self)
    }
    
    private func savePost() {
        if let isSaved = self.post?.saved, isSaved == true {
            self.post?.saved = false
            bookmarkButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
            savePostDelegate?.savePost(for: post!, isSave: false)
        } else {
            self.post?.saved = true
            bookmarkButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
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
    
    private func showBookmarkAnimation(completion: (() -> Void)? = nil) {
        guard let bookmarkImg = bookmarkImage() else { return }
        
        let shapeLayer = CALayer()
        shapeLayer.contents = bookmarkImg.cgImage
        shapeLayer.opacity = 0
        
        let layerWidth: CGFloat = 30
        let layerHeight: CGFloat = 40
        let centerPoint = CGPoint(x: postImage.bounds.midX, y: postImage.bounds.midY)
        shapeLayer.frame = CGRect(
            x: centerPoint.x - layerWidth / 2,
            y: centerPoint.y - layerHeight / 2,
            width: layerWidth,
            height: layerHeight
        )
        
        postImage.layer.addSublayer(shapeLayer)
        
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.fromValue = 0
        fadeAnimation.toValue = 1
        fadeAnimation.duration = 0.7
        fadeAnimation.autoreverses = true
        fadeAnimation.fillMode = .forwards
        fadeAnimation.isRemovedOnCompletion = false
        shapeLayer.add(fadeAnimation, forKey: "fadeInOut")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            shapeLayer.removeFromSuperlayer()
            completion?()
        }
    }
    
    private func bookmarkImage() -> UIImage? {
        let size = CGSize(width: 30, height: 40)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let bookmarkPath = UIBezierPath()
            bookmarkPath.move(to: CGPoint(x: 0, y: 0))
            bookmarkPath.addLine(to: CGPoint(x: 0, y: 40))
            bookmarkPath.addLine(to: CGPoint(x: 15, y: 25))
            bookmarkPath.addLine(to: CGPoint(x: 30, y: 40))
            bookmarkPath.addLine(to: CGPoint(x: 30, y: 0))
            bookmarkPath.close()
            
            UIColor.systemBlue.setFill()
            bookmarkPath.fill()
        }
        return image
    }
}
