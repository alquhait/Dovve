//
//  UIViewController.swift
//  Dovve
//
//  Created by Dheeraj Kumar Sharma on 27/09/20.
//  Copyright © 2020 Dheeraj Kumar Sharma. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func PushToProfile(_ userId:String) {
        let VC = UserProfileViewController()
        VC.userProfileId = userId
        navigationController?.pushViewController(VC, animated: true)
    }
    
    func PushProfileToProfile( _ userId:String , _ comparingFrom:String){
        if userId != comparingFrom {
            let VC = UserProfileViewController()
            VC.userProfileId = userId
            navigationController?.pushViewController(VC, animated: true)
        }
    }
    
    func PushToImageDetailView( _ media:[String] , _ index:Int){
        let VC = ImageDetailViewController()
        let navVC = UINavigationController(rootViewController: VC)
        VC.imgString = media
        VC.indexRow = index
        navVC.modalPresentationStyle = .fullScreen
        self.present(navVC, animated: true, completion: nil)
    }
    
}
