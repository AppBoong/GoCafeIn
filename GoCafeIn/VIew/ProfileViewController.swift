//
//  ProfileViewController.swift
//  GoCafeIn
//
//  Created by RedMac on 2020/09/10.
//  Copyright © 2020 AppBoong. All rights reserved.
//
import UIKit

protocol ProfileChangeDelegate {
    func change (success : @escaping () -> ())
    func refresh(path : Int, count : Int, like : Bool, likeCount : Int)
    func remove(path : Int)
    func likePlus()
    func likeMinus()
    func reload()
}
protocol FollowDelegate {
    func unFollow()
}
class ProfileViewController: UIViewController,ProfileChangeDelegate,FollowDelegate {
    @IBOutlet var profileCollectionView: UICollectionView!
    @IBOutlet var logOutButton: UIBarButtonItem!
    var myPost : [myPostModel] = []
    var myInform  =  [myInfo()]
    var interstitial: GADInterstitial!
    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
    func change(success : @escaping () -> ()) {
        self.getMyInfo()
        let loading = NVActivityIndicatorView(frame: CGRect(x: self.view.center.x - 25  , y: self.view.center.y - 30 , width: 60 , height: 60), type: .pacman, color: .systemYellow, padding: .pi)
        self.view.addSubview(loading)
       
        self.getMypost(loadingView: loading)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            
            self.profileCollectionView.reloadData()
            loading.stopAnimating()
            success()
            
        }
        
    }
    
    func refresh(path : Int, count : Int, like : Bool, likeCount : Int) {
        
        myPost[path].liked = like
        myPost[path].likeCount = count
        profileCollectionView.reloadItems(at: [IndexPath(item: path, section: 0)])
        

    }
    func remove(path : Int) {
        myPost.remove(at: path)
        profileCollectionView.deleteItems(at: [IndexPath(item: path, section: 0)])
    }
    func likePlus() {
        if myInform[0].likeCount == 0 {
            myInform[0].likeCount = 1
        }else {
            myInform[0].likeCount! += 1
        }
    }
    func likeMinus() {
        if myInform[0].likeCount == 0 {
            myInform[0].likeCount = 0
        }else {
            myInform[0].likeCount! -= 1
        }
    }
    func reload() {

        self.profileCollectionView.reloadData()
    }
    func unFollow() {
        if myInform[0].followingCount == 0 {
            myInform[0].followingCount = 0
        }else {
            myInform[0].followingCount! -= 1
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        self.profileCollectionView.reloadData()
        
    }
    func presentAD() {
        if interstitial.isReady {
            print("good")
            interstitial.present(fromRootViewController: self)
          }else {
            print("Ad wasn't ready")
          }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //ca-app-pub-2254515568525719~5829283273 - 앱id
        //"ca-app-pub-2254515568525719/7042099075" - 광고단위id
       
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-2254515568525719/7042099075")
        let request = GADRequest()
        interstitial.load(request)
        let loading = NVActivityIndicatorView(frame: CGRect(x: self.view.center.x - 25  , y: self.view.center.y - 30 , width: 60 , height: 60), type: .pacman, color: .systemYellow, padding: .pi)
 
        DispatchQueue.main.async {
            self.view.addSubview(loading)
            self.getMyInfo()
            self.getMypost(loadingView: loading)
            
            
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.presentAD()
            self.profileCollectionView.reloadData()
            loading.stopAnimating()
            
        }
        profileCollectionView.delegate = self
        profileCollectionView.dataSource = self
        profileCollectionView.register(ProfileCollectionViewCell.self, forCellWithReuseIdentifier: ProfileCollectionViewCell.identifier)

        rightItem(text : "Profile")
        refreshControl()
    }
    func refreshControl() {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(updateUI(refresh:)), for: .valueChanged)
        refresh.attributedTitle = NSAttributedString(string: "새로고침")
        profileCollectionView.refreshControl = refresh
    }
    @objc func updateUI(refresh : UIRefreshControl) {
        refresh.endRefreshing()
        let loading = NVActivityIndicatorView(frame: CGRect(x: self.view.center.x - 25  , y: self.view.center.y - 30 , width: 60 , height: 60), type: .pacman, color: .systemYellow, padding: .pi)
 
        DispatchQueue.main.async {
            self.view.addSubview(loading)
            self.getMyInfo()
            self.getMypost(loadingView: loading)
            
            
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.profileCollectionView.reloadData()
            loading.stopAnimating()
        }
        
    }
    func getMyInfo() {
        let uid = Auth.auth().currentUser?.uid
        DispatchQueue.main.async {
            DatabaseManager.shared.getMyInfo(uid: uid!) { (profilePic,username,likeCount,postCount,follower,following) in
                self.myInform[0].profileImage = profilePic
                self.myInform[0].username = username
                self.myInform[0].likeCount = likeCount
                self.myInform[0].postCount = postCount
                self.myInform[0].followerCount = follower
                self.myInform[0].followingCount = following

            }
           
        }
        print(self.myInform[0])
        
    }
    func getMypost(loadingView : NVActivityIndicatorView? = nil) {
        loadingView?.startAnimating()
        let uid = Auth.auth().currentUser?.uid
        let postUrl = "https://gocafein-c430b.firebaseio.com/users/\(uid!)/userPosts.json"
        DatabaseManager.shared.getPosts(url: postUrl, method: .get) { json in
            let arr = json.map {$0.1}.sorted { $0["postedDate"] > $1["postedDate"] }
            self.myPost.removeAll()
            for posts in arr {
                let post = myPostModel()
                post.postImage = posts["photo"].stringValue
                post.caption = posts["caption"].stringValue
                post.uid = posts["author"]["uid"].stringValue
                DatabaseManager.shared.getUserInfo(uid: uid!) { (username, profilePic) in
                      post.username = username
                      post.profileImage = profilePic
                  }
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
                post.liked = posts["likedUser"][uid!].boolValue
                let like = posts["likedUser"].dictionaryValue
                let likeTrue = like.map {$0.value.boolValue}
                let countLike = likeTrue.filter {$0 == true}.count
                post.likeCount = countLike
            self.myPost.append(post)
            
            }
            
        }
        
    }
    @IBAction func logoutButtonClicked(_ sender: Any) {
        
        showAlert(mainTitle: "로그아웃", mainMessage: "로그아웃 하시겠습니까?", oktitle:  "확인") {
                AuthManager.shared.logOut { success in
                    DispatchQueue.main.async {
                    if success == true {
                        Auth.auth().currentUser?.delete(completion: { (error) in
                            print(error)
                        })
                        self.myPost.removeAll()
                        self.profileCollectionView.reloadData()
                        UserDefaults.standard.removeObject(forKey: "username")
                        UserDefaults.standard.removeObject(forKey: "token")
                        UserDefaults.standard.removeObject(forKey: "photoURL")
                        UserDefaults.standard.removeObject(forKey: "uid")
                        let lvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        
                        
                        appDelegate.window?.rootViewController = lvc
                        self.view.window?.rootViewController = lvc
                    }
                    else {
                                     
                    }
                }
            }
        }
    }
}
extension ProfileViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myPost.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let layout = profileCollectionView.collectionViewLayout  as! UICollectionViewFlowLayout
        layout.minimumLineSpacing = 0.6
        layout.minimumInteritemSpacing = 0.3
     
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .overFullScreen
        let row = myPost[indexPath.row]
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
        vc.profileDelegate = self
        vc.path = indexPath.row
        present(nav, animated: true, completion: nil)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidthSize = (view.bounds.width / 3) - 0.6
        let collectionViewHeightSize = (view.bounds.width / 3) - 0.4

        return CGSize(width: collectionViewWidthSize , height: collectionViewHeightSize )
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileCollectionViewCell.identifier, for: indexPath) as? ProfileCollectionViewCell else {
            fatalError()
        }
        
        let row = myPost[indexPath.row]
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
    @objc func followingButton() {
        let fvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FollowViewController") as! FollowViewController
        fvc.follow = "following"
        let uid = Auth.auth().currentUser?.uid
        DatabaseManager.shared.getFollowInfo(uid: uid!, follow: "following") { (id, pic, name) in
            for i in id {
                
                DatabaseManager.shared.getUsername(uid: i) { (name, pic) in
                    fvc.followUid.append(i)
                    fvc.followUsername.append(name)
                    fvc.followProfilePic.append(pic)
                }
            }
            self.navigationController?.pushViewController(fvc, animated: true)
            fvc.delegate = self
        }

    }
    @objc func followerButton() {
        let fvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FollowViewController") as! FollowViewController
        fvc.follow = "follower"
        let uid = Auth.auth().currentUser?.uid
        DatabaseManager.shared.getFollowInfo(uid: uid!, follow: "follower") { (id, pic, name) in
            for i in id {
                
                DatabaseManager.shared.getUsername(uid: i) { (name, pic) in
                    fvc.followUid.append(i)
                    fvc.followUsername.append(name)
                    fvc.followProfilePic.append(pic)
                }
            }
            fvc.delegate = self
            self.navigationController?.pushViewController(fvc, animated: true)
        }
        
    }
    @objc func profileEdit() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "ProfileSettingViewController") as! ProfileSettingViewController
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ProfileCollectionReusableView", for: indexPath) as! ProfileCollectionReusableView
        headerView.profileChangeButton.addTarget(self, action: #selector(profileEdit), for: .touchUpInside)
        headerView.goFollowingButton.addTarget(self, action: #selector(followingButton), for: .touchUpInside)
        headerView.goFollowerButton.addTarget(self, action: #selector(followerButton), for: .touchUpInside)
        
        headerView.profileImage.layer.cornerRadius = headerView.profileImage.frame.size.width / 2
        headerView.profileImage.contentMode = .scaleToFill
        headerView.profileImage.layer.borderColor = UIColor.clear.cgColor
        headerView.profileImage.clipsToBounds = true
        let uid = Auth.auth().currentUser?.uid
        if uid == nil {
            
        }else {
        if myInform[0].profileImage == nil {
            headerView.profileImage.image = UIImage(systemName: "person.circle.fill")

        }else if myInform[0].profileImage == "" {
            headerView.profileImage.image = UIImage(systemName: "person.circle.fill")
        }
        else {
            let url = URL(string: myInform[0].profileImage!)
            headerView.profileImage.kf.setImage(with: url)
        }
            headerView.likeCountLabel.text = "\(myInform[0].likeCount ?? 0)"
            headerView.reviewCountLabel.text = "\(myInform[0].postCount ?? 0)"
            headerView.usernameLabel.text = myInform[0].username ?? ""
            headerView.followerCountLabel.text = "\(myInform[0].followerCount ?? 0)"
            headerView.followingCountLabel.text = "\(myInform[0].followingCount ?? 0)"
        }
        return headerView
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: profileCollectionView.bounds.width, height: 180)
    }
}
