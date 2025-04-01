//
//  PostTableViewCellXIB.swift
//  iOS_App
//
//  Created by Михаил Тарасенко on 18.03.2025.
//

import UIKit

class PostTableViewCell: UITableViewCell {

    @IBOutlet private weak var postView: PostView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        selectionStyle = .none
        contentView.layoutMargins = .zero
        preservesSuperviewLayoutMargins = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        postView.resetState()
    }

    public func setProperties(post: Post,
                              shareDelegate: ShareDelegate,
                              redrowCellDelegate: RedrowCellDelegate,
                              savePostDelegate: SavePostDelegate,
                              postDetailOpenerDelegate: PostDetailOpenerDelegate) {
        postView.setPropertiesForView(post: post, layoutStyle: .compact)
        postView.shareDelegate = shareDelegate
        postView.redrowCellDelegate = redrowCellDelegate
        postView.savePostDelegate = savePostDelegate
        postView.postDetailOpenerDelegate = postDetailOpenerDelegate
    }
}
