//
//  HomeViewController.swift
//  Dovve
//
//  Created by Dheeraj Kumar Sharma on 19/09/20.
//  Copyright © 2020 Dheeraj Kumar Sharma. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftKeychainWrapper

class HomeViewController: UIViewController {

    var dataModel:[HomeTimeLineModel]?
    var dataList:[TweetData]?
    
    private lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = CustomColors.appBackground
        refreshControl.backgroundColor = UIColor.dynamicColor(.secondaryBackground)
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        return refreshControl
    }()
    
    lazy var collectionView:UICollectionView = {
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewLayout.init())
        cv.refreshControl = refresher
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.showsVerticalScrollIndicator = false
        cv.register(SimpleTextPostCollectionViewCell.self, forCellWithReuseIdentifier: "SimpleTextPostCollectionViewCell")
        cv.register(PostWithImagesCollectionViewCell.self, forCellWithReuseIdentifier: "PostWithImagesCollectionViewCell")
        cv.register(QuotedPostCollectionViewCell.self, forCellWithReuseIdentifier: "QuotedPostCollectionViewCell")
        cv.register(QuotedPostWithImageCollectionViewCell.self, forCellWithReuseIdentifier: "QuotedPostWithImageCollectionViewCell")
        cv.register(PostWithImageAndQuoteCollectionViewCell.self, forCellWithReuseIdentifier: "PostWithImageAndQuoteCollectionViewCell")
        cv.register(PostWithImageAndQuotedImageCollectionViewCell.self, forCellWithReuseIdentifier: "PostWithImageAndQuotedImageCollectionViewCell")
        cv.setCollectionViewLayout(layout, animated: false)
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = UIColor.dynamicColor(.secondaryBackground)
        return cv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.dynamicColor(.secondaryBackground)
        view.addSubview(collectionView)
        collectionView.pin(to: view)
        setUpCustomNavBar()
        
        HomeTimeLineModel.fetchHometimeLine(view:self, max_id: "" , params:"") {(dataModel) in
            self.dataModel = dataModel
            self.dataList?.removeAll()
            self.getDataListArray(dataModel)
            self.collectionView.reloadData()
        }
    }
    
    @objc func pullToRefresh(){
        HomeTimeLineModel.fetchHometimeLine(view:self, max_id: "" , params:"") {(dataModel) in
            self.dataModel = dataModel
            self.dataList?.removeAll()
            self.getDataListArray(dataModel)
            self.collectionView.reloadData()
        }
        refresher.endRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setUpCustomNavBar()
    }
    
    func setUpCustomNavBar(){
        navigationController?.navigationBar.topItem?.title = "Home"
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 0.1)
        navigationController?.navigationBar.layer.shadowColor = UIColor.dynamicColor(.secondaryBackground).cgColor
        navigationController?.navigationBar.layer.shadowOpacity = 1
        navigationController?.navigationBar.layer.shadowRadius = 0.5
        
        navigationController?.navigationBar.barTintColor = UIColor.dynamicColor(.appBackground)
        navigationController?.navigationBar.isTranslucent = false
        self.navigationController!.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont(name: CustomFonts.appFontBold, size: 19)!,
            NSAttributedString.Key.foregroundColor: UIColor.dynamicColor(.textColor)
        ]
    }
    
    func getDataListArray(_ data:[HomeTimeLineModel]){
        var tweets = [TweetData]()
        let tweetCount = data.count
        for i in 0..<tweetCount{
            if data[i].isQuotedStatus == true {
                if data[i].isRetweetedStatus == true {
                    let tweet = TweetData(createdAt: data[i].createdAt, id: data[i].id, text: data[i].text, user: TweetUser(userId: data[i].user.userId, name: data[i].user.name, screenName: data[i].user.screen_name, profileImage: data[i].user.profileImage, isVerified: data[i].user.isVerified), media: data[i].media, isRetweetedStatus: true, retweetedBy: TweetRetweetedData(userProfileImage: data[i].retweetedBy.userProfileImage, userID: data[i].retweetedBy.userID) ,isQuotedStatus: data[i].isQuotedStatus, tweetQuotedStatus:TweetQuotedStatus(createdAt: data[i].quotedStatus.createdAt, user: TweetUser(userId: data[i].quotedStatus.user.userId, name: data[i].quotedStatus.user.name, screenName: data[i].quotedStatus.user.screen_name, profileImage: data[i].quotedStatus.user.profileImage, isVerified: data[i].quotedStatus.user.isVerified), text: data[i].quotedStatus.text, media: data[i].quotedStatus.media), retweetCount: data[i].retweetCount, favoriteCount: data[i].favoriteCount, favorited: data[i].favorited, retweeted: data[i].retweeted)
                    tweets.append(tweet)
                } else {
                    let tweet = TweetData(createdAt: data[i].createdAt, id: data[i].id, text: data[i].text, user: TweetUser(userId: data[i].user.userId, name: data[i].user.name, screenName: data[i].user.screen_name, profileImage: data[i].user.profileImage, isVerified: data[i].user.isVerified), media: data[i].media, isRetweetedStatus: false , retweetedBy: nil , isQuotedStatus: data[i].isQuotedStatus, tweetQuotedStatus:TweetQuotedStatus(createdAt: data[i].quotedStatus.createdAt, user: TweetUser(userId: data[i].quotedStatus.user.userId, name: data[i].quotedStatus.user.name, screenName: data[i].quotedStatus.user.screen_name, profileImage: data[i].quotedStatus.user.profileImage, isVerified: data[i].quotedStatus.user.isVerified), text: data[i].quotedStatus.text, media: data[i].quotedStatus.media), retweetCount: data[i].retweetCount, favoriteCount: data[i].favoriteCount, favorited: data[i].favorited, retweeted: data[i].retweeted)
                    tweets.append(tweet)
                }
            } else {
                if data[i].isRetweetedStatus == true {
                    let tweet = TweetData(createdAt: data[i].createdAt, id: data[i].id, text: data[i].text, user: TweetUser(userId: data[i].user.userId, name: data[i].user.name, screenName: data[i].user.screen_name, profileImage: data[i].user.profileImage, isVerified: data[i].user.isVerified), media: data[i].media, isRetweetedStatus: true , retweetedBy: TweetRetweetedData(userProfileImage: data[i].retweetedBy.userProfileImage, userID: data[i].retweetedBy.userID), isQuotedStatus: data[i].isQuotedStatus, tweetQuotedStatus:nil, retweetCount: data[i].retweetCount, favoriteCount: data[i].favoriteCount, favorited: data[i].favorited, retweeted: data[i].retweeted)
                    tweets.append(tweet)
                } else {
                    let tweet = TweetData(createdAt: data[i].createdAt, id: data[i].id, text: data[i].text, user: TweetUser(userId: data[i].user.userId, name: data[i].user.name, screenName: data[i].user.screen_name, profileImage: data[i].user.profileImage, isVerified: data[i].user.isVerified), media: data[i].media, isRetweetedStatus: false, retweetedBy: nil ,isQuotedStatus: data[i].isQuotedStatus, tweetQuotedStatus:nil, retweetCount: data[i].retweetCount, favoriteCount: data[i].favoriteCount, favorited: data[i].favorited, retweeted: data[i].retweeted)
                    tweets.append(tweet)
                }
            }
        }
        if dataList == nil {
            dataList = tweets
        } else {
            dataList?.append(contentsOf: tweets)
        }
    }
    
}

