//
//  LocationViewController.swift
//  GoCafeIn
//
//  Created by RedMac on 2020/09/10.
//  Copyright © 2020 AppBoong. All rights reserved.
//
import UIKit
protocol SearchDelegate {
    func refresh(path : Int, count : Int, like : Bool)
    func remove(path : Int)
}
class LocationViewController: UIViewController,UISearchBarDelegate,SearchDelegate {
    var randomPost : [locationPostModel] = []
 
    @IBOutlet var searchCollectionView: UICollectionView!
    @IBOutlet var postSearchBar: UISearchBar!
    var page  = 1
    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
    func refresh(path : Int, count : Int, like : Bool) {
        
        randomPost[path].liked = like
        randomPost[path].likeCount = count
        searchCollectionView.reloadItems(at: [IndexPath(item: path, section: 0)])
    }
    func remove(path : Int) {
        randomPost.remove(at: path)
        searchCollectionView.deleteItems(at: [IndexPath(item: path, section: 0)])
    }
    override func viewWillAppear(_ animated: Bool) {
   
        self.searchCollectionView.reloadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let loading = NVActivityIndicatorView(frame: CGRect(x: self.view.center.x - 25  , y: self.view.center.y - 30 , width: 60 , height: 60), type: .pacman, color: .systemYellow, padding: .pi)
        DispatchQueue.main.async {
            self.view.addSubview(loading)
            self.getRandomPost(loadingView : loading) {
                
            }
        }
        rightItem(text : "Searching")
        searchCollectionView.collectionViewLayout = LocationViewController.createLayout()
        searchCollectionView.register(SearchCollectionViewCell.self, forCellWithReuseIdentifier: SearchCollectionViewCell.identifier)
        searchCollectionView.delegate = self
        searchCollectionView.dataSource = self
        postSearchBar.delegate = self
        searchCollectionView.prefetchDataSource = self
        refreshControl()
    }
    func refreshControl() {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(updateUI(refresh:)), for: .valueChanged)
        refresh.attributedTitle = NSAttributedString(string: "새로고침")
        searchCollectionView.refreshControl = refresh
    }
    @objc func updateUI(refresh : UIRefreshControl) {
        refresh.endRefreshing()
        let loading = NVActivityIndicatorView(frame: CGRect(x: self.view.center.x - 25  , y: self.view.center.y - 30 , width: 60 , height: 60), type: .pacman, color: .systemYellow, padding: .pi)
        self.view.addSubview(loading)
        self.getRandomPost(loadingView: loading) {
            
        }
        
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let uid = Auth.auth().currentUser?.uid
        if postSearchBar.text?.isEmpty == true {
            showToast(title: "검색어를 입력해 주세요", position: .center)
        }else if postSearchBar.text == "서울시"{
            DatabaseManager.shared.searching(search: "서울특별시") { (area) in
                if area != [""]{
                    DispatchQueue.main.async {
                        self.randomPost.removeAll()
                        for i in area {
                            DatabaseManager.shared.getLikedPost(uid: uid!, postID: i) { postuid,profileImage,username,postImage,cafename,caption,menu,type,adress,area,city,date,postid,long,lat,rate,liked,likeCount in
                                let postList = locationPostModel()
                                DatabaseManager.shared.getBlocked(uid: uid!) { (userUid, postId) in
                                    
                                    if userUid.contains(postuid) == true || postId.contains(postid) == true{
                                        
                                    }else {
                                        postList.postImage = postImage
                                        postList.caption = caption
                                        postList.uid = postuid
                                        DatabaseManager.shared.getUserInfo(uid: postuid) { (username, profilePic) in
                                              postList.username = username
                                              postList.profileImage = profilePic
                                        }
                                        postList.postid = postid
                                        postList.cafename = cafename
                                        postList.menu = menu
                                        postList.type = type
                                        postList.adress = adress
                                        postList.area = area
                                        postList.city = city
                                        postList.long = long
                                        postList.lat = lat
                                        postList.rate = rate
                                        postList.date = date
                                        postList.liked = liked
                                        postList.likeCount = likeCount
                                        self.randomPost.append(postList)
                                    }
                                }
                            }
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.searchCollectionView.reloadData()
                    }
                }else {
                    self.randomPost.removeAll()
                    self.searchCollectionView.reloadData()
                }
            } cityValue: { (city) in
            } cafeValue: { (cafe) in
            } usernameValue : { (name) in
                
            }
        }else {
            DatabaseManager.shared.searching(search: postSearchBar.text!) { (area) in
                if area != [""]{
                    
                    DispatchQueue.main.async {
                        self.randomPost.removeAll()
                        for i in area {
                            DatabaseManager.shared.getLikedPost(uid: uid!, postID: i) { postuid,profileImage,username,postImage,cafename,caption,menu,type,adress,area,city,date,postid,long,lat,rate,liked,likeCount in
                                let postList = locationPostModel()
                                DatabaseManager.shared.getBlocked(uid: uid!) { (userUid, postId) in
                                    if userUid.contains(postuid) == true || postId.contains(postid) == true{
                                    }else {
                                        postList.postImage = postImage
                                        postList.caption = caption
                                        postList.uid = postuid
                                        DatabaseManager.shared.getUserInfo(uid: postuid) { (username, profilePic) in
                                              postList.username = username
                                              postList.profileImage = profilePic
                                        }
                                        postList.postid = postid
                                        postList.cafename = cafename
                                        postList.menu = menu
                                        postList.type = type
                                        postList.adress = adress
                                        postList.area = area
                                        postList.city = city
                                        postList.long = long
                                        postList.lat = lat
                                        postList.rate = rate
                                        postList.date = date
                                        postList.liked = liked
                                        postList.likeCount = likeCount

                                        self.randomPost.append(postList)
                                    }
                                }
                            }
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.searchCollectionView.reloadData()
                    }
                }else {
                    self.randomPost.removeAll()
                    self.searchCollectionView.reloadData()
                }
            } cityValue: { (city) in
                if city != [""]{
                    DispatchQueue.main.async {
                        self.randomPost.removeAll()
                        for i in city {
                            DatabaseManager.shared.getLikedPost(uid: uid!, postID: i) { postuid,profileImage,username,postImage,cafename,caption,menu,type,adress,area,city,date,postid,long,lat,rate,liked,likeCount in
                                let postList = locationPostModel()
                                DatabaseManager.shared.getBlocked(uid: uid!) { (userUid, postId) in
                                    
                                    if userUid.contains(postuid) == true || postId.contains(postid) == true{

                                    }else {
                                        postList.postImage = postImage
                                        postList.caption = caption
                                        postList.uid = postuid
                                        DatabaseManager.shared.getUserInfo(uid: postuid) { (username, profilePic) in
                                              postList.username = username
                                              postList.profileImage = profilePic
                                        }
                                        postList.postid = postid
                                        postList.cafename = cafename
                                        postList.menu = menu
                                        postList.type = type
                                        postList.adress = adress
                                        postList.area = area
                                        postList.city = city
                                        postList.long = long
                                        postList.lat = lat
                                        postList.rate = rate
                                        postList.date = date
                                        postList.liked = liked
                                        postList.likeCount = likeCount

                                        self.randomPost.append(postList)
                                    }
                                }
                            }
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.searchCollectionView.reloadData()
                    }
                }else {
                    self.randomPost.removeAll()
                    self.searchCollectionView.reloadData()
                }
            } cafeValue: { (cafe) in
                if cafe != [""]{
                    
                    DispatchQueue.main.async {
                        self.randomPost.removeAll()
                        for i in cafe {
                            DatabaseManager.shared.getLikedPost(uid: uid!, postID: i) { postuid,profileImage,username,postImage,cafename,caption,menu,type,adress,area,city,date,postid,long,lat,rate,liked,likeCount in
                                let postList = locationPostModel()
                                DatabaseManager.shared.getBlocked(uid: uid!) { (userUid, postId) in
                                    
                                    if userUid.contains(postuid) == true || postId.contains(postid) == true{
                                        
                                    }else {
                                        postList.postImage = postImage
                                        postList.caption = caption
                                        postList.uid = postuid
                                        DatabaseManager.shared.getUserInfo(uid: postuid) { (username, profilePic) in
                                              postList.username = username
                                              postList.profileImage = profilePic
                                        }
                                        postList.postid = postid
                                        postList.cafename = cafename
                                        postList.menu = menu
                                        postList.type = type
                                        postList.adress = adress
                                        postList.area = area
                                        postList.city = city
                                        postList.long = long
                                        postList.lat = lat
                                        postList.rate = rate
                                        postList.date = date
                                        postList.liked = liked
                                        postList.likeCount = likeCount

                                        self.randomPost.append(postList)
                                    }
                                }
                            }
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.searchCollectionView.reloadData()
                    }
                }else {
                    self.randomPost.removeAll()
                    self.searchCollectionView.reloadData()
                }
            } usernameValue: { (name) in
                if name != ""{
                    print(name)
                    DispatchQueue.main.async {
                        self.randomPost.removeAll()
                        let postUrl = "https://gocafein-c430b.firebaseio.com/users/\(name)/userPosts.json"
                        DatabaseManager.shared.getPosts(url: postUrl, method: .get) { json in
                            let arr = json.map {$0.1}.sorted { $0["postedDate"] > $1["postedDate"] }
                            for posts in arr {
                                let postList = locationPostModel()
                                postList.postImage = posts["photo"].stringValue
                                postList.caption = posts["caption"].stringValue
                                postList.uid = posts["author"]["uid"].stringValue
                                DatabaseManager.shared.getUserInfo(uid: uid!) { (username, profilePic) in
                                    postList.username = username
                                    postList.profileImage = profilePic
                                  }
                                postList.postid = posts["postid"].stringValue
                                postList.cafename = posts["cafename"].stringValue
                                postList.menu = posts["menu"].stringValue
                                postList.type = posts["type"].stringValue
                                postList.adress = posts["adress"].stringValue
                                postList.area = posts["area"].stringValue
                                postList.city = posts["city"].stringValue
                                postList.long = posts["long"].doubleValue
                                postList.lat = posts["lat"].doubleValue
                                postList.rate = posts["rate"].doubleValue
                                postList.date = posts["postedDate"].stringValue
                                postList.liked = posts["likedUser"][uid!].boolValue
                                let like = posts["likedUser"].dictionaryValue
                                let likeTrue = like.map {$0.value.boolValue}
                                let countLike = likeTrue.filter {$0 == true}.count
                                postList.likeCount = countLike
                            self.randomPost.append(postList)
                            
                            }
                            
                        }
                        
                        
                        
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        self.searchCollectionView.reloadData()
                    }
                }else {
                    self.randomPost.removeAll()
                    self.searchCollectionView.reloadData()
                }
            }
        }
    }
    func getRandomPost(loadingView : NVActivityIndicatorView? = nil, success : @escaping() -> ()) {
        let postUrl = "https://gocafein-c430b.firebaseio.com/allPosts.json"
        let uid = Auth.auth().currentUser?.uid
        loadingView?.startAnimating()
        DispatchQueue.main.async {
            DatabaseManager.shared.getPosts(url: postUrl, method: .get) { json in
                DatabaseManager.shared.getBlocked(uid: uid!) { (userUid, postId) in
                self.randomPost.removeAll()
                let arr = json.map {$0.1}
                for posts in arr  {
                        let post = locationPostModel()
                        
                                if userUid.contains(posts["author"]["uid"].stringValue) == true || postId.contains(posts["postid"].stringValue) == true{
                                    
                                }else {
                                    post.postImage = posts["photo"].stringValue
                                    post.caption = posts["caption"].stringValue
                                    post.uid = posts["author"]["uid"].stringValue
                                    DatabaseManager.shared.getUserInfo(uid: posts["author"]["uid"].stringValue) { (username, profilePic) in
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
                                    self.randomPost.append(post)
                                }
                            }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    success()
                    loadingView?.stopAnimating()
                    self.searchCollectionView.reloadData()
                }
            }
        }
    }
}

extension LocationViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDataSourcePrefetching{
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return randomPost.count
    }
    static func createLayout() -> UICollectionViewCompositionalLayout {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(2/3), heightDimension: .fractionalHeight(1)))
        item.contentInsets = NSDirectionalEdgeInsets(top: 0.5, leading: 0.5, bottom: 0.5, trailing: 0.5)
        let verticalStackItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.5)))
        verticalStackItem.contentInsets = NSDirectionalEdgeInsets(top: 0.5, leading: 0.5, bottom: 0.5, trailing: 0.5)
        let verticalStackGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalHeight(1)), subitem: verticalStackItem, count: 2)
        let tripleItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
        tripleItem.contentInsets = NSDirectionalEdgeInsets(top: 0.5, leading: 0.5, bottom: 0.5, trailing: 0.5)
        let tripleHorizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1/3)), subitem: tripleItem, count: 3)
        let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(2/3)), subitems: [item , verticalStackGroup])
        let horizontalGroup2 = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(2/3)), subitems: [verticalStackGroup, item])
        let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1)), subitems: [horizontalGroup, tripleHorizontalGroup])
        let verticalGroup2 = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1)), subitems: [horizontalGroup2 , tripleHorizontalGroup])
        let tripleHorizontalGroup2 = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1/3)), subitem: tripleItem, count: 3)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(8/3)), subitems: [verticalGroup, tripleHorizontalGroup2 , verticalGroup2, tripleHorizontalGroup2])
        let section = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .overFullScreen
        let row = randomPost[indexPath.row]
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
        vc.path = indexPath.row
        vc.searchDelegate = self
        present(nav, animated: true, completion: nil)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchCollectionViewCell.identifier, for: indexPath) as? SearchCollectionViewCell else {
                fatalError()
            }
            let row = randomPost[indexPath.row]
            cell.labelImage( text : "\(row.rate!)")
            if row.postImage == nil {
                cell.configure(with: UIImage(named: "")!)
            }
            else {
                cell.imageData()
                let url = URL(string: "\(row.postImage!)")
                cell.setImage(with : url!)
            }
        cell.city(city: "\(row.city!)")
        return cell
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}
