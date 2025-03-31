//
//  ShareDelegate.swift
//  iOS_App
//
//  Created by Михаил Тарасенко on 25.03.2025.
//

import UIKit

protocol ShareDelegate: AnyObject {
    func shareButtonWasPressed (_ view: PostView, viewController: UIActivityViewController)
}
