//
//  PostDetailsViewControllerXIB.swift
//  iOS_App
//
//  Created by Михаил Тарасенко on 18.03.2025.
//

import Foundation
import UIKit
import SDWebImage

class PostDetailsViewControllerXIB: UIViewController {
    
    @IBOutlet private weak var postView: PostView!
    
    var post: Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let currentPost = post else { return }
        guard let isSaved = post?.saved else { return }
        
        
        postView.setProperties(post: currentPost.post, isSaved: isSaved)
    }
}