extension HomeViewController:UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let dataList = dataList {
            return dataList.count
        }
        return Int()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let dataList = dataList {
            if dataList[indexPath.row].media == nil && dataList[indexPath.row].isQuotedStatus == false {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SimpleTextPostCollectionViewCell", for: indexPath) as! SimpleTextPostCollectionViewCell
                cell.data = dataList[indexPath.row]
                cell.delegate = self
                return cell
            }
            if dataList[indexPath.row].media != nil &&  dataList[indexPath.row].isQuotedStatus == false {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostWithImagesCollectionViewCell", for: indexPath) as! PostWithImagesCollectionViewCell
                cell.data = dataList[indexPath.row]
                cell.delegate = self
                return cell
            }
            if dataList[indexPath.row].media == nil && dataList[indexPath.row].isQuotedStatus == true && dataList[indexPath.row].tweetQuotedStatus.media == nil {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QuotedPostCollectionViewCell", for: indexPath) as! QuotedPostCollectionViewCell
                cell.data = dataList[indexPath.row]
                cell.delegate = self
                return cell
            }
            if dataList[indexPath.row].media != nil && dataList[indexPath.row].isQuotedStatus == true && dataList[indexPath.row].tweetQuotedStatus.media == nil {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostWithImageAndQuoteCollectionViewCell", for: indexPath) as! PostWithImageAndQuoteCollectionViewCell
                cell.data = dataList[indexPath.row]
                cell.delegate = self
                return cell
            }
            if dataList[indexPath.row].media == nil && dataList[indexPath.row].isQuotedStatus == true && dataList[indexPath.row].tweetQuotedStatus.media != nil {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QuotedPostWithImageCollectionViewCell", for: indexPath) as! QuotedPostWithImageCollectionViewCell
                cell.data = dataList[indexPath.row]
                cell.delegate = self
                return cell
            }
            if dataList[indexPath.row].media != nil && dataList[indexPath.row].isQuotedStatus == true && dataList[indexPath.row].tweetQuotedStatus.media != nil {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostWithImageAndQuotedImageCollectionViewCell", for: indexPath) as! PostWithImageAndQuotedImageCollectionViewCell
                cell.data = dataList[indexPath.row]
                cell.delegate = self
                return cell
            }
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let dataList = dataList {
            if dataList[indexPath.row].media == nil && dataList[indexPath.row].isQuotedStatus == false {
                let font = UIFont(name: CustomFonts.appFont, size: 17)!
                let estimatedH = dataList[indexPath.row].text.height(withWidth: (collectionView.frame.width - 100), font: font)
                return CGSize(width: collectionView.frame.width, height: estimatedH + 95 )
            }
            if dataList[indexPath.row].media != nil &&  dataList[indexPath.row].isQuotedStatus == false {
                let font = UIFont(name: CustomFonts.appFont, size: 17)!
                let estimatedH = dataList[indexPath.row].text.height(withWidth: (collectionView.frame.width - 100), font: font)
                let extraHeight = 105 + ((collectionView.frame.width - 100) * (9 / 16))
                return CGSize(width: collectionView.frame.width, height: estimatedH + extraHeight )
            }
            if dataList[indexPath.row].media == nil && dataList[indexPath.row].isQuotedStatus == true && dataList[indexPath.row].tweetQuotedStatus.media == nil {
                let font = UIFont(name: CustomFonts.appFont, size: 17)!
                let estimatedH = dataList[indexPath.row].text.height(withWidth: (collectionView.frame.width - 100), font: font)
                let estimatedHForQuotedTweet = dataList[indexPath.row].tweetQuotedStatus.text.height(withWidth: ((collectionView.frame.width - 100) - 30), font: font)
                return CGSize(width: collectionView.frame.width, height: estimatedH + estimatedHForQuotedTweet + 160)
            }
            if dataList[indexPath.row].media != nil && dataList[indexPath.row].isQuotedStatus == true && dataList[indexPath.row].tweetQuotedStatus.media == nil {
                let font = UIFont(name: CustomFonts.appFont, size: 17)!
                let estimatedH = dataList[indexPath.row].text.height(withWidth: (collectionView.frame.width - 100), font: font)
                let estimatedHForQuotedTweet = dataList[indexPath.row].tweetQuotedStatus.text.height(withWidth: ((collectionView.frame.width - 100) - 30), font: font)
                let imageCollectionForPostH = (collectionView.frame.width - 100) * (9/16)
                return CGSize(width: collectionView.frame.width, height: estimatedH + estimatedHForQuotedTweet + imageCollectionForPostH + 175)
            }
            if dataList[indexPath.row].media == nil && dataList[indexPath.row].isQuotedStatus == true && dataList[indexPath.row].tweetQuotedStatus.media != nil {
                let font = UIFont(name: CustomFonts.appFont, size: 17)!
                let estimatedH = dataList[indexPath.row].text.height(withWidth: (collectionView.frame.width - 100), font: font)
                let estimatedHForQuotedTweet = dataList[indexPath.row].tweetQuotedStatus.text.height(withWidth: ((collectionView.frame.width - 100) - 30), font: font)
                let imageCollectionHeight = ((collectionView.frame.width - 100) * (9/16))
                return CGSize(width: collectionView.frame.width, height: estimatedH + estimatedHForQuotedTweet + imageCollectionHeight + 160)
            }
            if dataList[indexPath.row].media != nil && dataList[indexPath.row].isQuotedStatus == true && dataList[indexPath.row].tweetQuotedStatus.media != nil {
                let font = UIFont(name: CustomFonts.appFont, size: 17)!
                let estimatedH = dataList[indexPath.row].text.height(withWidth: (collectionView.frame.width - 100), font: font)
                let estimatedHForQuotedTweet = dataList[indexPath.row].tweetQuotedStatus.text.height(withWidth: ((collectionView.frame.width - 100) - 30), font: font)
                let imageCollectionHeight = ((collectionView.frame.width - 100) * (9/16))
                let imageCollectionForPostH = (collectionView.frame.width - 100) * (9/16)
                return CGSize(width: collectionView.frame.width, height: estimatedH + estimatedHForQuotedTweet + imageCollectionHeight + imageCollectionForPostH + 175)
            }
        }
        return CGSize()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.7
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.7
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let loadMoreFrom = collectionView.contentSize.height - (collectionView.contentSize.height * 30/100)
        if ((collectionView.contentOffset.y + collectionView.frame.size.height) >= loadMoreFrom){
            if let dataList = dataList {
                let totalPosts = dataList.count
                let getLastId = Int(dataList[totalPosts - 1].id)
                HomeTimeLineModel.fetchHometimeLine(view:self ,max_id: "max_id=\(getLastId ?? 0)&" , params:"&max_id=\(getLastId ?? 0)") {(dataModel) in
                    self.dataList?.remove(at: totalPosts - 1)
                    self.getDataListArray(dataModel)
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
}

extension HomeViewController: SimpleTextPostDelegate, PostWithImagesDelegate, QuotedPostDelegate, QuotedPostWithImageDelegate , PostWithImageAndQuoteDelegate , PostWithImageAndQuotedImageDelegate {
    
    //MARK:-SimpleTextPost Actions
    func didUserProfileTapped(for cell: SimpleTextPostCollectionViewCell, _ isRetweetedUser: Bool) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        if let dataList = dataList {
            if isRetweetedUser {
                let userId = dataList[indexPath.row].retweetedBy.userID
                PushToProfile(userId!)
            } else {
                let userId = dataList[indexPath.row].user.userId
                PushToProfile(userId!)
            }
        }
    }
    
    //MARK:-PostWithImages Actions
    func didUserProfileTapped(for cell: PostWithImagesCollectionViewCell, _ isRetweetedUser: Bool) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        if let dataList = dataList {
            if isRetweetedUser {
                let userId = dataList[indexPath.row].retweetedBy.userID
                PushToProfile(userId!)
            } else {
                let userId = dataList[indexPath.row].user.userId
                PushToProfile(userId!)
            }
        }
    }
    
    func didImageTapped(for cell: PostWithImagesCollectionViewCell, _ index: Int) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        if let dataList = dataList {
            let media = dataList[indexPath.row].media
            PushToImageDetailView(media ?? [""] , index)
        }
    }
    
    //MARK:-QuotedPost Actions
    func didUserProfileTapped(for cell: QuotedPostCollectionViewCell, _ isQuotedUser: Bool, _ isRetweetedUser: Bool) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        if let dataList = dataList {
            if isRetweetedUser {
                let userId = dataList[indexPath.row].retweetedBy.userID
                PushToProfile(userId!)
            } else if isQuotedUser {
                let userId = dataList[indexPath.row].tweetQuotedStatus.user.userId
                PushToProfile(userId!)
            } else {
                let userId = dataList[indexPath.row].user.userId
                PushToProfile(userId!)
            }
        }
    }
    
    //MARK:-QuotedPostWithImage Actions
    func didUserProfileTapped(for cell: QuotedPostWithImageCollectionViewCell, _ isQuotedUser: Bool, _ isRetweetedUser: Bool) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        if let dataList = dataList {
            if isRetweetedUser {
                let userId = dataList[indexPath.row].retweetedBy.userID
                PushToProfile(userId!)
            } else if isQuotedUser {
                let userId = dataList[indexPath.row].tweetQuotedStatus.user.userId
                PushToProfile(userId!)
            } else {
                let userId = dataList[indexPath.row].user.userId
                PushToProfile(userId!)
            }
        }
    }
    
    func didImageTapped(for cell: QuotedPostWithImageCollectionViewCell, _ index: Int) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        if let dataList = dataList {
            let media = dataList[indexPath.row].tweetQuotedStatus.media
            PushToImageDetailView(media ?? [""] , index)
        }
    }
    
    //MARK:-PostWithImageAndQuote Actions
    func didUserProfileTapped(for cell: PostWithImageAndQuoteCollectionViewCell, _ isQuotedUser: Bool, _ isRetweetedUser: Bool) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        if let dataList = dataList {
            if isRetweetedUser {
                let userId = dataList[indexPath.row].retweetedBy.userID
                PushToProfile(userId!)
            } else if isQuotedUser {
                let userId = dataList[indexPath.row].tweetQuotedStatus.user.userId
                PushToProfile(userId!)
            } else {
                let userId = dataList[indexPath.row].user.userId
                PushToProfile(userId!)
            }
        }
    }
    
    func didImageTapped(for cell: PostWithImageAndQuoteCollectionViewCell, _ index: Int) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        if let dataList = dataList {
            let media = dataList[indexPath.row].media
            PushToImageDetailView(media ?? [""] , index)
        }
    }
    
    //MARK:-PostWithImageAndQuotedImage Actions
    func didUserProfileTapped(for cell: PostWithImageAndQuotedImageCollectionViewCell, _ isQuotedUser: Bool , _ isRetweetedUser:Bool) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        if let dataList = dataList {
            if isRetweetedUser {
                let userId = dataList[indexPath.row].retweetedBy.userID
                PushToProfile(userId!)
            } else if isQuotedUser {
                let userId = dataList[indexPath.row].tweetQuotedStatus.user.userId
                PushToProfile(userId!)
            } else {
                let userId = dataList[indexPath.row].user.userId
                PushToProfile(userId!)
            }
        }
    }
    
    func didImageTapped(for cell: PostWithImageAndQuotedImageCollectionViewCell, _ index: Int, isPostImage: Bool, isQuoteImage: Bool) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        if let dataList = dataList {
            if isPostImage {
                let media = dataList[indexPath.row].media
                PushToImageDetailView(media ?? [""] , index)
            } else if isQuoteImage {
                let media = dataList[indexPath.row].tweetQuotedStatus.media
                PushToImageDetailView(media ?? [""] , index)
            }
        }
    }
    
}
