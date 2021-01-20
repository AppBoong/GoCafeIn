//
//  UserProfileViewController.swift
//  GoCafeIn
//
//  Created by RedMac on 2020/12/16.
//  Copyright © 2020 AppBoong. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController {

    @IBOutlet var userProfileCollectionView: UICollectionView!
    var userInform = [userInfo()]
    var userPost : [userPostModel] = []
    var userUid : String?
    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
    override func viewWillAppear(_ animated: Bool) {
        self.userProfileCollectionView.reloadData()
        let loading = NVActivityIndicatorView(frame: CGRect(x: self.view.center.x - 25  , y: self.view.center.y - 30 , width: 60 , height: 60), type: .pacman, color: .systemYellow, padding: .pi)
        DispatchQueue.main.async {
            self.view.addSubview(loading)
            self.getUserInfo()
            self.getUserpost(loadingView: loading)
            
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            self.userProfileCollectionView.reloadData()
            loading.stopAnimating()
        }
       
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.userInform[0].profileImage = ""
        self.userInform[0].username = ""
        self.userInform[0].likeCount = 0
        self.userInform[0].postCount = 0
        self.userInform[0].followerCount = 0
        self.userInform[0].followingCount = 0
        userPost.removeAll()
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        
        
    }
    @objc func back() {
        
        dismiss(animated: true, completion: nil)
     
        }
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "back", style: .plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem?.tintColor = .brown
        userProfileCollectionView.delegate = self
        userProfileCollectionView.dataSource = self
        userProfileCollectionView.register(UserProfileCollectionViewCell.self, forCellWithReuseIdentifier: UserProfileCollectionViewCell.identifier)
        rightItem(text : "User")
    }
    func getUserInfo() {
        
        DatabaseManager.shared.getMyInfo(uid: userUid!) { (profilePic,username,likeCount,postCount,follower,following) in
            self.userInform[0].profileImage = profilePic
            self.userInform[0].username = username
            self.userInform[0].likeCount = likeCount
            self.userInform[0].postCount = postCount
            self.userInform[0].followerCount = follower
            self.userInform[0].followingCount = following
            
        }
        
    }
    func getUserpost(loadingView : NVActivityIndicatorView? = nil) {
        loadingView?.startAnimating()
        
        let postUrl = "https://gocafein-c430b.firebaseio.com/users/\(userUid!)/userPosts.json"
        DatabaseManager.shared.getPosts(url: postUrl, method: .get) { json in
            let arr = json.map {$0.1}.sorted { $0["postedDate"] > $1["postedDate"] }
            self.userPost.removeAll()
            for posts in arr {
                let post = userPostModel()
                post.postImage = posts["photo"].stringValue
                post.caption = posts["caption"].stringValue
                post.username = posts["author"]["username"].stringValue
                post.profileImage = posts["author"]["profilePic"].stringValue
                post.uid = posts["author"]["uid"].stringValue
                post.postid = posts["postid"].stringValue
                post.cafename = posts["cafename"].stringValue
                post.menu = posts["menu"].stringValue
                post.type = posts["type"].stringValue
                post.adress = posts["adress"].stringValue
                post.area = posts["area"].stringValue
                post.city = posts["city"].stringValue
                post.long = posts["long"].doubleValue
                post.lat = posts["lat"].doubleValue
                post.rate = posts["rate"].doubleValue
                post.date = posts["postedDate"].stringValue
                post.liked = posts["likedUser"][self.userUid!].boolValue
                let like = posts["likedUser"].dictionaryValue
                let likeTrue = like.map {$0.value.boolValue}
                let countLike = likeTrue.filter {$0 == true}.count
                post.likeCount = countLike
            self.userPost.append(post)
            
            }
            
        }
    }


}
extension UserProfileViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userPost.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let layout = userProfileCollectionView.collectionViewLayout  as! UICollectionViewFlowLayout
        layout.minimumLineSpacing = 0.6
        layout.minimumInteritemSpacing = 0.3
     
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .overFullScreen
        let row = userPost[indexPath.row]
        vc.gcity = row.city
        vc.garea = row.area
        vc.lat = row.lat
        vc.long = row.long
        vc.adress = row.adress
        vc.username = row.username
        vc.cafename = row.cafename
        vc.caption = row.caption
        vc.profileImage = row.profileImage
        vc.postImage = row.postImage
        vc.menu = row.menu
        vc.date = row.date
        vc.rate = row.rate
        vc.type = row.type
        vc.postid = row.postid
        vc.postuid = row.uid
        vc.liked = row.liked
        vc.likeCount = row.likeCount
        present(nav, animated: true, completion: nil)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidthSize = (view.bounds.width / 3) - 0.6
        let collectionViewHeightSize = (view.bounds.width / 3) - 0.4

        return CGSize(width: collectionViewWidthSize , height: collectionViewHeightSize )
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserProfileCollectionViewCell.identifier, for: indexPath) as? UserProfileCollectionViewCell else {
            fatalError()
        }
        let row = userPost[indexPath.row]
        if row.postImage == nil {
            cell.imageData()
            cell.configure(with: UIImage(named: ""))
        }
        else {
            cell.imageData()
            let url = URL(string: "\(row.postImage!)")
            cell.setImage(with : url!)
        }
        return cell
    }
    @objc func followButtonClick(sender : UIButton) {
        let uid = Auth.auth().currentUser?.uid
        DatabaseManager.shared.followCheck(uid: uid!, postUid: userUid!) { (snap) in
            if snap.contains(self.userUid!) == true{
                
                DatabaseManager.shared.unfollowing(postUid: self.userUid!, uid: uid!) {
                self.buttonImage(button: sender, text: "팔로우", image: UIImage(systemName: "person.badge.plus")!)
                    self.userInform[0].followerCount! -= 1
                    self.userProfileCollectionView.reloadData()
                }
            }else {
                
                DatabaseManager.shared.getMyName(uid: uid!, postUid: self.userUid!) { (pic, name) in
                    DatabaseManager.shared.follower(postUid: self.userUid!, uid: uid!, mypic: pic, myName: name)
                } followInfo: { (pic, name) in
                    DatabaseManager.shared.following(postUid: self.userUid!, uid: uid!, followPic: pic, followName: name){
                        self.buttonImage(button: sender, text: "팔로우 취소", image: UIImage(systemName: "person.badge.plus.fill")!)
                        self.userInform[0].followerCount! += 1
                        self.userProfileCollectionView.reloadData()
                    }
                }
            }
        }
    }
    @objc func followingButton() {
        let fvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FollowViewController") as! FollowViewController
        fvc.follow = "no"
        DatabaseManager.shared.getFollowInfo(uid: userUid!, follow: "following") { (id, pic, name) in
            for i in id {
                DatabaseManager.shared.getUsername(uid: i) { (name, pic) in
                    fvc.followUid.append(i)
                    fvc.followUsername.append(name)
                    fvc.followProfilePic.append(pic)
                }
            }
            let nav = UINavigationController(rootViewController: fvc)
            nav.modalPresentationStyle = .overFullScreen
            
            self.present(nav, animated: true, completion: nil)
        }
    }

    @objc func followerButton() {
        let fvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FollowViewController") as! FollowViewController
        fvc.follow = "no"
        DatabaseManager.shared.getFollowInfo(uid: userUid!, follow: "follower") { (id, pic, name) in
            for i in id {
                DatabaseManager.shared.getUsername(uid: i) { (name, pic) in
                    fvc.followUid.append(i)
                    fvc.followUsername.append(name)
                    fvc.followProfilePic.append(pic)
                }
            }
            let nav = UINavigationController(rootViewController: fvc)
            nav.modalPresentationStyle = .overFullScreen
            
            self.present(nav, animated: true, completion: nil)
        }
    }
    @objc func blockButton() {
        let uid = Auth.auth().currentUser?.uid
        showAction(title: "", message: "불건전한 유저", first: "차단하기", second: "신고하기") {
            DatabaseManager.shared.userBlock(uid: uid!, userUid: self.userUid!)
            self.dismiss(animated: true, completion: nil)
        } secondAction: {
            DatabaseManager.shared.userReport(uid: uid!, userUid: self.userUid!)
            self.showToast(title: "유저를 신고하였습니다.", position: .center)
        }

    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "UserProfileCollectionReusableView", for: indexPath) as! UserProfileCollectionReusableView
        let myUid = Auth.auth().currentUser?.uid
        if myUid! == userUid! {
            headerView.followButton.isHidden = true
            headerView.blockButton.isHidden = true
        }else {
            DatabaseManager.shared.followCheck(uid: myUid!, postUid: userUid!) { (snap) in
                if snap.contains(self.userUid!) == true{
                    self.buttonImage(button: headerView.followButton, text: "팔로우 취소", image: UIImage(systemName: "person.badge.plus.fill")!)
                }else {
                    self.buttonImage(button: headerView.followButton, text: "팔로우", image: UIImage(systemName: "person.badge.plus")!)
                }
            }
        }
        headerView.followButton.addTarget(self, action: #selector(followButtonClick(sender:)), for: .touchUpInside)
        headerView.goFollowingButton.addTarget(self, action: #selector(followingButton), for: .touchUpInside)
        headerView.goFollowerButton.addTarget(self, action: #selector(followerButton), for: .touchUpInside)
        headerView.blockButton.addTarget(self, action: #selector(blockButton), for: .touchUpInside)
        headerView.userProfileImage.layer.cornerRadius = headerView.userProfileImage.frame.size.width / 2
        headerView.userProfileImage.contentMode = .scaleToFill
        headerView.userProfileImage.layer.borderColor = UIColor.clear.cgColor
        headerView.userProfileImage.clipsToBounds = true
        if userInform[0].profileImage == nil {
        headerView.userProfileImage.image = UIImage(systemName: "person.circle.fill")
                
        }else if userInform[0].profileImage == ""{
            headerView.userProfileImage.image = UIImage(systemName: "person.circle.fill")
        }
        else {
        let url = URL(string: userInform[0].profileImage!)
        headerView.userProfileImage.kf.setImage(with: url)
        }
        headerView.userLikeCountLabel.text = "\(userInform[0].likeCount ?? 0)"
        headerView.userReviewCountLabel.text = "\(userInform[0].postCount ?? 0)"
        headerView.usernameLabel.text = userInform[0].username ?? ""
        headerView.followerCountLabel.text = "\(userInform[0].followerCount ?? 0)"
        headerView.followingCountLabel.text = "\(userInform[0].followingCount ?? 0)"
        return headerView
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: userProfileCollectionView.bounds.width, height: 180)
    }
}
