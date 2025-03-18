//
//  PostTableViewCellXIB.swift
//  iOS_App
//
//  Created by Михаил Тарасенко on 18.03.2025.
//

import UIKit

class PostTableViewCellXIB: UITableViewCell {

    @IBOutlet private weak var postView: PostView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    public func setProperties(post: Children, isSaved: Bool) {
        postView.setProperties(post: post, isSaved: isSaved)
    }
}
