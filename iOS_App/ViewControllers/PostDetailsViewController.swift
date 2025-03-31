//
//  PostDetailsViewControllerXIB.swift
//  iOS_App
//
//  Created by Михаил Тарасенко on 18.03.2025.
//

import Foundation
import UIKit
import SDWebImage

class PostDetailsViewController: UIViewController {
    
    @IBOutlet private weak var postView: PostView!
    
    weak var post: Post?
    weak var redrowCellDelegate: RedrowCellDelegate?
    weak var savePostDelegate: SavePostDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let post = post else { return }
        
        postView.setPropertiesForView(post: post, layoutStyle: .full)
        postView.shareDelegate = self
        postView.redrowCellDelegate = redrowCellDelegate
        postView.savePostDelegate = savePostDelegate
    }
}

extension PostDetailsViewController: ShareDelegate {
    func shareButtonWasPressed(_ view: PostView, viewController: UIActivityViewController) {
        present(viewController, animated: true, completion: nil)
    }
}
